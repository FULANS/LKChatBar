//
//  LKChatVoiceProgressHUD.h
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  状态指示器对应状态
 */
typedef NS_ENUM(NSUInteger, LKChatVoiceProgressState){
    LKChatVoiceProgressSuccess /**< 成功 */,
    LKChatVoiceProgressError /**< 出错,失败 */,
    LKChatVoiceProgressShort /**< 时间太短失败 */,
    LKChatVoiceProgressMessage /**< 自定义失败提示 */,
};

/**
 *  录音加载的指示器
 */

@interface LKChatVoiceProgressHUD : UIView

/**
 *  上次成功录音时长
 *
 *  @return
 */
+ (NSTimeInterval)seconds;


/**
 *  显示录音指示器
 */
+ (void)show;


/**
 *  隐藏录音指示器,使用自带提示语句
 *
 *  @param message 提示信息
 */
+ (void)dismissWithMessage:(NSString *)message;

/**
 *  隐藏hud,带有录音状态
 *
 *  @param progressState 录音状态
 */
+ (void)dismissWithProgressState:(LKChatVoiceProgressState)progressState;

/**
 *  修改录音的subTitle显示文字
 *
 *  @param str 需要显示的文字
 */
+ (void)changeSubTitle:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
