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
$plantDisplayWidth = [double]$timing.plant_display_width
$plantScale = [double]$timing.plant_scale
$plantAnchorX = [double]$timing.plant_anchor_x
$plantAnchorY = [double]$timing.plant_anchor_y
$projectileScale = [double]$timing.projectile_scale
$projectileAnchorX = [double]$timing.projectile_anchor_x
$projectileAnchorY = [double]$timing.projectile_anchor_y
$muzzleX = [int]$timing.muzzle_x
$muzzleY = [int]$timing.muzzle_y
if ($idleSeconds -le 0 -or $shootSeconds -le 0 -or $flySeconds -le 0 -or
    $plantDisplayWidth -le 0 -or $plantScale -le 0 -or $projectileScale -le 0) {
    throw 'Animation durations, plant_display_width, plant_scale, and projectile_scale must be greater than zero.'
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
$imageRoot = Join-Path $assetRoot 'reanim\weiku_b'
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

    $resourceId = 'IMAGE_REANIM_WEIKU_B_{0}_{1:D2}' -f $kind, $kindIndex
    $resourcePath = [IO.Path]::GetFileNameWithoutExtension($fileName)
    $resourceLines.Add(('  <Image id="{0}" path="{1}" />' -f $resourceId, $resourcePath))

    $size = Get-PngSize $entry.File.FullName
    $scale = Format-Number ($plantDisplayWidth * $plantScale / $size.Width)
    $plantTransforms.Add(('  <t><x>{0}</x><y>{1}</y><sx>{2}</sx><sy>{2}</sy><i>{3}</i></t>' -f (Format-Number $plantAnchorX), (Format-Number $plantAnchorY), $scale, $resourceId))
    $plantFrameIndex++
}

for ($i = 0; $i -lt $flyFrames.Count; $i++) {
    $entry = $flyFrames[$i]
    $fileName = 'fly_{0:D2}.png' -f $i
    $destination = Join-Path $imageRoot $fileName
    Copy-Item -LiteralPath $entry.File.FullName -Destination $destination -Force

    $resourceId = 'IMAGE_REANIM_WEIKU_B_FLY_{0:D2}' -f $i
    $resourcePath = [IO.Path]::GetFileNameWithoutExtension($fileName)
    $resourceLines.Add(('  <Image id="{0}" path="{1}" />' -f $resourceId, $resourcePath))
    $projectileTransforms.Add(('  <t><x>{0}</x><y>{1}</y><sx>{2}</sx><sy>{2}</sy><i>{3}</i></t>' -f (Format-Number $projectileAnchorX), (Format-Number $projectileAnchorY), (Format-Number $projectileScale), $resourceId))
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
    '  <name>weiku_b_sprite</name>'
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
    '  <name>weiku_b_projectile</name>'
) + $projectileTransforms + @(
    '</track>'
)

$generatedResourceBlock = @(
    '<!-- WEIKU_B GENERATED START -->'
    '<Resources id="LoadingImages">'
    '  <SetDefaults path="extension/reanim/weiku_b" idprefix="" />'
) + $resourceLines + @(
    '</Resources>'
    '<!-- WEIKU_B GENERATED END -->'
)

$header = @"
#ifndef __WEIKU_B_CONFIG_H__
#define __WEIKU_B_CONFIG_H__

// Generated by the WEIKU_B source folder's sync_assets.ps1.
// Edit timing.ini beside that script, then run the script again.
namespace WeikuBConfig
{
    static const float kIdleSeconds = $(Format-Number $idleSeconds)f;
    static const float kShootSeconds = $(Format-Number $shootSeconds)f;
    static const float kFlySeconds = $(Format-Number $flySeconds)f;
    static const int kMuzzleX = $muzzleX;
    static const int kMuzzleY = $muzzleY;
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

Set-Content -LiteralPath (Join-Path $assetRoot 'reanim\WeikuB.reanim') -Value $plantReanim -Encoding ASCII
Set-Content -LiteralPath (Join-Path $assetRoot 'reanim\WeikuBProjectile.reanim') -Value $projectileReanim -Encoding ASCII
# This build loads a .reanim.compiled file in preference to XML and does not
# invalidate it from the XML timestamp. Remove only WEIKU_B's stale caches so the
# next game launch necessarily uses the definitions generated above.
$compiledCacheNames = @('WeikuB.reanim.compiled', 'WeikuBProjectile.reanim.compiled')
$compiledCacheNames | ForEach-Object {
    $compiledPath = Join-Path $compiledRoot $_
    if (Test-Path -LiteralPath $compiledPath) {
        Remove-Item -LiteralPath $compiledPath -Force
    }
}
# MSBuild copies assets without removing destination-only files. Clear the same
# caches from the verified DebugGOTY x64 runtime directory as well.
$runtimeCompiledRoot = Join-Path $repoRoot 'build\DebugGOTY_x64\bin\extension\compiled\reanim'
$compiledCacheNames | ForEach-Object {
    $compiledPath = Join-Path $runtimeCompiledRoot $_
    if (Test-Path -LiteralPath $compiledPath) {
        Remove-Item -LiteralPath $compiledPath -Force
    }
}
$resourcesPath = Join-Path $assetRoot 'properties\resources.xml'
$generatedResourceText = $generatedResourceBlock -join "`r`n"
if (Test-Path -LiteralPath $resourcesPath) {
    $resourcesText = Get-Content -LiteralPath $resourcesPath -Raw -Encoding UTF8
    $generatedPattern = '(?s)\s*<!-- WEIKU_B GENERATED START -->.*?<!-- WEIKU_B GENERATED END -->\s*'
    if ($resourcesText -match '<!-- WEIKU_B GENERATED START -->') {
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
Set-Content -LiteralPath (Join-Path $repoRoot 'Lawn\WeikuBConfig.h') -Value $header -Encoding ASCII

$runtimeExtensionRoot = Join-Path $repoRoot 'build\DebugGOTY_x64\bin\extension'
$runtimeSynced = $false
if (Test-Path -LiteralPath (Split-Path -Parent $runtimeExtensionRoot)) {
    $runtimeReanimRoot = Join-Path $runtimeExtensionRoot 'reanim'
    $runtimeImageRoot = Join-Path $runtimeReanimRoot 'weiku_b'
    $runtimePropertiesRoot = Join-Path $runtimeExtensionRoot 'properties'
    New-Item -ItemType Directory -Force -Path $runtimeReanimRoot, $runtimeImageRoot, $runtimePropertiesRoot | Out-Null

    Copy-Item -LiteralPath (Join-Path $assetRoot 'reanim\WeikuB.reanim') -Destination $runtimeReanimRoot -Force
    Copy-Item -LiteralPath (Join-Path $assetRoot 'reanim\WeikuBProjectile.reanim') -Destination $runtimeReanimRoot -Force
    Get-ChildItem -LiteralPath $imageRoot -File -Filter '*.png' | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $runtimeImageRoot -Force
    }
    Copy-Item -LiteralPath $resourcesPath -Destination $runtimePropertiesRoot -Force
    $runtimeSynced = $true
}

Write-Host "Synced WEIKU_B: idle=$($idleFrames.Count), shoot=$($shootFrames.Count), fireIndex=$fireFrameIndex, fly=$($flyFrames.Count), plantWidth=$plantDisplayWidth, plantScale=$plantScale, projectileScale=$projectileScale, runtime=$runtimeSynced"
