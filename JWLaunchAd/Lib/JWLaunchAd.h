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
typedef void (^JWLaunchAdClickBlock)();
@interface JWLaunchAd : UIView
/**
 *  是否隐藏跳过按钮
 */
@property (nonatomic ,assign) BOOL hideSkip;
/**
 *  广告图
 */
@property(nonatomic,strong) UIImageView *adImgView;
/**
 *  广告frame
 */
@property (nonatomic, assign) CGRect adFrame;
/**
 *  加载完回调
 */
@property (nonatomic, copy) void(^LaunchAdClickBlock)(UIImage *image, NSURL *url);

/**
 *  广告点击事件回调
 */
@property(nonatomic,copy)JWLaunchAdClickBlock clickBlock;

/**
 *  初始化启动页广告
 *
 *  @param frame        frane
 *  @param strUrl       URL
 *  @param adDuration   停留时间
 *  @param adClickBlock 点击广告回调
 *  @param result       加载完成回调
 *
 *  @return self
 */
+ (instancetype)initImageWithURL:(CGRect)frame strUrl:(NSString *)strUrl adDuration:(NSInteger)adDuration options:(JWWebImageOptions)options result:(JWWebImageCompletionBlock)result;

/**
 *  清理缓冲
 */
+ (void)clearDiskCache;

/**
 *  内部初始化 - 无需调用
 *
 *  @param frame      frame
 *  @param adDuration 停留时间
 *
 *  @return self
 */
- (instancetype)initWithFrame:(CGRect)frame adDuration:(NSInteger)adDuration;
@end
