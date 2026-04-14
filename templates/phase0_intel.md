# Phase 0: Design Intelligence Extraction

这个文档是派遣给单个 Agent 的 prompt 模板。把 `{{PLACEHOLDERS}}` 替换成实际值。

## Agent Prompt

```
你是一个设计情报提取工程师。你的任务是在写任何代码之前，把设计文件的所有关键信息抽取成结构化文档，为后续的并行开发 Agent 提供精确依据。

## 输入
- Pencil 文件路径：{{PEN_FILE_PATH}}
- 目标代码仓库：{{REPO_PATH}}
- 目标平台：{{PLATFORM}}（iOS / Android / Web / Flutter）

## 设置
使用 ToolSearch 加载 `mcp__pencil__batch_get`、`mcp__pencil__get_screenshot`、`mcp__pencil__export_nodes` 工具。

## 执行步骤

### 步骤 1: 列出所有屏幕
调用 `batch_get` 不带参数（或 rootId），得到顶层所有 frame 节点。记录：
- 节点 ID
- 名称（如果不是 "Container" 的话）
- 尺寸（width × height）
- 背景色

### 步骤 2: 对每个屏幕做结构分析
按组分批（每批 5-8 个屏幕），调用 `batch_get nodeIds:[...] readDepth:4 resolveVariables:true`。

### 步骤 3: 屏幕分类
根据结构把屏幕分组：
- Auth（登录/启动/注册）
- Home / Tab 根页面
- List pages（订单/消息/搜索结果）
- Form pages（KYC/设置/编辑）
- Detail pages（商品/订单详情）
- Alert / Popup
- Other（FAQ / About / Contact）

产出屏幕分类表。

### 步骤 4: 提取设计 Token

遍历所有屏幕节点，统计：

**颜色** → `{{OUTPUT_DIR}}/color_tokens.json`
```json
{
  "background": { "hex": "#121212", "usage_count": 48, "semantic": "page bg" },
  "card": { "hex": "#1E1E1E", "usage_count": 35, "semantic": "card bg" },
  "primary": { "hex": "#7E57C2", "usage_count": 52, "semantic": "primary action" },
  ...
}
```

**字体** → `{{OUTPUT_DIR}}/typography.json`
按 (fontSize, fontWeight) 配对统计，记录典型用法：
```json
{
  "title_large": { "size": 28, "weight": "bold", "color": "#FFFFFF", "example": "App Name on splash" },
  "title_medium": { "size": 18, "weight": "semibold", "color": "#FFFFFF", "example": "Nav bar title" },
  ...
}
```

**间距/圆角** → `{{OUTPUT_DIR}}/spacing.json`
记录高频值（出现 3+ 次的）：
```json
{
  "padding": [16, 20, 24],
  "gap": [8, 12, 16],
  "corner_radius": { "card": 16, "button": 24, "input": 12 }
}
```

**阴影** → `{{OUTPUT_DIR}}/shadow_tokens.json`

### 步骤 5: 组件识别

寻找**在多屏重复出现的结构**，比如：
- 所有 "return button" 样式一致 → 抽象为 BackButton 组件
- 所有 "status badge" 样式一致 → StatusBadge 组件
- 所有 "detail row" 用同样布局 → DetailRow 组件
- 所有弹窗共用头部 → AlertPopup 基类

产出 `{{OUTPUT_DIR}}/component_catalog.json`：
```json
{
  "GradientButton": {
    "uses": 15,
    "found_in": ["NPJ8p", "IFaI6", "R099i", ...],
    "spec": {
      "height": 48,
      "cornerRadius": 24,
      "backgroundColor": "#7E57C2",
      "titleColor": "#FFFFFF",
      "font": { "size": 15, "weight": "semibold" }
    }
  },
  "DarkInputField": { ... },
  "StatusBadge": { ... }
}
```

### 步骤 6: 导出所有图片资源

使用 `batch_get` 搜索 `patterns: [{"type": "image"}]` 找到所有 image 节点。
用 `export_nodes outputDir:{{ASSETS_DIR}} format:png scale:3` 批量导出。

对每个导出的图片：
- 在代码项目的 Assets 目录创建对应的 imageset
- 生成 Contents.json
- 建立 asset_manifest.json 记录每张图片的 ID → 文件名映射

### 步骤 7: 识别"同结构多状态"

寻找**结构相同但状态/数据不同**的屏幕，比如：
- CreditInfo 的 3 种状态（审核中/待还款/待提取）使用同一布局
- 空状态 vs 有数据状态

产出 `{{OUTPUT_DIR}}/variant_groups.json`：
```json
{
  "CreditInfo": {
    "shared_layout": ["header card", "detail rows", "bank row", "schedule"],
    "variants": [
      { "node": "3QgC0", "status": "UnderReview", "bottom_bar": "none" },
      { "node": "hulqG", "status": "PendingRepayment", "bottom_bar": "Defer + Repay" },
      { "node": "1HM6O", "status": "ToBeWithdrawn", "bottom_bar": "Withdraw" }
    ]
  }
}
```

这个信息会让 Phase 3 Agent 知道"不要重复写 3 次 Controller，而是用一个 Controller + 状态切换"。

### 步骤 8: 产出总报告

写入 `{{OUTPUT_DIR}}/design_intel.md`，目录：

1. 项目概览（屏幕总数、分类、设计风格）
2. 设计 Token 汇总（颜色/字体/间距）
3. 组件目录（可复用组件清单）
4. 资源清单（图片/图标导出列表）
5. 屏幕映射表（屏幕名 → 代码文件）
6. 变体分组（哪些屏幕共享布局）
7. 下一步建议（Phase 1 要建哪些通用组件）

## 输出要求
- 所有 JSON 文件放在 `{{OUTPUT_DIR}}/`（默认 `{{REPO_PATH}}/design_data/`）
- 所有图片资源放在 `{{ASSETS_DIR}}/`（iOS 默认 `{{REPO_PATH}}/{{APP}}/Assets.xcassets/`）
- 总报告 `design_intel.md` 放在项目根目录
- 不写任何代码

## 关键注意事项
- **颜色统计时按 hex 归一化**（#fff → #FFFFFF，#7e57c2ff → #7E57C2）
- **字体 size/weight 组合**视为一个 token，不要按"设计师把同样字号给了不同元素"拆分
- **identifier 规则**：token 名用语义（`card_bg`）不用颜色名（`dark_grey`）
- **如果某屏 readDepth 超过 tokens 限制**，分层读取（先读父，再挑子节点单独读）
```

## 预期产出清单

执行完后 `{{REPO_PATH}}/design_data/` 下应有：
- `design_intel.md` — 总报告
- `color_tokens.json`
- `typography.json`
- `spacing.json`
- `shadow_tokens.json`
- `component_catalog.json`
- `variant_groups.json`
- `asset_manifest.json`
- `screens_map.md` — 屏幕到代码文件的映射

`{{REPO_PATH}}/{{APP}}/Assets.xcassets/` 下应有所有设计图中出现的图片资源。
