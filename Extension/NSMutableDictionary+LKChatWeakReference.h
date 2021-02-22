//
//  NSMutableDictionary+LKChatWeakReference.h
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (LKChatWeakReference)

- (void)lkchat_weak_setObject:(id)anObject forKey:(NSString *)aKey;

- (void)lkchat_weak_setObjectWithDictionary:(NSDictionary *)dic;

- (id)lkchat_weak_getObjectForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
