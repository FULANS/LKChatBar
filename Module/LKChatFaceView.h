//
//  LKLayIMChatFaceView.h
//  LiemsMobileEnterprise
//
//  Created by hillyoung on 2019/2/15.
//  Copyright © 2019 luculent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LKShowFaceViewType) {
    LKShowEmojiFace = 0,
    LKShowRecentFace,
    LKShowGifFace, // 暂时木有
};


@protocol LKChatFaceViewDelegate <NSObject>

- (void)faceViewSendFace:(NSString *)faceName;

@end



@interface LKChatFaceView : UIView

@property (strong, nonatomic) UIButton *sendButton;
@property (weak, nonatomic) id<LKChatFaceViewDelegate> delegate;
@property (assign, nonatomic, readonly) LKShowFaceViewType faceViewType;

@end

NS_ASSUME_NONNULL_END
