# Phase 2: Per-Screen Spec Generation

## 并行 Agent 派遣

按模块分派 4-6 个 Agent（参考 `SKILL.md` 的 Agent 分工规则）。每个 Agent 负责一组屏幕。

## Agent Prompt（每个 Agent 都用这个模板）

```
你是一个屏幕规格编写工程师。你的任务是为你负责的屏幕产出精确的规格文档（spec），不要写任何代码。这个 spec 会作为 Phase 3 代码实现 Agent 的唯一依据。

## 输入
- Pencil 文件路径：{{PEN_FILE_PATH}}
- design_intel.md 位置：{{OUTPUT_DIR}}/design_intel.md
- 你负责的屏幕节点 ID 列表：{{ASSIGNED_NODES}}
- 对应的代码文件（如果有已存在的）：{{EXISTING_FILES}}

## 先读必读
- `{{OUTPUT_DIR}}/design_intel.md`（尤其是组件目录和变体分组）
- `{{OUTPUT_DIR}}/color_tokens.json`
- `{{OUTPUT_DIR}}/component_catalog.json`
- Phase 1 产出的通用组件清单 `phase1_report.md`

## 执行步骤

### 步骤 1: 精确数据获取

对每个屏幕节点用 `batch_get readDepth:6 resolveVariables:true`。保存原始 JSON 到 `{{OUTPUT_DIR}}/raw/{{NODE_ID}}.json`。

### 步骤 2: 结构树提取

把 JSON 转成层级结构（tree）：
```
{{SCREEN_NAME}}
├── status_bar
├── nav_bar
│   ├── back_button (x:16, y:50, w:24, h:24)
│   └── title_label ("xxx", fontSize:18, weight:semibold, color:#FFFFFF)
├── header_card (x:16, y:96, w:343, h:208, radius:16, fill: gradient[...])
│   ├── description_label (fontSize:13, color:#FFFFFFD9)
│   └── days_row (x:16, y:171, w:311, h:18, centerAligned)
│       └── ... (7 个圆圈 + 6 个连接器)
└── ...
```

### 步骤 3: 组件复用标注

识别哪些元素应该用 Phase 1 建好的通用组件，而不是重写。例如：

```
Apply Now button → 使用 SCGradientButton
  配置: title="Apply Now"
  约束: width=343, height=48, bottom_safe=12

Password input → 使用 SCDarkTextField
  配置: placeholder="Enter password", secureEntry=YES
```

### 步骤 4: 资源标注

对需要图片的地方，引用 `asset_manifest.json`：
```
app_logo (x:144, y:100, w:72, h:72) → 资源: Assets/app_logo
```

不要让 Phase 3 Agent 去重新找图片。

### 步骤 5: 结构模式标注

如果这屏属于某个 variant group（比如 CreditInfo 的三种状态之一）：
- 标注这个 spec 是基础模板，还是某个具体状态
- 列出所有状态的差异点
- 建议：用一个 Controller 处理所有状态，通过参数切换

### 步骤 6: 产出 spec 文档

写到 `{{OUTPUT_DIR}}/specs/{{MODULE_NAME}}.md`。格式：

```markdown
# Spec: {{SCREEN_NAME}}

## 源节点
- ID: {{NODE_ID}}
- 尺寸: 375 × 812

## 屏幕类型
- 类型: Form / List / Detail / ...
- 是否属于 variant group: CreditInfo (变体之一)

## 层级结构
[元素 tree，见步骤 2]

## 元素规格（按从上到下、从外到内）

### header_card
- 坐标: x=16, y=96
- 尺寸: 343 × 208
- 圆角: 16
- 填充: 渐变
  - 起点: (0, 0), 终点: (0, 208)
  - 色标: #2D1B69 @ 0 → #3A2578 @ 0.5 → #4A2D6E @ 1
- 阴影: 无
- 子元素:
  - description_label: ...
  - ...

### apply_button
- 组件: SCGradientButton (Phase 1 已建)
- 配置: title="Apply Now"
- 约束:
  - x=16, y=[bottom - 60], w=343, h=48
  - 对齐: 底部紧贴 safe area，左右 16pt

## 状态/数据模型
[如有交互状态，列出来]

## 用到的资源
- Assets/app_logo
- Assets/home_footer_1 ~ home_footer_4

## 实现建议
- 推荐使用 UITableView（因为是长页面）
- 推荐继承 BaseViewController
- 数据模型字段: {...}

## 审计线索（供 Phase 4 使用）
- 关键字段: header_card.fill（渐变色标要对齐）
- 常见错误: 圆圈连接线应水平居中（不要从左起）
```

## 输出要求

- 每屏一个 `.md` spec 文档
- 所有原始 JSON 保存到 `{{OUTPUT_DIR}}/raw/`
- 写一个 `{{OUTPUT_DIR}}/specs/_index.md` 索引所有 spec

## 关键注意事项

- **不写任何代码** — 这是规格阶段，不是实现阶段
- **所有数值必须来自 JSON** — 不要目测、不要猜
- **用 Phase 1 的通用组件** — 看见一个按钮别又重新描述圆角/颜色，引用 SCGradientButton 就够了
- **标注清楚"为什么这样做"** — Phase 3 Agent 需要理解意图
- **检查横屏变体** — variant_groups.json 告诉你哪些屏幕结构相同
```

## 指挥官职责

Phase 2 全部 Agent 完成后，指挥官（主 Agent）必须：

1. **读所有 spec** — 确保无冲突
2. **跨屏一致性检查** — 如果 Screen A 和 Screen B 都有"返回按钮"但规格不同，是设计错误还是 Agent 错误？修正。
3. **组件复用检查** — 是否有屏幕"重新描述"了本该复用的组件？纠正。
4. **产出 consolidated_specs.md** — 一个总览文档，让 Phase 3 Agent 有全局视角。
