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

// Categorical slots 1-3. Radar polygons overlap, so every pair must be
// separable — only these three clear the all-pairs CVD floor on this surface.
const SERIES = ['#3987e5', '#d95926', '#199e70'];
const RADAR_MAX = 3;

function RadarChart({ models }) {
  const [hover, setHover] = useState(null);
  // Extra width for the axis labels: they sit outside the plot radius, and a
  // long one ("Terminal-Bench") overflows a box sized to the polygon alone.
  const W = 480, H = 400, cx = W / 2, cy = H / 2 + 6, R = 128;
  const n = BENCHMARKS.length;
  const pt = (i, frac) => {
    const a = (Math.PI * 2 * i) / n - Math.PI / 2;
    return [cx + Math.cos(a) * R * frac, cy + Math.sin(a) * R * frac];
  };

  return (
    <div className="flex flex-col lg:flex-row gap-8 items-center">
      <div className="relative shrink-0">
        <svg width={W} height={H} role="img" aria-label="模型能力雷达图">
          {[0.25, 0.5, 0.75, 1].map(f => (
            <polygon key={f} points={BENCHMARKS.map((_, i) => pt(i, f).join(',')).join(' ')}
              fill="none" stroke="#ffffff" strokeOpacity={f === 1 ? 0.16 : 0.07} strokeWidth="1" />
          ))}
          {BENCHMARKS.map((b, i) => {
            const [x, y] = pt(i, 1);
            const [lx, ly] = pt(i, 1.14);
            // Anchor away from the centre so long labels grow outward, not
            // across the plot or off the edge.
            const dx = lx - cx;
            const anchor = Math.abs(dx) < 12 ? 'middle' : dx > 0 ? 'start' : 'end';
            return (
              <g key={b.key}>
                <line x1={cx} y1={cy} x2={x} y2={y} stroke="#ffffff" strokeOpacity="0.07" strokeWidth="1" />
                <text x={lx} y={ly} textAnchor={anchor} dominantBaseline="middle"
                  fontSize="10" fill="#94a3b8" fontFamily="ui-monospace, monospace">{b.label}</text>
              </g>
            );
          })}
          {models.map((m, mi) => {
            const pts = BENCHMARKS.map((b, i) => pt(i, Math.min(1, (m[b.key] || 0) / b.max)));
            return (
              <g key={m.name}>
                <polygon points={pts.map(p => p.join(',')).join(' ')}
                  fill={SERIES[mi]} fillOpacity="0.13" stroke={SERIES[mi]} strokeWidth="2"
                  strokeLinejoin="round" />
                {pts.map((p, i) => (
                  <circle key={i} cx={p[0]} cy={p[1]} r="4.5" fill={SERIES[mi]}
                    stroke="#020617" strokeWidth="2"
                    onMouseEnter={() => setHover({ model: m.name, b: BENCHMARKS[i], v: m[BENCHMARKS[i].key], color: SERIES[mi] })}
                    onMouseLeave={() => setHover(null)} style={{ cursor: 'pointer' }} />
                ))}
              </g>
            );
          })}
        </svg>
        {hover && (
          <div className="absolute top-0 left-0 pointer-events-none bg-slate-900 border border-white/10 rounded-lg px-3 py-2 text-xs shadow-xl">
            <div className="flex items-center gap-2">
              <span className="inline-block w-2 h-2 rounded-full" style={{ background: hover.color }} />
              <span className="text-white font-medium">{hover.model}</span>
            </div>
            <div className="text-slate-400 mt-1">{hover.b.label}: <span className="font-mono text-slate-200">{hover.v}{hover.b.unit}</span></div>
            <div className="text-slate-600 text-[10px] mt-0.5">{hover.b.desc}</div>
          </div>
        )}
      </div>

      <div className="flex-1 w-full">
        <table className="w-full text-xs">
          <thead>
            <tr className="text-slate-500 border-b border-white/5">
              <th className="text-left pb-2 font-mono font-normal">指标</th>
              {models.map((m, i) => (
                <th key={m.name} className="text-right pb-2 font-medium">
                  <span className="inline-flex items-center gap-1.5">
                    <span className="inline-block w-2 h-2 rounded-full" style={{ background: SERIES[i] }} />
                    <span className="text-slate-200">{m.name}</span>
                  </span>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {BENCHMARKS.map(b => {
              const best = Math.max(...models.map(m => m[b.key] || 0));
              return (
                <tr key={b.key} className="border-b border-white/[0.03]">
                  <td className="py-2 text-slate-400">{b.label}<span className="text-slate-600 ml-1 text-[10px]">/{b.max}{b.unit}</span></td>
                  {models.map(m => (
                    <td key={m.name} className={`py-2 text-right font-mono ${m[b.key] === best ? 'text-white font-semibold' : 'text-slate-500'}`}>
                      {m[b.key]}{b.unit}
                    </td>
                  ))}
                </tr>
              );
            })}
          </tbody>
        </table>
        <p className="text-[10px] text-slate-600 mt-3">
          每轴按该指标满分归一化（AA Index /70，HLE /60，其余 /100）。加粗为该行最高分。
        </p>
      </div>
    </div>
  );
}

function PriceChart({ models }) {
  const [hover, setHover] = useState(null);
  const rows = [...models].sort((a, b) => a.priceIn - b.priceIn);
  const max = Math.max(...rows.map(m => m.priceOut), 1);
  const series = [
    { key: 'priceIn', label: '输入', color: SERIES[0] },
    { key: 'priceOut', label: '输出', color: SERIES[1] },
  ];

  return (
    <div>
      <div className="flex items-center gap-4 mb-5">
        {series.map(s => (
          <span key={s.key} className="flex items-center gap-1.5 text-xs text-slate-400">
            <span className="inline-block w-3 h-3 rounded-sm" style={{ background: s.color }} />
            {s.label} (USD / 百万 token)
          </span>
        ))}
      </div>
      <div className="space-y-4">
        {rows.map(m => (
          <div key={m.name} className="grid grid-cols-[130px_1fr] gap-3 items-center">
            <div className="text-xs text-slate-300 truncate text-right">{m.name}</div>
            <div className="space-y-[2px]">
              {series.map(s => (
                <div key={s.key} className="flex items-center gap-2 h-4"
                  onMouseEnter={() => setHover(`${m.name}-${s.key}`)} onMouseLeave={() => setHover(null)}>
                  <div className="flex-1 h-full bg-white/[0.03] rounded-sm overflow-hidden">
                    <div className="h-full transition-all"
                      style={{
                        width: `${Math.max((m[s.key] / max) * 100, 0.6)}%`,
                        background: s.color,
                        borderRadius: '2px 4px 4px 2px',
                        opacity: hover && hover !== `${m.name}-${s.key}` ? 0.45 : 1,
                      }} />
                  </div>
                  <span className="font-mono text-[10px] text-slate-400 w-14 shrink-0">${m[s.key].toFixed(2)}</span>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
      <p className="text-[10px] text-slate-600 mt-5">
        条形按输出价格上限统一缩放，两个系列共用同一坐标轴。最便宜的排在最前。
      </p>
    </div>
  );
}

function GuideView({ models }) {
  const pick = (label, why, test) => {
    const hits = models.filter(test).slice(0, 3);
    return hits.length ? { label, why, hits } : null;
  };
  const cases = [
    pick('写代码 / Agent', '看 SWE-bench 与 Terminal-Bench', m => m.swebench >= 80 || m.terminal >= 87),
    pick('预算优先', '按输入价格排序取最低', m => m.priceIn <= 0.55),
    pick('要能私有化部署', '仅开源权重的模型', m => m.type === 'Open'),
    pick('长文本 / 大上下文', '上下文窗口达到百万级', m => /M$/.test(m.context || '')),
    pick('中文内容创作', '标签含中文理解或内容创作', m => (m.tags || []).some(t => /中文|内容创作|创作/.test(t))),
    pick('数学 / 科研推理', '看 FrontierMath 与 GPQA', m => m.frontier >= 80 || m.gpqa >= 92),
  ].filter(Boolean);

  return (
    <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
      {cases.map(c => (
        <div key={c.label} className="rounded-xl border border-white/5 bg-white/[0.02] p-4">
          <h3 className="text-sm font-semibold text-white">{c.label}</h3>
          <p className="text-[11px] text-slate-500 mt-0.5 mb-3">{c.why}</p>
          <ul className="space-y-2">
            {c.hits.map((m, i) => (
              <li key={m.name} className="flex items-start gap-2">
                <span className="font-mono text-[10px] text-slate-600 mt-0.5">{i + 1}</span>
                <div className="min-w-0">
                  <div className="text-xs text-slate-200">{m.name}
                    <span className="text-slate-600 ml-1.5">{m.company}</span>
                  </div>
                  <div className="text-[10px] text-slate-500 truncate">{(m.strengths || [])[0]}</div>
                </div>
              </li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  );
}

function App() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [sortKey, setSortKey] = useState('aaIndex');
  const [sortDir, setSortDir] = useState('desc');
  const [filterType, setFilterType] = useState('all');
  const [expanded, setExpanded] = useState(null);
  const [activeTab, setActiveTab] = useState('ranking');
  const [radarPick, setRadarPick] = useState([]);

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

  // Empty pick = the top three by AA Index. Colour follows the entity's slot in
  // this list, so deselecting one must not repaint the others — hence the order
  // here is the selection order, not a re-sort.
  // Derived, not hardcoded: the tiles previously read "10+" for seven models
  // and credited Baichuan, which is not in the data.
  const stats = useMemo(() => {
    if (!models.length) return [];
    const ctx = s => {
      const m = /^([\d.]+)\s*([KM])?/.exec(s || '');
      return m ? parseFloat(m[1]) * (m[2] === 'M' ? 1e6 : m[2] === 'K' ? 1e3 : 1) : 0;
    };
    const open = models.filter(m => m.type === 'Open');
    const top = models.reduce((a, b) => (b.aaIndex > a.aaIndex ? b : a));
    const cheap = models.reduce((a, b) => (b.priceIn < a.priceIn ? b : a));
    const longest = models.reduce((a, b) => (ctx(b.context) > ctx(a.context) ? b : a));
    return [
      { label: '模型总数', value: String(models.length), sub: `${new Set(models.map(m => m.company)).size} 家厂商` },
      { label: '开源模型', value: String(open.length), sub: open.map(m => m.english || m.name).join(' / ') || '—' },
      { label: '最高AA Index', value: String(top.aaIndex), sub: top.name },
      { label: '最低价格', value: `$${cheap.priceIn}/M`, sub: cheap.name },
      { label: '最大上下文', value: longest.context, sub: longest.name },
    ];
  }, [models]);

  const radarModels = useMemo(() => {
    if (radarPick.length) return radarPick.map(n => models.find(m => m.name === n)).filter(Boolean);
    return [...models].sort((a, b) => b.aaIndex - a.aaIndex).slice(0, RADAR_MAX);
  }, [models, radarPick]);

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
          {stats.map((s,i) => (
            <div key={i} className="bg-slate-900/70 backdrop-blur-xl border border-white/5 rounded-xl p-4">
              <div className="text-xs text-slate-500 uppercase tracking-wider">{s.label}</div>
              <div className="text-xl font-bold text-white mt-1">{s.value}</div>
              <div className="text-[11px] text-slate-500 mt-0.5">{s.sub}</div>
            </div>
          ))}
        </div>

        <div className="flex items-center gap-1 mb-6 bg-white/5 rounded-xl p-1 w-fit">
          {[
            // Plain glyphs: Font Awesome was referenced but never loaded, so
            // the fa-* icons rendered as blank gaps beside each label.
            {id:'ranking',label:'性能排行',icon:'▤'},
            {id:'radar',label:'能力雷达',icon:'◈'},
            {id:'price',label:'价格对比',icon:'$'},
            {id:'guide',label:'选型指南',icon:'✦'},
          ].map(t => (
            <button key={t.id} onClick={() => setActiveTab(t.id)}
              className={`px-5 py-2 rounded-lg text-sm font-medium transition-all flex items-center gap-2 ${
                activeTab === t.id ? 'bg-white/10 text-white' : 'text-slate-500 hover:text-slate-300'
              }`}>
              <span aria-hidden="true" className="text-xs">{t.icon}</span>{t.label}
            </button>
          ))}
        </div>

        {(activeTab === 'ranking' || activeTab === 'price') && (
          <div className="flex gap-2 mb-6">
            {['all','Open','Closed'].map(t => (
              <button key={t} onClick={() => setFilterType(t)} className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${filterType === t ? 'bg-white/10 text-white' : 'text-slate-500 hover:text-slate-300'}`}>
                {t === 'all' ? '全部' : t === 'Open' ? '开源' : '闭源'}
              </button>
            ))}
          </div>
        )}

        {activeTab === 'radar' && (
          <div className="bg-slate-900/70 backdrop-blur-xl border border-white/5 rounded-2xl p-6 mb-6">
            <div className="flex flex-wrap items-center gap-2 mb-6">
              <span className="text-xs text-slate-500 mr-1">选择模型（最多 {RADAR_MAX} 个）:</span>
              {models.map(m => {
                const on = radarModels.some(x => x.name === m.name);
                const full = radarModels.length >= RADAR_MAX && !on;
                return (
                  <button key={m.name} disabled={full}
                    onClick={() => setRadarPick(p => {
                      const base = p.length ? p : radarModels.map(x => x.name);
                      return base.includes(m.name) ? base.filter(x => x !== m.name) : [...base, m.name].slice(0, RADAR_MAX);
                    })}
                    className={`px-3 py-1.5 rounded-lg text-xs transition-all border ${
                      on ? 'bg-white/10 text-white border-white/20'
                        : full ? 'text-slate-700 border-white/5 cursor-not-allowed'
                        : 'text-slate-400 border-white/5 hover:text-slate-200 hover:border-white/15'
                    }`}>
                    {on && <span className="inline-block w-2 h-2 rounded-full mr-1.5 align-middle"
                      style={{ background: SERIES[radarModels.findIndex(x => x.name === m.name)] }} />}
                    {m.name}
                  </button>
                );
              })}
            </div>
            {radarModels.length ? <RadarChart models={radarModels} />
              : <p className="text-sm text-slate-500 py-8 text-center">至少选择一个模型。</p>}
          </div>
        )}

        {activeTab === 'price' && (
          <div className="bg-slate-900/70 backdrop-blur-xl border border-white/5 rounded-2xl p-6 mb-6">
            {sorted.length ? <PriceChart models={sorted} />
              : <p className="text-sm text-slate-500 py-8 text-center">没有符合条件的模型。</p>}
          </div>
        )}

        {activeTab === 'guide' && (
          <div className="mb-6"><GuideView models={models} /></div>
        )}

        {activeTab === 'ranking' && (
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
        )}

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
