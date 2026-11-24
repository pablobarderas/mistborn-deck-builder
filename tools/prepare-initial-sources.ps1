[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$SourceRoot)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceDirectory = (Resolve-Path -LiteralPath $SourceRoot -ErrorAction Stop).Path
$destinationRoot = Join-Path $projectRoot 'evidencia_local'
if (-not (Test-Path -LiteralPath (Join-Path $destinationRoot '.gdignore') -PathType Leaf)) {
    throw 'Falta evidencia_local/.gdignore; no se copiarán originales al proyecto.'
}

$items = @(
    @{ From = 'personajes.png'; To = 'src_005/personajes.png'; Hash = 'DB0356C5FC95D1BF0178FF0DDF2D240EC87DBF24E4B38E34CF5C3BB95C96C952' },
    @{ From = 'kelsier/entrenamiento_kelsier.png'; To = 'src_004/entrenamiento_kelsier.png'; Hash = '2054E91A48E8C59692E971D284BB84930CA83D972FC1071678CEE566819E3F4B' },
    @{ From = 'marsh/entrenamiento_marsh.png'; To = 'src_004/entrenamiento_marsh.png'; Hash = '7000EC32F416BCF4444A5BD56293E7BB509C54CAB0F4D497327DF8F631985D1B' },
    @{ From = 'shan/entrenamiento_shan.png'; To = 'src_004/entrenamiento_shan.png'; Hash = '2176DECDD2842A1DA701969ECE93993DCEEF3ACB5C87DFCCCAF7D971B2342BD6' },
    @{ From = 'vin/entrenamiento_monedas.png'; To = 'src_004/entrenamiento_monedas.png'; Hash = 'EDB5D4838BAD62A3779BF4C36553C413DF050CEB05B6AE3DC6C1205FE7D2CB01' },
    @{ From = 'panel_niveles.png'; To = 'src_004/panel_niveles.png'; Hash = 'C4FF1DE62CF9A7A9283F1E4B24B232E44D071A7AD8C8DE92980E51AB917EACED' }
)

# Comprobar todo antes de copiar, para que una fuente ausente o alterada no deje un lote parcial nuevo.
foreach ($item in $items) {
    $inputFile = Join-Path $sourceDirectory $item.From
    $outputFile = Join-Path $destinationRoot $item.To
    if (-not (Test-Path -LiteralPath $inputFile -PathType Leaf)) {
        throw "Falta el original $($item.From)."
    }
    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $inputFile).Hash -ne $item.Hash) {
        throw "La huella del original $($item.From) no coincide."
    }
    if ((Test-Path -LiteralPath $outputFile) -and -not (Test-Path -LiteralPath $outputFile -PathType Leaf)) {
        throw "El destino $($item.To) no es un archivo."
    }
    if ((Test-Path -LiteralPath $outputFile -PathType Leaf) -and
        (Get-FileHash -Algorithm SHA256 -LiteralPath $outputFile).Hash -ne $item.Hash) {
        throw "Ya existe una copia diferente en $($item.To)."
    }
}

foreach ($item in $items) {
    $inputFile = Join-Path $sourceDirectory $item.From
    $outputFile = Join-Path $destinationRoot $item.To
    if (-not (Test-Path -LiteralPath $outputFile -PathType Leaf)) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $outputFile) | Out-Null
        Copy-Item -LiteralPath $inputFile -Destination $outputFile
    }
    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $outputFile).Hash -ne $item.Hash) {
        throw "La copia de $($item.From) no coincide."
    }
}
Write-Output 'P08_INITIAL_SOURCES_OK: seis originales locales comprobados; fuera de Git.'
