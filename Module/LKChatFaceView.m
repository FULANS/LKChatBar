//
//  LKLayIMChatFaceView.m
//  LiemsMobileEnterprise
//
//  Created by hillyoung on 2019/2/15.
//  Copyright © 2019 luculent. All rights reserved.
//

#import "LKChatFaceView.h"
#import "LKSwipeView.h"
#import "LKFacePageView.h"
#import "LKChatBarUtil.h"


@interface LKChatFaceView () <UIScrollViewDelegate,LKSwipeViewDelegate,LKSwipeViewDataSource,LKFacePageViewDelegate>

@property (nonatomic, strong) UIImageView *topLine;
@property (nonatomic, strong) LKSwipeView *swipeView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIScrollView *bottomView;

@property (nonatomic,strong) NSMutableArray <UIButton *>*allFaceBtns;

@property (assign, nonatomic) NSUInteger columnPerRow; /**< 每行显示的表情数量,6,6plus可能相应多显示  默认emoji5s显示7个 最近表情显示4个  gif表情显示4个 */
@property (assign, nonatomic) NSUInteger maxRows; /**< 每页显示的行数 默认emoji3行  最近表情2行  gif表情2行 */
@property (nonatomic, assign ,readonly) NSUInteger itemsPerPage;
@property (nonatomic, assign) NSUInteger pageCount;

@property (nonatomic, strong) NSMutableArray *faceArray;

@property (assign, nonatomic) LKShowFaceViewType faceViewType;
@property (nonatomic, assign) NSInteger currentEmojiIndex;

@end


@implementation LKChatFaceView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

#pragma mark - LKSwipeViewDelegate & LKSwipeViewDataSource
- (UIView *)swipeView:(LKSwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    LKFacePageView *facePageView = (LKFacePageView *)view;
    if (!view) {
        facePageView = [[LKFacePageView alloc] initWithFrame:swipeView.frame];
    }
    [facePageView setColumnsPerRow:self.columnPerRow];
    if ((index + 1) * self.itemsPerPage  >= self.faceArray.count) {
        [facePageView setDatas:[self.faceArray subarrayWithRange:NSMakeRange(index * self.itemsPerPage, self.faceArray.count - index * self.itemsPerPage)]];
    } else {
        [facePageView setDatas:[self.faceArray subarrayWithRange:NSMakeRange(index * self.itemsPerPage, self.itemsPerPage)]];
    }
    facePageView.delegate = self;
    return facePageView;
}

- (NSInteger)numberOfItemsInLKSwipeView:(LKSwipeView *)swipeView {
    return self.pageCount ;
}

- (void)swipeViewCurrentItemIndexDidChange:(LKSwipeView *)swipeView {
    self.pageControl.currentPage = swipeView.currentPage;
}

#pragma mark - LKFacePageViewDelegate
- (void)selectedFaceImageWithFaceID:(NSUInteger)faceID {
    NSString *faceName = [[LKChatFaceManager shareInstance] faceNameWithFaceID:faceID];
    if (faceName.length && faceID != 999) {
        NSDictionary *face = [NSDictionary dictionaryWithObjectsAndKeys:@(faceID).description,kFaceIDKey,faceName,kFaceNameKey, nil];
        [[LKChatFaceManager shareInstance] saveRecentFace:face];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)]) {
        [self.delegate faceViewSendFace:faceName];
    }
}

#pragma mark - Private Methods
- (void)setupConstraints {

    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.width.mas_equalTo(self);
        make.height.mas_equalTo(.5f);
    }];
    
    [self.swipeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.width.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-40);
        make.top.mas_equalTo(self);
    }];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.width.mas_equalTo(self);
        make.bottom.mas_equalTo(self.swipeView.mas_bottom);
        make.height.mas_equalTo(15);
    }];

    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.mas_equalTo(self);
        make.trailing.offset(-70);
        make.height.mas_equalTo(40);
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bottomView.mas_trailing).offset(0);
        make.trailing.offset(0);
        make.height.mas_equalTo(self.bottomView);
        make.centerY.mas_equalTo(self.bottomView);
    }];
    
    
    
}

