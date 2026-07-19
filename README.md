# 🛡️ DNS 内容过滤配置手册

> 让成人网站在你的设备上打不开 —— 挂梯走 Clash 规则，裸连走 hosts。

![最后更新](https://img.shields.io/github/last-commit/aggjjfd/dns-filter)
![仓库大小](https://img.shields.io/github/repo-size/aggjjfd/dns-filter)
![名单条数](https://img.shields.io/badge/hosts%20名单-12904%20条-blue)

面向 Android 手机 / iPad / Windows PC 的成人内容过滤方案：两份名单 + 三端配置，零凭据、零服务器，内容每 24 小时自动更新。

## ✨ 特性

- ⚡ **两层接力**：挂梯时 Clash 规则 REJECT，裸连时 hosts 挡解析，互不干扰
- 🔄 **自动更新**：域名清单走远程规则集，每 24 小时拉新，日常零维护
- ✏️ **自定义名单**：`custom-blocklist.txt` 一处维护，两层共用
- 🔓 **零凭据**：仓库只含公开名单与补丁，无任何密钥/token

## 🚀 快速开始

首次配置约 30 分钟：

1. 💻 **Windows**：Clash Verge 订阅右键 → 编辑扩展配置 → 粘贴 [`filter.stoverride`](filter.stoverride) 内容，保存
2. 🤖 **Android**：装 FlClash → 订阅覆写 → 粘贴同上；AdAway（root 模式）远程源填：
   `https://raw.githubusercontent.com/aggjjfd/dns-filter/main/adult-hosts.txt`
3. 📱 **iPad**：浏览器打开下方链接一键安装远程覆写（Stash）：
   `https://link.stash.ws/install-override/raw.githubusercontent.com/aggjjfd/dns-filter/main/filter.stoverride`
4. 🧱 **Windows 裸连兜底**：管理员记事本把 `adult-hosts.txt` 追加进 `C:\Windows\System32\drivers\etc\hosts`，然后 `ipconfig /flushdns`
5. 🔑 GitHub 密码写纸上放公司（防自己冲动拆规则）

✅ **验证**：挂梯和裸连各访问一个成人站点，都应打不开。

## 📐 方案原理

| 场景 | 生效层 | 原理 |
| --- | --- | --- |
| 挂着梯子 | Clash 规则层 | 成人域名在进代理隧道前被 REJECT |
| 裸连 | hosts 层 | 系统解析先查 hosts，成人域名指向 0.0.0.0 |

> ⚠️ **诚实声明**：挂梯时 hosts 摸不到流量；机场 + 本地客户端的架构防不住铁了心绕过的人（换客户端/手配节点即可）。本方案的目标是"绕过需要 10 分钟冷静操作"、防止"随手关了忘开"。

## 📱 各设备详解

- **Windows（Clash Verge Rev）**：订阅卡片右键 → 编辑扩展配置 → 粘贴补丁。扩展独立于订阅存储，机场订阅更新不丢；多台 PC 走客户端自带 WebDAV 同步
- **Android（FlClash）**：⚠️ CMFA 无覆写机制，须用 FlClash。订阅 → 覆写 → 粘贴补丁，确保两条 `RULE-SET` 在 rules 最前
- **iPad（Stash）**：远程覆写数组自动前插，REJECT 天然置顶；补丁文件本身更新后在 Stash 手动刷新一次

三端共性：**"注入点"只配一次，"内容"由规则集 URL 每 24 小时自动更新**。

## 🌐 hosts 层（裸连兜底）

```bash
uv run tools/make_hosts.py   # 生成 adult-hosts.txt（约 1.29 万条）
```

- **Windows**：并入系统 hosts（见快速开始第 4 步）
- **Android**：AdAway 选 **root 模式**（❌ VPN 模式与 Clash 互斥）+ Magisk 开 systemless hosts
- ⛔ 手机**不要**配置"私人 DNS"（海外 DoT 853 端口实测不通，会断网）

## ✏️ 自定义名单

漏网站点写进 [`custom-blocklist.txt`](custom-blocklist.txt)（一行一个域名）：

```bash
uv run tools/make_hosts.py   # 同时更新 hosts 和 clash-custom-blocklist.yaml
git push                     # 三端 24h 内自动生效
```

## ✅ 误杀放行

补丁 rules 最前加一行 `- DOMAIN-SUFFIX,域名,DIRECT`（或指向代理）。误杀太多再整体换 AdGuard Family（免费控制台 100 条白名单规则）。

## 📁 仓库结构

```
├── filter.stoverride           # 🧩 过滤补丁（三端 Clash 覆写共用）
├── adult-hosts.txt             # 🌐 hosts 黑名单（自动生成，约 1.29 万条）
├── clash-custom-blocklist.yaml # 📋 自定义 Clash 规则集（自动生成）
├── custom-blocklist.txt        # ✏️ 自定义名单源文件（手改这里）
└── tools/make_hosts.py         # 🔧 名单生成脚本
```

## 🔧 维护

日常零维护。仅当修改 `custom-blocklist.txt` 后：重跑脚本 → push → Windows 重新合并一次 hosts。
