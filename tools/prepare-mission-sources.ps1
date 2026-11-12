[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SourceDirectory
)

$ErrorActionPreference = 'Stop'

function Get-LocalItem {
    param([string]$Path, [switch]$Directory)

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($null -ne $item -and (
        ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
        ($item.PSIsContainer -ne $Directory.IsPresent)
    )) {
        throw "Destino local no admitido: $Path"
    }
    return $item
}

function Get-Sha256 {
    param([string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256 -ErrorAction Stop).Hash
}

$sourceFolder = Get-Item -LiteralPath $SourceDirectory
if (-not ($sourceFolder -is [IO.DirectoryInfo])) {
    throw 'Indica la carpeta que contiene misiones.1.png y misiones.2.png.'
}

$projectRoot = Split-Path -Parent $PSScriptRoot
$evidenceRoot = Join-Path $projectRoot 'evidencia_local'
$destinationFolder = Join-Path $evidenceRoot 'src_005'
$marker = Join-Path $evidenceRoot '.gdignore'
$null = Get-LocalItem $evidenceRoot -Directory
$null = Get-LocalItem $destinationFolder -Directory
$null = Get-LocalItem $marker

# Huellas de los originales registrados en docs/referencias/README.md (SRC-005).
$sourceHashes = [ordered]@{
    'misiones.1.png' = '0185C0D65D2CEC7B66070BD08D5CD7D8FE618272BE490ED82C725C419346FA9D'
    'misiones.2.png' = '3DA0CF82F7CCB10CC08AFA27EE3F694A8CF51B6C536E153CB21F8DB6F5225B5B'
}
$pending = @()
foreach ($name in $sourceHashes.Keys) {
    $source = Join-Path $sourceFolder.FullName $name
    $destination = Join-Path $destinationFolder $name
    $expectedHash = $sourceHashes[$name]
    if ((Get-Sha256 $source) -ne $expectedHash) {
        throw "Huella SHA-256 de origen distinta de SRC-005: $source"
    }
    if ($null -ne (Get-LocalItem $destination)) {
        if ((Get-Sha256 $destination) -ne $expectedHash) {
            throw "El destino existente difiere de SRC-005: $destination"
        }
    }
    else {
        $pending += [pscustomobject]@{
            Source = $source
            Destination = $destination
            Sha256 = $expectedHash
            Temporary = Join-Path $destinationFolder ([guid]::NewGuid().ToString('N') + '.tmp')
        }
    }
}

[IO.Directory]::CreateDirectory($destinationFolder) | Out-Null
# OpenOrCreate conserva un marcador existente y permite ejecuciones simultaneas.
$markerStream = [IO.File]::Open($marker, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::Write, [IO.FileShare]::ReadWrite)
$markerStream.Dispose()
try {
    foreach ($file in $pending) {
        [IO.File]::Copy($file.Source, $file.Temporary, $false)
        if ((Get-Sha256 $file.Temporary) -ne $file.Sha256) {
            throw "El original cambio mientras se copiaba: $($file.Source)"
        }
    }
    foreach ($file in $pending) {
        try {
            [IO.File]::Move($file.Temporary, $file.Destination)
        }
        catch [IO.IOException] {
            # Si otra ejecucion creo un destino identico, se reutiliza.
            if ($null -eq (Get-LocalItem $file.Destination) -or
                (Get-Sha256 $file.Destination) -ne $file.Sha256) {
                throw
            }
        }
    }
}
finally {
    foreach ($file in $pending) {
        [IO.File]::Delete($file.Temporary)
    }
}

Write-Output "Fuentes SRC-005 comprobadas en $destinationFolder"
