//
//  UIImage+LKChatExtension.m
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#import "UIImage+LKChatExtension.h"
#import "LKChatImageManager.h"
#import "NSBundle+LKChatExtension.h"

@implementation NSBundle (MyCategory)

+ (NSString *)lkchat_pathForResource:(NSString *)name
                            ofType:(NSString *)extension {
    // First try with the main bundle
    NSBundle * mainBundle = [NSBundle mainBundle];
    NSString * path = [mainBundle pathForResource:name
                                           ofType:extension];
    if (path) {
        return path;
    }
    
    // Otherwise try with other bundles
    NSBundle * bundle;
    for (NSString * bundlePath in [mainBundle pathsForResourcesOfType:@"bundle"
                                                          inDirectory:nil])
    {
        bundle = [NSBundle bundleWithPath:bundlePath];
        path = [bundle pathForResource:name
                                ofType:extension];
        if (path)
        {
            return path;
        }
    }
    
    HTLog(@"No path found for: %@ (.%@)", name, extension);
    return nil;
}

@end

@implementation UIImage (LKChatExtension)

#pragma mark -
#pragma mark - public Methods

- (CGSize)lkchat_getScaledSize{
    
    CGFloat ow = CGImageGetWidth(self.CGImage);
    CGFloat oh = CGImageGetHeight(self.CGImage);
    
    CGSize kMaxImageViewSize = {.width = 240, .height = 240};
    CGFloat aspectRatio = ow / oh;
    CGFloat width;
    CGFloat height;
    CGSize limitSize = kMaxImageViewSize;
    
    if (ow < limitSize.width && oh < limitSize.height) {
        width = ow;
        height = oh;
        return CGSizeMake(width, height);
    }
    
    //胖照片
    if (limitSize.width / aspectRatio <= limitSize.height) {
        width = limitSize.width;
        height = limitSize.width / aspectRatio;
    } else {
        //瘦照片
        width = limitSize.height * aspectRatio;
        height = limitSize.height;
    }
    return CGSizeMake(width, height);
}

- (UIImage *)lkchat_imageByScalingAspectFill {
    CGSize kMaxImageViewSize = {.width = 240, .height = 240};
    CGSize originSize = ({
        CGFloat width = self.size.width;
        CGFloat height = self.size.height;
        CGSize size = CGSizeMake(width, height);
        size;
    });
    UIImage *resizedImage = [self lkchat_imageByScalingAspectFillWithOriginSize:originSize limitSize:kMaxImageViewSize];
    return resizedImage;
}

- (UIImage *)lkchat_imageByScalingAspectFillWithOriginSize:(CGSize)originSize {
    CGSize kMaxImageViewSize = {.width = 240, .height = 240};
    UIImage *resizedImage = [self lkchat_imageByScalingAspectFillWithOriginSize:originSize limitSize:kMaxImageViewSize];
    return resizedImage;
}

- (UIImage *)lkchat_imageByScalingAspectFillWithOriginSize:(CGSize)originSize
                                               limitSize:(CGSize)limitSize {
    if (originSize.width == 0 || originSize.height == 0) {
        return self;
    }
    CGFloat aspectRatio = originSize.width / originSize.height;
    CGFloat width;
    CGFloat height;
    //胖照片
    if (limitSize.width / aspectRatio <= limitSize.height) {
        width = limitSize.width;
        height = limitSize.width / aspectRatio;
    } else {
        //瘦照片
        width = limitSize.height * aspectRatio;
        height = limitSize.height;
    }
    return [self lkchat_scaledToSize:CGSizeMake(width, height)];
}

+ (UIImage *)lkchat_imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName bundleForClass:(Class)aClass {
    if (imageName.length == 0) return nil;
    if ([imageName hasSuffix:@"/"]) return nil;
    NSBundle *bundle = [NSBundle lkchat_bundleForName:bundleName class:aClass];
    LKChatImageManager *manager = [LKChatImageManager defaultManager];
    UIImage *image = [manager getImageWithName:imageName
                                      inBundle:bundle];
    if (!image) {
        //`-getImageWithName` not work for image in Access Asset Catalog
        image = [UIImage imageNamed:imageName];
    }
    return image;
}

+ (UIImage *)lkchat_imageNamed:(NSString *)imageName {
    LKChatImageManager *manager = [LKChatImageManager defaultManager];
    UIImage *image = [manager getImageWithName:imageName];
    if (!image) {
        //`-getImageWithName` not work for image in Access Asset Catalog
        image = [UIImage imageNamed:imageName];
    }
    return image;
}

#pragma mark -
#pragma mark - Private Methods

- (UIImage *)lkchat_scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)lkchat_scalingPatternImageToSize:(CGSize)size {
    CGFloat scale = 0.0f;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat width = size.width;
    CGFloat height = size.height;
    if (CGSizeEqualToSize(self.size, size) == NO) {
        CGFloat widthFactor = size.width / self.size.width;
        CGFloat heightFactor = size.height / self.size.height;
        scale = (widthFactor > heightFactor ? widthFactor : heightFactor);
        width  = self.size.width * scale;
        height = self.size.height * scale;
        y = (size.height - height) * 0.5;
        
        x = (size.width - width) * 0.5;
    }
    // this is actually the interesting part:
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(x, y, width, height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(newImage == nil) {
        return self;
    }
    return newImage ;
}

@end
