[CmdletBinding()]
param(
    [ValidateSet('run', 'editor', 'import', 'test', 'preview', 'network', 'test-network', 'preview-network', 'board', 'preview-board', 'test-catalog', 'test-state', 'test-engine', 'test-setup', 'test-cycle')]
    [string]$Action = 'run',
    [string]$GodotPath = $env:GODOT_BIN
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$expectedVersion = (Get-Content -Raw -LiteralPath (Join-Path $projectRoot '.godot-version')).Trim()

if ([string]::IsNullOrWhiteSpace($GodotPath)) {
    $portableEngine = Join-Path $projectRoot ".tools/godot/Godot_v$expectedVersion-stable_win64_console.exe"
    if (Test-Path -LiteralPath $portableEngine) {
        $GodotPath = $portableEngine
    } else {
        foreach ($engineName in @('godot', 'godot4')) {
            $engineCommand = Get-Command $engineName -CommandType Application -ErrorAction SilentlyContinue
            if ($null -ne $engineCommand) {
                $GodotPath = $engineCommand.Source
                break
            }
        }
    }
}
if ([string]::IsNullOrWhiteSpace($GodotPath) -or -not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw "No se encuentra Godot $expectedVersion. Usa -GodotPath o GODOT_BIN. Consulta docs/desarrollo-local.md."
}
$GodotPath = (Resolve-Path -LiteralPath $GodotPath).Path
$engineVersion = (& $GodotPath --version | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or -not $engineVersion.StartsWith("$expectedVersion.stable.")) {
    throw "Version de Godot incompatible: '$engineVersion'. Se requiere $expectedVersion estable."
}
$logRoot = Join-Path $projectRoot 'tmp/godot'
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
$temporaryIgnore = Join-Path $projectRoot 'tmp/.gdignore'
if (-not (Test-Path -LiteralPath $temporaryIgnore)) {
    [System.IO.File]::WriteAllText($temporaryIgnore, '')
}

function Invoke-ProjectGodot {
    param([string[]]$EngineArguments, [string]$LogName)
    # Windows PowerShell convierte stderr nativo en ErrorRecord incluso en casos
    # negativos esperados. El fallo real se decide por código y marcas de prueba.
    $previousErrorPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $engineOutput = & $GodotPath --path $projectRoot --log-file (Join-Path $logRoot "$LogName.log") @EngineArguments 2>&1
        $engineCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorPreference
    }
    $engineOutput | ForEach-Object { Write-Host $_ }
    if ($engineCode -ne 0) {
        throw "Godot fallo en '$LogName' con codigo $engineCode."
    }
    if (($engineOutput | Out-String) -match '(?m)^SCRIPT ERROR:') {
        throw "Godot contiene errores de script en '$LogName', aunque su proceso haya devuelto codigo 0."
    }
    if ($LogName -in @('import', 'test-state', 'test-engine', 'test-setup', 'test-cycle') -and (($engineOutput | Out-String) -match '(?m)^(SCRIPT ERROR|ERROR):')) {
        throw "La accion $LogName contiene errores. Revisa tmp/godot/$LogName.log."
    }
    if ($LogName -eq 'test' -and ($engineOutput | Out-String) -notmatch 'P03_STARTUP_OK') {
        throw 'Las pruebas no alcanzaron su marca de finalizacion.'
    }
    if ($LogName -eq 'preview' -and ($engineOutput | Out-String) -notmatch 'P03_PREVIEW_OK') {
        throw 'No se genero la previsualizacion.'
    }
    if ($LogName -eq 'test-network' -and ($engineOutput | Out-String) -notmatch 'P04_NETWORK_OK') {
        throw 'La prueba de red no alcanzo su marca de finalizacion.'
    }
    if ($LogName -eq 'preview-network' -and ($engineOutput | Out-String) -notmatch 'P04_PREVIEW_OK') {
        throw 'No se completo la captura de conexion.'
    }
    if ($LogName -eq 'preview-board' -and ($engineOutput | Out-String) -notmatch 'P05_BOARD_OK') {
        throw 'No se completo la verificacion y captura del tablero.'
    }
    if ($LogName -eq 'test-catalog' -and ($engineOutput | Out-String) -notmatch 'P06_CATALOG_OK') {
        throw 'No se completo la verificacion del contrato de catalogo.'
    }
    if ($LogName -eq 'test-engine' -and ($engineOutput | Out-String) -notmatch 'P07_ENGINE_OK') {
        throw 'No se completo la verificacion de acciones y privacidad.'
    }
    if ($LogName -eq 'test-state' -and ($engineOutput | Out-String) -notmatch 'P07_STATE_OK') {
        throw 'No se completo la verificacion del estado de partida.'
    }
    if ($LogName -eq 'test-setup' -and ($engineOutput | Out-String) -notmatch 'P08_SETUP_OK') {
        throw 'No se completo la verificacion de preparacion.'
    }
    if ($LogName -eq 'test-cycle' -and ($engineOutput | Out-String) -notmatch 'P08_CYCLE_OK') {
        throw 'No se completo la verificacion del ciclo personal de cartas.'
    }
}

if ($Action -in @('run', 'import', 'test', 'preview', 'network', 'test-network', 'preview-network', 'board', 'preview-board', 'test-catalog', 'test-state', 'test-engine', 'test-setup', 'test-cycle')) {
    Invoke-ProjectGodot -EngineArguments @('--headless', '--editor', '--import') -LogName 'import'
}
switch ($Action) {
    'run' { Invoke-ProjectGodot -EngineArguments @() -LogName 'run' }
    'editor' { Invoke-ProjectGodot -EngineArguments @('--editor') -LogName 'editor' }
    'test' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/startup_test.gd') -LogName 'test' }
    'preview' { Invoke-ProjectGodot -EngineArguments @('--audio-driver', 'Dummy', '--script', 'res://tests/capture_startup.gd') -LogName 'preview' }
    'network' { Invoke-ProjectGodot -EngineArguments @('res://scenes/ConnectionScreen.tscn') -LogName 'network' }
    'test-network' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/network_test.gd') -LogName 'test-network' }
    'preview-network' { Invoke-ProjectGodot -EngineArguments @('--audio-driver', 'Dummy', '--script', 'res://tests/capture_connection.gd') -LogName 'preview-network' }
    'board' { Invoke-ProjectGodot -EngineArguments @('res://scenes/BoardPreview.tscn') -LogName 'board' }
    'preview-board' { Invoke-ProjectGodot -EngineArguments @('--audio-driver', 'Dummy', '--script', 'res://tests/board_preview_test.gd') -LogName 'preview-board' }
    'test-engine' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/game_engine_test.gd') -LogName 'test-engine' }
    'test-state' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/game_state_test.gd') -LogName 'test-state' }
    'test-setup' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/game_setup_test.gd') -LogName 'test-setup' }
    'test-cycle' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/card_cycle_test.gd') -LogName 'test-cycle' }
    'test-catalog' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/catalog_test.gd') -LogName 'test-catalog' }
}
