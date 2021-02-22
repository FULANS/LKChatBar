//
//  LKChatFaceManager.h
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#define kGroupsIDKey          @"name"
#define kGroupsRowKey        @"rows"

#define kFaceIDKey          @"face_id"
#define kFaceNameKey        @"face_name"
#define kFaceImageNameKey   @"face_image_name"

#define kFaceRankKey        @"face_rank"
#define kFaceClickKey       @"face_click"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LKChatBarUtil.h"


/**
 *  表情管理类,可以获取所有的表情名称
 *  TODO 直接获取所有的表情Dict,添加排序功能,对表情进行排序,常用表情排在前面
 */

@interface LKEmojiMatchingResult : NSObject

@property (nonatomic, assign) NSRange range;/**<匹配到的表情包文本的range*/
@property (nonatomic, strong) UIImage *emojiImage;/**<如果能在本地找到emoji的图片，则此值不为空*/
@property (nonatomic, strong) NSString *showingDescription;/**<表情的实际文本(形如：[哈哈])，不为空*/

@end

@interface LKChatFaceManager : NSObject

+ (instancetype)shareInstance;

#pragma mark - emoji表情相关
@property (strong, nonatomic, readonly) NSArray *allEmojiFaceGroups; // 全部的表情组
@property (strong, nonatomic, readonly) NSMutableArray *allemojiFaces;    // Groups数组 转的 全部表情数组
@property (strong, nonatomic, readonly) NSMutableArray *currentEmojiFaces; // 当前选中的表情数组
@property (strong, nonatomic, readonly) NSMutableArray *recentEmojiFaces; // 最近使用的表情数组
/**
 更新当前选中的表情数组
 @param index -1为最近 , 其他:0,1,2
 */
- (void)updateCurrentEmojiFacesIndex:(NSInteger)index;

/**
 *  存储一个最近使用的face
 *
 *  @param dict 包含以下key-value键值对
 *  face_id     表情id
 *  face_name   表情名称
 *  @return 是否存储成功
 */
- (BOOL)saveRecentFace:(NSDictionary *)dict;




- (UIImage *)faceImageWithFaceID:(NSUInteger)faceID;
- (NSString *)faceNameWithFaceID:(NSUInteger)faceID;
/**
 *  将文字中带表情的字符处理换成图片显示
 *
 *  @param text 未处理的文字
 *
 *  @return 处理后的文字
 */
- (NSMutableAttributedString *)emotionStrWithString:(NSString *)text;


- (void)configEmotionWithMutableAttributedString:(NSMutableAttributedString *)attributeString
                                            font:(UIFont *)font;

- (void)configEmotionWithMutableAttributedString:(NSMutableAttributedString *)attributeString;


- (NSArray<LKEmojiMatchingResult *> *)matchingEmojiForString:(NSString *)string;

@end

