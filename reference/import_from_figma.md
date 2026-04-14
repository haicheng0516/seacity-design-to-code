# 把 Figma 文件导入 Pencil

## 准备工作

### 方式 A: 本地 `.fig` 文件（推荐）
- 在 Figma 里打开目标文件
- File → Export → Save local copy (.fig)
- 保存到桌面或项目目录

### 方式 B: Figma 链接
- 在 Figma 复制文件链接（任意位置右键 → Copy link）
- 确保文件"可访问"权限（至少 View 权限的链接）

## 导入步骤

1. **打开 Pencil**
2. **新建画板**（`File → New Canvas` 或 `⌘N`）
3. **拖拽导入**：
   - 方式 A：把 `.fig` 文件从 Finder 拖到画板上
   - 方式 B：粘贴 Figma 链接，Pencil 会提示下载
4. **等待解析**（大文件可能需要 10-60 秒）
5. **保存** 画板为 `.pen` 文件，记下路径

## 验证导入

导入成功后你应该看到：
- 所有 Frame 都作为顶层节点出现
- 文字、矢量、图片都保留
- 颜色、字体、约束都正确

如果有缺失：
- 检查 Figma 文件是否有不兼容的功能（最新插件、未发布组件等）
- Pencil 版本是否过旧

## 给 Claude 使用

导入完成后，告诉 Claude：
```
/design-to-code
Pencil 文件在 ~/Desktop/my_app.pen
请按设计稿实现完整 UI
```

或者：
```
把 Pencil 里的设计做成 iOS App
文件路径: /Users/me/projects/mydesign.pen
```

Skill 会自动识别路径并开始 Phase 0。

## 常见问题

### Q: Figma 组件/Variants 丢失怎么办？
A: Pencil 会尽量保留组件关系，但复杂 Variant 可能退化为静态实例。如果需要语义化的"组件+变体"信息，在 Pencil 里手动调整节点 name（例如统一命名 `Button/Primary`, `Button/Secondary`）。

### Q: Auto Layout 能保留吗？
A: 大部分保留。Pencil 把 Figma 的 Auto Layout 映射成自己的 flex layout。如果布局有异常，在 Pencil 里可以手动修正。

### Q: 图片/图标素材丢失？
A: 检查 Figma 是否使用了 External Reference（引用外部图片）。Pencil 需要完整的导出包。建议先在 Figma 里 `Export all` 把素材打包。

### Q: 文件太大怎么办？
A: 按功能模块拆分到多个画板。每个画板一个 `.pen`。Skill 可以分批处理。
