//
//  NSMutableDictionary+LKChatWeakReference.m
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#import "NSMutableDictionary+LKChatWeakReference.h"
#import "LKChatWeakReference.h"

@implementation NSMutableDictionary (LKChatWeakReference)

- (void)lkchat_weak_setObject:(id)anObject forKey:(NSString *)aKey {
    [self setObject:makeLKChatWeakReference(anObject) forKey:aKey];
}

- (void)lkchat_weak_setObjectWithDictionary:(NSDictionary *)dictionary {
    for (NSString *key in dictionary.allKeys) {
        [self setObject:makeLKChatWeakReference(dictionary[key]) forKey:key];
    }
}

- (id)lkchat_weak_getObjectForKey:(NSString *)key {
    return weakReferenceNonretainedObjectValue(self[key]);
}

@end
