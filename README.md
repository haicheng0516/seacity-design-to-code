# seacity-design-to-code

> Claude Skill：把 Figma / Sketch / XD 设计稿自动实现成高保真 UI 代码 · 95%+ 还原度
>
> A Claude Skill that turns design files into high-fidelity UI code · 95%+ similarity

<p align="center">
  <b>语言 / Language:</b>
  &nbsp;
  <a href="#中文说明">🇨🇳 中文</a>
  &nbsp;·&nbsp;
  <a href="#english">🇺🇸 English</a>
</p>

---

<a name="中文说明"></a>

<details open>
<summary><strong>🇨🇳 中文说明（点击此行收起）</strong></summary>

<br>

## 这个 Skill 能做什么

你有 Figma / Sketch / XD 设计稿，想让 AI 帮你实现成 iOS / Android / Web 代码？

调用这个 Skill，它会自动：

1. 提取设计图里的所有颜色、字体、间距、组件
2. 导出所有图片素材到项目里
3. 先建好通用组件层（按钮、输入框、弹窗等）
4. 再按设计图生成每个屏幕的代码
5. 自审打分 → 修补差异 → 编译验证

**最终效果：95%+ 的设计还原度**，比手写快 10 倍。

---

## 一次性安装（约 5 分钟）

### 步骤 1: 安装 Pencil

前往 Pencil 官网下载安装包，安装后启动一次。

> Pencil 是一个设计协作工具，支持把 Figma / Sketch / XD 文件导入并作为 `.pen` 文件存储。我们用它作为 AI 和设计文件之间的桥梁。

### 步骤 2: 启用 Pencil MCP

打开 Pencil → 菜单栏 `Preferences` → `Developer` → 勾选 `Enable MCP Server`

记录 Pencil 提示的命令或路径，下一步会用到。

### 步骤 3: 注册 MCP 到 Claude Code

在终端运行：

```bash
claude mcp add pencil --command "<Pencil 上面给出的命令>"
```

或手动编辑 `~/.claude/settings.json`：

```json
{
  "mcpServers": {
    "pencil": {
      "command": "<pencil-mcp 可执行文件路径>"
    }
  }
}
```

### 步骤 4: 安装 Skill

```bash
cd ~/.claude/skills/
git clone https://github.com/haicheng0516/seacity-design-to-code.git
```

### 步骤 5: 重启 Claude Code

完全退出再重启。

### 步骤 6: 验证

在 Claude Code 里说：

```
列出 pencil 工具
```

看到 `mcp__pencil__batch_get`、`mcp__pencil__get_screenshot` 等工具就说明成功了。

---

## 使用流程（3 步）

### 第 1 步：把设计图导入 Pencil

1. 打开 Pencil → `File` → `New Canvas`（新建画板）
2. 把你的 `.fig` / `.sketch` / `.xd` 文件**直接拖到画板上**
3. 等待解析完成（大文件 10-60 秒）
4. `File` → `Save` 保存为 `.pen` 文件，记下路径

### 第 2 步：告诉 Claude 开始工作

在 Claude Code 里输入：

```
/seacity-design-to-code
```

或者用自然语言说：

```
用 seacity-design-to-code 这个 skill 把我的设计稿实现成 iOS App
Pencil 文件路径: ~/Desktop/my_design.pen
项目路径: ~/Desktop/MyApp
```

### 第 3 步：等待完成

Skill 会自动检测你的环境（Claude Code / Cursor / 其他）并选择合适的执行模式：

| 环境 | 模式 | 耗时（50 屏项目） |
|------|------|------------------|
| Claude Code | 并行 Agent 团队 | ~60 分钟 |
| Cursor | Task 队列 | ~2 小时 |
| 其他 LLM | 单线程 | ~6 小时 |

全程无需干预。可以去泡杯咖啡。

---

## 执行过程中会发生什么

Skill 运行时你会看到 6 个阶段：

### Phase 0: 设计情报提取（约 5 分钟）

Skill 读取所有屏幕、提取颜色/字体/间距、导出图片资源。
产出：`design_data/` 目录下一堆 JSON 文件 + 图片已导入 Assets。

### Phase 1: 通用组件层（约 10 分钟）

先建好所有可复用组件（按钮、输入框、弹窗、卡片等）。
产出：`UI/Common/View/` 下的组件文件。

### Phase 2: 屏幕规格生成（约 15 分钟）

每个屏幕产出一份精确规格文档（不写代码）。
产出：`specs/` 目录下每屏一份 `.md`。

### Phase 3: 代码实现（约 20 分钟）

按规格文档写代码。Claude Code 下多个 Agent 并行。
产出：项目完整 UI 代码。

### Phase 4: 差分审计（约 5 分钟）

独立 Agent 打分，找出真实差异。
产出：`FINAL_AUDIT.md`，每屏相似度百分比。

### Phase 5: 最终攻坚（按需，约 5 分钟）

修补 Phase 4 发现的问题。

### 最后：编译 + 运行验证

跑 build，启动模拟器，对每屏截图归档。
产出：`FINAL_REPORT.md` 完整报告。

