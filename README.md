# GXG · 观星哥的财经职场工具箱

> GXG = GuanXingGe | 面向财经职场人与商科毕业生，帮助提升职场竞争力

以财务职能为主，兼容投融资、审计、风控合规、商业分析等其他财经相关职能。

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
| 人岗匹配评估 | `skills/gxg-job-fit/` | 基于简历和 JD，分维度评估匹配项、差距与面试风险 |
| 面试辅导与陪练 | `skills/gxg-interview/` | 标准/深挖两种模式，逐题练习、即时反馈与样本作答 |
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
curl -fsSL https://raw.githubusercontent.com/YFzh1995/GXG/main/install.sh | bash -s -- codex
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
    ├── gxg-job-fit/      # 人岗匹配评估
    │   └── SKILL.md
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
