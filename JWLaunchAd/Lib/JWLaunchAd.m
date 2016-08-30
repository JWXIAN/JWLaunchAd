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

@property(nonatomic,strong)UIImageView *launchImgView;
@property(nonatomic,strong)UIButton *skipButton;
@property(nonatomic,copy) dispatch_source_t timer;
@property (nonatomic, assign) NSInteger adDuration;             //广告停留时间
@property (nonatomic, assign) BOOL hideSkip;                    //是否隐藏跳过按钮
@property (nonatomic, copy) JWLaunchAdClickBlock adClickBlock;  //广告点击
@end

@implementation JWLaunchAd

- (instancetype)initWithFrame:(CGRect)frame adDuration:(NSInteger)adDuration hideSkip:(BOOL)hideSkip{
    if (self = [super initWithFrame:frame]) {
        self.frame = [UIScreen mainScreen].bounds;
        _adFrame = frame;
        _adDuration = adDuration;
        _hideSkip = hideSkip;
        [self addSubview:self.launchImgView];
        [self animateEnd];
        [self addInWindow];
    }
    return self;
}

-(void)addInWindow{
    //监测DidFinished通知
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        //等DidFinished方法结束后,将其添加至window上(不然会检测是否有rootViewController)
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIApplication sharedApplication].delegate window] addSubview:self];
        });
    }];
}

-(void)animateStart{
    CGFloat duration = kDefaultDuration;
    if(_adDuration) duration = _adDuration;
    duration= duration/4.0;
    if(duration>1.0) duration=1.0;
    [UIView animateWithDuration:duration animations:^{
        self.adImgView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

-(void)dispath_tiemr{
    NSTimeInterval period = 1.0;//每秒执行
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    
    __block NSInteger duration = kDefaultDuration;
    if(_adDuration) duration = _adDuration;
    
    dispatch_source_set_event_handler(_timer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(duration>0) duration--;
            [_skipButton setTitle:[NSString stringWithFormat:@"%ld 跳过",duration] forState:UIControlStateNormal];
        });
    });
    dispatch_resume(_timer);
}

-(void)animateEnd{
    CGFloat duration = kDefaultDuration;
    if(_adDuration) duration = _adDuration;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adRemove];
    });
}

-(void)adRemove{
    [UIView animateWithDuration:0.8 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.transform=CGAffineTransformMakeScale(1.5, 1.5);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)tapAction:(UITapGestureRecognizer *)tap{
    if(self.adClickBlock) self.adClickBlock();
}

-(UIImage *)launchImage{
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
    DebugLog(@"请添加启动图片");
    return nil;
}

#pragma mark - 设置广告Frame
-(void)setAdFrame:(CGRect)adFrame{
    _adFrame = adFrame;
    _adImgView.frame = adFrame;
}

#pragma mark - 异步加载图片
+ (instancetype)initImageWithAttribute:(NSInteger)adDuration hideSkip:(BOOL)hideSkip setLaunchAd:(JWSetLaunchAdBlock)setLaunchAd{
    static JWLaunchAd *launchAd = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        launchAd = [[self alloc] initWithFrame:kScreen_Bounds adDuration:adDuration hideSkip:hideSkip];
        if(setLaunchAd) setLaunchAd(launchAd);
    });
    return launchAd;
}
#pragma mark - 加载广告图
- (void)setWebImageWithURL:(NSString *)strURL options:(JWWebImageOptions)options result:(JWWebImageCompletionBlock)result adClickBlock:(JWLaunchAdClickBlock)adClickBlock{
    [self addAdImgView];
    _adClickBlock = [adClickBlock copy];
    [_adImgView jw_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:kPlaceholderImage options:options completed:result?result:nil];
}
#pragma mark - 添加广告图
- (void)addAdImgView{
    [self addSubview:self.adImgView];
    [self addSubview:self.skipButton];
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

#pragma mark - 加载
-(UIImageView *)launchImgView{
    if(!_launchImgView){
        _launchImgView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _launchImgView.image = [self launchImage];
    }
    return _launchImgView;
}

-(UIImageView *)adImgView{
    if(!_adImgView){
        _adImgView = [[UIImageView alloc] initWithFrame:_adFrame];
        _adImgView.userInteractionEnabled = YES;
        _adImgView.alpha = 0.2;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [_adImgView addGestureRecognizer:tap];
    }
    return _adImgView;
}

-(UIButton *)skipButton{
    if(!_skipButton){
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-70,30, 60, 30);
        _skipButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        _skipButton.layer.cornerRadius = 15;
        _skipButton.layer.masksToBounds = YES;
        NSInteger duration = kDefaultDuration;
        if(_adDuration) duration = _adDuration;
        _skipButton.hidden = _hideSkip;
        [_skipButton setTitle:[NSString stringWithFormat:@"%ld 跳过",duration] forState:UIControlStateNormal];
        _skipButton.titleLabel.font = [UIFont systemFontOfSize:13.5];
        [_skipButton addTarget:self action:@selector(adRemove) forControlEvents:UIControlEventTouchUpInside];
        [self dispath_tiemr];
    }
    return _skipButton;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