- (void)setup{
    self.userInteractionEnabled = YES;
    self.allFaceBtns = @[].mutableCopy;
    self.faceArray = @[].mutableCopy;
    self.currentEmojiIndex = 0;
    
    [self addSubview:self.topLine];
    [self addSubview:self.swipeView];
    [self addSubview:self.pageControl];
    [self addSubview:self.bottomView];
    [self addSubview:self.sendButton];
    [self setupConstraints];
    [self setupFaceView];
}

- (void)setupFaceView {
    
    [self.faceArray removeAllObjects];
    [[LKChatFaceManager shareInstance] updateCurrentEmojiFacesIndex:self.currentEmojiIndex];
    if (self.currentEmojiIndex == -1) {
        [self setupRecentFaces];
    }else{
        [self setupEmojiFaces];
    }
    [self.swipeView reloadData];
}

- (void)clickFaceView:(UIButton *)sender{
    NSInteger tag = sender.tag;
    [self.allFaceBtns enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = NO;
    }];
    sender.selected = YES;
    self.currentEmojiIndex = tag;
    [self setupFaceView];
}

/**
 *  初始化最近使用的表情数组
 */
- (void)setupRecentFaces{
    self.faceViewType = LKShowRecentFace;
    [self.faceArray removeAllObjects];
    self.pageCount = 1;
    self.pageControl.currentPage = 0;
    self.pageControl.hidden = YES;
    self.maxRows = 2;
    self.columnPerRow = 4;
    [self.faceArray addObjectsFromArray:[[LKChatFaceManager shareInstance] currentEmojiFaces]];
}

/**
 *  初始化所有的emoji表情数组,添加删除按钮
 */
- (void)setupEmojiFaces{
    self.faceViewType = LKShowEmojiFace;
    [self.faceArray removeAllObjects];
    
    CGFloat width = [UIApplication sharedApplication].keyWindow.frame.size.width;
    CGFloat height = [UIApplication sharedApplication].keyWindow.frame.size.height;
    self.maxRows =  height > 480 ? 3 : 4;
    self.columnPerRow = width > 320 ? 8 : 7;
    NSInteger pageItemCount = self.itemsPerPage - 1; //计算每一页最多显示多少个表情  - 1(删除按钮)
    
    
    [self.faceArray addObjectsFromArray:[[LKChatFaceManager shareInstance] currentEmojiFaces]];
    NSInteger count = [self.faceArray count];
    self.pageCount = count % pageItemCount == 0 ? count / pageItemCount : (count / pageItemCount) + 1;
    self.pageControl.numberOfPages = self.pageCount;

    //循环,给每一页末尾加上一个delete图片,如果是最后一页直接在最后一个加上delete图片
    NSDictionary *delete = [NSDictionary dictionaryWithObjectsAndKeys:@"999",kFaceIDKey,@"删除",kFaceNameKey, nil];
    for (int i = 0; i < self.pageCount; i++) {
        if (self.pageCount - 1 == i) {
            [self.faceArray addObject:delete];
        } else {
            [self.faceArray insertObject:delete
                                 atIndex:(i + 1) * pageItemCount + i];
        }
    }
    
    self.pageControl.currentPage = 0;
    self.pageControl.hidden = NO;
}

/**
 *  初始化所有的GIF表情数组
 */
- (void)setupGIFFaces{
    self.faceViewType = LKShowGifFace;
    [self.faceArray removeAllObjects];
    self.pageControl.hidden = NO;
}


- (void)sendAction:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)]) {
        [self.delegate faceViewSendFace:@"发送"];
    }
}

#pragma mark - Getters
- (UIImageView *)topLine{
    if (!_topLine) {
        _topLine = [[UIImageView alloc] init];
        _topLine.backgroundColor = kBasicLineBackgroundColor;
    }
    return _topLine;
}

