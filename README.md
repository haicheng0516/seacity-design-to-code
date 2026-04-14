# seacity-design-to-code

> 🇨🇳 **中文用户**：直接看 **[使用说明.md](使用说明.md)** — 一步一步带你用起来
>
> 🇺🇸 **English users**: continue reading below

---

A Claude Code Skill that turns design files (Figma/Sketch/XD) into high-fidelity UI code through a systematic, parallelized agent workflow powered by Pencil MCP.

**Typical result: 95%+ visual similarity to the original design in 2 iteration rounds.**

> Extracted from a real iOS production project. See [examples/seacity_loan_app.md](examples/seacity_loan_app.md) for the case study that birthed this Skill.

## What this does

You give Claude (or any AI coding agent) a design file. It generates the full UI code with near-pixel accuracy.

Under the hood, it runs a 6-phase workflow. **The Skill automatically detects your environment and adapts**:

- **Claude Code / CLI** → Uses parallel Agent teams (4-6 agents working simultaneously)
- **Other agents (Cursor, Aider etc.)** → Falls back to Task Mode (sequential with task tracking)
- **Plain LLMs** → Linear mode (same quality, just slower)

Same Skill, three execution modes, same result.

## The 6-phase workflow

1. **Design Intel Extraction** — pull colors, fonts, spacing, components; export assets
2. **Common Layer Setup** — build all reusable components AND popups BEFORE screens
3. **Per-Screen Spec Generation** — each screen gets a precise spec doc
4. **Parallel Implementation** — code follows specs (contract-based comments)
5. **Differential Audit** — independent review agents find gaps
6. **Final Polish** — targeted fixes for remaining issues

## Quick start

### Prerequisites (one-time setup)

1. **Install Pencil** — a design tool that imports Figma/Sketch/XD files and exposes them via MCP.
   See [reference/setup_pencil.md](reference/setup_pencil.md)

2. **Install this Skill**:
   ```bash
   # For Claude Code
   cd ~/.claude/skills/
   git clone https://github.com/haicheng0516/seacity-design-to-code.git
   ```

3. **Verify**: In Claude Code, ask "列出 pencil 工具" — you should see `mcp__pencil__*` entries.

### Using the Skill

1. Open Pencil, create a new canvas
2. Drag your `.fig` / `.sketch` / `.xd` file into the canvas — it imports automatically
3. In Claude Code:
   ```
   /seacity-design-to-code
   ```
   Or just ask: "按这个设计稿把 UI 做出来"

The Skill takes over and runs the full workflow, first detecting your environment then picking the best mode.

## What you get

After the workflow completes:

- ✅ All UI screens coded to match the design
- ✅ Reusable components encapsulated (no copy-paste)
- ✅ Design tokens centralized (colors, fonts, spacing)
- ✅ All popups/alerts built in one place
- ✅ Zero compile errors, runs in simulator/emulator
- ✅ `FINAL_REPORT.md` with per-screen similarity scores
- ✅ `design_data/*.json` archived as design truth

## Real-world results

This Skill's workflow was battle-tested on a production iOS project (`SeacityA01`) — a 50-screen Philippines-market loan app:

- **Starting point**: 17% design fidelity (existing skeleton)
- **After 5 iteration rounds**: 95%+ fidelity
- **Total agent dispatches**: ~26
- **Files modified/created**: 200+

The V2 workflow baked into this Skill compresses those 5 rounds into 2. See [examples/seacity_loan_app.md](examples/seacity_loan_app.md).

## Design philosophy

| Principle | Why |
|-----------|-----|
| Commander never codes | Delegation beats omniscience |
| Aggressive parallelism (when available) | Time is the enemy |
| Data > screenshots | Eye-balling loses to JSON values |
| Audit separate from fix | Self-judging has blind spots |
| Infrastructure first | Stable common components prevent rework |
| Spec-then-code | No freehand structural decisions |

## Supported tech stacks

| Stack | Status |
|-------|--------|
| **iOS (Objective-C)** | ✅ Battle-tested |
| **iOS (Swift)** | ✅ Works (adjust prompts slightly) |
| **Android (Kotlin)** | ✅ Works with minor tweaks |
| **Flutter** | ✅ Works with minor tweaks |
| **React / Vue / Svelte** | ✅ Works with minor tweaks |

The core workflow is framework-agnostic. Phase prompts describe UI in universal terms (layout/colors/fonts/spacing) that every framework has.

## Supported AI environments

| Environment | Mode | Parallel? |
|-------------|------|-----------|
| **Claude Code / CLI** | Full Agent Mode | Yes (4-6 agents) |
| **Cursor** | Task Mode | Partial |
| **Aider** | Linear Mode | No |
| **Plain LLM API** | Linear Mode | No |

See [reference/execution_modes.md](reference/execution_modes.md) for details.

## Directory structure

```
seacity-design-to-code/
├── SKILL.md                    # Main entry (with frontmatter)
├── README.md
├── LICENSE                     # MIT
├── templates/                  # Per-phase agent prompts
│   ├── phase0_intel.md
│   ├── phase1_common.md
│   ├── phase2_spec.md
│   ├── phase3_impl.md
│   ├── phase4_audit.md
│   └── phase5_polish.md
├── reference/                  # How-to docs
│   ├── setup_pencil.md
│   ├── import_from_figma.md
│   ├── execution_modes.md
│   ├── anti_patterns.md
│   └── ios_conventions.md
├── scripts/                    # Helper scripts
│   ├── detect_pencil_mcp.sh
│   └── verify_build.sh
└── examples/
    └── seacity_loan_app.md     # The case study
```

## License

MIT — feel free to use, modify, and share.

## Contributing

This Skill was born from real project scars. If you find better patterns:
- New anti-patterns → `reference/anti_patterns.md`
- Better agent prompts → `templates/`
- Framework-specific tips → `reference/{framework}_conventions.md`

PRs welcome.

## FAQ

**Q: Why Pencil and not Figma API directly?**
A: Figma API has rate limits (~2 req/s). 50-screen projects hit the ceiling fast. Pencil imports the file locally and exposes unlimited access via MCP. Pencil also normalizes Figma/Sketch/XD into one format, so the workflow is design-tool-agnostic.

**Q: How long does a typical run take?**
A: See [reference/execution_modes.md](reference/execution_modes.md). TL;DR: 30 min to 6 hours depending on project size and environment.

**Q: Does it work for huge apps (100+ screens)?**
A: Yes, but split into logical sub-projects (e.g., "auth module", "commerce module"). Run Skill per sub-project.

**Q: What if my design changes?**
A: Re-run. Phase 4 differential audit finds what changed. Phase 5 fixes only the delta.

**Q: I don't use Claude Code. Can I still use this?**
A: Yes. The workflow falls back to Linear Mode and produces the same quality output. It just takes longer.

**Q: Can I override the auto-detected mode?**
A: Yes. Say "用 linear mode" or "用 full agent mode" in your prompt.

## Credits

Built by [@haicheng0516](https://github.com/haicheng0516) (Seacity) from a real project.

## Keywords

`claude-skill` `design-to-code` `figma-to-ios` `pencil-mcp` `ui-generation` `ai-coding-agent` `sketch-to-code` `xd-to-code` `claude-code`
