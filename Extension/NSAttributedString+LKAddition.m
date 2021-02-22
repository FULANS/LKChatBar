//
//  NSAttributedString+LKAddition.m
//  LKChartBar
//
//  Created by Sherlock on 2019/3/20.
//  Copyright © 2019 王郑. All rights reserved.
//

#import "NSAttributedString+LKAddition.h"

@implementation NSAttributedString (LKAddition)

- (NSRange)lk_rangeOfAll
{
    return NSMakeRange(0, self.length);
}

- (NSString *)lk_plainTextForRange:(NSRange)range{

    if (range.location == NSNotFound || range.length == NSNotFound) {
        return nil;
    }
    
    NSMutableString *result = [[NSMutableString alloc] init];
    if (range.length == 0) {
        return result;
    }
    NSString *string = self.string;
    [self enumerateAttribute:LKTextBackedStringAttributeName inRange:range options:kNilOptions usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        
        LKTextBackedString *backed = value;
        if (backed && backed.string) {
            [result appendString:backed.string];
        } else {
            [result appendString:[string substringWithRange:range]];
        }
    }];
    return result;
}

@end

@implementation NSMutableAttributedString (LKAddition)

- (void)lk_setTextBackedString:(LKTextBackedString *)textBackedString range:(NSRange)range
{
    if (textBackedString && ![NSNull isEqual:textBackedString]) {
        [self addAttribute:LKTextBackedStringAttributeName value:textBackedString range:range];
    } else {
        [self removeAttribute:LKTextBackedStringAttributeName range:range];
    }
}

@end


