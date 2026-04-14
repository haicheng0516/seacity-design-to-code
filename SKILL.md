---
name: design-to-code
description: 设计图驱动代码生成 — 把 Figma/Sketch 等设计文件导入 Pencil，通过 MCP 读取精确设计数据，用并行 Agent 团队 6 阶段迭代实现 UI 代码，目标相似度 95%+。触发场景："还原设计稿"、"从 Figma 生成代码"、"Pencil 文件"、"UI 高保真实现"、"把设计图做成 App"。
---

# Design-to-Code Skill

这是一个基于 Pencil MCP 的设计图→代码自动化工作流。把 Figma/Sketch 等设计文件导入 Pencil 后，通过 6 阶段并行 Agent 流程，生成高精度的 iOS / Android / Web UI 代码。

## 适用场景

- 用户手里有设计稿（Figma/Sketch/XD），需要实现成 App
- 已有项目但 UI 还原度低，需要大幅提升相似度
- 新项目从 0 开始，根据设计图生成完整代码

## 前置条件检查

**开始前必须确认**：

1. 当前会话能看到 `mcp__pencil__*` 工具
2. 用户已经把设计文件导入 Pencil 并告诉了你文件路径
3. 工程构建工具可用（iOS 需要 Xcode，Android 需要 Gradle 等）

如果没有 Pencil MCP，引导用户阅读 `reference/setup_pencil.md` 完成一次性安装。

## 核心原则（必读）

1. **指挥官不下场** — 主 Agent 只负责任务拆分、调度、验证；具体代码由 subagent 写
2. **激进并行** — 每阶段用 4-6 个 Agent 同时工作，按模块切分避免冲突
3. **数据优先于视觉** — 用 `batch_get` 取 JSON 精确数值，不依赖截图目测
4. **审计与修复分离** — 独立 Agent 打分，避免"既是运动员又是裁判"
5. **先建设施再盖楼** — Phase 1 先把通用组件建完，屏幕开发时组件已稳定
6. **每阶段都要编译** — 每轮结束必跑 build + simulator 截图验证
7. **规格先行** — Phase 2 产出 spec 后 Phase 3 才能写代码，禁止凭感觉

## 6 阶段工作流

### Phase 0: 设计情报提取（1 Agent，串行）

**目标**：在写一行代码之前，把所有"要知道的事"都整理出来。

调用 `templates/phase0_intel.md` 中的 prompt，让 Agent：

- 列出所有屏幕（`batch_get` 无参数）
- 对每屏用 `readDepth:4-5` 取结构树
- 提取设计系统：
  - `color_tokens.json` — 所有颜色及其用法
  - `typography.json` — 所有字体/字号/字重组合
  - `spacing.json` — 所有 padding/gap/radius
  - `shadow_tokens.json` — 所有阴影
  - `component_catalog.json` — 识别的可复用组件（按钮/输入框/卡片）
- 用 `export_nodes` 导出所有图片资源
- 识别结构模式（例如"3 个状态共用同一布局"）
- 产出 `design_intel.md` 汇总报告

### Phase 1: 通用组件层建设（1 Agent）

**目标**：屏幕开发开始前，所有可复用组件必须就位。

调用 `templates/phase1_common.md`。Agent 基于 `design_intel.md`：

- 写入设计 token（Colors、Fonts、Spacing）
- 创建所有通用组件（按钮 / 输入框 / 下拉框 / 卡片 / 状态徽章 / 空状态 / 加载态等）
- 创建弹窗系统（同时搞定所有 Alert/Popup 变体，不要堆到最后）
- 创建 Base 控制器/基础导航/Tab 栏（如果是根架构）

### Phase 2: 屏幕规格生成（N Agents 并行，只读）

**目标**：每屏的精确规格文档，作为 Phase 3 的编码依据。

调用 `templates/phase2_spec.md`。按模块分配 Agent（通常 4-6 个），每个 Agent：

- 对自己负责的屏幕用 `batch_get readDepth:6 resolveVariables:true` 取完整数据
- 产出 `spec_{module}.md`，内含每个元素的：
  - 层级结构（tree）
  - 精确坐标 x/y/w/h
  - 圆角、填充色、描边
  - 字体、字号、字重、颜色
  - 阴影、透明度、混合模式
  - 注明使用哪些 Phase 1 的通用组件
  - 注明使用哪些 Phase 0 导出的图片资源

