[CmdletBinding()]
param(
    [ValidateSet('run', 'editor', 'import', 'test', 'preview', 'network', 'test-network', 'preview-network', 'board', 'preview-board', 'test-catalog', 'test-missions', 'test-state', 'test-engine', 'test-setup', 'test-cycle', 'test-cleanup', 'test-sequence', 'test-funding', 'test-training', 'test-start', 'test-mission-advance', 'test-permanents', 'test-m8', 'test-m1')]
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
    $engineText = ($engineOutput | ForEach-Object { [string]$_ }) -join "`n"
    if ($engineCode -ne 0) {
        throw "Godot fallo en '$LogName' con codigo $engineCode."
    }
    if ($engineText -match '(?m)^SCRIPT ERROR:') {
        throw "Godot contiene errores de script en '$LogName', aunque su proceso haya devuelto codigo 0."
    }
    if ($LogName -in @('import', 'test-state', 'test-engine', 'test-setup', 'test-cycle', 'test-cleanup', 'test-sequence', 'test-funding', 'test-training', 'test-start', 'test-mission-advance', 'test-permanents', 'test-m8', 'test-m1') -and ($engineText -match '(?m)^(SCRIPT ERROR|ERROR):')) {
        throw "La accion $LogName contiene errores. Revisa tmp/godot/$LogName.log."
    }
    if ($LogName -eq 'test' -and $engineText -notmatch 'P03_STARTUP_OK') {
        throw 'Las pruebas no alcanzaron su marca de finalizacion.'
    }
    if ($LogName -eq 'preview' -and $engineText -notmatch 'P03_PREVIEW_OK') {
        throw 'No se genero la previsualizacion.'
    }
    if ($LogName -eq 'test-network' -and $engineText -notmatch 'P04_NETWORK_OK') {
        throw 'La prueba de red no alcanzo su marca de finalizacion.'
    }
    if ($LogName -eq 'preview-network' -and $engineText -notmatch 'P04_PREVIEW_OK') {
        throw 'No se completo la captura de conexion.'
    }
    if ($LogName -eq 'preview-board' -and $engineText -notmatch 'P05_BOARD_OK') {
        throw 'No se completo la verificacion y captura del tablero.'
    }
    if ($LogName -eq 'test-catalog' -and $engineText -notmatch 'P06_CATALOG_OK') {
        throw 'No se completo la verificacion del contrato de catalogo.'
    }
    if ($LogName -eq 'test-missions' -and $engineText -notmatch 'P08_MISSION_CATALOG_OK') {
        throw 'No se completo la verificacion del catalogo de misiones.'
    }
    if ($LogName -eq 'test-engine' -and $engineText -notmatch 'P07_ENGINE_OK') {
        throw 'No se completo la verificacion de acciones y privacidad.'
    }
    if ($LogName -eq 'test-state' -and $engineText -notmatch 'P07_STATE_OK') {
        throw 'No se completo la verificacion del estado de partida.'
    }
    if ($LogName -eq 'test-setup' -and $engineText -notmatch 'P08_SETUP_OK') {
        throw 'No se completo la verificacion de preparacion.'
    }
    if ($LogName -eq 'test-cycle' -and $engineText -notmatch 'P08_CYCLE_OK') {
        throw 'No se completo la verificacion del ciclo personal de cartas.'
    }
    if ($LogName -eq 'test-sequence' -and $engineText -notmatch 'P08_SEQUENCE_OK') {
        throw 'La prueba de secuencias no alcanzo su marca de finalizacion.'
    }
    if ($LogName -eq 'test-funding' -and $engineText -notmatch 'P08_FUNDING_OK') {
        throw 'La prueba de Funding no alcanzo su marca de finalizacion.'
    }
    if ($LogName -eq 'test-training' -and $engineText -notmatch 'P08_TRAINING_OK') {
        throw 'La prueba de entrenamiento no alcanzo su marca de finalizacion.'
    }
    if ($LogName -eq 'test-mission-advance' -and $engineText -notmatch 'P08_MISSION_ADVANCE_OK') {
        throw 'La prueba de avance de misiones no alcanzo su marca de finalizacion.'
    }
    if ($LogName -eq 'test-m1' -and $engineText -notmatch 'P08_M1_OK') {
        throw 'La suite M1 no confirmo P08_M1_OK.'
    }
    if ($LogName -eq 'test-m8' -and $engineText -notmatch 'P08_M8_OK') {
        throw 'No se completo la verificacion M8.'
    }
    if ($LogName -eq 'test-permanents' -and $engineText -notmatch 'P08_PERMANENTS_OK') {
        throw 'La prueba de permanentes no alcanzo su marca de finalizacion.'
    }
    if ($LogName -eq 'test-start' -and $engineText -notmatch 'P08_START_OK') {
        throw 'La prueba de inicio competitivo no alcanzo su marca de finalizacion.'
    }
    if ($LogName -eq 'test-cleanup' -and $engineText -notmatch 'P08_CLEANUP_OK') {
        throw 'No se completo la verificacion del cierre de limpieza.'
    }
}

if ($Action -in @('run', 'import', 'test', 'preview', 'network', 'test-network', 'preview-network', 'board', 'preview-board', 'test-catalog', 'test-missions', 'test-state', 'test-engine', 'test-setup', 'test-cycle', 'test-cleanup', 'test-sequence', 'test-funding', 'test-training', 'test-start', 'test-mission-advance', 'test-permanents', 'test-m8', 'test-m1')) {
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
    'test-sequence' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/sequence_test.gd') -LogName 'test-sequence' }
    'test-funding' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/funding_play_test.gd') -LogName 'test-funding' }
    'test-training' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/training_advance_test.gd') -LogName 'test-training' }
    'test-start' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/competitive_start_test.gd') -LogName 'test-start' }
    'test-cleanup' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/turn_cleanup_test.gd') -LogName 'test-cleanup' }
    'test-mission-advance' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/mission_advance_test.gd') -LogName 'test-mission-advance' }
    'test-m1' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/m1_test.gd') -LogName 'test-m1' }
    'test-m8' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/m8_test.gd') -LogName 'test-m8' }
    'test-permanents' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/permanents_test.gd') -LogName 'test-permanents' }
    'test-missions' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/mission_catalog_test.gd') -LogName 'test-missions' }
    'test-catalog' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/catalog_test.gd') -LogName 'test-catalog' }
}
