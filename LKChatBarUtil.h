//
//  LKChatBarUtil.h
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/3/26.
//  Copyright © 2019 luculent. All rights reserved.
//

#ifndef LKChatBarUtil_h
#define LKChatBarUtil_h

#define kChatEmojiBundle @"LKChatEmoji"
#define kChatEmojiPlist @"face"

#define kBasicLineBackgroundColor [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f]

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif


#import "NSAttributedString+LKAddition.h"
#import "UIImage+LKChatExtension.h"
#import "LKChatVoiceProgressHUD.h"
#import "LKChatFaceManager.h"
//#import "LKFaceManager.h"
#import "NSBundle+LKChatExtension.h"


#endif /* LKChatBarUtil_h */
