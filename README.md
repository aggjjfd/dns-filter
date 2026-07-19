# DNS 内容过滤配置手册

> 目标：Android 手机、iPad、Windows PC 过滤成人内容，冲动时不能随手关掉。
> 依据：`.scratch/handbook/research-dns-providers.md`（三轮调研，均附官方来源）。

## 一分钟版

两份名单 + 三端配置：挂梯时 Clash 规则 REJECT，裸连时 hosts 挡解析，让成人网站在这三台设备上打不开。

首次配置（约 30 分钟）：

1. push 本仓库到 GitHub，把 `dns/filter.stoverride` 里的 `<你的用户名>/<仓库>` 改成真实路径，再 push。
2. **Windows**：Clash Verge 订阅右键 → 编辑扩展配置 → 粘贴 `dns/filter.stoverride` 内容，保存。
3. **Android**：装 FlClash → 订阅覆写 → 粘贴同上；AdAway（root 模式）远程源填 `dns/adult-hosts.txt` 的 raw 链接。
4. **iPad**：浏览器打开 `https://link.stash.ws/install-override/raw.githubusercontent.com/<你的用户名>/<仓库>/main/dns/filter.stoverride` 一键安装。
5. **Windows 裸连兜底**：管理员记事本把 `dns/adult-hosts.txt` 追加进 `C:\Windows\System32\drivers\etc\hosts`，然后 `ipconfig /flushdns`。
6. GitHub 密码写纸上放公司。

验证：挂梯和裸连各访问一个成人站点，都应打不开。之后零维护；加新站点见「自定义名单」。

## 方案

两层，按场景接力、互不干扰：

- **挂梯时 → Clash 规则层**：`category-porn` 规则集 REJECT。机场订阅留客户端本地，过滤补丁（无凭据）托管 GitHub。
- **裸连时 → hosts 层**：同一份名单生成的 hosts 文件挡解析。

边界（诚实声明）：挂梯时 hosts 摸不到流量；机场 + 本地客户端的架构防不住铁了心绕过的人（换客户端/手配节点即可），本方案的目标是"绕过需要 10 分钟冷静操作"、防止"随手关了忘开"。真正的主防线是铁律（手机出卧室），本层只是辅助。光猫层已放弃（移动光猫可被运营商远程复位，最不可控）。

## 一、Clash 规则层（主战场）

补丁文件：`dns/filter.stoverride`（rules 置顶 REJECT + 两个远程规则集 + DNS 指向 CleanBrowsing 过滤 DoH）。三端接法：

- **Windows（Clash Verge Rev）**：订阅卡片右键 → 编辑扩展配置 → 粘贴补丁内容，保存。扩展独立于订阅存储，机场订阅更新不丢；多台 PC 用客户端自带的 WebDAV 同步。
- **Android（FlClash）**：CMFA 无覆写机制，须用 FlClash。订阅 → 覆写 → 粘贴补丁内容，确保两条 `RULE-SET` 在 rules 最前。多设备走 WebDAV 同步。
- **iPad（Stash）**：仓库 push 后，浏览器打开 `https://link.stash.ws/install-override/raw.githubusercontent.com/<你的用户名>/<仓库>/main/dns/filter.stoverride` 一键安装远程覆写。Stash 覆写数组自动前插，REJECT 天然置顶；补丁更新后在 Stash 里手动刷新覆写一次（自动更新官方未明确）。

三端共性：**"注入点"只配这一次，"内容"（域名清单）由规则集 URL 每 24 小时自动更新**。

## 二、hosts 层（裸连兜底）

生成：仓库根目录跑 `uv run dns/tools/make_hosts.py` → `dns/adult-hosts.txt`（约 1.29 万条）。

- **Windows**：管理员记事本打开 `C:\Windows\System32\drivers\etc\hosts`，全文追加 `adult-hosts.txt`，保存后执行 `ipconfig /flushdns`。
- **Android**：AdAway（F-Droid）选 **root 模式**（VPN 模式与 Clash 互斥，禁用）+ Magisk 开 systemless hosts，远程源指向 `adult-hosts.txt` 的 GitHub raw 链接，应用。
- 手机**不要**配置"私人 DNS"（海外 DoT 853 端口实测不通，会断网）。

## 自定义名单

漏网站点写进 `dns/custom-blocklist.txt`（一行一个域名）→ 重跑脚本 → 同时更新 hosts 和 `dns/clash-custom-blocklist.yaml` → push 后三端自动生效（Windows 的 hosts 需手动重新合并一次，AdAway 自动拉新）。

## 误杀放行

补丁 rules 最前加一行 `- DOMAIN-SUFFIX,域名,DIRECT`（或指向代理）。误杀太多再整体换 AdGuard Family（免费控制台 100 条白名单规则，地址见调研笔记）。

## 摩擦与维护

- 托管仓库的 GitHub 密码写纸上放公司；机场订阅 URL 只存在于客户端本地，不上传任何地方（含在线订阅转换服务）。
- 日常零维护；只有改 `custom-blocklist.txt` 时需要：重跑脚本 → push → Windows 重新合并 hosts。
