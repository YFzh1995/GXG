# GXG 一键安装脚本 (PowerShell)
# GitHub: https://github.com/YFzh1995/GXG
#
# 用法:
#   powershell -ExecutionPolicy Bypass -File install.ps1
#   powershell -ExecutionPolicy Bypass -File install.ps1 opencode
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Path C:\myskills
#   powershell -ExecutionPolicy Bypass -File install.ps1 -List
#
# 或者直接运行:
#   .\install.ps1
#   .\install.ps1 codex
#   .\install.ps1 -Path C:\myskills
#
# 支持平台: opencode | codex | claude-code | cursor | workbuddy | 自定义路径

param(
    [Parameter(Position = 0)]
    [string]$Platform = "",

    [string]$Path = "",

    [switch]$List = $false
)

$ErrorActionPreference = "Stop"
$REPO_URL = "https://github.com/YFzh1995/GXG"
$REPO_ARCHIVE = "$REPO_URL/archive/main.zip"

# ── 函数 ──────────────────────────────────────────────

function Write-Info {
    Write-Host "[GXG] $args" -ForegroundColor Green
}

function Write-Warn {
    Write-Host "[GXG] $args" -ForegroundColor Yellow
}

function Write-Error-Exit {
    Write-Host "[GXG] $args" -ForegroundColor Red
    exit 1
}

# ── 平台检测 ──────────────────────────────────────────

function Get-InstalledPlatforms {
    $platforms = @()
    $home = $env:USERPROFILE

    if (Test-Path "$home\.config\opencode") {
        $platforms += "opencode"
    }
    if (Test-Path "$home\.codex") {
        $platforms += "codex"
    }
    if (Test-Path "$home\.claude") {
        $platforms += "claude-code"
    }
    if (Test-Path "$home\.cursor") {
        $platforms += "cursor"
    }
    if (Test-Path "$home\.workbuddy") {
        $platforms += "workbuddy"
    }

    return $platforms
}

function Get-SkillsDir {
    param([string]$platform)
    $home = $env:USERPROFILE

    switch ($platform) {
        "opencode"    { return "$home\.config\opencode\skills" }
        "codex"       { return "$home\.codex\skills" }
        "claude-code" { return "$home\.claude\skills" }
        "cursor"      { return "$home\.cursor\skills" }
        "workbuddy"   { return "$home\.workbuddy\skills" }
        default       { return $platform }
    }
}

# ── 列表模式 ──────────────────────────────────────────

if ($List) {
    Write-Host "支持的平台："
    Write-Host "  opencode      —  ~/.config/opencode/skills/"
    Write-Host "  codex         —  ~/.codex/skills/"
    Write-Host "  claude-code   —  ~/.claude/skills/"
    Write-Host "  cursor        —  ~/.cursor/skills/"
    Write-Host "  workbuddy     —  ~/.workbuddy/skills/"
    Write-Host ""
    Write-Host "自定义路径：install.ps1 -Path C:\your\custom\path"
    exit 0
}

# ── 确定目标路径 ──────────────────────────────────────

if ($Path -ne "") {
    $SKILLS_DIR = $Path
    $platform_name = "自定义路径"
} elseif ($Platform -ne "") {
    $platform_name = $Platform
    $SKILLS_DIR = Get-SkillsDir $Platform
} else {
    $installed = Get-InstalledPlatforms
    if ($installed.Count -eq 0) {
        Write-Warn "未检测到已知平台，默认使用 opencode 路径"
        $platform_name = "opencode"
        $SKILLS_DIR = Get-SkillsDir "opencode"
    } elseif ($installed.Count -eq 1) {
        $platform_name = $installed[0]
        $SKILLS_DIR = Get-SkillsDir $installed[0]
    } else {
        Write-Warn "检测到多个已安装平台: $($installed -join ', ')"
        Write-Warn "请指定目标平台，例如: .\install.ps1 opencode"
        Write-Warn "或使用 -Path 指定自定义路径"
        Write-Warn "---"
        foreach ($p in $installed) {
            Write-Warn "  .\install.ps1 $p"
        }
        exit 1
    }
}

# ── 打印安装信息 ──────────────────────────────────────

Write-Host ""
Write-Host "  ╔══════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║  GXG · 观星哥的财经职场工具箱  ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Info "平台:  $platform_name"
Write-Info "路径:  $SKILLS_DIR"
Write-Host ""

# ── 创建目录 ──────────────────────────────────────────

New-Item -ItemType Directory -Force -Path $SKILLS_DIR | Out-Null

# ── 判断运行模式 ──────────────────────────────────────

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$IS_LOCAL = (Test-Path (Join-Path $SCRIPT_DIR "SKILL.md")) -and (Test-Path (Join-Path $SCRIPT_DIR "skills"))

