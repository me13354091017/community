# School Tools Board · 课堂白板（STB）— 桌面版

> 本仓库是 **School Tools Board（STB）课堂白板** 的 Windows 桌面版，属于 [SCHOOL_TOOLS](https://me13354091017.github.io/school_tools/) 旗下应用，字母标记 **STB**。
>
> 底座是开源项目 **[InkCanvasForClass Community Edition（ICC-CE）](https://github.com/InkCanvasForClass/community)**（作者 [CJKmkp](https://github.com/CJKmkp) 及各位贡献者，GPL-3.0）。感谢上游三代开发（WXRIW/Ink-Canvas → ChangSakura/Ink-Canvas → InkCanvasForClass → ICC-CE）打下的墨迹、PPT 批注、多页白板、手势基础；本仓库在其源码上做品牌与面向课堂场景的改造。

在线版（Web，零依赖）：<https://me13354091017.github.io/SCHOOL_TOOLS_BOARD/>

## 为什么以 ICC-CE 为底座

ICC-CE 是面向教室一体机的成熟墨迹白板，很多关键能力是“用久才发现必须有”的，自研很难在短期内达到同等手感：

| 能力 | 说明 |
|---|---|
| **PPT 演示批注** | 在 PowerPoint 放映中用笔写、按幻灯片逐页保存墨迹，翻页后墨迹跟着走，合上再开还在 |
| **多页白板 + 时间机器** | 一节课上百页滑页翻动、无限步撤销/重做、页缩略图与页面管理 |
| **手势与笔压** | 双指缩放/旋转/平移，笔压直接参与笔宽，手掌防误触 |
| **形状与教学工具** | 直线/矩形/椭圆/箭头/抛物线等形状、坐标系与函数图像、计时器、聚光灯等 |

## 获取

- 构建产物：仓库 **Actions → STB Desktop Build → 最新运行 → Artifacts → `SchoolToolsBoard-STB-win-x64`**
- 发布版：仓库 **Releases**（由 CI 在打标签时自动创建）
- 运行环境：Windows 10 1809 / Windows 11，x64 一体机；PPT 批注需要本机安装 PowerPoint

## 本地构建

需要 .NET SDK 10 与 Visual Studio 生成工具（含 MSBuild）：

```powershell
dotnet restore "Ink Canvas/InkCanvasForClass.csproj"
msbuild "Ink Canvas/InkCanvasForClass.csproj" /p:Configuration=Release /p:Platform=x64 /m
```

产物在 `Ink Canvas/bin/Release/x64/net10.0-windows10.0.19041.0/`，主程序 `SchoolToolsBoard.exe`。

## 本仓库相对上游的改动

改名与图标不直接写入源码，而是在 CI 里构建前打补丁（见 `.github/workflows/stb-build.yml`），好处是**永不与上游冲突**，以后 `git pull` 跟着 ICC-CE 升级不会破：

- `AssemblyName`：`InkCanvasForClass` → `SchoolToolsBoard`（主程序 `SchoolToolsBoard.exe`）
- 窗口标题：`InkCanvasforClass` → `School Tools Board · 课堂白板`
- 应用图标：由 `stb/icon.svg`（STB）现场生成，覆盖 `Resources/icc.ico`

功能层面暂不改动上游代码，先保证能跟着上游升级、能稳定出包。后续要加的课堂特性会单独放分支。

## 许可与致谢

本仓库沿用 **GPL-3.0**（与上游一致）。你可以自由使用、修改、再发布，但修改后必须同样以 GPL-3.0 开源，并保留上游版权声明。

完整许可证见 [LICENSE](LICENSE)；上游项目：<https://github.com/InkCanvasForClass/community>，官网 <https://iccce.ink>。

上游 README 中原有的使用须知、免责声明、贡献指南同样适用，请一并阅读（本次未改动）。
