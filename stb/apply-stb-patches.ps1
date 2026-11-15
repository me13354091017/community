# STB 品牌与功能补丁（构建前执行）
# 1) 板中板：把 ICC-CE 的「小白板」按希沃板中板的形态改造（命名 / 白底黑笔 / 主板上居中 / 关闭贴回）
# 2) 性能：把几项偏“高质量低性能”的默认值调到“平衡”，弱 GPU 一体机上更稳
$ErrorActionPreference = 'Stop'

function Patch-File {
    param([string]$Path, [string]$Old, [string]$New, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path)) { throw "missing file: $Path ($Label)" }
    $raw = Get-Content -LiteralPath $Path -Raw -Encoding utf8
    if (-not $raw.Contains($Old)) { throw "anchor not found: $Label ($Path)" }
    $raw = $raw.Replace($Old, $New)
    Set-Content -LiteralPath $Path -Value $raw -NoNewline -Encoding utf8
    Write-Host "PATCHED $Label"
}

Write-Host 'PHASE A: 板中板命名'
Patch-File 'Ink Canvas/Properties/FloatingBarStrings.resx' `
    '<data name="FloatingBar_MiniWhiteboard" xml:space="preserve">
    <value>小白板</value>' `
    '<data name="FloatingBar_MiniWhiteboard" xml:space="preserve">
    <value>板中板</value>' `
    'resx: 小白板 -> 板中板'

Write-Host 'PHASE B: 板中板外观与默认尺寸'
Patch-File 'Ink Canvas/Resources/Settings.cs' `
    '        public double DefaultWidth { get; set; } = 400;' `
    '        public double DefaultWidth { get; set; } = 640;' `
    'mini default width 640'
Patch-File 'Ink Canvas/Resources/Settings.cs' `
    '        public double DefaultHeight { get; set; } = 300;' `
    '        public double DefaultHeight { get; set; } = 420;' `
    'mini default height 420'
Patch-File 'Ink Canvas/Resources/Settings.cs' `
    '        public string BackgroundColor { get; set; } = "#FF2A2A2A";' `
    '        public string BackgroundColor { get; set; } = "#FFFFFFFF";' `
    'mini background white'
Patch-File 'Ink Canvas/Resources/Settings.cs' `
    '        public string PenColor { get; set; } = "#FFFFFFFF";' `
    '        public string PenColor { get; set; } = "#FF000000";' `
    'mini pen black'
Patch-File 'Ink Canvas/Resources/Settings.cs' `
    '        public int CurrentColorIndex { get; set; } = 0;' `
    '        public int CurrentColorIndex { get; set; } = 1;' `
    'mini default color index -> black'

Write-Host 'PHASE C: 板中板在主板上居中弹出'
Patch-File 'Ink Canvas/MainWindow_cs/MW_MiniWhiteboard.cs' `
    '            _miniWhiteboardWindow.Owner = this;' `
    '            _miniWhiteboardWindow.Owner = this;
            _miniWhiteboardWindow.WindowStartupLocation = WindowStartupLocation.CenterOwner;' `
    'mini window center-owner'

