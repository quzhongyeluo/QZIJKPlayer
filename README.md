# QZIJKPlayer
基于 IJK的简易直播/视频播放器，支持切换多个播放源、全屏、跟随屏幕旋转全屏 Swift

预览图：

![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gflcs4v5zdj30n01dsgpr.jpg)



![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gflcpy1xt2j30n01dsgnm.jpg)



横屏模式

![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gflcrqszvaj31ds0n0jyo.jpg)



功能比较简单，UI布局主要使用的 xib，可以自行在上面添加所需功能，自动横屏旋转需要系统打开自动旋转功能。

IJKMediaFramework可以自行编译，也可以使用我的编译的

下载地址：

链接: https://pan.baidu.com/s/1eSZp9NrIlQ60VED0pFUAjg 提取码: pskk



使用方法：

```Swift
let player = QZIJKPlayerViewController()
player.view.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: view.bounds.width * 9 / 16)
playView.addSubview(player.view)
self.addChild(player)
let playModel_first = QZIJKPlayerPlayModel(title: "Test_1", url: "http://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4", name: "高清")
let playModel_second = QZIJKPlayerPlayModel(title: "Test_2", url: "http://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4", name: "超清")
player.setPlayData(playModels: [playModel_first, playModel_second])
player.delegate = self
player.isHiddenBottomProgressView = true
```

QZIJKPlayerPlayModel需要播放的源，可以添加多个 playModel，例如高清、超清，有多个 playModel的时候，会显示源切换按钮。

QZIJKPlayerDelegate为播放器代理，包含播放完成代理，点击了返回按钮代理，可自行拓展所需要的代理

更改 IJK 配置的内容在QZIJKPlayerPresenter.swift文件上

资源文件在QZPlayerResource.bundle文件上，QZPlayerResource.swift 可以获取这些资源图片



