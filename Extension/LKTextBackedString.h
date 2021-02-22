//
//  LKTextBackedString.h
//  LKChartBar
//
//  Created by Sherlock on 2019/3/20.
//  Copyright © 2019 王郑. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull const LKTextBackedStringAttributeName;

@interface LKTextBackedString : NSObject <NSCoding, NSCopying>

@property (nullable, nonatomic, copy) NSString *string;

+ (nullable instancetype)stringWithString:(nullable NSString *)string;

@end
