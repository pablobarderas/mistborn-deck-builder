[CmdletBinding()]
param(
    [ValidateSet('run', 'editor', 'import', 'test', 'preview')]
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
    if ($LogName -eq 'import' -and (($engineOutput | Out-String) -match '(?m)^(SCRIPT ERROR|ERROR):')) {
        throw 'La importacion contiene errores. Revisa tmp/godot/import.log.'
    }
    if ($LogName -eq 'test' -and ($engineOutput | Out-String) -notmatch 'P03_STARTUP_OK') {
        throw 'Las pruebas no alcanzaron su marca de finalizacion.'
    }
    if ($LogName -eq 'preview' -and ($engineOutput | Out-String) -notmatch 'P03_PREVIEW_OK') {
        throw 'No se genero la previsualizacion.'
    }
}

if ($Action -in @('run', 'import', 'test', 'preview')) {
    Invoke-ProjectGodot -EngineArguments @('--headless', '--editor', '--import') -LogName 'import'
}
switch ($Action) {
    'run' { Invoke-ProjectGodot -EngineArguments @() -LogName 'run' }
    'editor' { Invoke-ProjectGodot -EngineArguments @('--editor') -LogName 'editor' }
    'test' { Invoke-ProjectGodot -EngineArguments @('--headless', '--script', 'res://tests/startup_test.gd') -LogName 'test' }
    'preview' { Invoke-ProjectGodot -EngineArguments @('--audio-driver', 'Dummy', '--script', 'res://tests/capture_startup.gd') -LogName 'preview' }
}
