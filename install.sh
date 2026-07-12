#!/usr/bin/env bash
#
# GXG 一键安装脚本
# GitHub: https://github.com/YFzh1995/GXG
#
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/YFzh1995/gxg/main/install.sh | bash
#   bash install.sh                    # 自动检测平台
#   bash install.sh opencode           # 指定平台
#   bash install.sh --path ~/myskills  # 自定义安装路径
#
# 支持平台: opencode | codex | claude-code | cursor | generic

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
  local detected=""
  if command -v opencode &>/dev/null || [ -d "$HOME/.config/opencode" ]; then
    detected="opencode"
  elif [ -d "$HOME/.codex" ]; then
    detected="codex"
  elif [ -d "$HOME/.claude" ]; then
    detected="claude-code"
  elif [ -d "$HOME/.cursor" ]; then
    detected="cursor"
  else
    detected="opencode"
    warn "未检测到已知平台，默认使用 opencode 路径"
  fi
  echo "$detected"
}

get_skills_dir() {
  local platform="$1"
  case "$platform" in
    opencode)    echo "$HOME/.config/opencode/skills" ;;
    codex)       echo "$HOME/.codex/skills" ;;
    claude-code) echo "$HOME/.claude/skills" ;;
    cursor)      echo "$HOME/.cursor/skills" ;;
    *)           echo "$platform" ;;
  esac
}

# ── 参数解析 ──────────────────────────────────────────
PLATFORM=""
CUSTOM_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path)
      CUSTOM_PATH="$2"
      shift 2
      ;;
    opencode|codex|claude-code|cursor)
      PLATFORM="$1"
      shift
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
rsync -a "$REPO_DIR/SKILL.md" "$SKILLS_DIR/gxg/"
rsync -a "$REPO_DIR/VERSION" "$SKILLS_DIR/gxg/"
rsync -a "$REPO_DIR/install.sh" "$SKILLS_DIR/gxg/" 2>/dev/null || true

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
echo -e "  ${CYAN}●${NC} 面试辅导与陪跑教练   →  gxg-interview"
echo -e "  ${CYAN}●${NC} 商业洞察               →  gxg-insight"
echo ""
info "使用方法：在 AI 对话中输入 @gxg 即可开始"
info "手动更新：cd ${SKILLS_DIR}/gxg && git pull && bash install.sh"
info ""
info "观星哥 | 小红书：观星哥 | 微信：guanxingge2025"
echo ""
