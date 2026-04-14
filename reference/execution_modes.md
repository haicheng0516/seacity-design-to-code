# 三种执行模式详解

这个 Skill 根据运行环境自动选择合适的执行模式。

## 模式 1: FULL AGENT MODE（推荐）

### 环境要求
- Claude Code / Claude CLI
- 能访问 `Agent` 或 `subagent` 派遣工具
- 能运行 `mcp__pencil__*` MCP 工具

### 工作方式
指挥官（主 Agent）通过派遣多个子 Agent 并行工作：

```
指挥官 (主 Agent)
  ├─ 派遣 Agent 1 ─── Phase 2 / Module A spec
  ├─ 派遣 Agent 2 ─── Phase 2 / Module B spec
  ├─ 派遣 Agent 3 ─── Phase 2 / Module C spec
  ├─ 派遣 Agent 4 ─── Phase 2 / Module D spec
  └─ 派遣 Agent 5 ─── Phase 2 / Module E spec
      ↓ 所有 Agent 并行工作
      ↓ 结果收集回指挥官
  → Phase 3 同理
```

### 并行度
- Phase 0: 1 Agent
- Phase 1: 1 Agent（可再分为组件层+弹窗层各 1）
- Phase 2/3/4: 4-6 Agents
- Phase 5: 按需 N Agents

### 适用项目
- 大型项目（30+ 屏幕）
- 时间敏感的任务
- 需要并行压缩时间

### 预期耗时
- 30 屏项目：~30 分钟
- 50 屏项目：~60 分钟
- 100 屏项目：~90 分钟

---

## 模式 2: TASK MODE（半并行）

### 环境要求
- 支持 `TaskCreate` / `TaskUpdate` 工具
- 可使用 MCP
- 无 Agent 派遣能力

### 工作方式
把"每个 Agent 的工作"转成 Task 队列，主循环依次处理：

```
for module in [Home, Order, Me, KYC, Loan, Bank, Secondary]:
    TaskCreate("Phase 2: spec for " + module)

for task in TaskList():
    TaskUpdate(task, in_progress)
    execute_phase2_for_module(task.module)
    TaskUpdate(task, completed)
```

### 好处
- 保持清晰的模块化
- 可视化进度（Tasks 面板）
- 仍然比纯线性稍快（内存管理更好）

### 适用项目
- Cursor / 有限 Agent 支持的环境
- 小到中型项目

### 预期耗时
- 30 屏：~60 分钟
- 50 屏：~2 小时

---

## 模式 3: LINEAR MODE（单线程）

### 环境要求
- 最低要求：能调用 MCP 工具 + 读写文件
- 适用任何 LLM 编码助手

### 工作方式
所有工作在同一个上下文中顺序执行：

```
Phase 0: 情报提取
  ↓
Phase 1: 通用组件层
  ↓
Phase 2 Module 1: 读 pencil → 写 spec
Phase 2 Module 2: 读 pencil → 写 spec
...
  ↓
Phase 3 Module 1: 读 spec → 写代码 → 编译
Phase 3 Module 2: 读 spec → 写代码 → 编译
...
```

### 额外纪律要求

Linear Mode 下**没有并行 Agent 互相兜底**，所以必须更严格：

1. **每改一屏立即编译** — 不要积累错误
2. **每 Phase 结束写 checkpoint** — 保存到 `progress.md`，方便中断后恢复
3. **上下文管理** — 每处理一个模块后清理无关文件引用，避免上下文爆炸
4. **严格 spec-then-code** — 绝不跳过 spec 阶段

### 挑战

- **上下文限制** — 大项目的上下文可能不够，建议分批处理
- **无"第二意见"** — 没有独立审计 Agent，容易有盲点

### 缓解措施

- 每个 Phase 结束把关键信息写入文件，让下次调用能恢复
- Phase 4 审计时**换视角**：假装自己是不同的 QA Agent，刻意挑刺
- 每屏完成后立即对比设计截图和实现截图（视觉辅助审计）

### 适用项目
- 小型项目（<20 屏）
- 使用非 Claude 的 AI 助手
- 没有 Agent 派遣能力的环境

### 预期耗时
- 10 屏：~45 分钟
- 30 屏：~3 小时
- 50 屏：~6 小时

---

## 自动检测逻辑

Skill 启动时按以下伪代码检测：

```python
def detect_mode():
    tools = get_available_tools()

    if "Agent" in tools or "subagent" in tools:
        return "FULL_AGENT_MODE"

    if "TaskCreate" in tools and "TaskUpdate" in tools:
        return "TASK_MODE"

    return "LINEAR_MODE"

mode = detect_mode()
print(f"Running in {mode}")
```

检测结果会影响：
- Phase 2-5 的执行策略
- 进度追踪方式
- checkpoint 频率

## 切换模式

如果用户明确指定模式，可覆盖检测结果：

```
用户: 用 linear mode 跑这个 Skill
→ 强制 LINEAR_MODE，即使在 Claude Code 里
```

使用场景：
- 测试 Linear Mode 的正确性
- 上下文敏感任务不适合多 Agent 切换
- 用户想看完整的决策过程
