# Pencil MCP 一次性安装指南

整个 design-to-code Skill 依赖 Pencil MCP 访问设计文件。按以下步骤一次性配置好。

## 步骤 1: 安装 Pencil 应用

访问 Pencil 官网下载对应平台的安装包，安装后启动一次。

> 注：Pencil 是一个设计协作/处理工具，支持导入 Figma/Sketch/XD 文件并以统一格式存储为 `.pen` 文件。

## 步骤 2: 启用 Pencil MCP 服务

启动 Pencil，在菜单中找到：
- `Preferences` / `Settings` → `Developer` / `MCP` 标签
- 勾选 `Enable MCP Server`
- 记下显示的命令或端点

## 步骤 3: 在 Claude Code 注册 MCP

在终端执行（具体命令以 Pencil 提示为准）：

```bash
claude mcp add pencil --command "<Pencil 给出的命令>"
```

或手动编辑 `~/.claude/settings.json`：

```json
{
  "mcpServers": {
    "pencil": {
      "command": "<pencil-mcp-executable>",
      "args": []
    }
  }
}
```

## 步骤 4: 重启 Claude Code

完全退出 Claude Code，重新打开。

## 步骤 5: 验证安装

在 Claude Code 里说：
```
列出 pencil 工具
```

预期看到以下工具（或类似）：
- `mcp__pencil__get_editor_state`
- `mcp__pencil__batch_get`
- `mcp__pencil__get_screenshot`
- `mcp__pencil__export_nodes`
- `mcp__pencil__open_document`
- `mcp__pencil__get_variables`
- `mcp__pencil__batch_design`

如果列表为空或缺工具：
- 检查 Pencil 是否在运行
- 检查 MCP 服务是否启用
- 重启 Claude Code

## 常见问题

### Q: Pencil 是必需的吗？能不能直接用 Figma MCP？
A: 可以直接用 Figma MCP，但有 API 速率限制（~2 请求/秒），50+ 屏项目会明显变慢，并且 Figma/Sketch/XD 的 JSON 结构不一致，需要写多套 Agent 模板。Pencil 作为统一中间层更稳定、更快。

### Q: Pencil 怎么导入 Figma 文件？
A: 打开 Pencil，新建画板，把 `.fig` 文件直接拖入画板即可。详细步骤见 `import_from_figma.md`。

### Q: 对免费/付费账号有要求吗？
A: 不影响 MCP 访问。具体功能限制请查看 Pencil 官方文档。

### Q: MCP 连接不稳定怎么办？
A:
- 关闭其他 MCP 服务测试是否干扰
- Pencil 重新勾选 Enable MCP
- 查看 Claude Code 日志 `~/.claude/logs/`

## 配置完成后

你只需在每个新项目里：
1. 打开 Pencil 新建画板
2. 拖入设计文件
3. 运行 `/design-to-code`

Skill 自动跑完整个流程。
