//
//  LKChatWeakReference.h
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef id (^LKChatWeakReference)(void);

LKChatWeakReference makeLKChatWeakReference(id object);

id weakReferenceNonretainedObjectValue(LKChatWeakReference ref);

NS_ASSUME_NONNULL_END
