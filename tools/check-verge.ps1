# 排查 Verge Rev 配置冲突
$base = "$env:APPDATA\io.github.clash-verge-rev.clash-verge-rev"

Write-Host "=== 1. dns_config.yaml ==="
Get-Content (Join-Path $base 'dns_config.yaml')

Write-Host ""
Write-Host "=== 2. 订阅的编辑规则 (rhRMUrHnh4Dt.yaml) ==="
Get-Content (Join-Path $base 'profiles\rhRMUrHnh4Dt.yaml')

Write-Host ""
Write-Host "=== 3. 订阅的编辑代理组 (gqRHKuXvIEzQ.yaml) ==="
Get-Content (Join-Path $base 'profiles\gqRHKuXvIEzQ.yaml')

Write-Host ""
Write-Host "=== 4. 订阅的编辑脚本 (sjzT3KaNu6yL.js) ==="
Get-Content (Join-Path $base 'profiles\sjzT3KaNu6yL.js')

Write-Host ""
Write-Host "=== 5. verge.yaml 关键配置 ==="
Get-Content (Join-Path $base 'verge.yaml')
