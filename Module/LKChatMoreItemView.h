//
//  LKChatMoreItemView.h
//  LiemsMobile70
//
//  Created by WZheng on 2020/4/8.
//  Copyright © 2020 Luculent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LKChatMoreViewItemType) {
    LKChatMoreViewItemTypeDefault = 0,       /**< 默认未知类型 */
    LKChatMoreViewItemTypeTakePicture = 1,         /**< 拍照 */
    LKChatMoreViewItemTypePhotoAlbum = 2,         /**< 相册 */
    LKChatMoreViewItemTypeVideo = 3,         /**< 短视频 */
    LKChatMoreViewItemTypeLocation = 4,          /**< 地理位置 */
};

NS_ASSUME_NONNULL_BEGIN

@interface LKChatMoreViewItem : NSObject

@property (nonatomic, copy) NSString *pluginTitle;
@property (nonatomic, strong) UIImage  *pluginIconImage;

@end

@interface LKChatMoreItemView : UIView

@property (nonatomic,assign, readonly) LKChatMoreViewItemType pluginType;

- (void)fillWithPluginTitle:(NSString *)pluginTitle
            pluginIconImage:(UIImage *)pluginIconImage
                    itemTyp:(LKChatMoreViewItemType)pluginType;

@property (copy, nonatomic) void (^pluginDidClicked)(LKChatMoreViewItemType pluginType);

@end

NS_ASSUME_NONNULL_END
