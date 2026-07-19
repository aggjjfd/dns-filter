# 测试 Windows 端拦截是否生效（pre-commit hook 用）
# 检测：① hosts 层（直连 → 127.0.0.1：连不上）② Clash 规则层（走代理 → REJECT）
# 门禁：hosts 层失败 → 阻止提交；Clash 层失败 → 仅警告（CDN 缓存/规则集未拉取）
# 用法：pwsh.exe -File tools/test-block.ps1
$ErrorActionPreference = 'Stop'
$domains = @(
  '7777sq.com'
  'jm222.xyz'
  'picacgp.com'
  'pronhub.com'
  'nhentai.com'
)
$proxy = 'http://127.0.0.1:7890'    # Verge Rev 默认 HTTP 代理端口
$bypass = @('--noproxy', '*')        # 绕开环境变量代理
$timeout = @('--connect-timeout', '5')
$hostsFail = $false
$clashFail = $false

Write-Host '🧱 hosts 层（直连，预期连不上）...' -ForegroundColor Cyan
foreach ($d in $domains) {
  $code = curl.exe -s -o nul -w '%{http_code}' $bypass $timeout "http://$d" 2>$null
  if ($code -eq '000') {
    Write-Host "  ✅ $d" -ForegroundColor Green
  } else {
    Write-Host "  ❌ $d → HTTP $code" -ForegroundColor Red
    $hostsFail = $true
  }
}

Write-Host ''
Write-Host '⚡ Clash 规则层（走代理，预期 REJECT）...' -ForegroundColor Cyan
foreach ($d in $domains) {
  $code = curl.exe -s -o nul -w '%{http_code}' --proxy $proxy $timeout "https://$d" 2>$null
  if ($code -eq '000') {
    Write-Host "  ✅ $d" -ForegroundColor Green
  } else {
    Write-Host "  ⚠️  $d → HTTP $code（规则集缓存未更新）" -ForegroundColor Yellow
    $clashFail = $true
  }
}

Write-Host ''
if ($hostsFail) {
  Write-Host '❌ hosts 层检测未通过，commit 已阻止。修复后重试。' -ForegroundColor Red
  exit 1
}
if ($clashFail) {
  Write-Host '⚠️  Clash 层有未拦截（CDN 缓存/规则集未拉取），请在 Verge Rev 右键更新规则集。' -ForegroundColor Yellow
}
Write-Host '✅ 检测通过。' -ForegroundColor Green
exit 0
