//
//  LKChatMoreView.h
//  LiemsMobile70
//
//  Created by WZheng on 2020/4/8.
//  Copyright © 2020 Luculent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKChatMoreItemView.h"

NS_ASSUME_NONNULL_BEGIN
@class LKChatBar;


@interface LKChatMoreView : UIView

@property (assign, nonatomic) NSUInteger numberPerLine;
@property (assign, nonatomic) UIEdgeInsets edgeInsets;
@property (weak, nonatomic) LKChatBar *inputViewRef;

@property (copy, nonatomic) void (^LKChatMoreViewResultBlock)(LKChatMoreViewItemType type , id object);

@end

NS_ASSUME_NONNULL_END
