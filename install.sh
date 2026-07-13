#!/usr/bin/env bash
#
# GXG 一键安装脚本
# GitHub: https://github.com/YFzh1995/GXG
#
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/YFzh1995/GXG/main/install.sh | bash
#   bash install.sh                    # 自动检测平台
#   bash install.sh opencode           # 指定平台
#   bash install.sh --path ~/myskills  # 自定义安装路径
#   bash install.sh --list             # 查看支持的平台列表
#
# 支持平台: opencode | codex | claude-code | cursor | workbuddy | 自定义路径

set -euo pipefail

# ── 颜色 ──────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── 函数 ──────────────────────────────────────────────
info()  { echo -e "${GREEN}[GXG]${NC} $1"; }
warn()  { echo -e "${YELLOW}[GXG]${NC} $1"; }
error() { echo -e "${RED}[GXG]${NC} $1"; exit 1; }

# ── 平台检测 ──────────────────────────────────────────
detect_platform() {
  local platforms=()
  if command -v opencode &>/dev/null || [ -d "$HOME/.config/opencode" ]; then
    platforms+=("opencode")
  fi
  if [ -d "$HOME/.codex" ]; then
    platforms+=("codex")
  fi
  if [ -d "$HOME/.claude" ]; then
    platforms+=("claude-code")
  fi
  if [ -d "$HOME/.cursor" ]; then
    platforms+=("cursor")
  fi
  if [ -d "$HOME/.workbuddy" ]; then
    platforms+=("workbuddy")
  fi

  if [ ${#platforms[@]} -eq 0 ]; then
    warn "未检测到已知平台，默认使用 opencode 路径"
    warn "可使用 --path 指定自定义路径，或 --list 查看所有支持平台"
    echo "opencode"
    return
  fi

  if [ ${#platforms[@]} -eq 1 ]; then
    echo "${platforms[0]}"
    return
  fi

  # 多个平台共存时，不静默选择一个
  warn "检测到多个已安装平台: ${platforms[*]}"
  warn "请指定目标平台，例如: bash install.sh opencode"
  warn "或使用 --path 指定自定义路径"
  warn "---"
  for p in "${platforms[@]}"; do
    warn "  bash install.sh $p"
  done
  exit 1
}

get_skills_dir() {
  local platform="$1"
  case "$platform" in
    opencode)    echo "$HOME/.config/opencode/skills" ;;
    codex)       echo "$HOME/.codex/skills" ;;
    claude-code) echo "$HOME/.claude/skills" ;;
    cursor)      echo "$HOME/.cursor/skills" ;;
    workbuddy)   echo "$HOME/.workbuddy/skills" ;;
    *)           echo "$platform" ;;
  esac
}

# ── 参数解析 ──────────────────────────────────────────
PLATFORM=""
CUSTOM_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path)
      if [[ $# -lt 2 || -z "${2:-}" ]]; then
        error "--path 需要一个目标路径，例如: bash install.sh --path /your/custom/path"
      fi
      CUSTOM_PATH="$2"
      shift 2
      ;;
    opencode|codex|claude-code|cursor|workbuddy)
      PLATFORM="$1"
      shift
      ;;
    --list)
      echo "支持的平台："
      echo "  opencode      —  ~/.config/opencode/skills/"
      echo "  codex         —  ~/.codex/skills/"
      echo "  claude-code   —  ~/.claude/skills/"
      echo "  cursor        —  ~/.cursor/skills/"
      echo "  workbuddy     —  ~/.workbuddy/skills/"
      echo ""
      echo "自定义路径：bash install.sh --path /your/custom/path"
      exit 0
      ;;
    *)
      warn "未知参数: $1（已忽略）"
      shift
      ;;
  esac
done

if [ -z "$PLATFORM" ] && [ -z "$CUSTOM_PATH" ]; then
  PLATFORM=$(detect_platform)
fi

if [ -n "$CUSTOM_PATH" ]; then
  SKILLS_DIR="$CUSTOM_PATH"