- (LKSwipeView *)swipeView {
    if (!_swipeView) {
        _swipeView = [[LKSwipeView alloc] init];
        _swipeView.delegate = self;
        _swipeView.dataSource = self;
    }
    return _swipeView;
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.enabled = NO;
    }
    return _pageControl;
}

- (UIButton *)sendButton{
    if (!_sendButton) {
        _sendButton = [[UIButton alloc] init];
        _sendButton.backgroundColor = HT_MAIN_Theme_COLOR;
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [UIScrollView new];
        UIImageView *topLine = [UIImageView new];
        topLine.backgroundColor = kBasicLineBackgroundColor;
        [_bottomView addSubview:topLine];
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.offset(0);
            make.height.mas_equalTo(.5f);
            make.width.mas_equalTo(_bottomView);
        }];
        
        
        UIButton *recentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [recentButton setTitle:@"最近" forState:(UIControlStateNormal)];
        recentButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [_bottomView addSubview:recentButton];
        [recentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [recentButton setTitleColor:HT_MAIN_Theme_COLOR forState:UIControlStateSelected];
        recentButton.tag = -1;
        [recentButton addTarget:self action:@selector(clickFaceView:) forControlEvents:UIControlEventTouchUpInside];


        
        [recentButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.offset(0);
            make.leading.offset(0);
            make.width.equalTo(recentButton.mas_height);
            make.centerY.offset(0);
        }];
        [self.allFaceBtns addObject:recentButton];
        
        
        NSArray *groups = [[LKChatFaceManager shareInstance] allEmojiFaceGroups];
        NSInteger count = groups.count;
        
        for (int i = 0; i < count; i++) {
            
            NSDictionary *group = groups[i];
            NSString *name = group[kGroupsIDKey];
            
            UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [emojiButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [emojiButton setTitleColor:HT_MAIN_Theme_COLOR forState:UIControlStateSelected];
            [emojiButton setTitle:name forState:(UIControlStateNormal)];
            [emojiButton addTarget:self action:@selector(clickFaceView:) forControlEvents:UIControlEventTouchUpInside];
            emojiButton.tag = i;
            emojiButton.selected = i == 0;
            emojiButton.titleLabel.font = [UIFont systemFontOfSize:10];
            [_bottomView addSubview: emojiButton];
            [self.allFaceBtns addObject:emojiButton];
            
            UIButton *preBtn = self.allFaceBtns[i];
            
            UIView *line = [UIView new];
            line.backgroundColor = [kBasicLineBackgroundColor colorWithAlphaComponent:0.5];
            [_bottomView addSubview: line];
            
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(preBtn.mas_trailing).offset(1.5f);
                make.width.mas_offset(.5f);
                make.centerY.offset(0);
                make.height.equalTo(_bottomView.mas_height).multipliedBy(0.5);
            }];
            
            [emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(preBtn.mas_trailing).offset(4);
                make.bottom.offset(0);
                make.width.equalTo(recentButton.mas_height);
                make.centerY.offset(0);
            }];
            
            if (i == count - 1) {
                [emojiButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(preBtn.mas_trailing).offset(4);
                    make.bottom.offset(0);
                    make.width.equalTo(recentButton.mas_height);
                    make.trailing.mas_lessThanOrEqualTo(-4);
                    make.centerY.offset(0);
                }];
            }
        }
    }
    return _bottomView;
}

/**
 *  每一页显示的表情数量 = M每行数量*N行
 */
- (NSUInteger)itemsPerPage {
    return self.maxRows * self.columnPerRow;
}

- (UIImage *)imageInBundlePathForImageName:(NSString *)imageName {
    return   ({
        UIImage *image = [UIImage lkchat_imageNamed:imageName bundleName:@"LKChatKeyboard" bundleForClass:[self class]];
        image;});
}

@end
