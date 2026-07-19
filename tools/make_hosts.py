# /// script
# requires-python = ">=3.10"
# ///
"""生成过滤名单产物：hosts 黑名单 + Clash 自定义规则集。

输入：
    dns/custom-blocklist.txt   手工补充的漏网站点，一行一个域名（# 注释）
产出：
    dns/adult-hosts.txt            category-porn + 自定义，hosts 格式（0.0.0.0 指向，含 www 变体）
    dns/clash-custom-blocklist.yaml  仅自定义名单，mihomo rule-provider（behavior: domain）格式

用法：
    uv run dns/tools/make_hosts.py
"""
from pathlib import Path
from urllib.request import urlopen

SOURCE = "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/category-porn.list"
ROOT = Path(__file__).resolve().parent.parent
CUSTOM = ROOT / "custom-blocklist.txt"
HOSTS_OUT = ROOT / "adult-hosts.txt"
CLASH_OUT = ROOT / "clash-custom-blocklist.yaml"

HOSTS_HEADER = """# 成人内容 hosts 黑名单
# 由 dns/tools/make_hosts.py 自动生成，源：v2fly category-porn（MetaCubeX 转换）+ dns/custom-blocklist.txt
# 用法：Windows 并入 C:\\Windows\\System32\\drivers\\etc\\hosts；Android 用 AdAway（root 模式）添加为远程源
"""

CLASH_HEADER = """# 自定义屏蔽规则集（mihomo rule-provider，behavior: domain）
# 由 dns/tools/make_hosts.py 根据 dns/custom-blocklist.txt 生成，勿手改
"""

def parse_domains(lines: list[str]) -> set[str]:
    domains: set[str] = set()
    for raw in lines:
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        # 规则集语法：+.example.com 表示域名及子域；hosts 无通配符，退化为 主域 + www 变体
        domain = line[2:] if line.startswith("+.") else line
        if " " in domain or "/" in domain or ":" in domain:
            continue  # 跳过 regex/full: 等无法表达的条目
        domains.add(domain)
        if domain.count(".") == 1:
            domains.add("www." + domain)
    return domains

def main() -> None:
    porn = urlopen(SOURCE, timeout=60).read().decode("utf-8").splitlines()
    custom = CUSTOM.read_text(encoding="utf-8").splitlines() if CUSTOM.exists() else []

    hosts = sorted(parse_domains(porn) | parse_domains(custom))
    HOSTS_OUT.write_text(
        f"{HOSTS_HEADER}# 共 {len(hosts)} 条\n\n" + "\n".join(f"0.0.0.0 {d}" for d in hosts) + "\n",
        encoding="utf-8",
    )

    clash = sorted(parse_domains(custom))
    CLASH_OUT.write_text(
        f"{CLASH_HEADER}payload:\n" + "".join(f"  - '+.{d}'\n" for d in clash),
        encoding="utf-8",
    )
    print(f"generated {HOSTS_OUT} ({len(hosts)} entries), {CLASH_OUT} ({len(clash)} custom)")

if __name__ == "__main__":
    main()
