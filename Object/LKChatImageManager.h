//
//  LKChatImageManager.h
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LKChatImageManager : NSObject

+ (instancetype)defaultManager;

- (UIImage *)getImageWithName:(NSString *)name;
- (UIImage *)getImageWithName:(NSString *)name inBundle:(NSBundle *)bundle;

@end

