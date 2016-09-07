//
//  JWLaunchAd.h
//  JWLaunchAd
//
//  Created by GJW on 16/7/11.
//  Copyright © 2016年 JW. All rights reserved.
//  https://github.com/JWXIAN/JWLaunchAd.git
//
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

#import <UIKit/UIKit.h>
#import "UIImageView+JWWebCache.h"

@class JWLaunchAd;
typedef void (^JWLaunchAdClickBlock)();
typedef void (^JWSetLaunchAdBlock)(JWLaunchAd *launchAd);

typedef NS_ENUM(NSUInteger, SkipShowType)
{
    SkipShowTypeNone = 0,       /** 无跳过 */
    SkipShowTypeDefault,        /** 跳过+倒计时*/
    SkipShowTypeAnimation,      /** 动画跳过 ⭕️ */
};

@interface JWLaunchAd : UIView

/**
 *  广告图
 */
@property(nonatomic, strong) UIImageView *launchAdImgView;

/**
 *  广告frame
 */
@property (nonatomic, assign) CGRect launchAdViewFrame;

/**
 *  清理缓冲
 */
+ (void)clearDiskCache;

/**
 *  初始化启动页广告
 *
 *  @param adDuration  停留时间
 *  @param hideSkip    是否隐藏跳过
 *  @param setLaunchAd launchAdView
 *
 *  @return self
 */
+ (instancetype)initImageWithAttribute:(NSInteger)adDuration showSkipType:(SkipShowType)showSkipType setLaunchAd:(JWSetLaunchAdBlock)setLaunchAd;

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
@end
