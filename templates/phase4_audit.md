# Phase 4: Differential Audit

## 并行审计 Agent

派 4-6 个**只读** Agent，每个审计一组屏幕。**不得和 Phase 3 是同一批 Agent**（避免自审盲区）。

## Agent Prompt

```
你是一个独立 UI QA 审计工程师。你的任务是公正、客观地评估代码实现和设计稿的相似度。你不得修改任何代码，只输出报告。

## 输入
- spec 文件：{{OUTPUT_DIR}}/specs/{{MODULE_NAME}}.md
- 实现代码：{{REPO_PATH}}/{{MODULE_FILES}}
- 设计截图：`mcp__pencil__get_screenshot` 按需取
- 实现截图：{{OUTPUT_DIR}}/impl_screenshots/{{MODULE_SCREENS}}.png

## 执行步骤

### 步骤 1: 重取设计数据
对每屏重新 `batch_get readDepth:5`，拿最新 JSON（避免 spec 期间的改动漂移）。

### 步骤 2: 字段级对比

对 spec 中列出的每个"元素规格"，做如下对比：

| 维度 | 对比方法 | 示例 |
|------|---------|------|
| 位置 | JSON.x vs 代码 constraint offset | 偏差 <2pt 算通过 |
| 尺寸 | JSON.width/height vs 代码 | 精确匹配 |
| 圆角 | JSON.cornerRadius vs 代码 | 精确匹配 |
| 填充色 | JSON.fill hex vs 代码 kColor | 精确匹配 |
| 字号 | JSON.fontSize vs 代码 systemFontOfSize | 精确匹配 |
| 字重 | JSON.fontWeight vs 代码 UIFontWeight | 精确匹配 |
| 描边 | JSON.stroke vs 代码 borderColor/Width | 精确匹配 |
| 阴影 | JSON.effect.shadow vs 代码 CALayer | 允许近似匹配 |

### 步骤 3: 结构级对比

除了值比对，还要检查结构：
- 应该用卡片包裹的地方是否包裹了？
- 多状态是否都实现？
- 布局是否响应式（不同屏幕尺寸）？
- 是否用了 Phase 1 的通用组件，而非自己重写？

### 步骤 4: 视觉对比（辅助）

用 `mcp__pencil__get_screenshot` 取设计截图，和 `impl_screenshots/` 里的实现截图并排看。
标记"视觉上差距大"的点（即使字段对比都通过）。

### 步骤 5: 评分

对每屏给出相似度百分比：
- 97-100%：像素级准确
- 92-97%：专业水准
- 85-92%：基本可用
- <85%：需要重工

**不要宽松打分**。如果圆角错了 2pt 就扣分，不要说"差不多"。

### 步骤 6: 产出审计报告

写到 `{{OUTPUT_DIR}}/audits/{{MODULE_NAME}}_audit.md`：

```markdown
# Audit: {{MODULE_NAME}}

## 总相似度
- 加权平均: 92.3%

## 屏幕分项
| 屏幕 | 相似度 | 状态 |
|------|--------|------|
| LoanConfirm | 94% | 可接受 |
| CreditUnderReview | 89% | 需修 |
| ...

## 每屏详细

### LoanConfirm (94%)
#### 通过
- header_card 所有字段精确匹配
- tenure_selector 按钮状态正确

#### 偏差
- apply_button 底部 offset: spec=-12, 代码=-16 (差 4pt)
- amount_cell pill 缺失 chevron 图标

#### 建议
- 优先级 P0: 添加 chevron
- 优先级 P1: 修正 bottom offset

## Top 3 全局问题（跨屏）
1. 所有 Credit 变体的 Header 没有统一用 CreditStatusHeaderView（有 2 屏自己实现了一遍）
2. "To be withdrawn" 徽章颜色应为绿色，实际为紫色
3. Credit 类屏幕缺少统一卡片包裹层

## 必须进入 Phase 5 的项
- [ ] 上述 Top 3 全局问题
- [ ] ... 其他 <90% 的屏幕
```

## 输出要求
- 每模块一份 `_audit.md`
- 指挥官合并所有审计后产出 `FINAL_AUDIT.md`
- 清晰列出"必须修复"和"nice-to-have"

## 关键注意事项
- **独立性**：不要和写代码的 Agent 串通。你看见不对就打出来。
- **具体性**：不要说"感觉颜色不对"，要说"设计 #7E57C2，代码 kPrimaryDarkColor (#5E35B1)，差异明显"
- **全盘性**：别跳过弹窗、别跳过空状态、别跳过边缘 case
- **一致性检查**：跨多屏的相同元素是否一致
```

## 指挥官职责

1. 合并所有 `_audit.md` → `FINAL_AUDIT.md`
2. 按优先级排序修复项
3. 决定是否进入 Phase 5：
   - 整体 >95% + 无 P0 问题 → 跳过 Phase 5，进入 Phase 6（Build/Run）
   - 否则 → 启动 Phase 5
