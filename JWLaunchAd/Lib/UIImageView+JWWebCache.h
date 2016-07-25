//
//  UIImageView+JWWebCache.h
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

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, JWWebImageOptions) {
    JWWebImageDefault = 1 << 0,         // 有缓存,读取缓存,不重新加载,没缓存先加载,并缓存
    JWWebImageOnlyLoad = 1 << 1,        // 只加载,不缓存
    JWWebImageRefreshCached = 1 << 2    // 先读缓存,再加载刷新图片和缓存
};

typedef void(^JWWebImageCompletionBlock)(UIImage *image, NSURL *url);
typedef void(^JWDispatch_asyncBlock)(UIImage *image, NSURL *url, NSData *data);

@interface JWWebImageDownloader : NSObject

/**
 *  缓冲路径
 *
 *  @return 路径
 */
+ (NSString *)cacheImagePath;
/**
 *  检查目录
 *
 *  @param path 路径
 */
+(void)checkDirectory:(NSString *)path;
@end

@interface UIImage(GIF)
/**
 *  NSData -> UIImage
 *
 *  @param data Data
 *
 *  @return UIImage
 */
+ (UIImage *)jw_gifWithData:(NSData *)data;
@end

@interface UIImageView (JWWebCache)

/**
 *  获取当前图像的URL
 */
- (NSURL *)jw_imageURL;

/**
 *  异步加载网络图片+缓存
 *
 *  @param url            图片url
 *  @param placeholder    默认图片
 *  @param completedBlock 加载完成回调
 */
- (void)jw_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage completed:(JWWebImageCompletionBlock)completedBlock;

/**
 *  异步加载网络图片+缓存
 *
 *  @param url            图片url
 *  @param placeholder    默认图片
 *  @param options        缓存机制
 *  @param completedBlock 加载完成回调
 */
-(void)jw_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage options:(JWWebImageOptions)options completed:(JWWebImageCompletionBlock)completedBlock;

@end
