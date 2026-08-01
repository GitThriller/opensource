import React, { useState, useEffect, useMemo } from 'react';

const BENCHMARKS = [
  { key: "aaIndex", label: "AA Index", desc: "Artificial Analysis综合评分", max: 70, unit: "分" },
  { key: "swebench", label: "SWE-bench", desc: "真实GitHub bug修复", max: 100, unit: "%" },
  { key: "terminal", label: "Terminal-Bench", desc: "Agent终端任务", max: 100, unit: "%" },
  { key: "gpqa", label: "GPQA Diamond", desc: "PhD级科学问答", max: 100, unit: "%" },
  { key: "frontier", label: "FrontierMath", desc: "研究级数学", max: 100, unit: "%" },
  { key: "mmmu", label: "MMMU-Pro", desc: "多模态大学题", max: 100, unit: "%" },
  { key: "hle", label: "HLE", desc: "人类最后考试", max: 60, unit: "%" },
];

function App() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [sortKey, setSortKey] = useState('aaIndex');
  const [sortDir, setSortDir] = useState('desc');
  const [filterType, setFilterType] = useState('all');
  const [expanded, setExpanded] = useState(null);

  useEffect(() => {
    fetch('./data/models.json')
      .then(r => r.ok ? r.json() : Promise.reject())
      .then(d => { setData(d); setLoading(false); })
      .catch(() => { setData({ meta: { generated_at: new Date().toISOString() }, models: [] }); setLoading(false); });
  }, []);

  // Every hook must run on every render — keep useMemo above the loading
  // branch, or the hook count changes once data arrives (React error #310).
  const models = data?.models || [];
  const news = data?.news || [];
  const benchmarkNote = data?.meta?.benchmarks?.label || '';
  const sources = data?.meta?.news?.sources || [];
  const sorted = useMemo(() => {
    let d = [...models];
    if (filterType !== 'all') d = d.filter(m => m.type === filterType);
    return d.sort((a, b) => sortDir === 'desc' ? b[sortKey] - a[sortKey] : a[sortKey] - b[sortKey]);
  }, [models, sortKey, sortDir, filterType]);

  if (loading) return <div className="min-h-screen flex items-center justify-center text-slate-500">加载中...</div>;

  const handleSort = (key) => {
    if (sortKey === key) setSortDir(d => d === 'desc' ? 'asc' : 'desc');
    else { setSortKey(key); setSortDir('desc'); }
  };

  const getScoreColor = (score, max) => {
    const pct = score / max;
    if (pct >= 0.9) return 'text-emerald-400';
    if (pct >= 0.8) return 'text-amber-400';
    if (pct >= 0.7) return 'text-blue-400';
    return 'text-slate-400';
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-300 pb-12">
      <header className="bg-slate-900/70 backdrop-blur-xl border-b border-white/5 sticky top-0 z-50">
        <div className="max-w-[1600px] mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-red-600 to-orange-500 flex items-center justify-center shadow-lg">
                <span className="text-white font-bold text-lg">中</span>
              </div>
              <div>
                <h1 className="text-xl font-bold text-white tracking-tight">国内AI大模型 <span className="text-red-400">全景对比</span></h1>
                <p className="text-[10px] text-slate-500 font-mono">AUTO-UPDATED DAILY // v2.0</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <div className="text-xs text-slate-500">
                更新: {data?.meta?.generated_at ? new Date(data.meta.generated_at).toLocaleString('zh-CN', {month:'short',day:'numeric',hour:'2-digit',minute:'2-digit'}) : 'N/A'}
              </div>
              <span className="px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 text-[10px] font-medium border border-emerald-500/20">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 inline-block mr-1 animate-pulse"></span>
                自动刷新
              </span>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-[1600px] mx-auto px-6 py-6">
        <div className="grid grid-cols-2 lg:grid-cols-5 gap-4 mb-6">
          {[
            {label:"模型总数",value:"10+",sub:"主流厂商"},
            {label:"开源模型",value:"4",sub:"Kimi/DeepSeek/GLM/Baichuan"},
            {label:"最高AA Index",value:"57.1",sub:"Kimi K3 (#4全球)"},
            {label:"最低价格",value:"$0.27/M",sub:"DeepSeek V4-Pro"},
            {label:"最大上下文",value:"200万字",sub:"Kimi K3"},
          ].map((s,i) => (
            <div key={i} className="bg-slate-900/70 backdrop-blur-xl border border-white/5 rounded-xl p-4">
              <div className="text-xs text-slate-500 uppercase tracking-wider">{s.label}</div>
              <div className="text-xl font-bold text-white mt-1">{s.value}</div>
              <div className="text-[11px] text-slate-500 mt-0.5">{s.sub}</div>
            </div>
          ))}
        </div>

        <div className="flex items-center gap-1 mb-6 bg-white/5 rounded-xl p-1 w-fit">
          {[
            {id:'ranking',label:'性能排行',icon:'fa-trophy'},
            {id:'radar',label:'能力雷达',icon:'fa-bullseye'},
            {id:'price',label:'价格对比',icon:'fa-tags'},
            {id:'guide',label:'选型指南',icon:'fa-compass'},
          ].map(t => (
            <button key={t.id} className="px-5 py-2 rounded-lg text-sm font-medium transition-all text-slate-500 hover:text-slate-300 flex items-center gap-2">
              <i className={`fa-solid ${t.icon}`}></i>{t.label}
            </button>
          ))}
        </div>

        <div className="flex gap-2 mb-6">
          {['all','Open','Closed'].map(t => (
            <button key={t} onClick={() => setFilterType(t)} className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${filterType === t ? 'bg-white/10 text-white' : 'text-slate-500 hover:text-slate-300'}`}>
              {t === 'all' ? '全部' : t === 'Open' ? '开源' : '闭源'}
            </button>
          ))}
        </div>

        <div className="bg-slate-900/70 backdrop-blur-xl border border-white/5 rounded-2xl p-6">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="text-left text-[11px] font-mono text-slate-500 uppercase tracking-wider border-b border-white/5">
                  <th className="pb-3 pl-2">排名</th>
                  <th className="pb-3">模型</th>
                  <th className="pb-3">公司</th>
                  <th className="pb-3">类型</th>
                  {BENCHMARKS.map(b => (
                    <th key={b.key} className="pb-3 cursor-pointer hover:text-white transition-colors" onClick={() => handleSort(b.key)}>
                      <div className="flex items-center gap-1">
                        {b.label}
                        {sortKey === b.key && <span className={`text-xs ${sortDir === 'desc' ? 'text-amber-400' : 'text-slate-600'}`}>▼</span>}
                      </div>
                    </th>
                  ))}
                  <th className="pb-3">价格</th>
                  <th className="pb-3 pr-2">详情</th>
                </tr>
              </thead>
              <tbody>
                {sorted.map((m, i) => (
                  <React.Fragment key={m.name}>
                    <tr className="border-b border-white/[0.02] text-sm cursor-pointer hover:bg-amber-500/5 transition-colors" onClick={() => setExpanded(expanded === i ? null : i)}>
                      <td className="py-3 pl-2"><span className={`text-xs font-mono font-bold ${i < 3 ? 'text-amber-400' : i < 6 ? 'text-orange-400' : 'text-slate-600'}`}>#{i + 1}</span></td>
                      <td className="py-3">
                        <div className="flex items-center gap-2">
                          <span className="text-white font-medium">{m.name}</span>
                          {m.name === 'Kimi K3' && <span className="text-[9px] px-1.5 py-0.5 rounded bg-red-500/20 text-red-400 font-bold">NEW</span>}
                        </div>
                      </td>
                      <td className="py-3 text-slate-400">{m.company}</td>
                      <td className="py-3">
                        <span className={`text-[10px] px-2 py-0.5 rounded-full ${m.type === 'Open' ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-blue-500/10 text-blue-400 border border-blue-500/20'}`}>{m.type === 'Open' ? '开源' : '闭源'}</span>
                      </td>
                      {BENCHMARKS.map(b => (
                        <td key={b.key} className="py-3">
                          <div className="flex items-center gap-2">
                            <span className={`font-mono font-semibold text-xs ${getScoreColor(m[b.key], b.max)}`}>{m[b.key]}{b.unit}</span>
                            <div className="w-10 h-1.5 rounded-full bg-white/5 overflow-hidden hidden xl:block">
                              <div className="h-full rounded-full" style={{width:`${(m[b.key]/b.max)*100}%`,backgroundColor:m[b.key]>=90?'#10b981':m[b.key]>=80?'#f59e0b':'#3b82f6'}}></div>
                            </div>
                          </div>
                        </td>
                      ))}
                      <td className="py-3"><span className="font-mono text-xs text-slate-300">${m.priceIn}</span></td>
                      <td className="py-3 pr-2"><span className="text-slate-600 text-xs">{expanded === i ? '▲' : '▼'}</span></td>
                    </tr>
                    {expanded === i && (
                      <tr><td colSpan="12" className="py-4 px-4 bg-white/[0.02]">
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
                          <div><span className="text-amber-400 font-medium">亮点:</span> <span className="text-slate-300">{m.highlight}</span></div>
                          <div><span className="text-emerald-400 font-medium">优势:</span> <span className="text-slate-400">{m.strengths.join(' · ')}</span></div>
                          <div><span className="text-red-400 font-medium">短板:</span> <span className="text-slate-400">{m.weaknesses.join(' · ')}</span></div>
                        </div>
                        <div className="mt-2 text-[10px] text-slate-500">生态: {m.ecosystem}</div>
                      </td></tr>
                    )}
                  </React.Fragment>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {news.length > 0 && (
          <section className="mt-8">
            <h2 className="text-sm font-semibold text-slate-300 mb-3">最新动态</h2>
            <div className="grid gap-2 md:grid-cols-2 lg:grid-cols-3">
              {news.map((n, i) => (
                <a
                  key={i}
                  href={n.link}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="block rounded-lg border border-white/5 bg-slate-900/50 p-3 hover:border-amber-400/30 transition-colors"
                >
                  <p className="text-xs text-slate-300 leading-relaxed">{n.title}</p>
                  <p className="text-[10px] text-slate-600 mt-1.5 font-mono">{n.source}</p>
                </a>
              ))}
            </div>
          </section>
        )}

        <footer className="mt-8 pt-6 border-t border-white/5 text-center">
          <p className="text-xs text-slate-600">
            {benchmarkNote && <>基准数据: {benchmarkNote} | </>}
            {sources.length > 0 && <>新闻来源: {sources.join(', ')} | </>}
            <a href="https://github.com/GitThriller/opensource/tree/main/china-ai-tracker-auto" className="text-slate-500 hover:text-amber-400 ml-1">GitHub Source</a>
          </p>
        </footer>
      </main>
    </div>
  );
}

export default App;
