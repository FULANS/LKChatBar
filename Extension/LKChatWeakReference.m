//
//  LKChatWeakReference.m
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#import "LKChatWeakReference.h"

LKChatWeakReference makeLKChatWeakReference(id object) {
    __weak id weakref = object;
    return ^{
        return weakref;
    };
}

id weakReferenceNonretainedObjectValue(LKChatWeakReference ref) {
    return ref ? ref() : nil;
}