---

## 预期产出

Skill 跑完后你的项目里会多出：

```
你的项目/
├── design_data/              ← Skill 的档案（设计系统数据）
│   ├── design_intel.md
│   ├── color_tokens.json
│   ├── typography.json
│   ├── component_catalog.json
│   └── raw/ (每屏原始 JSON)
├── specs/                    ← 每屏规格文档
├── audits/                   ← 审计报告
├── FINAL_AUDIT.md
├── FINAL_REPORT.md
└── [你的代码]/                ← UI 代码已全部生成
    └── UI/
        ├── Common/View/      ← 通用组件
        ├── Auth/
        ├── Home/
        ├── ...
        └── 每个模块的 Controller/View/Model
```

---

## 常见问题

**Q: 跑到一半要中断能继续吗？**

A: 可以。Skill 每阶段结束都会保存 `progress.md` checkpoint，重新运行时会接着上次的进度。

**Q: 设计图改了怎么办？**

A: 重新运行 Skill。Phase 4 的差分审计会识别变化，Phase 5 只修变化的部分，不会重写所有代码。

**Q: 项目太大上下文不够怎么办？**

A: 按功能模块拆分成几个子项目（比如 "认证模块"、"交易模块"），每个独立跑 Skill。

**Q: 我不用 Claude Code，能用吗？**

A: 能。Skill 会自动降级到 Linear Mode，用 Cursor / Aider / 其他 AI 都行，只是没有并行，会慢一些。

**Q: 支持哪些技术栈？**

A: iOS（OC/Swift）、Android（Kotlin/Java）、Flutter、React/Vue/Svelte 都支持。iOS 的 OC 版本测试最充分。

**Q: 弹窗会自动生成吗？**

A: 会。Phase 1 就会把所有弹窗类型一次性建完，不会漏。

**Q: 结果只有 70% 相似度怎么办？**

A: 先看 `FINAL_AUDIT.md` 找出哪屏最差。通常是：
- 某个屏幕 spec 不完整（Phase 2 漏了元素）
- Phase 4 没检查到的结构问题
- 自定义插件没导入 Pencil

手动指出问题后让 Claude 针对修复即可。

**Q: 我能手动指定执行模式吗？**

A: 能。在 prompt 里说"用 linear mode 跑"或"用 full agent mode 跑"即可覆盖自动检测。

**Q: Pencil 收费吗？**

A: 查看 Pencil 官方说明。Skill 本身完全免费开源（MIT License）。

---

## 真实案例

这个 Skill 源自一个真实的 iOS 项目（SeacityA01，菲律宾贷款 App，50 屏 + 17 弹窗）：

- 起点：初始相似度 17%
- 5 轮迭代后：95%+
- Agent 总调度：~26 次
- 文件改动：200+

完整案例见 [examples/seacity_loan_app.md](examples/seacity_loan_app.md)

---

## 反馈 / 贡献

发现 Skill 有坑？发 Issue：
https://github.com/haicheng0516/seacity-design-to-code/issues

想改进 Skill？欢迎 PR：

- 踩坑经验 → `reference/anti_patterns.md`
- 更好的 Agent prompt → `templates/`
- 新的技术栈支持 → `reference/{stack}_conventions.md`

---

## 作者

