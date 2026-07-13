# GXG

把岗位要求、个人经历和公司材料，变成更清楚的求职判断、面试准备与商业洞察。

GXG（GuanXingGe）是观星哥创建的财经职场 AI Skills 工具箱，面向财经职场人与商科毕业生。当前深度支持财务、会计、税务、内控、财务分析、资金与业财等岗位，也可结合真实材料处理其他财经相关职能的问题。

你可以提交简历、JD、目标公司、招股书/年报，以及过去购买观星哥服务时形成的资料（可选，非必须）。GXG 会根据当前任务选择合适的 Skill，给出有证据、有边界、可以继续使用的结果。

**当前版本：v1.2.2**

[第一次使用](#从第一次提问开始) · [查看三个 Skill](#直接调用的-skill) · [安装 GXG](#安装) · [联系作者](#作者与反馈)

## 你可以用它做什么

| 你交付的内容 | GXG 会帮你做什么 |
|---|---|
| 简历 + 目标岗位 JD | 分维度判断匹配项、差距、证据强弱和面试风险 |
| 简历 + JD + 目标公司 | 从面试官视角深挖疑点，逐题生成参考作答并结合真实细节修改 |
| 公司名、行业名或招股书/年报 | 拆解行业逻辑、商业模式、赚钱方式、竞争与关键风险 |
| 过去的 GXG 服务资料 | 复用已经确认的经历、能力与辅导成果，让判断和回答更贴合本人 |
| 一个还不明确的财经职场问题 | 先识别需求，再路由到当前最合适的 Skill |

## 从第一次提问开始

安装后，在支持 Skills 的 AI 对话中输入：

```text
@gxg
```

GXG 会让你选择当前要处理的任务：

```text
1. 分析我和这个岗位的匹配度
2. 模拟面试，深挖我的简历
3. 分析一家公司或招股书，学习商业逻辑
```

你也可以直接带着真实任务开始：

```text
@gxg 帮我分析这份简历与目标岗位的匹配情况。
@gxg 我下周要面试这家公司，请结合简历和 JD 帮我准备。
@gxg 分析一下这家公司的招股书，它靠什么赚钱？
```

GXG 会读取当前对话中已经提供的信息并路由到对应 Skill。材料不足时，它会说明缺少什么、缺失会影响哪些判断，不会把推测写成你的真实经历。

## 常见场景与当前入口

### 判断自己是否适合一个岗位

```text
@gxg-job-fit
```

提供简历、目标公司与 JD。GXG 会拆解岗位的显性要求和合理的隐性需求，对照你的事实经历，输出匹配项、差距项、风险与面试待验证问题；不给缺乏依据的单一百分制分数。

### 准备一场真实面试

```text
@gxg-interview
```

提供简历、目标公司与 JD。GXG 会从简历疑点和岗位风险出发逐题训练，每题提供口语化参考作答；你补充真实细节后，它会继续修改成更个性化、更经得起追问的版本。

### 从真实公司学习商业逻辑

```text
@gxg-insight
```

提供公司名、行业名或你关心的商业问题。GXG 会搜索并解读招股书、年报等公开材料，从行业结构、商业模式、收入成本、竞争壁垒和风险出发形成商业洞察。

## 直接调用的 Skill

GXG 当前正式包含 1 个主入口和 3 个子 Skill：

| 目标 | 直接调用 | 主要产出 |
|---|---|---|
| 不确定该从哪里开始 | `@gxg` | 识别需求并路由到合适的子 Skill |
| 评估简历与岗位是否匹配 | `@gxg-job-fit` | 候选人画像、岗位画像、匹配项、差距与面试风险 |
| 做简历深挖和模拟面试 | `@gxg-interview` | 逐题训练、参考作答、定制修改与面试总结 |
| 分析公司、行业或招股书 | `@gxg-insight` | 事实底稿、商业逻辑分析与结构化报告 |

## 什么是“GXG 资料”

如果你过去购买过观星哥的咨询、简历或面试服务，可以把已有资料继续交给相关 Skill 使用。“GXG 资料”明确包括两类：

1. **GXG 咨询录音文本**：咨询、辅导或复盘过程的录音转写文本。
2. **GXG 简历及面试服务的全套交付材料**：包括人设文档、简历诊断/修改材料、岗位分析、人岗匹配分析、面试问题清单、面试辅导记录、参考话术及其他相关交付物。

这些资料不是使用 GXG 的必需条件。你可以只提供手头现有的部分；提供后，相关 Skill 可以复用材料中已经讨论和确认的经历、能力与行为证据，减少重复沟通并提高结果的个性化程度。

## 安装

### 一键安装

适用于 macOS、Linux 与 WSL：

```bash
curl -fsSL https://raw.githubusercontent.com/YFzh1995/GXG/main/install.sh | bash
```

安装脚本会识别当前环境。也可以明确指定平台：

```bash
bash install.sh opencode
bash install.sh codex
bash install.sh claude-code
bash install.sh cursor
```

安装到自定义目录：

```bash
bash install.sh --path ~/my-skills
```

### Windows PowerShell

```powershell
iwr -Uri https://raw.githubusercontent.com/YFzh1995/GXG/main/install.ps1 -OutFile $env:TEMP\gxg-install.ps1
& $env:TEMP\gxg-install.ps1
Remove-Item $env:TEMP\gxg-install.ps1
```

安装完成后，新建一个对话并输入 `@gxg`。如果当前平台不支持从主 Skill 动态加载子 Skill，可直接输入 `@gxg-job-fit`、`@gxg-interview` 或 `@gxg-insight`。

## 更新

已经安装 GXG 后，可以直接对当前 Agent 说：

```text
更新 GXG
```

也可以重新运行安装脚本：

```bash
curl -fsSL https://raw.githubusercontent.com/YFzh1995/GXG/main/install.sh | bash -s -- codex
```

GXG 主入口每两周自动检查一次远程版本；发现新版本时会先询问是否更新。当前 Agent 没有立即读取到新能力时，请新建一次对话后再使用。

当前版本：`v1.2.2`。

## 项目结构

```text
GXG/
├── SKILL.md                  # @gxg 主入口与路由
├── VERSION                   # 当前版本
├── install.sh                # macOS / Linux / WSL 安装脚本
├── install.ps1               # Windows 安装脚本
└── skills/
    ├── gxg-job-fit/          # 人岗匹配评估
    ├── gxg-interview/        # 面试辅导与陪练
    └── gxg-insight/          # 商业洞察
```

## 作者与反馈

作者：**观星哥**

- 小红书：观星哥
- 微信：`guanxingge2025`
- GitHub：[@YFzh1995](https://github.com/YFzh1995)

如果你对这套 Skills 有建议、使用反馈或希望新增的财经职场场景，欢迎联系观星哥。

## 许可证

本项目采用 MIT License。
