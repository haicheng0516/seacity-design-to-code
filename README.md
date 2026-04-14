# design-to-code

A Claude Code Skill that turns design files (Figma/Sketch/XD) into high-fidelity UI code through a systematic, parallelized agent workflow powered by Pencil MCP.

**Typical result: 95%+ visual similarity to the original design in 2 iteration rounds.**

## What this does

You give Claude a design file. It generates the full UI code with near-pixel accuracy. That's it.

Under the hood, it runs a 6-phase workflow that dispatches multiple Claude agents in parallel, each responsible for a specific part of the work:

1. **Design Intel Extraction** — pulls colors, fonts, spacing, components, exports assets
2. **Common Layer Setup** — builds all reusable components BEFORE screens
3. **Per-Screen Spec Generation** — each agent produces a precise spec doc
4. **Parallel Implementation** — agents write code from specs (contract-based)
5. **Differential Audit** — independent review agents find gaps
6. **Final Polish** — targeted fixes for remaining issues

## Quick start

### Prerequisites (one-time setup)

1. **Install Pencil** — a design tool that can import Figma/Sketch/XD files and expose them via MCP
   See [reference/setup_pencil.md](reference/setup_pencil.md)

2. **Install this Skill**:
   ```bash
   cd ~/.claude/skills/
   git clone https://github.com/YOUR_USERNAME/design-to-code.git
   ```

3. **Verify**: In Claude Code, ask "列出 pencil 工具" — you should see `mcp__pencil__*` entries

### Using the Skill

1. Open Pencil, create a new canvas
2. Drag your Figma (or Sketch / XD) file into the canvas — it imports automatically
3. In Claude Code:
   ```
   /design-to-code
   ```
   Or just ask: "按这个设计稿把 UI 做出来"

The Skill takes over and runs the full workflow.

## What you get

After the workflow completes:

- ✅ All UI screens coded to match the design
- ✅ Reusable components encapsulated (no copy-paste)
- ✅ Design tokens centralized (colors, fonts, spacing)
- ✅ Zero compile errors, runs in simulator/emulator
- ✅ A `FINAL_REPORT.md` with per-screen similarity scores
- ✅ `design_data/*.json` archived for future reference

## Real-world results

This Skill was extracted from a production iOS project (`SeacityA01`) that went from 17% initial similarity to 95%+ through 5 iteration rounds. The V2 workflow baked into this Skill compresses that to 2 rounds.

See [examples/seacity_loan_app.md](examples/seacity_loan_app.md) for the full case study.

## Design philosophy

- **Commander never codes** — the main agent only dispatches and validates
- **Aggressive parallelism** — 4-6 agents work simultaneously per phase
- **Data over screenshots** — precise JSON values beat visual guessing
- **Audit is separate from fix** — no self-judging
- **Infrastructure first** — reusable components built before screens
- **Spec-then-code** — no freehand structural decisions

## Supported tech stacks

- **iOS** (Objective-C, Swift) — battle-tested
- **Android** (Kotlin, Java) — works with minor prompt tweaks
- **Web** (React, Vue) — works with minor prompt tweaks
- **Flutter** — works with minor prompt tweaks

The core workflow is framework-agnostic. The Phase prompts describe UI in terms of "layout / colors / fonts / spacing" which every framework has.

## License

MIT

## Contributing

This Skill was born from a real project's scars. If you find better patterns while using it, PRs welcome:
- New anti-patterns in `reference/anti_patterns.md`
- Better agent prompts in `templates/`
- Framework-specific tips in `reference/{framework}_conventions.md`

## FAQ

**Q: Why Pencil and not Figma API directly?**
A: Figma API has rate limits (~2 req/s), 50-screen projects hit the ceiling fast. Pencil imports the file locally and exposes unlimited access via MCP. Pencil also normalizes Figma/Sketch/XD into one format, so the workflow is design-tool-agnostic.

**Q: How long does a typical run take?**
A: For a 30-50 screen app: ~30-60 minutes of wall time. Most of it is the agents working in parallel. You're free to watch or go get coffee.

**Q: Does it work for huge apps (100+ screens)?**
A: Yes, but split into logical sub-projects (e.g., "auth module", "commerce module"). Run Skill per sub-project.

**Q: What if my design changes?**
A: Re-run the Skill. Phase 4 differential audit finds what changed. Phase 5 fixes only the delta.
