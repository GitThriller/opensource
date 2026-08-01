#!/usr/bin/env python3
"""Build public/data/models.json for the dashboard.

Two kinds of data end up in that file and they are NOT equally trustworthy,
so each is labelled in `meta`:

  news       — fetched live from RSS on every run.
  benchmarks — fetched from the Artificial Analysis API only when AA_API_KEY
               is set. Without a key we fall back to the curated snapshot
               below, and mark it as such so the page can say so.

The snapshot is hand-maintained. Update SNAPSHOT_DATE when you edit it.
"""
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

import requests

# public/ so Create React App copies the file into build/
OUT = Path(__file__).resolve().parent.parent / "public" / "data" / "models.json"

SNAPSHOT_DATE = "2026-08-01"

AA_API = "https://artificialanalysis.ai/api/v2/data/llms/models"

# Verified reachable 2026-08-01. jiqizhixin.com/rss now 302s to a marketing
# page and serves no feed, so it is deliberately not listed here.
FEEDS = [
    ("量子位", "https://www.qbitai.com/feed"),
    ("雷锋网", "https://www.leiphone.com/feed"),
    ("36氪", "https://36kr.com/feed"),
]

# Hand-curated. These are NOT live figures — see module docstring.
SNAPSHOT = [
    {"name":"Kimi K3","company":"月之暗面","english":"Moonshot AI","type":"Open","params":"2.8T","context":"1M","priceIn":3.00,"priceOut":15.00,"aaIndex":57.1,"swebench":67.5,"terminal":88.3,"gpqa":93.5,"frontier":81.2,"mmmu":81.6,"hle":54.0,"highlight":"2.8T参数·#4 AA Index·7月27日开源","tags":["长文本","编程","多模态","开源","Agent"],"strengths":["200万字上下文","Agent集群调度","中文语音","性价比"],"weaknesses":["速度偏慢","纯知识任务一般"],"ecosystem":"Kimi Code, Kimi APP","openDate":"2026-07-27"},
    {"name":"Qwen 3.7 Max","company":"阿里巴巴","english":"Alibaba","type":"Closed","params":"未公开","context":"1M","priceIn":0.50,"priceOut":2.00,"aaIndex":55.0,"swebench":82.0,"terminal":87.9,"gpqa":92.0,"frontier":84.9,"mmmu":79.0,"hle":52.0,"highlight":"Arena 91分·国产最高·LiveCode 91.6%","tags":["编程","智能体","多语言","电商"],"strengths":["长时间自主Agent","编程竞赛","中文编程","性价比极高"],"weaknesses":["创意写作一般","多模态非顶尖"],"ecosystem":"通义千问APP, 钉钉, 阿里云","openDate":"-"},
    {"name":"GLM 5.2 (Max)","company":"智谱AI","english":"Zhipu AI","type":"Open","params":"未公开","context":"128K","priceIn":1.53,"priceOut":6.00,"aaIndex":53.0,"swebench":82.0,"terminal":87.9,"gpqa":92.0,"frontier":84.9,"mmmu":78.0,"hle":50.0,"highlight":"智能体榜#9·Bash恢复快","tags":["编程","数据分析","工具调用","开源"],"strengths":["代码解释器强大","Excel可视化","工具调用","清华系技术"],"weaknesses":["创意任务弱","移动端卡顿","长对话逻辑断层"],"ecosystem":"智谱清言APP, ChatGLM","openDate":"-"},
    {"name":"DeepSeek V4-Pro","company":"深度求索","english":"DeepSeek","type":"Open","params":"未公开","context":"128K","priceIn":0.27,"priceOut":1.10,"aaIndex":44.3,"swebench":80.6,"terminal":79.3,"gpqa":88.4,"frontier":75.6,"mmmu":75.0,"hle":48.0,"highlight":"MIT开源·$0.27/M·性价比之王","tags":["开源","编程","数学","极低价"],"strengths":["数学推理顶尖(96.8%)","编程成本极低(0.22元/题)","可私有化部署","算法实现"],"weaknesses":["中文创意一般","工程落地需把关","多模态弱"],"ecosystem":"DeepSeek API, 开源社区","openDate":"-"},
    {"name":"豆包 1.5 Pro","company":"字节跳动","english":"ByteDance","type":"Closed","params":"未公开","context":"256K","priceIn":0.50,"priceOut":2.00,"aaIndex":52.0,"swebench":72.0,"terminal":75.0,"gpqa":85.0,"frontier":70.0,"mmmu":72.0,"hle":45.0,"highlight":"中文推理#1(港大测评)·抖音生态","tags":["中文理解","内容创作","语音","社交"],"strengths":["中文语境理解顶尖","短视频内容生成","青年语言风格","语音交互流畅","性价比极高"],"weaknesses":["专业场景薄弱","知识库广度有限","企业级功能不完善","高端推理有限"],"ecosystem":"豆包APP, 抖音, 飞书, 剪映","openDate":"-"},
    {"name":"文心一言 5.0","company":"百度","english":"Baidu","type":"Closed","params":"未公开","context":"128K","priceIn":0.80,"priceOut":3.20,"aaIndex":48.0,"swebench":74.0,"terminal":70.0,"gpqa":86.0,"frontier":68.0,"mmmu":74.0,"hle":42.0,"highlight":"中文语义理解顶尖·搜索实时·古诗词","tags":["中文创作","搜索","政府合规","教育"],"strengths":["中文语义准确率最高","接入百度搜索实时信息","古诗词/方言精准","政府公文适配"],"weaknesses":["长文本易丢细节","逻辑推理偶尔跳跃","专业知识更新延迟","复杂代码精度不足"],"ecosystem":"文心一言APP, 百度系产品","openDate":"-"},
    {"name":"讯飞星火 4.0 Ultra","company":"科大讯飞","english":"iFlytek","type":"Closed","params":"未公开","context":"64K","priceIn":1.00,"priceOut":4.00,"aaIndex":47.0,"swebench":70.0,"terminal":68.0,"gpqa":82.0,"frontier":65.0,"mmmu":70.0,"hle":40.0,"highlight":"语音交互<0.8秒·方言识别顶尖·教育","tags":["语音","教育","智能硬件","方言"],"strengths":["语音响应<0.8秒","方言识别行业领先","教育知识图谱完善","智能硬件集成"],"weaknesses":["文本生成多样性不足","复杂逻辑处理需加强","跨平台适配待优化"],"ecosystem":"讯飞星火APP, 学习机, 智能耳机","openDate":"-"},
]


