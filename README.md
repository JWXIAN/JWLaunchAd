![image](https://github.com/JWXIAN/JWLaunchAd/blob/master/JWLaunchAd/Resources/logo.png)

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/JWXIAN/JWLaunchAd/blob/master/LICENSE)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%207%2B-brightgreen.svg)](https://github.com/JWXIAN/MVCProject)
[![CocoaPods](https://img.shields.io/badge/pod-1.3.4-blue.svg)](http://cocoapods.org/?q=JWLaunchAd)&nbsp;
[![AppVeyor](https://img.shields.io/appveyor/ci/gruntjs/grunt.svg?maxAge=2592000)](https://github.com/JWXIAN/MVCProject)


Demo Project
==============
![image](https://github.com/JWXIAN/JWLaunchAd/blob/master/JWLaunchAd/Resources/1.gif)
![image](https://github.com/JWXIAN/JWLaunchAd/blob/master/JWLaunchAd/Resources/2.gif)
![image](https://github.com/JWXIAN/JWLaunchAd/blob/master/JWLaunchAd/Resources/4.gif)

API
==============
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
*  设置动画跳过属性
*
*  @param strokeColor     转动颜色
*  @param lineWidth       宽度
*  @param backgroundColor 背景色
*  @param textColor       字体颜色
*/
- (void)setAnimationSkipWithAttribute:(UIColor *)strokeColor lineWidth:(NSInteger)lineWidth backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor;

/**
 *  广告图Frame
 */
@property (assign, nonatomic) CGRect launchAdViewFrame;


```

Usage
==============
* 在AppDelegate中设置Window.rootViewController之后调用下面方法

```objc
//  1.设置启动页广告图片的URL
NSString *imgUrlString =@"http://imgstore.cdn.sogou.com/app/a/100540002/714860.jpg";
    
//  2.初始化启动页
[JWLaunchAd initImageWithAttribute:6.0 showSkipType:SkipShowTypeAnimation setLaunchAd:^(JWLaunchAd *launchAd) {
    __block JWLaunchAd *weakSelf = launchAd;
    //如果选择 SkipShowTypeAnimation 需要设置动画跳过按钮的属性
    [weakSelf setAnimationSkipWithAttribute:[UIColor redColor] lineWidth:3.0 backgroundColor:nil textColor:nil];

    [launchAd setWebImageWithURL:imgUrlString options:JWWebImageDefault result:^(UIImage *image, NSURL *url) {

        //  异步缓冲图片完成后调整图片Frame
        weakSelf.launchAdViewFrame = CGRectMake(0, 0, kScreen_Width, kScreen_Height-100);
    } adClickBlock:^{

        //  3.广告回调  
        NSString *url = @"https://www.baidu.com";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }];
}];

```

Installation
==============

### CocoaPods

1. Add `pod 'JWLaunchAd'` to your Podfile.
2. Run pod install or pod update.
3. Import `JWLaunchAd.h`.

### Manually

1. Add the source files to your Xcode project.
2. Import `JWLaunchAd.h`.

Requirements
==============
This library requires `iOS 7.0+` .

License
==============
JWLaunchAd is provided under the MIT license. See LICENSE file for details.