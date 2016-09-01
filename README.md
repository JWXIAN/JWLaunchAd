![image](https://github.com/JWXIAN/JWLaunchAd/blob/master/JWLaunchAd/Resources/JWLaunchAd.png)
[![Support](https://img.shields.io/badge/support-iOS%207%2B-brightgreen.svg)](https://github.com/JWXIAN/MVCProject)
[![AppVeyor](https://img.shields.io/appveyor/ci/gruntjs/grunt.svg?maxAge=2592000)](https://github.com/JWXIAN/MVCProject)
[![Bintray](https://img.shields.io/badge/version-1.3-brightgreen.svg)](https://github.com/JWXIAN/MVCProject)

--
![image](https://github.com/JWXIAN/JWLaunchAd/blob/master/JWLaunchAd/Resources/gif.gif)
![image](https://github.com/JWXIAN/JWLaunchAd/blob/master/JWLaunchAd/Resources/gif2.gif)

--
API
--
```objc
/**
 *  初始化启动页
 *
 *  @param adDuration  停留时间
 *  @param hideSkip    是否隐藏跳过
 *  @param setLaunchAd launchAdView
 *
 *  @return self
 */
+ (instancetype)initImageWithAttribute:(NSInteger)adDuration hideSkip:(BOOL)hideSkip setLaunchAd:(JWSetLaunchAdBlock)setLaunchAd;

/**
 *  设置图片
 *
 *  @param strURL       URL
 *  @param options      图片缓冲模式
 *  @param result       UIImage *image, NSURL *url
 *  @param adClickBlock 点击图片回调
 */
- (void)setWebImageWithURL:(NSString *)strURL options:(JWWebImageOptions)options result:(JWWebImageCompletionBlock)result adClickBlock:(JWLaunchAdClickBlock)adClickBlock;


/**
 *  广告图Frame
 */
@property (assign, nonatomic) CGRect launchAdViewFrame;


```
--
Usage
--
* 在AppDelegate中设置window.rootViewController之后调用下面方法

```objc
//  1.设置启动页广告图片的url
NSString *imgUrlString =@"http://imgstore.cdn.sogou.com/app/a/100540002/714860.jpg";
    
//  2.初始化启动页广告(初始化后,自动添加至视图,不用手动添加)
[JWLaunchAd initImageWithAttribute:6.0 hideSkip:NO setLaunchAd:^(JWLaunchAd *launchAd) {
    __block JWLaunchAd *weakSelf = launchAd;
    [launchAd setWebImageWithURL:imgUrlString options:JWWebImageDefault result:^(UIImage *image, NSURL *url) {

        //  异步加载图片完成回调(可以调整图片尺寸)
        weakSelf.launchAdViewFrame = CGRectMake(0, 0, kScreen_Width, kScreen_Height-100);
    } adClickBlock:^{

        //  3.点击广告回调  
        NSString *url = @"https://www.baidu.com";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }];
}];

```
