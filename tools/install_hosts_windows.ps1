# 将 adult-hosts.txt 注入 Windows 系统 hosts（幂等，带标记块可重复执行）
# 用法：右键「以管理员身份运行 PowerShell」后执行本脚本
$ErrorActionPreference = 'Stop'

$hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
$blockFile = Join-Path $PSScriptRoot '..\adult-hosts.txt'
$beginMark = '# >>> dns-filter >>>'
$endMark   = '# <<< dns-filter <<<'

if (-not (Test-Path $blockFile)) { throw "找不到 $blockFile，请在 dns-filter 仓库内执行" }

$lines = Get-Content $hostsPath -ErrorAction SilentlyContinue
# 移除旧的标记块（若存在）
$out = New-Object System.Collections.Generic.List[string]
$skip = $false
foreach ($l in $lines) {
    if ($l -match [regex]::Escape($beginMark)) { $skip = $true; continue }
    if ($l -match [regex]::Escape($endMark))   { $skip = $false; continue }
    if (-not $skip) { $out.Add($l) }
}
$out.Add($beginMark)
foreach ($l in Get-Content $blockFile) {
    if ($l -match '^\s*#' -or $l -match '^\s*$') { continue }
    $out.Add($l)
}
$out.Add($endMark)
[System.IO.File]::WriteAllLines($hostsPath, $out)

$count = ($out | Where-Object { $_ -match '^0\.0\.0\.0\s' }).Count
Write-Host "已写入 $count 条屏蔽记录到 $hostsPath" -ForegroundColor Green
ipconfig /flushdns | Out-Null
Write-Host "DNS 缓存已刷新" -ForegroundColor Green