Seacity ([@haicheng0516](https://github.com/haicheng0516))

如果这个 Skill 帮到你，点个 ⭐ 让更多人看到。

</details>

---

<a name="english"></a>

<details>
<summary><strong>🇺🇸 English (click to expand)</strong></summary>

<br>

## What this Skill does

You have a Figma / Sketch / XD design and want AI to implement it as iOS / Android / Web code?

This Skill automatically:

1. Extracts all colors, fonts, spacing, components from your design
2. Exports all image assets to your project
3. Builds the common component layer (buttons, inputs, popups, etc.) FIRST
4. Then generates code for each screen based on the design
5. Self-audits → patches differences → verifies build

**End result: 95%+ design fidelity**, 10x faster than hand-coding.

---

## One-time setup (~5 minutes)

### Step 1: Install Pencil

Download from Pencil's website. Launch it once.

> Pencil is a design collaboration tool that imports Figma / Sketch / XD files and stores them as `.pen` files. We use it as the bridge between AI and your design files.

### Step 2: Enable Pencil MCP

Open Pencil → `Preferences` → `Developer` → check `Enable MCP Server`

Note the command Pencil shows you.

### Step 3: Register MCP in Claude Code

In terminal:

```bash
claude mcp add pencil --command "<pencil-mcp command>"
```

Or edit `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "pencil": {
      "command": "<pencil-mcp executable path>"
    }
  }
}
```

### Step 4: Install the Skill

```bash
cd ~/.claude/skills/
git clone https://github.com/haicheng0516/seacity-design-to-code.git
```

### Step 5: Restart Claude Code

Fully quit and relaunch.

### Step 6: Verify

In Claude Code, ask:

```
list pencil tools
```

You should see `mcp__pencil__batch_get`, `mcp__pencil__get_screenshot`, etc.

---

## Usage (3 steps)

### Step 1: Import design into Pencil

1. Open Pencil → `File` → `New Canvas`
2. **Drag** your `.fig` / `.sketch` / `.xd` file onto the canvas
3. Wait for parsing (10-60 seconds for large files)
4. `File` → `Save` as `.pen` and note the path

### Step 2: Tell Claude to start

In Claude Code:

```
/seacity-design-to-code
```

Or natural language:

```
Use seacity-design-to-code skill to implement my design as an iOS App.
Pencil file: ~/Desktop/my_design.pen
Project path: ~/Desktop/MyApp
```

### Step 3: Wait

The Skill auto-detects your environment and picks the best mode:

| Environment | Mode | Duration (50-screen project) |
|-------------|------|------------------------------|
| Claude Code | Parallel agent team | ~60 min |
| Cursor | Task queue | ~2 hrs |
| Other LLM | Single-thread | ~6 hrs |

No intervention needed. Grab coffee.

---

## What happens during execution

The Skill runs 6 phases:

### Phase 0: Design Intelligence Extraction (~5 min)
Read all screens, extract colors/fonts/spacing, export image assets.

### Phase 1: Common Component Layer (~10 min)
Build all reusable components (buttons, inputs, popups, cards) BEFORE screens.

### Phase 2: Per-Screen Spec Generation (~15 min)
Generate precise spec docs (no code yet).

### Phase 3: Code Implementation (~20 min)
Write code following specs. Multiple agents in parallel (Claude Code).

### Phase 4: Differential Audit (~5 min)
Independent agents score similarity, find real differences.

### Phase 5: Final Polish (as needed, ~5 min)
Fix issues found in Phase 4.

### Finally: Build + Run verification
Run build, launch simulator, screenshot each screen.
Produces `FINAL_REPORT.md`.

---

## Expected output

After the Skill completes, your project will have:

```
your-project/
├── design_data/              ← Skill's archive (design system data)
│   ├── design_intel.md
│   ├── color_tokens.json
│   ├── typography.json
│   ├── component_catalog.json
│   └── raw/ (per-screen JSON)
├── specs/                    ← Per-screen spec docs
├── audits/                   ← Audit reports
├── FINAL_AUDIT.md
├── FINAL_REPORT.md
└── [your code]/              ← Full UI code generated
    └── UI/
        ├── Common/View/      ← Reusable components
        ├── Auth/
        ├── Home/
        └── ...
```

---

## FAQ

**Q: Can I pause and resume?**

A: Yes. Each phase saves a `progress.md` checkpoint. Re-running continues from where you left off.

**Q: What if the design changes?**

A: Re-run the Skill. Phase 4's differential audit identifies changes. Phase 5 fixes only the delta.

**Q: My project is huge (100+ screens). What do I do?**

A: Split into logical sub-projects (e.g., "auth module", "commerce module"). Run the Skill per sub-project.

**Q: I don't use Claude Code. Can I still use this?**

A: Yes. The Skill falls back to Linear Mode — works with Cursor, Aider, any LLM. Just slower.

**Q: Which tech stacks are supported?**

A: iOS (OC/Swift), Android (Kotlin/Java), Flutter, React/Vue/Svelte. iOS Objective-C is the most battle-tested.

**Q: Are popups auto-generated?**

A: Yes. Phase 1 builds all popup variants at once, so none are missed.

**Q: What if I only get 70% similarity?**

A: Check `FINAL_AUDIT.md` to find the worst screen. Common causes:
- Spec is incomplete (Phase 2 missed elements)
- Structural issues Phase 4 didn't catch
- Custom plugins not imported to Pencil

Point out the specific issue and ask Claude to fix it.

**Q: Can I override the auto-detected mode?**

A: Yes. Say "use linear mode" or "use full agent mode" in your prompt.

**Q: Does Pencil cost money?**

A: Check Pencil's official documentation. This Skill itself is completely free (MIT License).

---

## Real-world case study

This Skill was extracted from a production iOS project (SeacityA01, Philippines loan app, 50 screens + 17 popups):

- **Starting point**: 17% initial similarity
- **After 5 iteration rounds**: 95%+
- **Total agent dispatches**: ~26
- **Files modified**: 200+

Full case study: [examples/seacity_loan_app.md](examples/seacity_loan_app.md)

---

## Feedback / Contributing

Found a bug? File an issue:
https://github.com/haicheng0516/seacity-design-to-code/issues

Want to improve the Skill? PRs welcome:

- Anti-patterns → `reference/anti_patterns.md`
- Better agent prompts → `templates/`
- New stack support → `reference/{stack}_conventions.md`

---

## Author

Seacity ([@haicheng0516](https://github.com/haicheng0516))

If this Skill helped you, star ⭐ the repo to help more people find it.

</details>

---

## Keywords

`claude-skill` `design-to-code` `figma-to-ios` `pencil-mcp` `ui-generation` `ai-coding-agent` `sketch-to-code` `xd-to-code` `claude-code` `seacity`