def fetch_news(limit_per_feed=5):
    """Live headlines. A dead feed is skipped, never fatal."""
    import feedparser

    items, ok = [], []
    for label, url in FEEDS:
        try:
            parsed = feedparser.parse(url)
            if parsed.bozo and not parsed.entries:
                print(f"  ! {label}: no entries ({parsed.bozo_exception})", file=sys.stderr)
                continue
            for e in parsed.entries[:limit_per_feed]:
                items.append({
                    "title": e.get("title", "").strip(),
                    "link": e.get("link", ""),
                    "source": label,
                    "published": e.get("published", ""),
                })
            ok.append(label)
            print(f"  ok {label}: {len(parsed.entries[:limit_per_feed])} items")
        except Exception as exc:  # a flaky feed must not fail the run
            print(f"  ! {label}: {exc}", file=sys.stderr)
    return items, ok


def fetch_benchmarks():
    """Live AA Index, or (None, reason) when unavailable.

    Returns a {model_name_lower: aaIndex} map on success.
    """
    key = os.environ.get("AA_API_KEY")
    if not key:
        return None, "AA_API_KEY not set"
    try:
        r = requests.get(AA_API, headers={"x-api-key": key}, timeout=30)
        if r.status_code == 401:
            return None, "AA_API_KEY rejected (401)"
        r.raise_for_status()
        payload = r.json()
        rows = payload.get("data", payload if isinstance(payload, list) else [])
        scores = {}
        for row in rows:
            name = (row.get("name") or row.get("model_name") or "").strip().lower()
            idx = row.get("artificial_analysis_intelligence_index")
            if name and isinstance(idx, (int, float)):
                scores[name] = float(idx)
        if not scores:
            return None, "AA response contained no index values"
        return scores, "ok"
    except Exception as exc:
        return None, f"AA request failed: {exc}"


def generate():
    print("Fetching news...")
    news, live_feeds = fetch_news()

    print("Fetching benchmarks...")
    scores, bench_note = fetch_benchmarks()

    models = [dict(m) for m in SNAPSHOT]
    matched = 0
    if scores:
        for m in models:
            hit = scores.get(m["name"].strip().lower())
            if hit is not None:
                m["aaIndex"] = hit
                m["aaIndexLive"] = True
                matched += 1
        print(f"  ok AA Index applied to {matched}/{len(models)} models")
    else:
        print(f"  .. benchmarks: curated snapshot ({bench_note})")

    benchmarks_live = bool(scores) and matched > 0
    data = {
        "meta": {
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "benchmarks": {
                "live": benchmarks_live,
                "note": bench_note,
                "snapshot_date": SNAPSHOT_DATE,
                "label": (
                    "AA Index 实时获取自 artificialanalysis.ai"
                    if benchmarks_live
                    else f"基准分数为 {SNAPSHOT_DATE} 人工整理的快照，非实时数据"
                ),
            },
            "news": {
                "live": bool(news),
                "sources": live_feeds,
            },
            # Only claim what this script actually contacted.
            "sources": (
                (["artificialanalysis.ai"] if benchmarks_live else []) + list(live_feeds)
            ),
        },
        "models": models,
        "news": news,
    }

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Wrote {OUT}")
    print(f"  models={len(models)} news={len(news)} benchmarks_live={benchmarks_live}")


if __name__ == "__main__":
    generate()
