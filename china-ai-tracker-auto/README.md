# 国内AI大模型全景对比 - 自动更新版

## 快速开始（3步搞定）

### 1. Fork 这个仓库
点击 GitHub 右上角的 **Fork** 按钮。

### 2. 启用 GitHub Pages
- 进入你 fork 的仓库 → **Settings** → **Pages**
- Source 选择 **GitHub Actions**
- 等待首次部署（2-3分钟）

### 3. 启用自动更新
- 进入 **Actions** 标签
- 点击 **Daily Data Update**
- 点击 **Enable workflow**

✅ 完成！每天北京时间 **早上6点** 自动刷新数据。

## 手动刷新
Actions → Daily Data Update → **Run workflow**

## 自定义数据源
编辑 `scripts/fetch_data.py` 添加：
- 新的 RSS 源
- 新的模型数据
- 新的 benchmark 来源

## 技术架构
```
GitHub Actions (每天 06:00 UTC+8)
    ↓
Python 脚本抓取数据 → data/models.json
    ↓
React 构建 → GitHub Pages 部署
    ↓
用户访问 https://yourname.github.io/china-ai-tracker
```

## License
MIT