**指挥官必须审查**所有 spec，确保：
- 相同元素在多屏上用同一规格（一致性）
- 没有漏用通用组件（不要重复造轮子）

### Phase 3: 代码实现（N Agents 并行）

**目标**：把 spec 变成可运行的代码。

调用 `templates/phase3_impl.md`。每个 Agent 收到：
- 自己负责的 spec.md（精确数值）
- design_intel.md（设计系统）
- 通用组件清单（Phase 1 建好的）
- 资源清单（Phase 0 导出的）

**契约机制**：Agent 写代码时必须在关键赋值旁标注 spec 字段：
```objc
// spec: loan_confirm.amount_cell.pill_bg = #2A2A2A
container.backgroundColor = k16RGBColor(0x2A2A2A);
```

严禁凭感觉填数字。

### Phase 4: 差分审计（N Agents 并行，只读）

**目标**：找出代码和设计的真实差异，不是"觉得不像"。

调用 `templates/phase4_audit.md`。独立 Agent：

- 重新 `batch_get` 设计节点
- 读代码
- 字段级对比（颜色 hex、字号 pt、间距 px）
- 产出相似度分数 + Top N 修复项

## 评分标准建议：
- >95% = 达标
- 90-95% = 可接受，记录 nice-to-have
- <90% = 必须进入 Phase 5

### Phase 5: 最终攻坚（按需，N Agents 并行）

只针对 Phase 4 标记为必须修复的项。完成后重跑 Phase 4 验证。

### Phase 6: Build + Run 验证

- 编译（iOS: `xcodebuild`；Android: `gradle assemble`；Web: `npm build`）
- 启动模拟器/浏览器
- 对每屏截图
- 产出 `FINAL_REPORT.md`

## Agent 分工规则

按功能模块切分，**永远不要**按"按钮由A改、文字由B改"这种横向切分。推荐切法：

| 模块类型 | 示例 | Agent 数 |
|---------|------|---------|
| 认证流程 | Splash + Login | 1 |
| 主页 + Tab 架构 | Home + TabBar + Nav | 1 |
| 列表页 | Order / 消息 | 1 |
| 个人中心 | Me / Profile + Settings | 1 |
| 业务流程（多步） | KYC / 下单 / 充值 | 1 |
| 业务详情 | Loan / Product / Detail | 1 |
| 次要页面集合 | About / Contact / Feedback 等 | 1 |
| 弹窗/通用 | 在 Phase 1 处理 | 0（已在 P1） |

## 反模式（千万别做）

❌ 一个 Agent 搞定所有屏幕 → 结果 17% 相似度
❌ 只看截图对比 → 漏掉精确数值
❌ Phase 2 跳过直接写代码 → 结构错误，Phase 4 才发现
❌ 同 Agent 既修又审 → 盲点
❌ 跨模块修改文件 → 冲突、回滚风险
❌ 弹窗留到最后 → 通用组件不稳导致屏幕反复改
❌ 不编译就宣称完成 → 崩溃到用户面前

## 成功标准

- 整体相似度 ≥ 95%
- 编译零错误
- 主要交互流程可走通（push 跳转、弹窗、表单提交等）
- 所有通用组件可复用（不要复制粘贴）
- 代码遵守项目约定（View/Cell 单文件、命名规范等）

## 迭代预期

- 首次生成（Phase 0-3）：~85-90%
- 加 Phase 4 审计 + Phase 5 攻坚：~95%+
- 总 Agent 调度次数：8-15 次（取决于屏幕数量）

## 进一步阅读

- `templates/phase0_intel.md` 到 `phase5_polish.md` — 每 Phase 的 Agent prompt 模板
- `reference/setup_pencil.md` — Pencil MCP 一次性安装指南
- `reference/import_from_figma.md` — Figma 导入 Pencil 的步骤
- `reference/anti_patterns.md` — 踩坑经验（来自真实项目）
- `reference/ios_conventions.md` — iOS 项目约定（Masonry/Pod 等）
- `examples/seacity_loan_app.md` — 完整案例参考
