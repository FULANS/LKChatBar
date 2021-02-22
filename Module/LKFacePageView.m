//
//  LKFacePageView.m
//  LiemsMobileEnterprise
//
//  Created by hillyoung on 2019/2/15.
//  Copyright © 2019 luculent. All rights reserved.
//

#import "LKFacePageView.h"


/**
 *  预览表情显示的View
 */
@interface LKFacePreviewView : UIView

@property (weak, nonatomic) UIImageView *faceImageView /**< 展示face表情的 */;
@property (weak, nonatomic) UIImageView *backgroundImageView /**< 默认背景 */;
@property (weak, nonatomic) UILabel *descLab /**< 文字 */;

@end

@implementation LKFacePreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:({
        NSString *imageName = @"emoji-preview-bg";
        UIImage *image = [UIImage lkchat_imageNamed:imageName bundleName:@"LKChatKeyboard" bundleForClass:[self class]];
        image;})
                                        ];
    [self addSubview:self.backgroundImageView = backgroundImageView];

    UIImageView *faceImageView = [[UIImageView alloc] init];
    [self addSubview:self.faceImageView = faceImageView];

    self.bounds = self.backgroundImageView.bounds;
    
    
    UILabel *descLab = [UILabel new];
    descLab.textColor = kBasicLineBackgroundColor;
    descLab.font = [UIFont systemFontOfSize:12];
    descLab.adjustsFontSizeToFitWidth = YES;
    descLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    descLab.textAlignment = NSTextAlignmentCenter;
    descLab.frame = CGRectMake(self.frame.size.width / 4, self.frame.size.height - 16, self.frame.size.width / 2, 16);
    [self addSubview:self.descLab = descLab];
    [self setClipsToBounds:YES];
}

/**
 *  修改faceImageView显示的图片
 *
 *  @param image 需要显示的表情图片
 */
- (void)setFaceImage:(UIImage *)image desc:(NSString *)desc {
    self.hidden = image == nil;
    if (self.faceImageView.image == image) {
        return;
    }

    [self.faceImageView setImage:image];
    [self.faceImageView sizeToFit];
    self.faceImageView.center = CGPointMake(self.backgroundImageView.center.x, self.backgroundImageView.center.y - 25);
    self.descLab.text = desc;
    self.descLab.center = CGPointMake(self.backgroundImageView.center.x, self.backgroundImageView.center.y);
    
    [UIView animateWithDuration:.25f animations:^{
        self.faceImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 animations:^{
            self.faceImageView.transform = CGAffineTransformIdentity;
        }];
    }];
}

@end

@interface LKFacePageView ()

@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) LKFacePreviewView *facePreviewView;

@end

@implementation LKFacePageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageViews = [NSMutableArray array];

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:longPress];
        self.userInteractionEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                          [self.facePreviewView removeFromSuperview];
                                                      }];

        [self setup];
    }
    return self;
}

#pragma mark - Private Methods

- (void)setup {
    
    //判断是否需要重新添加所有的imageView
    if (self.imageViews && self.imageViews.count >= self.datas.count) {
        for (UIImageView *imageView in self.imageViews) {
            NSUInteger index = [self.imageViews indexOfObject:imageView];
            imageView.hidden = index >= self.datas.count;
            if (!imageView.hidden) {
                NSDictionary *faceDict = self.datas[index];
                UIImage *faceImage = [[LKChatFaceManager shareInstance] faceImageWithFaceID:[faceDict[kFaceIDKey] integerValue]];
                imageView.tag = [faceDict[kFaceIDKey] integerValue];
                imageView.image = faceImage;
            }
        }
    } else {
        //计算每个item的大小
      CGFloat itemWidth = MIN((self.frame.size.width - 40) / (self.columnsPerRow), self.frame.size.height/2);
        NSUInteger currentColumn = 0;
        NSUInteger currentRow = 0;
        for (NSDictionary *faceDict in self.datas) {
            if (currentColumn >= self.columnsPerRow) {
                currentRow ++ ;
                currentColumn = 0;
            }
            //计算每一个图片的起始X位置 (左边距) + 第几列*itemWidth + 第几页*一页的宽度
            CGFloat left = (self.frame.size.width - self.columnsPerRow * itemWidth) / 2;
            CGFloat startX = left + currentColumn * itemWidth;
            //计算每一个图片的起始Y位置  第几行*每行高度
            CGFloat startY = currentRow * itemWidth;
            UIImageView *imageView = [self faceImageViewWithID:faceDict[kFaceIDKey]];
            [imageView setFrame:CGRectMake(startX, startY, itemWidth, itemWidth)];
            [self addSubview:imageView];
            [self.imageViews addObject:imageView];
            currentColumn ++ ;
        }
    }
}

