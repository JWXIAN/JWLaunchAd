//
//  JWLaunchAd.m
//  JWLaunchAd
//
//  Created by GJW on 16/7/11.
//  Copyright © 2016年 JW. All rights reserved.
//
//  https://github.com/JWXIAN/JWLaunchAd.git
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "JWLaunchAd.h"

#define kDefaultDuration 3;//默认停留时间
#define kPlaceholderImage [UIImage imageNamed:@""] //占位图

#ifdef DEBUG
#define DebugLog(...) NSLog(__VA_ARGS__)
#else
#define DebugLog(...)
#endif

#define kScreen_Bounds  [UIScreen mainScreen].bounds
#define kScreen_Height  [UIScreen mainScreen].bounds.size.height
#define kScreen_Width   [UIScreen mainScreen].bounds.size.width

@interface JWLaunchAd()

@property (nonatomic,strong ) UIImageView          *launchImgView;
@property (nonatomic,strong ) UIButton             *btnSkip;
@property (nonatomic,copy   ) dispatch_source_t    dispatchTimer;
@property (nonatomic, assign) NSInteger            adDuration;      //广告停留时间
@property (nonatomic, assign) BOOL                 hideSkip;        //是否隐藏跳过按钮
@property (nonatomic, copy  ) JWLaunchAdClickBlock adClickBlock;    //广告点击
@property (nonatomic, assign) SkipShowType         showSkipType;
@property (nonatomic,strong ) CAShapeLayer         *shapelayer;
@end

@implementation JWLaunchAd

- (instancetype)initWithFrame:(CGRect)frame adDuration:(NSInteger)adDuration showSkipType:(SkipShowType)showSkipType{
    if (self = [super initWithFrame:frame]) {
        self.frame = kScreen_Bounds;
        _launchAdViewFrame = frame;
        _adDuration = adDuration;
        _showSkipType = showSkipType;
        [self addSubview:self.launchImgView];
        [self dispatch_Remove];
        [self addInWindow];
    }
    return self;
}

- (void)addInWindow{
    //监测DidFinished通知
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        //等DidFinished方法结束后,将其添加至window上(不然会检测是否有rootViewController)
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIApplication sharedApplication].delegate window] addSubview:self];
        });
    }];
}

- (void)animateStart{
    CGFloat duration = kDefaultDuration;
    if(_adDuration) duration = _adDuration;
    duration= duration/4.0;
    if(duration>1.0) duration=1.0;
    [UIView animateWithDuration:duration animations:^{
        self.launchAdImgView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - 动画跳过
- (void)layoutSubviews{
    if(_showSkipType==2) {
        _btnSkip.frame = CGRectMake(kScreen_Width - 40,40, 30, 30);
        [self animation];
    }
}
//添加动画
-(void)animation{
    CABasicAnimation *pathAnimaton = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    pathAnimaton.duration = _adDuration-1;
    pathAnimaton.fromValue = @(0.0f);
    pathAnimaton.toValue = @(1.0f);
    [self.shapelayer addAnimation:pathAnimaton forKey:nil];
}
//设置属性
- (void)setAnimationSkipWithAttribute:(UIColor *)strokeColor lineWidth:(NSInteger)lineWidth  backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor{
    self.shapelayer = [CAShapeLayer layer];
    UIBezierPath *BezierPath = [UIBezierPath bezierPathWithOvalInRect:self.btnSkip.bounds];
    self.shapelayer.lineWidth = lineWidth?lineWidth:3.0;
    self.shapelayer.strokeColor = [strokeColor?strokeColor:[UIColor redColor] CGColor];
    self.shapelayer.fillColor = [UIColor clearColor].CGColor;
    self.shapelayer.path = BezierPath.CGPath;
    self.btnSkip.backgroundColor = backgroundColor?backgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self.btnSkip.layer addSublayer:self.shapelayer];
}

#pragma mark - 开始计时
- (void)dispath_Tiemr{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _dispatchTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_dispatchTimer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    
    __block NSInteger duration = kDefaultDuration;
    
    if(_adDuration) duration = _adDuration;
    dispatch_source_set_event_handler(_dispatchTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_btnSkip setTitle:_showSkipType==1?[NSString stringWithFormat:@"%ld 跳过",(long)duration]:@"跳过" forState:UIControlStateNormal];
            if(duration==1){
                dispatch_source_cancel(_dispatchTimer);
                [self launchAdRemove];
            }
            duration--;
        });
    });
    dispatch_resume(_dispatchTimer);
}

- (void)dispatch_Remove{
    CGFloat duration = kDefaultDuration;
    if(_adDuration) duration = _adDuration;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self launchAdRemove];
    });
}

