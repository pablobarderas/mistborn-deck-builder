[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceDirectory,
    [Parameter(Mandatory = $true)]
    [string]$GodotPath
)

$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Assert-Rejected {
    param([string]$Folder, [string]$ExpectedError)
    try {
        & $prepare -SourceDirectory $Folder
    }
    catch {
        Assert-True ($_.Exception.Message.Contains($ExpectedError)) $_.Exception.Message
        return
    }
    throw "Se esperaba rechazo: $ExpectedError"
}

function Invoke-TestGodot {
    param([string[]]$Arguments)
    $log = & $godot --headless --path $project @Arguments 2>&1
    if ($LASTEXITCODE -ne 0 -or ($log -match 'SCRIPT ERROR|(^|\s)ERROR:')) {
        throw ($log -join [Environment]::NewLine)
    }
    return $log
}

$repo = Split-Path -Parent $PSScriptRoot
$godot = (Resolve-Path -LiteralPath $GodotPath).ProviderPath
$originals = (Resolve-Path -LiteralPath $SourceDirectory).ProviderPath
$temporaryRoot = [IO.Path]::GetFullPath((Join-Path $repo 'tmp'))
$project = Join-Path $temporaryRoot ('mission-sources-' + [guid]::NewGuid().ToString('N'))
$projectTools = Join-Path $project 'tools'
$evidence = Join-Path $project 'evidencia_local'
$destination = Join-Path $evidence 'src_005'
$first = Join-Path $destination 'misiones.1.png'
$second = Join-Path $destination 'misiones.2.png'
$prepare = Join-Path $projectTools 'prepare-mission-sources.ps1'

try {
    [IO.Directory]::CreateDirectory($projectTools) | Out-Null
    Copy-Item -LiteralPath (Join-Path $repo 'tools/prepare-mission-sources.ps1') -Destination $prepare
    $invalid = Join-Path $project 'invalid'
    [IO.Directory]::CreateDirectory($invalid) | Out-Null
    [IO.File]::WriteAllText((Join-Path $invalid '.gdignore'), '')
    Copy-Item -LiteralPath (Join-Path $originals 'misiones.1.png') -Destination $invalid
    [IO.File]::WriteAllText((Join-Path $invalid 'misiones.2.png'), 'origen incorrecto')
    Assert-Rejected $invalid 'Huella SHA-256 de origen'
    Assert-True (-not (Test-Path -LiteralPath $evidence)) 'Un origen invalido creo evidencia.'

    [IO.Directory]::CreateDirectory($destination) | Out-Null
    [IO.File]::WriteAllText($second, 'destino en conflicto')
    Assert-Rejected $originals 'El destino existente difiere'
    Assert-True (-not (Test-Path -LiteralPath $first)) 'El conflicto del segundo destino altero el primero.'
    Assert-True (([IO.File]::ReadAllText($second)) -eq 'destino en conflicto') 'Se sobreescribio el segundo destino.'
    [IO.File]::Delete($second)

    & $prepare -SourceDirectory $originals
    Assert-True (Test-Path -LiteralPath (Join-Path $evidence '.gdignore') -PathType Leaf) 'Falta .gdignore.'
    foreach ($copy in @($first, $second)) {
        $original = Join-Path $originals (Split-Path -Leaf $copy)
        Assert-True ((Get-FileHash -LiteralPath $copy).Hash -eq (Get-FileHash -LiteralPath $original).Hash) "Copia distinta: $copy"
        [IO.File]::SetLastWriteTimeUtc($copy, [datetime]'2024-01-01T00:00:00Z')
    }
    & $prepare -SourceDirectory $originals
    foreach ($copy in @($first, $second)) {
        Assert-True ([IO.File]::GetLastWriteTimeUtc($copy).Year -eq 2024) "Se reescribio la copia identica: $copy"
    }
    Assert-True ((Get-ChildItem -LiteralPath $destination -Force).Count -eq 2) 'Quedaron archivos temporales.'

    $ignored = git -C $repo check-ignore evidencia_local/src_005/misiones.1.png evidencia_local/src_005/misiones.2.png
    Assert-True ($LASTEXITCODE -eq 0 -and @($ignored).Count -eq 2) 'Los escaneos no quedan excluidos de Git.'

    [IO.File]::WriteAllText((Join-Path $project 'project.godot'), @'
config_version=5
[application]
config/name="Mission sources probe"
config/features=PackedStringArray("4.7", "GL Compatibility")
[rendering]
renderer/rendering_method="gl_compatibility"
'@)
    [IO.File]::WriteAllText((Join-Path $project 'probe.gd'), @'
extends SceneTree
func _initialize() -> void:
	for sheet: int in [1, 2]:
		var path: String = "res://evidencia_local/src_005/misiones.%d.png" % sheet
		if not FileAccess.file_exists(path) or ResourceLoader.exists(path, "Texture2D"):
			push_error("La evidencia debe ser accesible como archivo y quedar fuera de la importacion.")
			quit(1)
			return
	print("MISSION_SOURCE_IMPORT_OK")
	quit(0)
'@)
    Invoke-TestGodot -Arguments @('--editor', '--import') | Out-Null
    $probeLog = Invoke-TestGodot -Arguments @('--script', 'res://probe.gd')
    Assert-True (($probeLog -join ' ') -match 'MISSION_SOURCE_IMPORT_OK') 'No se comprobo la exclusion de importacion.'

    [IO.File]::WriteAllText((Join-Path $project 'export_presets.cfg'), @'
[preset.0]
name="Mission source probe"
platform="Windows Desktop"
runnable=false
export_filter="all_resources"
include_filter=""
exclude_filter=""
script_export_mode=0

[preset.0.options]
binary_format/architecture="x86_64"
'@)
    $archive = Join-Path $project 'probe.zip'
    Invoke-TestGodot -Arguments @('--export-pack', 'Mission source probe', $archive) | Out-Null
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($archive)
    try {
        $entries = @($zip.Entries.FullName)
        Assert-True (@($entries -match '(^|/)probe\.(gd|gdc)$').Count -gt 0) 'La exportacion no contiene el control positivo.'
        Assert-True (-not ($entries -match 'evidencia_local|misiones\.[12]\.png')) 'La exportacion contiene evidencia local.'
    }
    finally {
        $zip.Dispose()
    }
    Write-Output 'MISSION_SOURCES_OK: preparacion, conflictos, repeticion, Git, importacion y exportacion.'
}
finally {
    if (Test-Path -LiteralPath $project) {
        $resolved = (Resolve-Path -LiteralPath $project).ProviderPath
        if ($resolved -ne $project -or (Split-Path -Parent $resolved) -ne $temporaryRoot) {
            throw "Ruta de limpieza fuera del directorio de prueba: $resolved"
        }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
