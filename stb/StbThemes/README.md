# STB 主题文件

- `Styles/StbLight.xaml` / `Styles/StbDark.xaml`：全局明/暗调色覆盖字典，由 `MW_AutoTheme.SetTheme` 在 Light/Dark 之后合并。
- `FloatingBarThemes/stb-light`、`FloatingBarThemes/stb-dark`：外置浮动栏主题包（manifest.json + Theme.xaml），构建时随发布目录一起打包。

CI 步骤：`stb-build.yml` 的 PHASE 3.6 把 `Styles/*.xaml` 拷入 `Ink Canvas/Resources/Styles` 参与编译；PHASE 8 把 `FloatingBarThemes/*` 拷进发布目录的 `FloatingBarThemes`。