Write-Host 'PHASE D: 板中板关闭时把板书贴回主白板（可撤销）'
Patch-File 'Ink Canvas/Windows/MiniWhiteboardWindow.xaml.cs' `
    '            // Save current page strokes before closing
            SaveCurrentPage();

            LogHelper.WriteLogToFile("小白板窗口已关闭", LogHelper.LogType.Event);' `
    '            // Save current page strokes before closing
            SaveCurrentPage();

            // STB: 板中板关闭时把板书按屏幕位置贴回主白板，并登记到时间机器（可撤销）
            try
            {
                if (Owner is MainWindow ownerWindow)
                {
                    ownerWindow.StbMergeMiniWhiteboard(this, MiniInkCanvas == null ? null : MiniInkCanvas.Strokes);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLogToFile("板中板贴回失败: " + ex.Message, LogHelper.LogType.Error);
            }

            LogHelper.WriteLogToFile("板中板窗口已关闭", LogHelper.LogType.Event);' `
    'mini window merge on closing'

Patch-File 'Ink Canvas/MainWindow_cs/MW_MiniWhiteboard.cs' `
    '        internal void CloseMiniWhiteboard()
        {
            if (_miniWhiteboardWindow != null && _miniWhiteboardWindow.IsLoaded)
            {
                _miniWhiteboardWindow.Close();
            }
            _miniWhiteboardWindow = null;
        }' `
    '        internal void CloseMiniWhiteboard()
        {
            if (_miniWhiteboardWindow != null && _miniWhiteboardWindow.IsLoaded)
            {
                _miniWhiteboardWindow.Close();
            }
            _miniWhiteboardWindow = null;
        }

        /// <summary>
        /// STB 板中板：把浮窗上的墨迹按窗口在屏幕上的实际位置贴回当前白板，并登记到时间机器
        /// </summary>
        internal void StbMergeMiniWhiteboard(MiniWhiteboardWindow mini, System.Windows.Ink.StrokeCollection strokes)
        {
            try
            {
                if (mini == null || strokes == null || strokes.Count == 0) return;
                var miniCanvas = mini.MiniInkCanvas;
                if (miniCanvas == null) return;

                double dpi = 1.0;
                var source = PresentationSource.FromVisual(this);
                if (source != null && source.CompositionTarget != null)
                {
                    dpi = source.CompositionTarget.TransformToDevice.M11;
                    if (dpi <= 0) dpi = 1.0;
                }

                var miniOrigin = miniCanvas.PointToScreen(new System.Windows.Point(0, 0));
                var mainOrigin = inkCanvas.PointToScreen(new System.Windows.Point(0, 0));
                var dx = (miniOrigin.X - mainOrigin.X) / dpi;
                var dy = (miniOrigin.Y - mainOrigin.Y) / dpi;

                var merged = new System.Windows.Ink.StrokeCollection();
                foreach (var stroke in strokes)
                {
                    var clone = stroke.Clone();
                    var matrix = new System.Windows.Media.Matrix();
                    matrix.Translate(dx, dy);
                    clone.Transform(matrix);
                    merged.Add(clone);
                }

                inkCanvas.Select(new System.Windows.Ink.StrokeCollection());
                inkCanvas.Strokes.Add(merged);
                try { timeMachine.CommitStrokeUserInputHistory(merged); } catch { }
                LogHelper.WriteLogToFile("板中板贴回主白板: " + merged.Count + " 条笔迹");
            }
            catch (Exception ex)
            {
                LogHelper.WriteLogToFile("板中板贴回主白板失败: " + ex.Message, LogHelper.LogType.Error);
            }
        }' `
    'mini merge-to-main method'

Write-Host 'PHASE E: 性能默认值（弱 GPU 一体机更稳）'
Patch-File 'Ink Canvas/Resources/Settings.cs' `
    '        public int InkSmoothingQuality { get; set; } = 2;' `
    '        public int InkSmoothingQuality { get; set; } = 1;' `
    'ink smoothing quality -> balanced'
Patch-File 'Ink Canvas/Resources/Settings.cs' `
    '        public bool DisableToolbarAnimation { get; set; } = false;' `
    '        public bool DisableToolbarAnimation { get; set; } = true;' `
    'disable toolbar animation'
Patch-File 'Ink Canvas/Resources/Settings.cs' `
    '        public string WindowBackdrop { get; set; } = "Mica";' `
    '        public string WindowBackdrop { get; set; } = "None";' `
    'window backdrop -> none'
Patch-File 'Ink Canvas/Resources/Settings.cs' `
    '        public bool ShowPPTEnhancedPreviewLoadingAnimation { get; set; } = true;' `
    '        public bool ShowPPTEnhancedPreviewLoadingAnimation { get; set; } = false;' `
    'ppt preview loading animation off'

Write-Host 'STB PATCHES DONE'
