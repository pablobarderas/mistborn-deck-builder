[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SourceFile
)

$ErrorActionPreference = 'Stop'
$expected = '747A01D7EBBF69E8272C052C81A40BEAA5EF67FFF853C1C4E1E8C69B49A105CB'
$source = Get-Item -LiteralPath $SourceFile -ErrorAction Stop
if ($source.PSIsContainer -or ($source.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
    throw 'El origen debe ser el PNG original, no una carpeta ni un enlace.'
}
if ((Get-FileHash -LiteralPath $source.FullName -Algorithm SHA256).Hash -ne $expected) {
    throw 'El origen no coincide con la huella de SRC-005 para mercado.3.png.'
}

$projectRoot = Split-Path -Parent $PSScriptRoot
$evidenceRoot = Join-Path $projectRoot 'evidencia_local'
$folder = Join-Path $evidenceRoot 'src_005'
$destination = Join-Path $folder 'mercado.3.png'
$marker = Join-Path $evidenceRoot '.gdignore'
foreach ($path in @($evidenceRoot, $folder, $destination, $marker)) {
    $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
    if ($null -ne $item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw "No se admite un enlace en el destino: $path"
    }
}
$markerItem = Get-Item -LiteralPath $marker -ErrorAction SilentlyContinue
if ($null -ne $markerItem -and $markerItem.PSIsContainer) {
    throw 'El marcador .gdignore no puede ser una carpeta.'
}
$existing = Get-Item -LiteralPath $destination -ErrorAction SilentlyContinue
if ($null -ne $existing) {
    if ($existing.PSIsContainer -or (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -ne $expected) {
        throw 'El destino existente no coincide con SRC-005; no se sobrescribe.'
    }
    [IO.Directory]::CreateDirectory($evidenceRoot) | Out-Null
    if ($null -eq $markerItem) { [IO.File]::WriteAllText($marker, '') }
    Write-Output 'Fuente de Perseguir ya preparada y verificada.'
    return
}

[IO.Directory]::CreateDirectory($folder) | Out-Null
if ($null -eq $markerItem) { [IO.File]::WriteAllText($marker, '') }
$temporary = Join-Path $folder ([guid]::NewGuid().ToString('N') + '.tmp')
try {
    [IO.File]::Copy($source.FullName, $temporary, $false)
    if ((Get-FileHash -LiteralPath $temporary -Algorithm SHA256).Hash -ne $expected) {
        throw 'El original cambió durante la copia.'
    }
    [IO.File]::Move($temporary, $destination)
}
finally {
    if (Test-Path -LiteralPath $temporary) { [IO.File]::Delete($temporary) }
}
Write-Output 'Fuente de Perseguir preparada y verificada.'
