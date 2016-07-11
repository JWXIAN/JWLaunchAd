//
//  UIImageView+JWWebCache.m
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

#import "UIImageView+JWWebCache.h"
#import "objc/runtime.h"
#import <CommonCrypto/CommonDigest.h>

#ifdef DEBUG
#define DebugLog(...) NSLog(__VA_ARGS__)
#else
#define DebugLog(...)
#endif

static char imageURLKey;

@implementation JWWebImageDownloader
#pragma mark - 缓冲目录
+ (NSString *)cacheImagePath{
    NSString *path =[NSHomeDirectory() stringByAppendingPathComponent:@"Library/JWLaunchAdCache"];
    [self checkDirectory:path];
    return path;
}
#pragma mark - 检查目录
+ (void)checkDirectory:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) { //判断是否为文件夹
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}
#pragma mark - 得到图片缓冲
+(UIImage *)getCacheImageWithURL:(NSURL *)url{
    if(!url) return nil;
    NSString *directoryPath = [self cacheImagePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@",
                      directoryPath,[self md5String:url.absoluteString]];
    return [UIImage imageWithContentsOfFile:path];
}
#pragma mark - 刷新图片缓冲
+(void)saveImage:(UIImage *)image imageURL:(NSURL *)url{
    NSData *data = UIImagePNGRepresentation(image);
    NSString *path = [NSString stringWithFormat:@"%@/%@",[self cacheImagePath],[self md5String:url.absoluteString]];
    if (data) {
        BOOL isOk = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        if (!isOk) DebugLog(@"cache file error for URL: %@", url);
    }
}
#pragma mark - 在目录创建文件
+ (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        DebugLog(@"create cache directory failed, error = %@", error);
    } else {
        DebugLog(@"LaunchAdCachePath:%@",path);
        // 标记无需备份目录
        NSURL *url = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        if (error) {
            DebugLog(@"error to set do not backup attribute, error = %@", error);
        }
    }
}
#pragma mark - URL MD5
+ (NSString *)md5String:(NSString *)string {
    if(string == nil || [string length] == 0)  return nil;
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}
@end

@implementation UIImageView (JWWebCache)
#pragma mark - AssociatedObject
- (NSURL *)jw_imageURL{
    return objc_getAssociatedObject(self, &imageURLKey);
}
#pragma mark - WebCache
- (void)jw_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage completed:(JWWebImageCompletionBlock)completedBlock{
    [self jw_setImageWithURL:url placeholderImage:placeholderImage options:JWWebImageDefault completed:completedBlock];
}
- (void)jw_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage options:(JWWebImageOptions)options completed:(JWWebImageCompletionBlock)completedBlock{
    if (placeholderImage) self.image = placeholderImage;
    if (url) {
        __weak typeof(self)weakSelf = self;
        objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if(!options) options = JWWebImageDefault;
        //只加载,不缓存
        if(options&JWWebImageOnlyLoad){
            [self dispatch_async:url result:^(UIImage *image, NSURL *url) {
                weakSelf.image = image;
                if(image&&completedBlock) completedBlock(image, url);
            }];
            return;
        }
        //有缓存,读取缓存,不重新加载,没缓存先加载,并缓存
        UIImage *image = [JWWebImageDownloader getCacheImageWithURL:url];
        if(image&&completedBlock){
            weakSelf.image = image;
            if(image&&completedBlock) completedBlock(image,url);
            if(options&JWWebImageDefault) return;
        }
        //先读缓存,再加载刷新图片和缓存
        [self dispatch_async:url result:^(UIImage *image, NSURL *url) {
            weakSelf.image = image;
            if(image&&completedBlock) completedBlock(image,url);
            [JWWebImageDownloader saveImage:image imageURL:url];
        }];
    }
}
#pragma mark - 异步加载图片
- (void)dispatch_async:(NSURL *)url result:(JWDispatch_asyncBlock)result{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) result(image,url);
        });
    });
}
@end