#pragma mark - 移除广告
- (void)launchAdRemove{
    [UIView animateWithDuration:1.0 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.transform=CGAffineTransformMakeScale(1.5, 1.5);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if(self.shapelayer) [self.shapelayer removeAllAnimations];
    }];
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    if(self.adClickBlock) self.adClickBlock();
}

#pragma mark - 获取启动页
- (UIImage *)getLaunchImage{
    UIImage *launchImage = [self assetsLaunchImage];
    if(launchImage) return launchImage;
    return [self storyboardLaunchImage];
}

#pragma mark - 获取Assets里LaunchImage
- (UIImage *)assetsLaunchImage{
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString *viewOrientation = @"Portrait";//横屏 @"Landscape"
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict){
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]){
            launchImageName = dict[@"UILaunchImageName"];
            UIImage *image = [UIImage imageNamed:launchImageName];
            return image;
        }
    }
    return nil;
}

#pragma mark - 获取Storyboard
- (UIImage *)storyboardLaunchImage{
    NSString *storyboardLaunchName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchStoryboardName"];
    UIViewController *sbLaunchVC = [[UIStoryboard storyboardWithName:storyboardLaunchName bundle:nil] instantiateInitialViewController];
    if(sbLaunchVC){
        UIView *view = sbLaunchVC.view;
        view.frame = kScreen_Bounds;
        return [self viewConvertImage:view];
    }
    return nil;
}
#pragma mark - 将View转成Image
- (UIImage*)viewConvertImage:(UIView*)launchView{
    CGSize imageSize = launchView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    [launchView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *launchImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return launchImage;
}

#pragma mark - 设置广告Frame
- (void)setLaunchAdViewFrame:(CGRect)launchAdViewFrame{
    _launchAdViewFrame = launchAdViewFrame;
    _launchAdImgView.frame = launchAdViewFrame;
}

#pragma mark - 异步加载图片
+ (instancetype)initImageWithAttribute:(NSInteger)adDuration showSkipType:(SkipShowType)showSkipType setLaunchAd:(JWSetLaunchAdBlock)setLaunchAd{
    static JWLaunchAd *launchAd = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        launchAd = [[self alloc] initWithFrame:kScreen_Bounds adDuration:adDuration showSkipType:showSkipType];
        if(setLaunchAd) setLaunchAd(launchAd);
    });
    return launchAd;
}
#pragma mark - 加载广告图
- (void)setWebImageWithURL:(NSString *)strURL options:(JWWebImageOptions)options result:(JWWebImageCompletionBlock)result adClickBlock:(JWLaunchAdClickBlock)adClickBlock{
    [self addAdImgView];
    _adClickBlock = [adClickBlock copy];
    [_launchAdImgView jw_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:kPlaceholderImage options:options completed:result?result:nil];
}
#pragma mark - 添加广告图
- (void)addAdImgView{
    [self addSubview:self.launchAdImgView];
    [self addSubview:self.btnSkip];
    [self animateStart];
}
#pragma mark - 清理缓冲
+ (void)clearDiskCache{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [JWWebImageDownloader cacheImagePath];
        [fileManager removeItemAtPath:path error:nil];
        [JWWebImageDownloader checkDirectory:path];
    });
}

#pragma mark - 启动页
- (UIImageView *)launchImgView{
    if(!_launchImgView){
        _launchImgView = [[UIImageView alloc] initWithFrame:kScreen_Bounds];
        _launchImgView.image = [self getLaunchImage];
    }
    return _launchImgView;
}

#pragma mark - 广告图
- (UIImageView *)launchAdImgView{
    if(!_launchAdImgView){
        _launchAdImgView = [[UIImageView alloc] initWithFrame:_launchAdViewFrame];
        _launchAdImgView.alpha = 0.2;
        _launchAdImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [_launchAdImgView addGestureRecognizer:tap];
    }
    return _launchAdImgView;
}

#pragma mark - 跳过
- (UIButton *)btnSkip{
    if(!_btnSkip){
        _btnSkip = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnSkip.frame = _showSkipType==1?CGRectMake(kScreen_Width-70,30, 60, 30):CGRectMake(kScreen_Width-50,30, 30, 30);
        _btnSkip.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _btnSkip.layer.cornerRadius = _showSkipType==1?15:15;
        _btnSkip.titleLabel.font = [UIFont systemFontOfSize:_showSkipType==1?13.5:12];
        NSInteger duration = kDefaultDuration;
        if(_adDuration) duration = _adDuration;
        [_btnSkip setTitle:_showSkipType==1?[NSString stringWithFormat:@"%ld 跳过",(long)duration]:@"跳过" forState:UIControlStateNormal];
        [_btnSkip addTarget:self action:@selector(launchAdRemove) forControlEvents:UIControlEventTouchUpInside];
        [self dispath_Tiemr];
    }
    return _btnSkip;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
