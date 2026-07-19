# 检查所有 profile 文件是否有规则注入
$d = "$env:APPDATA\io.github.clash-verge-rev.clash-verge-rev\profiles"
foreach ($f in Get-ChildItem $d -Filter "*.yaml") {
    $hits = Select-String -Path $f.FullName -Pattern "RULE-SET|rule-providers|prepend" | Select-Object -First 3
    if ($hits) {
        Write-Host "$($f.Name) => 有规则注入: $($hits[0].Line)"
    } else {
        Write-Host "$($f.Name) => 无规则注入"
    }
}
