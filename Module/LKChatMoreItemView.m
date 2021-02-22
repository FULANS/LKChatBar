//
//  LKChatMoreItemView.m
//  LiemsMobile70
//
//  Created by WZheng on 2020/4/8.
//  Copyright © 2020 Luculent. All rights reserved.
//

#import "LKChatMoreItemView.h"

@implementation LKChatMoreViewItem
@end


@interface LKChatMoreItemView ()

@property (nonatomic, assign) LKChatMoreViewItemType pluginType;
@property (nonatomic, strong) UIImageView *iconIV;
@property (nonatomic, strong) HTLabel *titleLab;

@end

@implementation LKChatMoreItemView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubViews:frame];
    }
    return self;
}

- (void)fillWithPluginTitle:(NSString *)pluginTitle
            pluginIconImage:(UIImage *)pluginIconImage
                    itemTyp:(LKChatMoreViewItemType)pluginType{

    self.iconIV.image = pluginIconImage;
    self.titleLab.text = pluginTitle;
    self.pluginType = pluginType;
}

- (void)addSubViews:(CGRect)frame{
    
    [self addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.offset(0);
        make.height.mas_offset(12);
    }];
    
    [self addSubview:self.iconIV];
    [self.iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.offset(8);
        make.trailing.offset(-8);
        make.bottom.equalTo(self.titleLab.mas_top).mas_offset(-8);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPluginAction:)];
    [self addGestureRecognizer:tap];

}

- (void)clickPluginAction:(UITapGestureRecognizer *)sender{
    !self.pluginDidClicked ? : self.pluginDidClicked(self.pluginType);
}

#pragma mark - UI
- (HTLabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [HTLabel new];
        _titleLab.numberOfLines = 1;
        _titleLab.textColor = HT_UIColorFromRGB(0x666666);
        _titleLab.font = [UIFont systemFontOfSize:12];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UIImageView *)iconIV{
    if (!_iconIV) {
        _iconIV = [UIImageView new];
        _iconIV.contentMode = UIViewContentModeCenter;
        _iconIV.backgroundColor = HT_UIColorFromRGB(0xF2F3F7);
    }
    return _iconIV;
}

@end
