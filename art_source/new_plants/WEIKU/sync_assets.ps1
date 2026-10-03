[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$sourceRoot = $PSScriptRoot
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $sourceRoot '..\..\..')).Path
$timingPath = Join-Path $sourceRoot 'timing.ini'
$timing = ConvertFrom-StringData (Get-Content -LiteralPath $timingPath -Raw -Encoding UTF8)

$idleSeconds = [double]$timing.idle_seconds
$shootSeconds = [double]$timing.shoot_seconds
$flySeconds = [double]$timing.fly_seconds
if ($idleSeconds -le 0 -or $shootSeconds -le 0 -or $flySeconds -le 0) {
    throw 'All animation durations must be greater than zero.'
}

function Get-NumberedFrames([string]$path) {
    $frames = Get-ChildItem -LiteralPath $path -File -Filter '*.png' | ForEach-Object {
        if ($_.BaseName -notmatch '^(\d+)') {
            throw "Frame name must start with a number: $($_.FullName)"
        }
        [pscustomobject]@{ File = $_; Number = [int]$Matches[1] }
    } | Sort-Object Number, @{ Expression = { $_.File.Name } }

    if ($frames.Count -eq 0) {
        throw "No PNG frames found in $path"
    }
    return @($frames)
}

function Get-PngSize([string]$path) {
    Add-Type -AssemblyName System.Drawing
    $image = [System.Drawing.Image]::FromFile($path)
    try {
        return [pscustomobject]@{ Width = $image.Width; Height = $image.Height }
    }
    finally {
        $image.Dispose()
    }
}

function Format-Number([double]$value) {
    $formatted = $value.ToString('0.########', [Globalization.CultureInfo]::InvariantCulture)
    if ($formatted -notmatch '\.') {
        $formatted += '.0'
    }
    return $formatted
}

$idleFrames = Get-NumberedFrames (Join-Path $sourceRoot 'plant\idle')
$shootFrames = Get-NumberedFrames (Join-Path $sourceRoot 'plant\shoot')
$flyFrames = Get-NumberedFrames (Join-Path $sourceRoot 'projectile\fly')
$fireFrames = @($shootFrames | Where-Object { $_.File.BaseName -match '_shoot$' })
if ($fireFrames.Count -ne 1) {
    throw 'Exactly one shoot frame must end with _shoot.png.'
}
$fireFrameIndex = [array]::IndexOf([object[]]$shootFrames, $fireFrames[0])

$assetRoot = Join-Path $repoRoot 'assets\extension'
$imageRoot = Join-Path $assetRoot 'reanim\weiku'
$compiledRoot = Join-Path $assetRoot 'compiled\reanim'
New-Item -ItemType Directory -Force -Path $imageRoot, $compiledRoot | Out-Null

$resourceLines = [Collections.Generic.List[string]]::new()
$plantTransforms = [Collections.Generic.List[string]]::new()
$projectileTransforms = [Collections.Generic.List[string]]::new()

$plantFrameIndex = 0
foreach ($entry in @($idleFrames) + @($shootFrames)) {
    $kind = if ($plantFrameIndex -lt $idleFrames.Count) { 'IDLE' } else { 'SHOOT' }
    $kindIndex = if ($kind -eq 'IDLE') { $plantFrameIndex } else { $plantFrameIndex - $idleFrames.Count }
    $fileName = ('{0}_{1:D2}.png' -f $kind.ToLowerInvariant(), $kindIndex)
    $destination = Join-Path $imageRoot $fileName
    Copy-Item -LiteralPath $entry.File.FullName -Destination $destination -Force

    $resourceId = 'IMAGE_REANIM_WEIKU_{0}_{1:D2}' -f $kind, $kindIndex
    $resourcePath = [IO.Path]::GetFileNameWithoutExtension($fileName)
    $resourceLines.Add(('  <Image id="{0}" path="{1}" />' -f $resourceId, $resourcePath))

    $size = Get-PngSize $entry.File.FullName
    $scale = Format-Number (120.0 / $size.Width)
    $plantTransforms.Add(('  <t><x>40</x><y>40</y><sx>{0}</sx><sy>{0}</sy><i>{1}</i></t>' -f $scale, $resourceId))
    $plantFrameIndex++
}

for ($i = 0; $i -lt $flyFrames.Count; $i++) {
    $entry = $flyFrames[$i]
    $fileName = 'fly_{0:D2}.png' -f $i
    $destination = Join-Path $imageRoot $fileName
    Copy-Item -LiteralPath $entry.File.FullName -Destination $destination -Force

    $resourceId = 'IMAGE_REANIM_WEIKU_FLY_{0:D2}' -f $i
    $resourcePath = [IO.Path]::GetFileNameWithoutExtension($fileName)
    $resourceLines.Add(('  <Image id="{0}" path="{1}" />' -f $resourceId, $resourcePath))
    $projectileTransforms.Add(('  <t><x>20</x><y>20</y><sx>0.06</sx><sy>0.06</sy><i>{0}</i></t>' -f $resourceId))
}

