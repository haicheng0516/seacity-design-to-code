# Phase 1: Common Layer Setup

## Agent Prompt

```
你是一个基础设施建设工程师。你的任务是基于 Phase 0 产出的 design_intel.md，建好所有通用层代码，为 Phase 3 的屏幕开发提供稳定的基础。

## 输入
- design_intel.md 所在目录：{{OUTPUT_DIR}}
- 目标代码仓库：{{REPO_PATH}}
- 目标平台：{{PLATFORM}}
- 项目语言/框架：{{STACK}}（例如 iOS Objective-C + Masonry）

## 执行步骤

### 步骤 1: 写入设计 Token

基于 `color_tokens.json`、`typography.json`、`spacing.json`：

**iOS (Objective-C) 示例**：
在 `UI/Common/Utils/UIColors.h` 写入所有颜色宏：
```objc
#define kBackgroundColor         k16RGBColor(0x121212)
#define kCardBackgroundColor     k16RGBColor(0x1E1E1E)
#define kInputBackgroundColor    k16RGBColor(0x2A2A2A)
#define kPrimaryColor            k16RGBColor(0x7E57C2)
#define kTextPrimaryColor        k16RGBColor(0xFFFFFF)
#define kTextSecondaryColor      k16RGBColor(0xE0E0E0)
#define kTextHintColor           k16RGBColor(0x9E9E9E)
...
```

**Android / Web** 按项目约定放入 `colors.xml` / `theme.ts`。

### 步骤 2: 建所有通用组件

基于 `component_catalog.json`，把每个识别出的组件单独成文件。

**iOS 示例目录**：
```
UI/Common/View/
├── SCGradientButton.h/.m       ← 主按钮
├── SCDarkTextField.h/.m        ← 暗色输入框
├── SCDarkDropdownField.h/.m    ← 下拉选择
├── SCStatusBadgeView.h/.m      ← 状态徽章
├── SCInfoRowView.h/.m          ← Key-Value 信息行
├── SCContactInfoRowView.h/.m   ← 联系方式行（带复制按钮）
├── SCEmptyStateView.h/.m       ← 空状态视图
├── SCAlertPopupView.h/.m       ← 弹窗基类
├── SCAlertFactory.h/.m         ← 弹窗工厂
└── ...（所有 catalog 中出现的组件）
```

每个组件必须：
- 单独头文件 + 实现文件
- 属性/配置清晰暴露
- 支持所有 variant_groups.json 中该组件出现过的状态
- 使用 Phase 0 写入的 Token（不得硬编码颜色/字号）

### 步骤 3: 弹窗系统一次性建完（重要！）

**不要**把弹窗留到最后做。在本阶段一次性建好所有类型的弹窗：

```
SCAlertPopupView (基类)
└── SCAlertFactory (工厂方法)
    ├── + showUpgradeAlertWithVersion:...
    ├── + showForceUpgradeAlertWithVersion:...
    ├── + showRatingAlert...
    ├── + showPermissionAlert...
    ├── + showDeleteAccountAlert...
    ├── + showSignOutAlert...
    ├── + showVerificationFailedAlert...
    └── ...（对应所有设计中的弹窗变体）
```

每个工厂方法对设计中的一个弹窗节点。参数化标题/图标/消息/按钮。

### 步骤 4: 基础架构（如果是全新项目）

- Base 控制器 / Base View（如果有）
- 导航栏样式统一
- Tab 栏实现（如果是 Tab 架构）
- Router / 页面跳转规则
- Loading / Toast / HUD 封装

### 步骤 5: 验证构建

运行构建命令：
- iOS: `xcodebuild -workspace {{PROJECT}}.xcworkspace -scheme {{PROJECT}} -sdk iphonesimulator build`
- Android: `./gradlew assembleDebug`
- Web: `npm run build`

必须通过。

## 输出要求

- 所有通用组件各自独立文件（不要堆在一起）
- 每个组件顶部注释标明对应的设计节点 ID 和 component_catalog.json 中的名字
- 产出 `{{OUTPUT_DIR}}/phase1_report.md` 记录：
  - 创建了哪些文件
  - 每个组件的公开 API
  - 编译状态

## 关键注意事项

- **禁止硬编码颜色/字号/圆角** — 全部用 Token
- **组件 API 要稳定** — Phase 3 Agent 会依赖这些 API
- **弹窗也是通用组件** — 不要只做个 "Loading 弹窗" 就走人
- **给 Phase 3 Agent 留说明** — 哪些组件可用、每个组件怎么用
```

## 预期产出清单

- 所有通用组件文件
- Token 头文件更新
- `phase1_report.md` 通用层清单
- Build 通过
