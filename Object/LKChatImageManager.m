//
//  LKChatImageManager.m
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#import "LKChatImageManager.h"
#import "NSBundle+LKChatScaleArray.h"
#import "NSString+LKChatAddScale.h"
#import "NSMutableDictionary+LKChatWeakReference.h"

@interface LKChatImageManager()

@property (nonatomic, strong) NSMutableDictionary *imageBuff;

@end

@implementation LKChatImageManager

+ (instancetype)defaultManager {
    static LKChatImageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (UIImage *)getImageWithName:(NSString *)name {
    UIImage *storeImage = [self getImageWithName:name inBundle:[NSBundle mainBundle]];
    return storeImage;
}

- (UIImage *)getImageWithName:(NSString *)name inBundle:(NSBundle *)bundle {
    UIImage *image = [self.imageBuff lkchat_weak_getObjectForKey:name];
    if(image) {
        return image;
    }
    NSString *res = name.stringByDeletingPathExtension;
    NSString *ext = name.pathExtension;
    NSString *path = nil;
    CGFloat scale = 1;
    // If no extension, guess by system supported (same as UIImage).
    NSArray *exts = ext.length > 0 ? @[ext] : @[@"", @"png", @"jpeg", @"jpg", @"gif", @"webp", @"apng"];
    NSArray *scales = [NSBundle lkchat_scaleArray];
    for (int s = 0; s < scales.count; s++) {
        scale = ((NSNumber *)scales[s]).floatValue;
        NSString *scaledName = [res lkchat_stringByAppendingScale:scale];
        for (NSString *e in exts) {
            path = [bundle pathForResource:scaledName ofType:e];
            if (path) break;
        }
        if (path) break;
    }
    if (path.length == 0) return nil;
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length == 0) return nil;
    UIImage *storeImage = [[UIImage alloc] initWithData:data scale:scale];
    [self.imageBuff lkchat_weak_setObject:storeImage forKey:name];
    return storeImage;
}

- (NSMutableDictionary *)imageBuff {
    if(!_imageBuff) {
        _imageBuff = [NSMutableDictionary dictionary];
    }
    return _imageBuff;
}


@end
