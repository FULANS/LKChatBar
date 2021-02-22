//
//  LKLayIMChatBar.h
//  LiemsMobileEnterprise
//
//  Created by hillyoung on 2019/2/15.
//  Copyright © 2019 luculent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


NS_ASSUME_NONNULL_BEGIN
extern CGFloat const LKAnimateDuration;
static CGFloat const kLKFunctionViewHeight = 227.f;
static CGFloat const kLKChatBarBottomOffset = 8.f;
static CGFloat const kLKChatBarTextViewBottomOffset = 8;
static CGFloat const kLKChatBarTextViewFrameMinHeight = 37.f; // kLKLayIMChatBarMinHeight - 2*kChatBarTextViewBottomOffset;
static CGFloat const kLKChatBarTextViewFrameMaxHeight = 102.f; //kLKLayIMChatBarMaxHeight - 2*kChatBarTextViewBottomOffset;
static CGFloat const kLKChatBarMaxHeight = kLKChatBarTextViewFrameMaxHeight + 2*kLKChatBarTextViewBottomOffset;
static CGFloat const kLKChatBarMinHeight = kLKChatBarTextViewFrameMinHeight + 2*kLKChatBarTextViewBottomOffset;

FOUNDATION_EXTERN NSString *const lkChatBatchDeleteTextPrefix;
FOUNDATION_EXTERN NSString *const lkChatBatchDeleteTextSuffix;


/**
 *  functionView 类型
 */
typedef NS_ENUM(NSUInteger, LKFunctionViewShowType){
    LKFunctionViewShowNothing /**< 不显示functionView */,
    LKFunctionViewShowFace /**< 显示表情View */,
    LKFunctionViewShowVoice /**< 显示录音view */,
    LKFunctionViewShowMore /**< 显示更多view */,
    LKFunctionViewShowKeyboard /**< 显示键盘 */,
};

@protocol LKChatBarDelegate;

/**
 *  信息输入框,支持语音,文字,表情,选择照片,拍照
 */
@interface LKChatBar : UIView

@property (weak, nonatomic) id<LKChatBarDelegate> delegate;
@property (strong, nonatomic) HYPlaceholdTextView *textView;
@property (nonatomic, readonly) UIViewController *controllerRef;

- (instancetype)initWithFrame:(CGRect)frame
                  commentMode:(BOOL)isComment; /**<评论模式:只有表情和键盘*/

/*!
 *
 缓存输入框文字，兼具内存缓存和本地数据库缓存的作用。同时也负责着输入框内容被清空时的监听，收缩键盘。内部重写了setter方法，self.cachedText 就相当于self.textView.text，使用最重要的场景：为了显示voiceButton，self.textView.text = nil;

 */
@property (copy, nonatomic) NSString *cachedText;
@property (nonatomic, assign) LKFunctionViewShowType showType;

/*!
 * 在 `-presentViewController:animated:completion:` 的completion回调中调用该方法，屏蔽来自其它 ViewController 的键盘通知事件。
 */
- (void)close;

/*!
 * 对应于 `-close` 方法。
 */
- (void)open;

/*!
 * 追加后，输入框默认开启编辑模式
 */
- (void)appendString:(NSString *)string;
- (void)appendString:(NSString *)string beginInputing:(BOOL)beginInputing;

/**
 *  结束输入状态
 */
- (void)endInputing;

/**
 *  进入输入状态
 */
- (void)beginInputing;

@end

/**
 *  LKLayIMChatBar代理事件,发送图片,地理位置,文字,语音信息等
 */
@protocol LKChatBarDelegate <NSObject>


@optional

/*!
 *  chatBarFrame改变回调
 *
 *  @param chatBar chatBar
 */
- (void)chatBarFrameDidChange:(LKChatBar *)chatBar shouldScrollToBottom:(BOOL)shouldScrollToBottom;

/*!
 *  发送图片信息,支持多张图片
 *
 *  @param chatBar chatBar
 *  @param pictures 需要发送的图片信息
 */
- (void)chatBar:(LKChatBar *)chatBar sendPictures:(NSArray <FolderModel *>*)pictures;


/**
 发送视频

 @param chatBar chatBar
 @param video 需要发送的附件信息
 */
- (void)chatBar:(LKChatBar *)chatBar sendVideo:(FolderModel *)video;



/*!
 *  发送地理位置信息
 *
 *  @param chatBar chatBar
 *  @param locationCoordinate 需要发送的地址位置经纬度
 *  @param locationText       需要发送的地址位置对应信息
 */

- (void)chatBar:(LKChatBar *)chatBar sendLocation:(CLLocationCoordinate2D)locationCoordinate locationText:(NSString *)locationText;

- (void)chatBar:(LKChatBar *)chatBar sendLocation:(CLLocationCoordinate2D)locationCoordinate locationText:(NSString *)locationText locationImage:(NSData *)imageData;

/*!
 *  发送普通的文字信息,可能带有表情
 *
 *  @param chatBar chatBar
 *  @param message 需要发送的文字信息
 */
- (void)chatBar:(LKChatBar *)chatBar sendMessage:(NSString *)message;

/*!
 *  发送语音信息
 *
 *  @param chatBar chatBar
 *  @param voiceFileName 语音data数据
 *  @param seconds   语音时长
 */
- (void)chatBar:(LKChatBar *)chatBar sendVoice:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds;

/*!
 *  输入了 @ 的时候
 *
 */
- (void)didInputAtSign:(LKChatBar *)chatBar;

- (NSArray *)regulationForBatchDeleteText;

@end
NS_ASSUME_NONNULL_END
