# YTVLCMoivePlayer

技术博客地址：[一款基于VLC的在线视频播放器](https://www.jianshu.com/p/47428e089656)

序言：VLC是开源的多媒体播放器，也是基于FFmpeg，而且现行的大部分常用的视频格式都可以正常解码和播放。基于编译出来的MobileVLCKit.framework，我封装了一款在线视频播放器。
* 至于MobileVLCKit.framework的编译这里就不在累述，提供两个参考博文：1.[iOS中VLC的集成与简单使用](https://www.jianshu.com/p/1721cd8622f0)
2.[iOS 使用 VLC](https://www.jianshu.com/p/64de78eab7da)
* 先上一张播放器的外形图：
> ![IMG_1003.PNG](https://upload-images.jianshu.io/upload_images/2737326-5459458766121184.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
> ![IMG_1005.PNG](https://upload-images.jianshu.io/upload_images/2737326-e38a8d3c2a2f3473.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* 项目结构：
![1.png](https://upload-images.jianshu.io/upload_images/2737326-13fc142e171456a5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* 播放器的使用也是非常的简单，只要初始化后提供播放的URL即可开始播放。
```
NSURL *url = [NSURL URLWithString:@"http://v4ttyey-10001453.video.myqcloud.com/Microblog/288-4-1452304375video1466172731.mp4"];
NSURL *bundleUrl = [[NSBundle mainBundle]URLForResource:@"YTVLCMoivePlayer" withExtension:@"bundle"];
NSBundle *myBundle = [NSBundle bundleWithURL:bundleUrl];
YTVLCMoivePlayer *player = [[YTVLCMoivePlayer alloc]initWithNibName:@"YTVLCMoivePlayer" bundle:myBundle];
player.url = url;
[self presentViewController:player animated:YES completion:nil];

```

