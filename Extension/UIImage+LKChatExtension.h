//
//  UIImage+LKChatExtension.h
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (LKChatExtension)

- (UIImage *)lkchat_imageByScalingAspectFill;
/*!
 * @attention This will invoke `CGSize kMaxImageViewSize = {.width = 200, .height = 200};`.
 */
- (UIImage *)lkchat_imageByScalingAspectFillWithOriginSize:(CGSize)originSize;

- (UIImage *)lkchat_imageByScalingAspectFillWithOriginSize:(CGSize)originSize
                                               limitSize:(CGSize)limitSize;

+ (UIImage *)lkchat_imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName bundleForClass:(Class)aClass;
+ (UIImage *)lkchat_imageNamed:(NSString *)name;

- (UIImage *)lkchat_scalingPatternImageToSize:(CGSize)size;

- (CGSize)lkchat_getScaledSize;

@end

NS_ASSUME_NONNULL_END
