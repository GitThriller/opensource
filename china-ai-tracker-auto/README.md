# 国内AI大模型全景对比 - 自动更新版

本项目位于 `opensource` 仓库的子目录中，工作流文件在仓库根目录的
`.github/workflows/china-ai-tracker.yml`（GitHub Actions 只读取根目录的
`.github/workflows/`，放在子目录里不会被触发）。

## 本地运行

不需要 GitHub，也不需要联网部署。打开终端：

```bash
cd /Users/egl/Git/opensource/china-ai-tracker-auto
npm start
```

等到出现 `Compiled successfully`，再打开 http://localhost:3000 。

**终端窗口要一直开着** —— 关掉窗口或按 Ctrl+C，本地网站就停了。
`localhost` 只是你自己电脑上跑的服务，和 GitHub 无关；重启电脑后要重新执行
上面的命令。

首次在新机器上运行需要先装依赖：

```bash
npm install
pip3 install requests feedparser
```

## 手动刷新数据

```bash
python3 scripts/fetch_data.py
```

写入 `public/data/models.json`。放在 `public/` 下，构建时才会被复制进 `build/`。

## 线上部署

部署到 GitHub Pages 后，任何设备打开网址即可访问，不需要本地跑任何东西：

**https://gitthriller.github.io/opensource**

首次需要手动开启一次：仓库 → **Settings** → **Pages** → Source 选
**GitHub Actions**。（工作流自带的 `GITHUB_TOKEN` 权限不足以创建 Pages 站点，
必须手动开这一次。）

之后每天北京时间早上 6 点自动刷新并重新部署。手动触发：
**Actions** → **China AI Tracker — Daily Update** → **Run workflow**。

## 数据说明

| 数据 | 来源 | 是否实时 |
|---|---|---|
| 新闻动态 | 量子位 / 雷锋网 / 36氪 RSS | 每次运行实时抓取 |
| 基准分数 | 人工整理的快照 | 否，除非配置 API key |

基准分数默认是 `scripts/fetch_data.py` 里手工维护的快照，页面底部会注明快照
日期。若要改成实时抓取 Artificial Analysis 的 AA Index，在仓库
**Settings → Secrets and variables → Actions** 添加 `AA_API_KEY`。

页面显示的来源只反映实际请求过的服务，不会把未抓取的数据标为某个来源。

## 自定义数据源

编辑 `scripts/fetch_data.py`：
- `FEEDS` —— 新增/替换 RSS 源（注意 jiqizhixin.com/rss 已失效，会 302 跳到
  营销页，没有内容）
- `SNAPSHOT` —— 模型列表与基准分数，改动后记得同步更新 `SNAPSHOT_DATE`

## 技术架构

```
GitHub Actions (每天 06:00 UTC+8)
    ↓
scripts/fetch_data.py → public/data/models.json
    ↓
React 构建 (CRA) → build/
    ↓
upload-pages-artifact → deploy-pages
    ↓
https://gitthriller.github.io/opensource
```

## License
MIT
