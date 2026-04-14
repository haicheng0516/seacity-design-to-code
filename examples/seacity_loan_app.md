# Case Study: SeacityA01 Loan App

This case study documents the real project that birthed this Skill. Reading it will give you a concrete sense of what the workflow produces.

## Project

**Name**: SeacityA01
**Type**: iOS loan app (菲律宾市场 Philippines market, ₱ currency)
**Scope**: 50 screens including 17 popups
**Stack**: Objective-C, Masonry, CocoaPods
**Starting point**: Existing skeleton project with ~15% design fidelity

## Design

**Source**: Figma file from UI designer → imported into Pencil as `pencil-new.pen`
**Screens**:
- Splash, Login
- Home (KYC state, Products state)
- Order history (list + empty)
- Me/Profile
- KYC 4-step flow
- Face ID + ID Capture
- Loan Confirm
- Credit Info (3 status variants)
- Bank Account list + Change Bank
- EMI Calculator
- Feedback, About, Contact, Repayment, Terms, Official Website
- 17 popup alerts (Upgrade, Rating, Permission, Confirm, etc.)

## Iteration History

| Round | Approach | Agents | Outcome |
|-------|----------|--------|---------|
| 0 | Initial analysis | 1 | ~17% similarity identified |
| 1 | Full rewrite | 6 parallel | ~88% |
| 2 | Screenshot pixel-fix | 4 parallel | ~93% |
| 3 | JSON precision fix | 4 parallel | ~94% |
| 4 | Independent audit | 4 parallel (read-only) | Found structural issues |
| 5 | Final polish | 4 parallel | ~95%+ |

Total: 5 rounds, ~26 agent dispatches, ~200 file edits

## V2 Compression

The Skill's V2 workflow learned from these 5 rounds. Target: same result in 2 rounds.

Key optimizations baked in:
- **Phase 0** extracts design tokens BEFORE coding (eliminated Round 2-3 color fixes)
- **Phase 1** builds common components + all popups FIRST (eliminated Round 5 popup audit)
- **Phase 2** generates specs BEFORE code (eliminated Round 4's structural surprises)
- **Phase 3** contract mechanism (annotations) (reduced Round 4 audit effort)

Expected with V2: ~2 rounds (Phase 0-3 one-shot + Phase 4-5 minor polish)

## Key Learnings That Shaped the Skill

### 1. Design Tool Doesn't Matter — Pencil Normalizes Everything
The Figma file imported to Pencil beautifully. No data loss. `batch_get` exposed everything we needed (x/y/w/h/fills/fonts/effects).

### 2. Common Components Must Come First
Round 1 had agents building bespoke buttons, cards, inputs across modules. By Round 2 we discovered 5 different "dark text fields" in the codebase. Phase 1 now mandates common layer FIRST.

### 3. Popups Are Components Too
We initially thought popups could wait. Wrong. The app has 17 popup variants used across many screens. Building them in Phase 1 (alongside regular components) saved us Round 5 of chaos.

### 4. Audit Agents Need to Be Independent
Round 1 Phase 3 agents self-reported "95%". Round 4 independent audit revealed 17%. Never let the builder be the auditor.

### 5. `batch_get` > Screenshots
Screenshot comparison missed exact pixel values. JSON data from `batch_get` is the source of truth.

### 6. TabBar Behavior Is Non-Obvious
Sub-pages should hide TabBar. Our V1 missed this. Now `BaseViewController` enforces `hidesBottomBarWhenPushed = YES` by default, root VCs override to `NO`.

### 7. Philippines-Specific Details Matter
Initial code was written for India (₹, +91, IFSC code, PAN card). Design was for Philippines (₱, +63, UMID). This cost us the entire Round 1 in form fields. Phase 0 now explicitly extracts market/locale hints.

## Sample Output Artifacts

```
design_data/
├── design_intel.md               # Phase 0 summary
├── color_tokens.json             # 28 colors cataloged
├── typography.json               # 12 font variants
├── spacing.json                  # Corner radius/padding rules
├── component_catalog.json        # 18 reusable components identified
├── variant_groups.json           # CreditInfo 3 variants, etc.
├── asset_manifest.json           # 12 images exported
└── raw/                          # Per-screen JSON dumps

specs/
├── auth.md
├── home.md
├── order.md
├── me.md
├── kyc.md
├── loan_credit.md
├── bank.md
└── secondary.md

audits/
├── auth_audit.md
├── home_audit.md
└── ... (one per module)

FINAL_AUDIT.md
FINAL_REPORT.md
```

## Final Metrics

- **Similarity**: 94-95% average
- **Build**: BUILD SUCCEEDED (0 errors)
- **Files**: 100+ files modified or created
- **Lines of code**: ~15,000
- **Wall time**: ~2 hours (with V2 workflow, estimated)

## Code Size Breakdown

| Layer | Files | Lines |
|-------|-------|-------|
| Base + Common | 22 | ~2,500 |
| Home module | 11 | ~1,400 |
| Order module | 5 | ~800 |
| Me module | 6 | ~900 |
| KYC module | 10 | ~2,800 |
| Loan + Credit module | 14 | ~2,200 |
| Bank module | 4 | ~900 |
| Secondary pages | 10 | ~1,600 |
| Popups | 2 | ~1,200 (17 variants) |

## If You're Reading This to Judge Quality

Look at these specific choices:
- `SCCustomTabBar`: purple capsule selected state, transparent unselected — matches design 1:1
- `CreditStatusHeaderView`: handles 3 status variants in one view
- `LoanConfirmViewController`: wraps content in unified `#1E1E1E` rounded-16 card (Round 5 fix)
- `EmergencyContactCell`: Name + Phone in single grouped 120pt card (Round 5 fix)
- `SCAlertPopupView` + 17 factory methods — single popup system, unified styling

These patterns are what Phase 0's "component catalog" and Phase 2's "variant groups" enable.
