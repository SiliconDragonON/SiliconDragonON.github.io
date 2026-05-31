# wenyangblog 博客维护说明

这是 SiliconDragonON 的个人博客项目，使用 Hexo 生成静态网站，使用 Butterfly 主题，通过 GitHub Pages 发布。

访问地址：

```text
https://SiliconDragonON.github.io
```

GitHub 仓库：

```text
https://github.com/SiliconDragonON/SiliconDragonON.github.io
```

## 分支说明

本项目使用两个分支：

```text
source 分支：保存 Hexo 博客源码
main 分支：保存 Hexo 生成后的静态网页文件
```

平时写文章、改配置、改主题、换图片，都在 `source` 分支中完成。

GitHub Pages 实际发布网站时使用的是 `main` 分支。不要手动在 `main` 分支里写文章或修改页面，因为 `main` 分支的内容会被 `hexo deploy` 自动覆盖。

## 常用目录说明

```text
source/_posts/              博客文章目录
source/img/                 网站图片资源目录
source/about/index.md       关于页面
source/categories/index.md  分类页面
source/tags/index.md        标签页面
_config.yml                 Hexo 主配置文件
_config.butterfly.yml       Butterfly 主题配置文件
package.json                项目依赖配置
run-hexo.cmd                Windows 下运行 Hexo 的辅助脚本
new-post.cmd                双击/命令行创建新文章
preview-blog.cmd            本地预览脚本
push-and-deploy.cmd         自动提交源码并部署网站
```

## 本地预览网站

在 PowerShell 或 CMD 中执行：

```powershell
cd F:\website
.\run-hexo.cmd clean
.\run-hexo.cmd generate
.\run-hexo.cmd server
```

然后打开：

```text
http://localhost:4000
```

说明：

```text
clean      清理旧的生成文件
generate   重新生成静态网页
server     启动本地预览服务
```

## 添加新文章

推荐使用 Hexo 命令创建文章：

```powershell
cd F:\website
.\run-hexo.cmd new "文章标题"
```

也可以使用项目提供的快捷脚本：

```powershell
cd F:\website
.\new-post.cmd "文章标题"
```

创建后，文章会出现在：

```text
source/_posts/
```

也可以手动在 `source/_posts/` 中新建 `.md` 文件，但必须写好文章头部信息，例如：

```markdown
---
title: 文章标题
date: 2026-05-31 23:00:00
tags:
  - 标签1
  - 标签2
categories:
  - 分类名称
---

这里开始写正文。
```

注意字段名是 `date`，不是 `data`。

## 提交源码到 GitHub

当你新增文章、修改文章、修改配置或替换图片后，先把源码提交到 GitHub 的 `source` 分支。

完整命令：

```powershell
cd F:\website
git status
git add .
git commit -m "Update blog source"
git push origin source
```

说明：

```text
git status
查看当前有哪些文件被修改、新增或删除。

git add .
把当前项目中的改动加入暂存区。

git commit -m "Update blog source"
生成一次源码提交。引号中的内容是提交说明，可以改成更具体的描述。

git push origin source
把本地 source 分支推送到 GitHub 仓库的 source 分支。
```

如果网络不稳定，可以改用：

```powershell
git -c http.version=HTTP/1.1 push origin source
```

## 发布网站到 GitHub Pages

源码推送完成后，还需要把 Hexo 生成出来的静态网页部署到 `main` 分支。

完整命令：

```powershell
cd F:\website
.\run-hexo.cmd clean
.\run-hexo.cmd generate
.\run-hexo.cmd deploy
```

说明：

```text
.\run-hexo.cmd clean
清理 public/ 等旧的生成结果。

.\run-hexo.cmd generate
根据 source/_posts、主题配置和站点配置重新生成静态网页。

.\run-hexo.cmd deploy
把生成后的 public/ 内容推送到 GitHub 仓库的 main 分支。
```

部署成功后，等待几十秒到几分钟，再访问：

```text
https://SiliconDragonON.github.io
```

## 完整更新流程

每次修改博客后，推荐按这个顺序执行：

```powershell
cd F:\website

git status
git add .
git commit -m "Update blog"
git push origin source

.\run-hexo.cmd clean
.\run-hexo.cmd generate
.\run-hexo.cmd deploy
```

这套流程会完成两件事：

```text
1. 把 Hexo 源码保存到 GitHub 的 source 分支
2. 把生成后的网页发布到 GitHub 的 main 分支
```

如果想一键完成提交和部署，可以执行：

```powershell
cd F:\website
.\push-and-deploy.cmd
```

这个脚本会自动执行：

