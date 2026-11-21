[CmdletBinding()]
param([string]$GodotPath = '')
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$expectedVersion = (Get-Content -Raw -LiteralPath (Join-Path $root '.godot-version')).Trim()
if (-not $GodotPath) { $GodotPath = Join-Path $root ".tools/godot/Godot_v$expectedVersion-stable_win64_console.exe" }
$GodotPath = (Resolve-Path -LiteralPath $GodotPath).Path
$engineVersion = (& $GodotPath --version | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or -not $engineVersion.StartsWith("$expectedVersion.stable.")) { throw 'Version de Godot incompatible.' }
$target = Join-Path $root ('tmp/runtime-clean-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$logRoot = Join-Path $root 'tmp'
function Invoke-CheckedGodot([string[]]$Arguments, [string]$Log, [string]$Marker) {
    $old = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $lines = & $GodotPath @Arguments 2>&1
        $code = $LASTEXITCODE
    } finally { $ErrorActionPreference = $old }
    $lines | Set-Content -Encoding UTF8 -LiteralPath $Log
    $content = ($lines | ForEach-Object { [string]$_ }) -join "`n"
    if ($code -ne 0 -or $content -match '(?m)^(SCRIPT ERROR|ERROR):' -or ($Marker -and $content -notmatch $Marker)) { throw "Fallo del ensayo: $Log" }
}
& git -C $root clone --quiet --no-local $root $target 2> (Join-Path $logRoot 'runtime-clone.log')
if ($LASTEXITCODE -ne 0) { throw 'No se pudo crear el clon de prueba.' }
foreach ($folder in @('scripts', 'tests', 'tools')) {
    Copy-Item -LiteralPath (Join-Path $root $folder) -Destination $target -Recurse -Force
}
if (Test-Path -LiteralPath (Join-Path $target 'evidencia_local')) { throw 'El clon contiene originales.' }
New-Item -ItemType Directory -Path (Join-Path $target 'tmp/runtime_catalog') -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $target 'tmp/.gdignore'), '')
foreach ($name in @('trial.json', 'states.bin', 'authoring.json')) {
    Copy-Item -LiteralPath (Join-Path $root "tmp/runtime_catalog/$name") -Destination (Join-Path $target 'tmp/runtime_catalog')
}
Invoke-CheckedGodot @('--headless', '--path', $target, '--editor', '--import') (Join-Path $logRoot 'runtime-clean-import.log') ''
Invoke-CheckedGodot @('--headless', '--path', $target, '--quit-after', '500', '--script', 'res://tests/runtime_catalog_test.gd') (Join-Path $logRoot 'runtime-clean-test.log') 'P08_RUNTIME_CATALOG_OK'
New-Item -ItemType Directory -Path (Join-Path $target 'runtime_trial') -Force | Out-Null
foreach ($name in @('trial.json', 'states.bin')) {
    Copy-Item -LiteralPath (Join-Path $root "tmp/runtime_catalog/$name") -Destination (Join-Path $target 'runtime_trial')
}
$preset = @"
[preset.0]
name="Runtime trial"
platform="Windows Desktop"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter="runtime_trial/*.json,runtime_trial/*.bin,data/cartas.json,data/README.md"
exclude_filter="evidencia_local/*,tmp/*,docs/*,.tools/*,data/perseguir.json,data/misiones.json"
export_path=""
script_export_mode=2
[preset.0.options]
binary_format/embed_pck=false
"@
[IO.File]::WriteAllText((Join-Path $target 'export_presets.cfg'), $preset)
$pack = Join-Path $target 'runtime-trial.pck'
Invoke-CheckedGodot @('--headless', '--path', $target, '--editor', '--export-pack', 'Runtime trial', $pack) (Join-Path $logRoot 'runtime-export.log') ''
$runner = Join-Path $target 'empty-runner'
New-Item -ItemType Directory -Path $runner | Out-Null
Push-Location -LiteralPath $runner
try {
    Invoke-CheckedGodot @('--headless', '--main-pack', $pack, '--quit-after', '500', '--script', 'res://tests/runtime_catalog_test.gd', '--', 'res://runtime_trial/') (Join-Path $logRoot 'runtime-export-test.log') 'P08_RUNTIME_CATALOG_OK'
    Invoke-CheckedGodot @('--headless', '--main-pack', $pack, '--quit-after', '500', '--script', 'res://tools/runtime_pack_inventory.gd', '--', (Join-Path $logRoot 'runtime-pack-inventory.json')) (Join-Path $logRoot 'runtime-inventory.log') 'P08_RUNTIME_INVENTORY_OK'
} finally { Pop-Location }
$inventory = Get-Content -Raw -LiteralPath (Join-Path $logRoot 'runtime-pack-inventory.json') | ConvertFrom-Json
$hashes = @()
foreach ($name in @('misiones.1.png', 'misiones.2.png', 'mercado.3.png')) {
    $hashes += (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $root "evidencia_local/src_005/$name")).Hash.ToLowerInvariant()
}
$found = @($inventory | Where-Object { $_.path -match 'evidencia_local|misiones[.][12][.]png|mercado[.]3[.]png' -or $_.sha256 -in $hashes })
if ($found.Count) { throw 'Se encontraron originales en el paquete.' }
$report = [ordered]@{ clone = $target; pack = $pack; pack_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $pack).Hash.ToLowerInvariant(); entries = @($inventory).Count; forbidden_entries = $found.Count; original_sha256 = $hashes }
$report | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $logRoot 'runtime-distribution-report.json')
& python (Join-Path $root 'tools/inspect_runtime_pack.py') $pack (Join-Path $root 'evidencia_local/src_005') (Join-Path $logRoot 'runtime-pack-bytes.json')
if ($LASTEXITCODE -ne 0) { throw 'La inspeccion de bytes fallo.' }
Write-Host 'P08_RUNTIME_DISTRIBUTION_OK'
