# /// script
# requires-python = ">=3.10"
# ///
"""生成过滤名单产物：hosts 黑名单 + Clash 自定义规则集 + Shadowrocket 规则集。

输入：
    custom-blocklist.txt   手工补充的漏网站点，一行一个域名（# 注释）
产出：
    adult-hosts.txt              category-porn + 自定义，hosts 格式（127.0.0.1 指向）
    clash-custom-blocklist.yaml  仅自定义名单，mihomo rule-provider（behavior: domain）格式
    adult-shadowrocket.list      category-porn + 自定义，Shadowrocket/Surge 格式（DOMAIN-SUFFIX 每行一条）

用法：
    uv run tools/make_hosts.py
"""
from pathlib import Path
from urllib.request import urlopen

SOURCE = "https://cdn.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@meta/geo/geosite/category-porn.list"
ROOT = Path(__file__).resolve().parent.parent
CUSTOM = ROOT / "custom-blocklist.txt"
HOSTS_OUT = ROOT / "adult-hosts.txt"
CLASH_OUT = ROOT / "clash-custom-blocklist.yaml"
SR_OUT = ROOT / "adult-shadowrocket.list"

HOSTS_HEADER = """# 成人内容 hosts 黑名单
# 由 tools/make_hosts.py 自动生成，源：v2fly category-porn（MetaCubeX 转换）+ custom-blocklist.txt
# 用法：Windows 并入 C:\\Windows\\System32\\drivers\\etc\\hosts；Android 用 AdAway（root 模式）添加为远程源
"""

CLASH_HEADER = """# 自定义屏蔽规则集（mihomo rule-provider，behavior: domain）
# 由 tools/make_hosts.py 根据 custom-blocklist.txt 生成，勿手改
"""

SR_HEADER = """# 成人域名拦截规则集（Shadowrocket/Surge 格式，RULE-SET 远程引用）
# 由 tools/make_hosts.py 自动生成，源：v2fly category-porn（MetaCubeX 转换）+ custom-blocklist.txt
"""

def base_domains(lines: list[str]) -> set[str]:
    domains: set[str] = set()
    for raw in lines:
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        # 规则集语法：+.example.com 表示域名及子域
        domain = line[2:] if line.startswith("+.") else line
        if " " in domain or "/" in domain or ":" in domain:
            continue  # 跳过 regex/full: 等无法表达的条目
        domains.add(domain)
    return domains

def main() -> None:
    porn = urlopen(SOURCE, timeout=60).read().decode("utf-8").splitlines()
    custom = CUSTOM.read_text(encoding="utf-8").splitlines() if CUSTOM.exists() else []
    porn_base, custom_base = base_domains(porn), base_domains(custom)

    hosts = sorted(porn_base | custom_base)
    HOSTS_OUT.write_text(
        f"{HOSTS_HEADER}# 共 {len(hosts)} 条\n\n" + "\n".join(f"127.0.0.1 {d}" for d in hosts) + "\n",
        encoding="utf-8",
    )

    clash = sorted(custom_base)
    CLASH_OUT.write_text(
        f"{CLASH_HEADER}payload:\n" + "".join(f"  - '+.{d}'\n" for d in clash),
        encoding="utf-8",
    )

    sr = sorted(porn_base | custom_base)
    SR_OUT.write_text(
        f"{SR_HEADER}# 共 {len(sr)} 条\n" + "".join(f"DOMAIN-SUFFIX,{d}\n" for d in sr),
        encoding="utf-8",
    )
    print(f"generated hosts={len(hosts)}, clash-custom={len(clash)}, shadowrocket={len(sr)}")

if __name__ == "__main__":
    main()
