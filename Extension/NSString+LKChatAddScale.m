//
//  NSString+LKChatAddScale.m
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#import "NSString+LKChatAddScale.h"

@implementation NSString (LKChatAddScale)
- (NSString *)lkchat_stringByAppendingScale:(CGFloat)scale{
    if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    return [self stringByAppendingFormat:@"@%@x", @(scale)];
}
@end
