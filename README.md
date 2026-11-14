# pmx-skills

个人 Codex skills 集合，供多台机器安装和同步。

## 已收录

| Skill | 用途 |
| --- | --- |
| [install-app](skills/install-app/SKILL.md) | 在 `~/app/<软件名>` 安装和维护自托管软件，交付配置、验证结果及运维文档。 |
| [3xui](skills/3xui/SKILL.md) | 安装维护 3x-ui，配置 REALITY、动态订阅、Clash/小火箭接入与分流，排查客户端兼容问题。 |

## 发布为 GitHub 私有仓库

需要安装 Git 和 GitHub CLI（`gh`），然后在仓库目录运行：

```bash
bash scripts/publish-github.sh
```

脚本会通过 GitHub 设备码流程登录：按照终端提示，在浏览器打开授权网址并输入一次性设备码。不要把 GitHub token 写入仓库或发送到聊天。

脚本为当前登录账号创建私有仓库 `pmx-skills`，并推送 `main` 分支。首次提交优先使用已有 Git 作者配置；未配置时使用 GitHub 用户名和该账号的 noreply 邮箱，仅写入本仓库配置。

如果仓库已初始化、已有远程配置或存在同名 GitHub 仓库，脚本会停止并保留现状，供人工核对。

## 在其他机器安装

先使用有权读取私有仓库的账号登录 GitHub CLI，然后克隆：

```bash
gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git --hostname github.com
gh repo clone pmx0117/pmx-skills ~/app/pmx-skills
```

先确认目标机器没有需要保留的同名 skill，再复制完整目录：

```bash
mkdir -p ~/.agents/skills
cp -R ~/app/pmx-skills/skills/install-app ~/.agents/skills/
cp -R ~/app/pmx-skills/skills/3xui ~/.agents/skills/
```

`references/` 和 `agents/` 均需随 `SKILL.md` 一起复制。如果目标已安装同名 skill，先将旧目录移到备份路径，再复制。

若所用客户端从 `~/.codex/skills` 加载 skills，可在该路径尚不存在时增加链接：

```bash
mkdir -p ~/.codex/skills
ln -s ~/.agents/skills/install-app ~/.codex/skills/install-app
ln -s ~/.agents/skills/3xui ~/.codex/skills/3xui
```

重新启动 Codex，并确认能通过 `$install-app`、`$3xui` 调用。不同客户端版本的发现行为以目标机器实际结果为准。

## 更新和新增

修改 `skills/<名称>/` 下的文件后提交并推送。其他机器执行 `git pull --ff-only`，备份旧安装，再复制更新后的 skill 目录。

新增 skill 时，在 `skills/` 下创建独立目录，至少包含 `SKILL.md`；引用的文档和资源一并保存。仓库仅存放 skills 及分发说明，不保存实际部署的数据、凭据或备份。
