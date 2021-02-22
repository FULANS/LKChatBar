//
//  LKTextBackedString.m
//  LKChartBar
//
//  Created by Sherlock on 2019/3/20.
//  Copyright © 2019 王郑. All rights reserved.
//

#import "LKTextBackedString.h"

NSString *const LKTextBackedStringAttributeName = @"LKTextBackedString";

@implementation LKTextBackedString

+ (instancetype)stringWithString:(NSString *)string
{
    LKTextBackedString *one = [[self alloc] init];
    one.string = string;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.string forKey:@"string"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _string = [aDecoder decodeObjectForKey:@"string"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    typeof(self) one = [[self.class alloc] init];
    one.string = self.string;
    return one;
}

@end
