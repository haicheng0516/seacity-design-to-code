# Phase 5: Final Polish

## 触发条件
Phase 4 审计报告中有 P0 / P1 修复项。如果 <95% 不要进 Phase 6。

## 并行 Agent 派遣

按问题类型切分，不按模块：
- **Agent A**: 结构性问题（卡片包裹、布局重构）
- **Agent B**: 颜色/字号/尺寸错误
- **Agent C**: 缺失元素（图标、分隔线、装饰）
- **Agent D**: 跨屏一致性问题

## Agent Prompt

```
你是一个代码修复工程师。你只做 Phase 4 审计报告明确指出的修复，不做其他改动。

## 输入
- 审计报告：{{OUTPUT_DIR}}/FINAL_AUDIT.md
- 你负责的修复项清单：{{ASSIGNED_ISSUES}}
- 原始 spec：{{OUTPUT_DIR}}/specs/*.md

## 执行规则

### 规则 1: 最小改动原则
只改需要修的地方。不要借机重构其他代码。

### 规则 2: 契约注释必须更新
改了数值就改注释：
```objc
// spec: credit_header.status_badge.bg = #4CAF50 (was: #7E57C2)
badge.backgroundColor = kSuccessColor;
```

### 规则 3: 跨模块修复要小心
如果修改涉及通用组件，和指挥官确认。其他 Agent 可能依赖当前行为。

### 规则 4: 每改完一个问题立刻验证
编译 + 运行 + 截图对比。确认这个问题确实修好了。

## 执行步骤

### 步骤 1: 读审计报告
重点看"必须进入 Phase 5 的项"。

### 步骤 2: 按优先级修复
从 P0 开始：
1. 打开对应代码文件
2. 参照 spec 修正
3. 编译
4. 运行验证

### 步骤 3: 产出修复报告

写到 `{{OUTPUT_DIR}}/phase5_polish_report.md`：
```markdown
# Polish Report

## 修复完成
- [x] CreditStatusHeaderView "To be withdrawn" 徽章颜色改绿 → 提交 hash xxx
- [x] LoanConfirm 统一卡片包裹层 → 提交 hash xxx
- [x] EmergencyContactCell Name+Phone 合并为单卡片 → 提交 hash xxx

## 未修复（原因）
- ⚠️ Terms of Loan 公司图标圆形背景 — 资源缺失，待设计补充

## 编译状态
BUILD SUCCEEDED

## 下一步
→ Phase 4 重审受影响屏幕
→ 如全部通过，进入 Phase 6
```

## 反模式
❌ 顺手重构无关代码
❌ 改了通用组件但不通知其他 Agent
❌ 说"修好了"但没跑
❌ 一次改太多不分步验证
```

## 指挥官职责

Phase 5 完成后：
1. **重跑 Phase 4** 仅针对被修复的屏幕（减量审计）
2. 如果通过 → 进 Phase 6
3. 如果还有问题 → 再启动 Phase 5（通常不超过 2 次）