```text
1. clean + generate，先确认网站能正常生成
2. git add / commit / push，把源码推送到 source 分支
3. hexo deploy，把静态网页推送到 main 分支
4. 如果 deploy 网络失败，会尝试直接推送 .deploy_git 到 main 分支
```

## 修改网站界面

网站界面主要由 Butterfly 主题配置控制，优先修改：

```text
_config.butterfly.yml
```

常见修改位置：

```yaml
avatar:
  img: /img/avatar.png
  effect: false
```

这里设置头像。头像图片应放在：

```text
source/img/avatar.png
```

首页顶部大背景图：

```yaml
default_top_img: /img/background.png
index_img: /img/background.png
```

全站背景图：

```yaml
background: /img/background.png
```

背景图片应放在：

```text
source/img/background.png
```

导航栏菜单：

```yaml
menu:
  Home: / || fas fa-home
  Archives: /archives/ || fas fa-archive
  Tags: /tags/ || fas fa-tags
  Categories: /categories/ || fas fa-folder-open
  Contact: /contact/ || fas fa-address-book
  About: /about/ || fas fa-user
```

社交链接：

```yaml
social:
  fab fa-github: https://github.com/SiliconDragonON || GitHub || '#24292e'
  fas fa-envelope: mailto:3011223675@qq.com || QQ Mail || '#12b7f5'
```

联系页面位于：

```text
source/contact/index.md
```

联系方式可以在这个文件中修改，也可以同步修改 `_config.butterfly.yml` 中的 `social` 配置。

如果要修改网站标题、作者、网站地址，修改：

```text
_config.yml
```

常见字段：

```yaml
title: wenyangblog
author: SiliconDragonON
url: https://SiliconDragonON.github.io
```

## 修改图片资源

所有会被网站使用的图片，都建议放在：

```text
source/img/
```

然后在 Markdown 或配置文件中使用这种路径：

```text
/img/图片文件名.png
```

不要使用本机绝对路径，例如：

```text
C:\Users\Administrator\Pictures\xxx.png
```

这种路径只能在本机看到，发布到 GitHub Pages 后别人无法访问。

## 为不同分类设置不同图片

分类和标签封面图在 `_config.butterfly.yml` 中配置。

默认分类页封面：

```yaml
category_img: /img/covers/blog.jpg
```

为不同分类设置不同封面：

```yaml
category_per_img:
  - 博客: /img/covers/blog.jpg
  - 技术: /img/covers/technology.jpg
  - 单片机: /img/covers/mcu.jpg
  - 编程: /img/covers/code.jpg
  - 笔记: /img/covers/notes.jpg
```

标签页封面：

```yaml
tag_per_img:
  - 51MCU: /img/covers/mcu.jpg
  - 单片机: /img/covers/mcu.jpg
  - C: /img/covers/code.jpg
  - Hexo: /img/covers/technology.jpg
  - Blog: /img/covers/blog.jpg
```

图片文件放在：

```text
source/img/covers/
```

新增分类后，如果想使用单独封面，只需要：

```text
1. 把图片放入 source/img/covers/
2. 在 category_per_img 中增加一行分类映射
3. clean + generate + deploy
```

## 搜索、订阅和站点地图

当前已经启用：

```text
本地搜索：/search.xml
RSS 订阅：/atom.xml
站点地图：/sitemap.xml
```

相关依赖在 `package.json` 中：

```text
hexo-generator-search
hexo-generator-feed
hexo-generator-sitemap
```

Butterfly 搜索入口在 `_config.butterfly.yml` 中：

```yaml
search:
  use: local_search
  placeholder: 搜索文章、标签或关键词
```

## 双击 cmd 闪退的原因

直接双击 `.cmd` 文件时，命令执行完成后窗口会自动关闭，这是 Windows 的正常行为。

推荐在 PowerShell 中执行命令。或者新建一个 `deploy-blog.cmd`：

```bat
@echo off
cd /d F:\website

call run-hexo.cmd clean
call run-hexo.cmd generate
call run-hexo.cmd deploy

pause
```

双击这个文件时，执行结束后窗口会停住，方便查看结果。

## 常见问题

如果 `git push` 失败，先确认网络能访问 GitHub，然后重试：

```powershell
git push origin source
```

如果仍然失败，可以尝试：

```powershell
git -c http.version=HTTP/1.1 push origin source
```

如果 `hexo deploy` 失败，通常是网络或 GitHub 连接问题。可以重新执行：

```powershell
.\run-hexo.cmd deploy
```

如果网站没有马上更新，等待 1 到 5 分钟后刷新浏览器，GitHub Pages 有时需要一点时间生效。
