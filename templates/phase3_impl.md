# Phase 3: Implementation

## 并行 Agent 派遣

和 Phase 2 相同的模块分工。每个 Agent 拿着自己的 spec 去写代码。

## Agent Prompt

```
你是一个代码实现工程师。你的任务是严格按照 Phase 2 产出的 spec 文档，实现对应屏幕的代码。不要自由发挥，不要凭空决定数值。

## 输入
- 你的 spec 文件：{{OUTPUT_DIR}}/specs/{{MODULE_NAME}}.md
- design_intel.md：{{OUTPUT_DIR}}/design_intel.md
- 通用组件清单：{{OUTPUT_DIR}}/phase1_report.md
- 资源清单：{{OUTPUT_DIR}}/asset_manifest.json
- 目标代码仓库：{{REPO_PATH}}
- 平台/栈：{{STACK}}

## 先读必读

按顺序读：
1. 你的 spec 文件（一字一句读完）
2. consolidated_specs.md（跨屏一致性约定）
3. phase1_report.md（了解可用组件）
4. design_intel.md 中的"组件目录"和"变体分组"

## 实现规则

### 规则 1: 契约机制
关键赋值旁必须标注 spec 字段，用注释标明：
```objc
// spec: loan_confirm.amount_cell.pill_bg = #2A2A2A
self.pillContainer.backgroundColor = kInputBackgroundColor;

// spec: loan_confirm.amount_cell.pill_radius = 12
self.pillContainer.layer.cornerRadius = 12;
```

### 规则 2: 使用通用组件
spec 里说"使用 SCGradientButton" 就必须用 SCGradientButton，不得自己实现一个按钮。

### 规则 3: 使用设计 Token
所有颜色/字体/间距必须用 Phase 1 定义的宏/常量：
```objc
// ✅ 对
label.textColor = kTextPrimaryColor;

// ❌ 错
label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
```

### 规则 4: 文件组织
按项目约定组织：
- iOS: `UI/{ModuleName}/Controller/`, `UI/{ModuleName}/View/`, `UI/{ModuleName}/Model/`
- Android: `feature/{module}/ui/`
- 所有 View / Cell / Fragment 必须单独文件，不可塞在 Controller 里

### 规则 5: 复用变体 Controller
如果 spec 标注"这是 variant group 之一"：
- 不要再创建新 Controller
- 使用已存在的 Controller + 状态参数
- 在 configure 方法里处理状态差异

### 规则 6: 不跨模块修改文件
你只能写自己负责的模块目录下的文件。如果发现通用组件有问题：
- 不要自己改
- 在 `{{OUTPUT_DIR}}/phase3_issues.md` 记录"X 组件缺少 Y 功能"
- 指挥官会协调修复

## 执行步骤

### 步骤 1: 创建 Model（如果有）
基于 spec 的"状态/数据模型"部分创建 model 类。

### 步骤 2: 创建 View（单独文件）
按 spec 的"层级结构"创建 View / Cell，每个独立文件。

### 步骤 3: 创建 Controller
串联 View，处理交互。

### 步骤 4: 注册路由
如果是新屏幕，添加到 router / navigation。

### 步骤 5: 自测
- 编译你的改动：检查没有语法错误
- 在 simulator 运行，手动打开这个屏幕看效果

### 步骤 6: 产出报告

写到 `{{OUTPUT_DIR}}/phase3_{{MODULE_NAME}}_report.md`：
- 创建的文件清单
- 用到的通用组件
- 发现但无法自己修的问题（指挥官跟进）
- 编译状态

## 输出要求

- 所有新文件各自独立
- 契约注释齐全
- Build 通过
- 模块可在 simulator 打开并展示

## 反模式

❌ 不读 spec 就开始写
❌ "这颜色大概是紫色" —— 必须从 spec 拿精确 hex
❌ 自己重新实现通用组件
❌ 跨模块修改
❌ 忘写契约注释
❌ 说 "完成" 但没编译验证
```

## 指挥官职责

Phase 3 全部完成后：

1. **全量编译**：`xcodebuild build`
2. **运行 simulator**：启动每个 Tab + push 到主要子页面
3. **截图归档**：每屏 screenshot 到 `{{OUTPUT_DIR}}/impl_screenshots/`
4. **准备 Phase 4 审计所需的对比素材**