/**
 *  根据faceID获取一个imageView实例
 *
 *  @param faceID faceID
 *
 *  @return UIImageView
 */
- (UIImageView *)faceImageViewWithID:(NSString *)faceID{

    UIImage *faceImage = [[LKChatFaceManager shareInstance] faceImageWithFaceID:[faceID integerValue]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:faceImage];
    imageView.userInteractionEnabled = YES;
    imageView.tag = [faceID integerValue];
    imageView.contentMode = UIViewContentModeCenter;

    //添加图片的点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [imageView addGestureRecognizer:tap];

    return imageView;
}


/**
 *  根据点击位置获取点击的imageView
 *
 *  @param point 点击的位置
 *
 *  @return 被点击的imageView
 */
- (UIImageView *)faceViewWitnInPoint:(CGPoint)point{
    for (UIImageView *imageView in self.imageViews) {
        if (CGRectContainsPoint(imageView.frame, point)) {
            return imageView;
        }
    }
    return nil;
}

- (NSDictionary *)faceWitnInPoint:(CGPoint)point{
    NSDictionary *face;;
    UIImageView *touchFaceView = [self faceViewWitnInPoint:point];
    
    if (touchFaceView) {
        NSInteger index = [self.imageViews indexOfObject:touchFaceView];
        if (index < self.datas.count) {
            face = self.datas[index];
        }
    }
    return face;
}


#pragma mark - Response Methods

- (void)handleTap:(UITapGestureRecognizer *)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedFaceImageWithFaceID:)]) {
        [self.delegate selectedFaceImageWithFaceID:tap.view.tag];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
    CGPoint touchPoint = [longPress locationInView:self];
    CGPoint windowPoint = [longPress locationInView:[UIApplication sharedApplication].keyWindow];
    UIImageView *touchFaceView = [self faceViewWitnInPoint:touchPoint];
    NSDictionary *face = [self faceWitnInPoint:touchPoint];
    NSString *desc = face ? face[kFaceNameKey] : @"";
    NSString *faceid = face ? face[kFaceIDKey] : nil;
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self.facePreviewView setCenter:CGPointMake(windowPoint.x, windowPoint.y - 40)];
        [self.facePreviewView setFaceImage:touchFaceView.image desc:desc];
        // 防止被键盘所在的窗口挡住,不能用 keyWindow , 使用 lastObject
        [[UIApplication sharedApplication].windows.lastObject addSubview:self.facePreviewView];
        self.facePreviewView.layer.zPosition = 1;
        
        
    } else if (longPress.state == UIGestureRecognizerStateChanged){
        [self.facePreviewView setCenter:CGPointMake(windowPoint.x, windowPoint.y - 40)];
        [self.facePreviewView setFaceImage:touchFaceView.image desc:desc];
    } else if (longPress.state == UIGestureRecognizerStateEnded) {
        [self.facePreviewView removeFromSuperview];
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectedFaceImageWithFaceID:)]) {
            [self.delegate selectedFaceImageWithFaceID:[faceid integerValue]];
        }
        
    }
}

#pragma mark - Getters

- (LKFacePreviewView *)facePreviewView {
    if (!_facePreviewView) {
        _facePreviewView = [[LKFacePreviewView alloc] initWithFrame:CGRectZero];
    }
    return _facePreviewView;
}

#pragma mark - Setters

- (void)setDatas:(NSArray *)datas {
    _datas = [datas copy];
    [self setup];
}

- (void)setColumnsPerRow:(NSUInteger)columnsPerRow {
    if (_columnsPerRow != columnsPerRow) {
        _columnsPerRow = columnsPerRow;
        [self.imageViews removeAllObjects];
        for (UIView *subView in self.subviews) {
            [subView removeFromSuperview];
        }
    }
}

@end
