---
name: perf
description: Profiles the codebase for performance issues and proposes concrete optimizations with impact estimates. Use when diagnosing slow queries, bundle bloat, memory leaks, or rendering bottlenecks.
---

Profile the codebase for performance issues and propose concrete optimizations.

## Analysis Areas

### Frontend (if applicable)
- **Bundle size** — Large imports, tree-shaking failures, duplicate dependencies
- **Render performance** — Unnecessary re-renders, missing memoization
- **Loading** — Unoptimized images, missing lazy loading, render-blocking resources
- **Core Web Vitals** — LCP, FID/INP, CLS impact assessment

### Backend
- **Database queries** — N+1 queries, missing indexes, full table scans
- **Memory** — Leaks, unbounded caches, large object retention
- **Concurrency** — Blocking operations, missing async/await
- **I/O** — Unnecessary file reads, unstreamed responses, missing connection pooling

### API Layer
- **Response size** — Over-fetching, missing pagination
- **Caching** — Missing cache headers, redundant fetches
- **Batching** — Sequential requests that could be parallelized

## Rules

- Measure before optimizing — don't guess at bottlenecks
- Focus on the critical path first
- Only suggest optimizations with meaningful impact
- Never sacrifice readability for micro-optimizations

---
Nox