$totalPlantFrames = $idleFrames.Count + $shootFrames.Count
$idleMarker = [Collections.Generic.List[string]]::new()
$shootMarker = [Collections.Generic.List[string]]::new()
for ($i = 0; $i -lt $totalPlantFrames; $i++) {
    if ($i -eq 0) { $idleMarker.Add('  <t><f>0</f></t>') }
    elseif ($i -eq $idleFrames.Count) { $idleMarker.Add('  <t><f>-1</f></t>') }
    else { $idleMarker.Add('  <t></t>') }

    if ($i -eq 0) { $shootMarker.Add('  <t><f>-1</f></t>') }
    elseif ($i -eq $idleFrames.Count) { $shootMarker.Add('  <t><f>0</f></t>') }
    else { $shootMarker.Add('  <t></t>') }
}

$plantReanim = @(
    '<fps>12</fps>'
    '<track>'
    '  <name>anim_idle</name>'
) + $idleMarker + @(
    '</track>'
    '<track>'
    '  <name>anim_shooting</name>'
) + $shootMarker + @(
    '</track>'
    '<track>'
    '  <name>weiku_sprite</name>'
) + $plantTransforms + @(
    '</track>'
)

$projectileMarker = @('  <t><f>0</f></t>') + @(1..($flyFrames.Count - 1) | ForEach-Object { '  <t></t>' })
$projectileReanim = @(
    '<fps>12</fps>'
    '<track>'
    '  <name>anim_fly</name>'
) + $projectileMarker + @(
    '</track>'
    '<track>'
    '  <name>weiku_projectile</name>'
) + $projectileTransforms + @(
    '</track>'
)

$generatedResourceBlock = @(
    '<!-- WEIKU GENERATED START -->'
    '<Resources id="LoadingImages">'
    '  <SetDefaults path="extension/reanim/weiku" idprefix="" />'
) + $resourceLines + @(
    '</Resources>'
    '<!-- WEIKU GENERATED END -->'
)

$header = @"
#ifndef __WEIKU_CONFIG_H__
#define __WEIKU_CONFIG_H__

// Generated by the WEIKU source folder's sync_assets.ps1.
// Edit timing.ini beside that script, then run the script again.
namespace WeikuConfig
{
    static const float kIdleSeconds = $(Format-Number $idleSeconds)f;
    static const float kShootSeconds = $(Format-Number $shootSeconds)f;
    static const float kFlySeconds = $(Format-Number $flySeconds)f;
    static const int kIdleFrameCount = $($idleFrames.Count);
    static const int kShootFrameCount = $($shootFrames.Count);
    static const int kFlyFrameCount = $($flyFrames.Count);
    static const int kFireFrameIndex = $fireFrameIndex;
    static const int kShootTicks = (int)(kShootSeconds * 100.0f + 0.5f);
    static const int kFireTick = (kFireFrameIndex * kShootTicks + kShootFrameCount - 1) / kShootFrameCount;
    static const int kFireCounter = kShootTicks + 1 - (kFireTick > 0 ? kFireTick : 1);
}

#endif
"@

Set-Content -LiteralPath (Join-Path $assetRoot 'reanim\Weiku.reanim') -Value $plantReanim -Encoding ASCII
Set-Content -LiteralPath (Join-Path $assetRoot 'reanim\WeikuProjectile.reanim') -Value $projectileReanim -Encoding ASCII
$resourcesPath = Join-Path $assetRoot 'properties\resources.xml'
$generatedResourceText = $generatedResourceBlock -join "`r`n"
if (Test-Path -LiteralPath $resourcesPath) {
    $resourcesText = Get-Content -LiteralPath $resourcesPath -Raw -Encoding UTF8
    $generatedPattern = '(?s)\s*<!-- WEIKU GENERATED START -->.*?<!-- WEIKU GENERATED END -->\s*'
    if ($resourcesText -match '<!-- WEIKU GENERATED START -->') {
        $resourcesText = [regex]::Replace($resourcesText, $generatedPattern, "`r`n$generatedResourceText`r`n")
    }
    else {
        $resourcesText = $resourcesText.Replace('</ResourceManifest>', "$generatedResourceText`r`n</ResourceManifest>")
    }
}
else {
    $resourcesText = "<?xml version=`"1.0`"?>`r`n<ResourceManifest>`r`n$generatedResourceText`r`n</ResourceManifest>`r`n"
}
$resourcesText = $resourcesText.TrimEnd([char[]]"`r`n")
Set-Content -LiteralPath $resourcesPath -Value $resourcesText -Encoding ASCII
Set-Content -LiteralPath (Join-Path $repoRoot 'Lawn\WeikuConfig.h') -Value $header -Encoding ASCII

Write-Host "Synced Weiku: idle=$($idleFrames.Count), shoot=$($shootFrames.Count), fireIndex=$fireFrameIndex, fly=$($flyFrames.Count)"
