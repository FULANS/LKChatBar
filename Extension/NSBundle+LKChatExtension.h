//
//  NSBundle+LKChatExtension.h
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (LKChatExtension)

+ (NSBundle *)lkchat_bundleForName:(NSString *)bundleName class:(Class)aClass;

@end

NS_ASSUME_NONNULL_END
