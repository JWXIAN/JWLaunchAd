# JWLaunchAd
一行代码集成启动广告图
![image](https://github.com/JWXIAN/JWScrollView/blob/master/gif.gif)
    //设置启动页广告图片的url
    NSString *imgUrlString =@"http://imgstore.cdn.sogou.com/app/a/100540002/714860.jpg";
    
    //初始化启动页广告(初始化后,自动添加至视图,不用手动添加)
    JWLaunchAd *launchAd = [JWLaunchAd initImageWithURL:CGRectMake(0, 0,self.window.bounds.size.width, self.window.bounds.size.height-150) strUrl:imgUrlString adDuration:10.0 options:JWWebImageDefault result:^(UIImage *image, NSURL *url) {
        //异步加载图片完成回调(若需根据图片实际尺寸,刷新广告frame,可在这里操作)
        //launchAd.adFrame = ...;
        NSLog(@"%@", url);
    }];
    //是否隐藏跳过按钮（默认显示）
    launchAd.hideSkip = NO;
    //广告点击事件
    launchAd.clickBlock = ^(){
        NSString *url = @"https://www.baidu.com";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    };