else
  SKILLS_DIR=$(get_skills_dir "$PLATFORM")
fi

# ── 打印安装信息 ──────────────────────────────────────
echo ""
echo -e "${CYAN}  ╔══════════════════════════════════╗${NC}"
echo -e "${CYAN}  ║  GXG · 观星哥的财经职场工具箱  ║${NC}"
echo -e "${CYAN}  ╚══════════════════════════════════╝${NC}"
echo ""
info "平台:  ${PLATFORM}"
info "路径:  ${SKILLS_DIR}"
echo ""

# ── 创建目录 ──────────────────────────────────────────
mkdir -p "$SKILLS_DIR"

# ── 判断运行模式（本地运行 vs 远程管道） ──────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IS_LOCAL=false
if [ -f "$SCRIPT_DIR/SKILL.md" ] && [ -d "$SCRIPT_DIR/skills" ]; then
  IS_LOCAL=true
  REPO_DIR="$SCRIPT_DIR"
else
  # 远程管道模式：clone 到临时目录
  REPO_DIR=$(mktemp -d /tmp/gxg-install.XXXXXX)
  info "下载 GXG..."
  if ! git clone --depth 1 https://github.com/YFzh1995/GXG.git "$REPO_DIR" 2>/dev/null; then
    rm -rf "$REPO_DIR"
    error "下载失败，请检查网络连接"
  fi
fi

# ── 安装主路由 ────────────────────────────────────────
info "安装主路由..."
mkdir -p "$SKILLS_DIR/gxg"
rsync -a "$REPO_DIR/SKILL.md" "$SKILLS_DIR/gxg/"
rsync -a "$REPO_DIR/VERSION" "$SKILLS_DIR/gxg/"
rsync -a "$REPO_DIR/install.sh" "$SKILLS_DIR/gxg/" 2>/dev/null || true
if [ -d "$REPO_DIR/agents" ]; then
  rsync -a "$REPO_DIR/agents/" "$SKILLS_DIR/gxg/agents/"
fi

# 初始化 .last_check
if [ ! -f "$SKILLS_DIR/gxg/.last_check" ]; then
  echo "2000-01-01" > "$SKILLS_DIR/gxg/.last_check"
fi

# ── 安装子技能（铺平到 skills 根目录） ────────────────
echo ""
for skill_dir in "$REPO_DIR/skills/"*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  target="$SKILLS_DIR/$skill_name"

  info "安装 ${skill_name}..."

  # 删除旧的非 git 目录，用新内容覆盖
  if [ -d "$target/.git" ]; then
    warn "${skill_name} 是独立 git 仓库，跳过（如需覆盖请先删除该目录）"
    continue
  fi

  # 备份旧版本
  if [ -d "$target" ]; then
    BACKUP_DIR="$SKILLS_DIR/.gxg-backup/${skill_name}-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -R "$target" "$BACKUP_DIR/"
    info "  已备份到 ${BACKUP_DIR}"
  fi

  rm -rf "$target"
  mkdir -p "$target"
  rsync -a "$skill_dir" "$target"

  info "  ${skill_name} ✓"
done

# ── 清理临时目录 ──────────────────────────────────────
if [ "$IS_LOCAL" = false ]; then
  rm -rf "$REPO_DIR"
fi

# ── 完成 ──────────────────────────────────────────────
echo ""
info "──────────────────────────────────────"
info "GXG 安装完成！"
info ""
info "已安装子技能："
echo -e "  ${CYAN}●${NC} 人岗匹配评估           →  gxg-job-fit"
echo -e "  ${CYAN}●${NC} 面试辅导与陪跑教练     →  gxg-interview"
echo -e "  ${CYAN}●${NC} 商业洞察               →  gxg-insight"
echo ""
info "使用方法：在 AI 对话中输入 @gxg 即可开始"
info "手动更新：curl -fsSL https://raw.githubusercontent.com/YFzh1995/GXG/main/install.sh | bash"
info ""
info "观星哥 | 小红书：观星哥 | 微信：guanxingge2025"
echo ""
