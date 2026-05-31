# wenyangblog

Hexo personal blog for SiliconDragonON, using the Butterfly theme.

## Local preview

```powershell
.\run-hexo.cmd clean
.\run-hexo.cmd generate
.\run-hexo.cmd server
```

The local preview normally runs at `http://localhost:4000`.

## Write posts

```powershell
.\run-hexo.cmd new "文章标题"
```

Posts are created under `source/_posts`.

## Deploy

The Hexo deploy target is:

```text
https://github.com/SiliconDragonON/SiliconDragonON.github.io.git
```

The generated site is deployed to the `main` branch:

```powershell
.\run-hexo.cmd clean
.\run-hexo.cmd generate
.\run-hexo.cmd deploy
```

After deployment, the site should be available at:

```text
https://SiliconDragonON.github.io
```
