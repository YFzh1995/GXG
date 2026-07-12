# GXG · 观星哥的财经职场工具箱

> GXG = GuanXingGe | 面向财务人与商科毕业生，帮助提升职场竞争力

---

## 快速开始

```bash
curl -fsSL https://raw.githubusercontent.com/YFzh1995/GXG/main/install.sh | bash
```

安装后在 AI 对话中输入 `@gxg` 即可开始。

---

## 当前子技能

| 子技能 | 目录 | 说明 |
|--------|------|------|
| 面试辅导与陪跑教练 | `skills/gxg-interview/` | 财务面试匹配度分析 + 话术策略 + 问答准备 |
| 商业洞察 | `skills/gxg-insight/` | 从招股书学商业逻辑，建立商业思维 |

---

## 手动安装

```bash
# 指定平台
bash install.sh opencode
bash install.sh codex
bash install.sh claude-code
bash install.sh cursor

# 自定义路径
bash install.sh --path ~/my-skills
```

---

## 更新

```bash
cd ~/.config/opencode/skills/gxg  # 根据你的终端调整路径
git pull origin main && bash install.sh
```

GXG 会在每次触发时（每两周检查一次）自动检测版本更新并提示。

---

## 目录结构

```
gxg/
├── SKILL.md              # 主路由（name: gxg）
├── VERSION               # 版本号
├── install.sh            # 一键安装
├── README.md
└── skills/               # 所有子技能（一个仓库 = 一个产品）
    ├── gxg-interview/    # 面试辅导
    │   └── SKILL.md
    └── gxg-insight/      # 商业洞察
        ├── SKILL.md
        ├── prompts/
        │   ├── extract-facts.md
        │   ├── merge-facts.md
        │   ├── reason-business.md
        │   └── generate-report.md
        └── templates/
            └── report-template.md
```

---

## 作者

**观星哥**
- 小红书：观星哥
- 微信：guanxingge2025
- GitHub：[YFzh1995](https://github.com/YFzh1995)

---

## License

MIT
