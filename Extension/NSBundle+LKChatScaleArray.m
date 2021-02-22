//
//  NSBundle+LKChatScaleArray.m
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#import "NSBundle+LKChatScaleArray.h"
#import <UIKit/UIKit.h>

@implementation NSBundle (LKChatScaleArray)

+ (NSArray *)lkchat_scaleArray; {
    static NSArray *scales;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat screenScale = [UIScreen mainScreen].scale;
        if (screenScale <= 1) {
            scales = @[ @1,@2,@3 ];
        } else if (screenScale <= 2) {
            scales = @[ @2,@3,@1 ];
        } else {
            scales = @[ @3,@2,@1 ];
        }
    });
    return scales;
}

@end
