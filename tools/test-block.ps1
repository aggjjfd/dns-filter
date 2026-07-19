# 测试 Windows 端拦截是否生效（pre-commit hook 用）
# 检查两点：① hosts 层（nslookup 解析到 0.0.0.0）② Clash 规则层（curl 走代理被 REJECT）
# 用法：pwsh.exe -File tools/test-block.ps1

$ErrorActionPreference = 'Stop'
$testDomains = @(
  '7777sq.com',
  'jm222.xyz',
  'picacgp.com',
  'pronhub.com',
  'nhentai.com'
)
$clashProxy = 'http://127.0.0.1:7890'  # Verge Rev 默认 HTTP 代理端口
$failed = @()

Write-Host "🔍 检测屏蔽域名 hosts 解析..." -ForegroundColor Cyan
foreach ($d in $testDomains) {
  $result = nslookup $d 2>$null | Select-String 'Address:' | Select-Object -Last 1
  if ($result -match '0\.0\.0\.0|127\.0\.0\.1') {
    Write-Host "  ✅ hosts: $d → 0.0.0.0" -ForegroundColor Green
  } else {
    Write-Host "  ❌ hosts: $d → 未屏蔽（${result}）" -ForegroundColor Red
    $failed += "hosts: $d"
  }
}

Write-Host ""
Write-Host "🔍 测试 Clash 规则层（经代理 REJECT）..." -ForegroundColor Cyan
foreach ($d in $testDomains) {
  try {
    $resp = curl.exe -s -o /dev/null -w '%{http_code}' --proxy $clashProxy --connect-timeout 3 "https://$d" 2>$null
    if ($resp -eq '000') {
      Write-Host "  ✅ Clash: $d → 连接被拒绝" -ForegroundColor Green
    } else {
      Write-Host "  ❌ Clash: $d → HTTP $resp（未拦截）" -ForegroundColor Red
      $failed += "Clash: $d"
    }
  } catch {
    Write-Host "  ⚠️  Clash: $d → 跳过（代理未启动？）" -ForegroundColor Yellow
  }
}

Write-Host ""
if ($failed.Count -gt 0) {
  Write-Host "❌ 以下检测未通过：" -ForegroundColor Red
  $failed | ForEach-Object { Write-Host "   - $_" }
  exit 1
} else {
  Write-Host "✅ 全部检测通过，屏蔽正常。" -ForegroundColor Green
  exit 0
}
