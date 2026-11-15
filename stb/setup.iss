; STB 桌面版安装包（Inno Setup 6）
; 该脚本仅打包，不负责构建；app 目录由 CI 从 stb-latest 的 zip 解出

#define AppName "SchoolToolsBoard"
#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef AppDir
  #define AppDir "app"
#endif

[Setup]
AppId={{B7D2F3A4-2C61-4E9B-9A7E-5D2C4E1F8B03}
AppName=School Tools Board · 课堂白板
AppVersion={#AppVersion}
AppVerName=SchoolToolsBoard {#AppVersion}
AppPublisher=SCHOOL_TOOLS
AppPublisherURL=https://me13354091017.github.io/school_tools/
AppSupportURL=https://github.com/me13354091017/SCHOOL_TOOLS_BOARD
DefaultDirName={autopf}\SchoolToolsBoard
DefaultGroupName=SchoolToolsBoard
DisableProgramGroupPage=yes
OutputDir=out
OutputBaseFilename=SchoolToolsBoard-STB-Setup-{#AppVersion}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
UninstallDisplayName=SchoolToolsBoard · 课堂白板
#ifdef IconFile
SetupIconFile={#IconFile}
#endif

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加任务:"

[Files]
Source: "{#AppDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\SchoolToolsBoard"; Filename: "{app}\SchoolToolsBoard.exe"
Name: "{autodesktop}\SchoolToolsBoard"; Filename: "{app}\SchoolToolsBoard.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\SchoolToolsBoard.exe"; Description: "立即启动 SchoolToolsBoard"; Flags: nowait postinstall skipifsilent
