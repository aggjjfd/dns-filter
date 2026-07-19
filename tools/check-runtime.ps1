# 排查当前 Verge Rev 配置状态
$profiles = "$env:APPDATA\io.github.clash-verge-rev.clash-verge-rev\profiles"

Write-Host "=== merge 配置 (mOvUPdxSJbMO.yaml, 971 bytes) ==="
Get-Content (Join-Path $profiles 'mOvUPdxSJbMO.yaml')

Write-Host ""
Write-Host "=== 订阅配置 rules 前 5 行 (R2PTyfRM1KOM.yaml) ==="
$sub = Get-Content (Join-Path $profiles 'R2PTyfRM1KOM.yaml') -Encoding UTF8
$inRules = $false; $rc = 0
foreach ($line in $sub) {
    if ($line -match '^rules:') { $inRules = $true; continue }
    if ($inRules) {
        if ($line -match '^\S') { break }
        $rc++
        if ($rc -le 5) { Write-Host "  $line" }
    }
}
Write-Host "rules 总数: $rc"

Write-Host ""
Write-Host "=== 订阅配置 proxy-groups ==="
$inG = $false; $gc = 0
foreach ($line in $sub) {
    if ($line -match '^proxy-groups:') { $inG = $true; continue }
    if ($inG) {
        if ($line -match '^\S') { break }
        if ($line -match '^\s+-\s+name:') { $gc++; Write-Host "  $line" }
    }
}
Write-Host "proxy-groups 总数: $gc"