if ($IS_LOCAL) {
    $REPO_DIR = $SCRIPT_DIR
} else {
    # 远程模式：下载 zip 到临时目录
    $TEMP_DIR = Join-Path $env:TEMP "gxg-install-$(Get-Random)"
    $ZIP_FILE = Join-Path $env:TEMP "gxg-main.zip"

    Write-Info "下载 GXG..."
    try {
        Invoke-WebRequest -Uri $REPO_ARCHIVE -OutFile $ZIP_FILE -TimeoutSec 30
        Expand-Archive -Path $ZIP_FILE -DestinationPath $TEMP_DIR -Force
        Remove-Item $ZIP_FILE
    } catch {
        if (Test-Path $TEMP_DIR) { Remove-Item -Recurse -Force $TEMP_DIR }
        if (Test-Path $ZIP_FILE) { Remove-Item -Force $ZIP_FILE }
        Write-Error-Exit "下载失败，请检查网络连接: $_"
    }

    # GitHub zip 解压有一个外层目录 GXG-main/
    $REPO_DIR = Join-Path $TEMP_DIR "GXG-main"
    if (-not (Test-Path (Join-Path $REPO_DIR "SKILL.md"))) {
        # 可能解压结构不同，尝试查找
        $items = Get-ChildItem $TEMP_DIR -Directory
        if ($items.Count -eq 1) {
            $REPO_DIR = $items[0].FullName
        }
    }
}

# ── 安装主路由 ────────────────────────────────────────

Write-Info "安装主路由..."
New-Item -ItemType Directory -Force -Path "$SKILLS_DIR\gxg" | Out-Null
Copy-Item (Join-Path $REPO_DIR "SKILL.md") "$SKILLS_DIR\gxg\" -Force
Copy-Item (Join-Path $REPO_DIR "VERSION") "$SKILLS_DIR\gxg\" -Force
Copy-Item (Join-Path $REPO_DIR "install.sh") "$SKILLS_DIR\gxg\" -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $REPO_DIR "install.ps1") "$SKILLS_DIR\gxg\" -Force -ErrorAction SilentlyContinue
if (Test-Path (Join-Path $REPO_DIR "agents")) {
    Copy-Item (Join-Path $REPO_DIR "agents") "$SKILLS_DIR\gxg\agents\" -Recurse -Force
}

# 初始化 .last_check
if (-not (Test-Path "$SKILLS_DIR\gxg\.last_check")) {
    "2000-01-01" | Out-File -FilePath "$SKILLS_DIR\gxg\.last_check" -Encoding ascii
}

# ── 安装子技能 ────────────────────────────────────────

Write-Host ""
$skillsDir = Join-Path $REPO_DIR "skills"
if (Test-Path $skillsDir) {
    foreach ($skillDir in (Get-ChildItem $skillsDir -Directory)) {
        $skillName = $skillDir.Name
        $target = Join-Path $SKILLS_DIR $skillName

        Write-Info "安装 ${skillName}..."

        # 跳过独立 git 仓库
        if (Test-Path (Join-Path $target ".git")) {
            Write-Warn "${skillName} 是独立 git 仓库，跳过（如需覆盖请先删除该目录）"
            continue
        }

        # 备份旧版本
        if (Test-Path $target) {
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $backupDir = Join-Path $SKILLS_DIR ".gxg-backup" "$skillName-$timestamp"
            New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
            Copy-Item $target $backupDir -Recurse -Force
            Write-Info "  已备份到 ${backupDir}"
        }

        # 删除旧版本，写入新版本
        Remove-Item $target -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item $skillDir.FullName $target -Recurse -Force

        Write-Info "  ${skillName} ✓"
    }
}

# ── 清理临时目录 ──────────────────────────────────────

if (-not $IS_LOCAL -and $TEMP_DIR) {
    Remove-Item -Recurse -Force $TEMP_DIR -ErrorAction SilentlyContinue
}

# ── 完成 ──────────────────────────────────────────────

Write-Host ""
Write-Info "──────────────────────────────────────"
Write-Info "GXG 安装完成！"
Write-Info ""
Write-Info "已安装子技能："
Write-Host "  ● 面试辅导与陪跑教练   →  gxg-interview" -ForegroundColor Cyan
Write-Host "  ● 商业洞察               →  gxg-insight" -ForegroundColor Cyan
Write-Host ""
Write-Info "使用方法：在 AI 对话中输入 @gxg 即可开始"
Write-Info "手动更新：重新运行本安装脚本即可"
Write-Info "         powershell -ExecutionPolicy Bypass -File install.ps1"
Write-Host ""
Write-Info "观星哥 | 小红书：观星哥 | 微信：guanxingge2025"
Write-Host ""
