//
//  LKLayIMChatBar.m
//  LiemsMobileEnterprise
//
//  Created by hillyoung on 2019/2/15.
//  Copyright © 2019 luculent. All rights reserved.
//

#import "LKChatBar.h"
#import "LKSwipeView.h"
#import "LKFacePageView.h"
#import "LKChatMoreView.h"
#import "LKChatFaceView.h"
#import "LKChatBarUtil.h"
#import "LKMp3Recorder.h"

NSString *const lkChatBatchDeleteTextPrefix = @"lkChatBatchDeleteTextPrefix";
NSString *const lkChatBatchDeleteTextSuffix = @"lkChatBatchDeleteTextSuffix";

CGFloat const LKAnimateDuration = .5f;

@interface LKChatBar () <UITextViewDelegate, UINavigationControllerDelegate, LKChatFaceViewDelegate,LKMp3RecorderDelegate>

@property (strong, nonatomic) LKMp3Recorder *MP3;
@property (nonatomic, strong) UIView *inputBarBackgroundView; /**< 输入栏目背景视图 */
@property (strong, nonatomic) UIButton *voiceButton; /**< 切换录音模式按钮 */
@property (strong, nonatomic) UIButton *voiceRecordButton; /**< 录音按钮 */

@property (strong, nonatomic) UIButton *faceButton; /**< 表情按钮 */
@property (strong, nonatomic) UIButton *moreButton; /**< 更多按钮 */
@property (weak, nonatomic) LKChatFaceView *faceView; /**< 当前活跃的底部view,用来指向faceView */
@property (weak, nonatomic) LKChatMoreView *moreView; /**< 当前活跃的底部view,用来指向moreView */
@property (assign, nonatomic, readonly) CGFloat bottomHeight;
@property (strong, nonatomic, readonly) UIViewController *rootViewController;
@property (assign, nonatomic) CGSize keyboardSize;
@property (assign, nonatomic) CGFloat oldTextViewHeight;
@property (nonatomic, assign, getter=shouldAllowTextViewContentOffset) BOOL allowTextViewContentOffset;
@property (nonatomic, assign, getter=iSHidden) BOOL close;

@property (nonatomic, copy) NSString *temp_str;

@property (nonatomic, assign, getter=isCommentMode) BOOL commentMode;

#pragma mark - MessageInputView Customize UI
///=============================================================================
/// @name MessageInputView Customize UI
///=============================================================================

@property (nonatomic, strong) UIColor *messageInputViewBackgroundColor;
@property (nonatomic, strong) UIColor *messageInputViewTextFieldTextColor;
@property (nonatomic, strong) UIColor *messageInputViewTextFieldBackgroundColor;
@property (nonatomic, strong) UIColor *messageInputViewRecordTextColor;

@end

@implementation LKChatBar

#pragma mark - Life Cycle


- (instancetype)initWithFrame:(CGRect)frame
                  commentMode:(BOOL)isComment{
    self = [super initWithFrame:frame];
    if (self) {
        self.commentMode = isComment;
        [self setup];
    }
    return self;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setupConstraints {
    CGFloat offset = 8;
    [self.inputBarBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self).priorityLow();; 
    }];

    
    if (self.isCommentMode) {
        [self.faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.offset(-offset);
            make.bottom.offset(-kLKChatBarBottomOffset);
            make.width.height.mas_offset(32);
        }];
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(kLKChatBarTextViewBottomOffset);
            make.leading.offset(offset);
            make.trailing.equalTo(self.faceButton.mas_leading).offset(-offset);
            make.bottom.offset(-kLKChatBarTextViewBottomOffset);
            make.height.mas_greaterThanOrEqualTo(kLKChatBarTextViewFrameMinHeight);
        }];
    }else{
        
        [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.inputBarBackgroundView.mas_left).with.offset(offset);
            make.bottom.equalTo(self.inputBarBackgroundView.mas_bottom).with.offset(-kLKChatBarBottomOffset);
            make.width.height.mas_offset(32);
        }];
        
        [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.inputBarBackgroundView.mas_right).with.offset(-offset);
            make.bottom.equalTo(self.inputBarBackgroundView.mas_bottom).with.offset(-kLKChatBarBottomOffset);
            make.width.height.mas_offset(32);
        }];
        
        [self.faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.moreButton.mas_left).with.offset(-offset);
            make.bottom.equalTo(self.inputBarBackgroundView.mas_bottom).with.offset(-kLKChatBarBottomOffset);
            make.width.height.mas_offset(32);
        }];
        
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.voiceButton.mas_right).with.offset(offset);
            make.right.equalTo(self.faceButton.mas_left).with.offset(-offset);
            make.top.equalTo(self.inputBarBackgroundView).with.offset(kLKChatBarTextViewBottomOffset);
            make.bottom.equalTo(self.inputBarBackgroundView).with.offset(-kLKChatBarTextViewBottomOffset);
            make.height.mas_greaterThanOrEqualTo(kLKChatBarTextViewFrameMinHeight);
        }];
        
        CGFloat voiceRecordButtoInsets = -5.f;
        [self.voiceRecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.textView).insets(UIEdgeInsetsMake(voiceRecordButtoInsets, voiceRecordButtoInsets, voiceRecordButtoInsets, voiceRecordButtoInsets));
        }];
        
        [self.faceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.left.mas_equalTo(self);
            make.height.mas_equalTo(kLKFunctionViewHeight);
            make.top.mas_equalTo(self.mas_bottom);
        }];
        
        [self.moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.left.mas_equalTo(self);
            make.height.mas_equalTo(kLKFunctionViewHeight);
            make.top.mas_equalTo(self.mas_bottom);
        }];
        
    }
    
    
    
}

- (void)dealloc {
    self.delegate = nil;
    _faceView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -
#pragma mark - Setter Method

- (void)setCachedText:(NSString *)cachedText {
    _cachedText = [cachedText copy];
    if ([_cachedText isEqualToString:@""]) {
        [self updateChatBarConstraintsIfNeededShouldCacheText:NO];
        self.allowTextViewContentOffset = YES;
        return;
    }
    if ([self isSpace:cachedText]) {
        _cachedText = @"";
        return;
    }
}

- (UIViewController *)controllerRef {
    return (UIViewController *)self.delegate;
}

- (void)setDelegate:(id<LKChatBarDelegate>)delegate {
    _delegate = delegate;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (range.location == [textView.text length]) {
        self.allowTextViewContentOffset = YES;
    } else {
        self.allowTextViewContentOffset = NO;
    }
    if ([text isEqualToString:@"\n"]) { // 进行发送: 把 富文本转成 text
        [self sendTextMessage:[self plainText] ]; //  textView.text
        return NO;
    } else if (text.length == 0){
        //构造元素需要使用两个空格来进行缩进，右括号]或者}写在新的一行，并且与调用语法糖那行代码的第一个非空字符对齐：
        NSArray *defaultRegulations = @[
                                        //判断删除的文字是否符合表情文字规则
                                        @{
                                            lkChatBatchDeleteTextPrefix : @"face[",
                                            lkChatBatchDeleteTextSuffix : @"]",
                                            },
                                        //判断删除的文字是否符合提醒群成员的文字规则
                                        @{
                                            lkChatBatchDeleteTextPrefix : @"@",
                                            lkChatBatchDeleteTextSuffix : @" ",
                                            },
                                        ];
        NSArray *additionRegulation;
        if ([self.delegate respondsToSelector:@selector(regulationForBatchDeleteText)]) {
            additionRegulation = [self.delegate regulationForBatchDeleteText];
        }
        if (additionRegulation.count > 0) {
            defaultRegulations = [defaultRegulations arrayByAddingObjectsFromArray:additionRegulation];
        }
        for (NSDictionary *regulation in defaultRegulations) {
            NSString *prefix = regulation[lkChatBatchDeleteTextPrefix];
            NSString *suffix = regulation[lkChatBatchDeleteTextSuffix];
            if (![self textView:textView shouldChangeTextInRange:range deleteBatchOfTextWithPrefix:prefix suffix:suffix]) {
                return  NO;
            }
        }
        return YES;
    } else if ([text isEqualToString:@"@"]) {
        if ([self.delegate respondsToSelector:@selector(didInputAtSign:)]) {
            [self.delegate didInputAtSign:self];
        }
        return YES;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self textViewDidChange:textView shouldCacheText:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range deleteBatchOfTextWithPrefix:(NSString *)prefix
          suffix:(NSString *)suffix {
    NSString *substringOfText = [textView.text substringWithRange:range];
    if ([substringOfText isEqualToString:suffix]) {
        NSUInteger location = range.location;
        NSUInteger length = range.length;
        NSString *subText;
        while (YES) {
            if (location == 0) {
                return YES;
            }
            location -- ;
            length ++ ;
            subText = [textView.text substringWithRange:NSMakeRange(location, length)];
            if (([subText hasPrefix:prefix] && [subText hasSuffix:suffix])) {
                //这里注意，批量删除的字符串，除了前缀和后缀，中间不能有空格出现
                NSString *string = [textView.text substringWithRange:NSMakeRange(location, length-1)];
                if (![self containsString:@" "InString:string]) {
                    break;
                }
            }
        }

        textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
        [textView setSelectedRange:NSMakeRange(location, 0)];
        [self textViewDidChange:self.textView];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.faceButton.selected = self.moreButton.selected = self.voiceButton.selected = NO;
    [self showFaceView:NO];
    [self showMoreView:NO];
    [self showVoiceView:NO];
    return YES;
}

#pragma mark -
#pragma mark - Private Methods
- (BOOL)isSpace:(NSString *)string{
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([[string stringByTrimmingCharactersInSet: set] length] == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)containsString:(NSString *)string InString:(NSString *)str{
    if ([str rangeOfString:string].location == NSNotFound) {
        return NO;
    }
    return YES;
}


- (void)updateChatBarConstraintsIfNeeded {
    NSString *reason = [NSString stringWithFormat:@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Should update on main thread"];
    NSAssert([NSThread mainThread], reason);
    BOOL shouldCacheText = NO;
    BOOL shouldScrollToBottom = YES;
    LKFunctionViewShowType functionViewShowType = self.showType;
    switch (functionViewShowType) {
        case LKFunctionViewShowNothing: {
            shouldScrollToBottom = NO;
            shouldCacheText = YES;
        }
            break;
        case LKFunctionViewShowFace:
        case LKFunctionViewShowMore:
        case LKFunctionViewShowKeyboard: {
            shouldCacheText = YES;
        }
            break;
        case LKFunctionViewShowVoice:
            shouldCacheText = NO;
            break;
    }
    [self updateChatBarConstraintsIfNeededShouldCacheText:shouldCacheText];
    [self chatBarFrameDidChangeShouldScrollToBottom:shouldScrollToBottom];
}

- (void)updateChatBarConstraintsIfNeededShouldCacheText:(BOOL)shouldCacheText {
    [self textViewDidChange:self.textView shouldCacheText:shouldCacheText];
}

- (void)updateChatBarKeyBoardConstraints {
    
    // FIX:Tabbar
    CGFloat tabBarHeight = 0;
    if (!self.controllerRef.tabBarController.tabBar.isHidden) {
        tabBarHeight = self.controllerRef.tabBarController.tabBar.frame.size.height;
    }

    if (self.keyboardSize.height < 1){
        [self.superview setNeedsUpdateConstraints];
        [UIView animateWithDuration:LKAnimateDuration animations:^{
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-self.keyboardSize.height-[self screenInsets].bottom + tabBarHeight);
            }];
            
            [self.superview layoutIfNeeded];
            [self.faceView layoutIfNeeded];
        } completion:nil];
        
    }else{
        [self.superview setNeedsUpdateConstraints];
        [UIView animateWithDuration:LKAnimateDuration animations:^{
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-self.keyboardSize.height + tabBarHeight);
            }];
            [self.superview layoutIfNeeded];
            [self.faceView layoutIfNeeded];
        } completion:nil];
    }
}

#pragma mark - 核心方法
///=============================================================================
/// @name 核心方法
///=============================================================================

/*!
 * updateChatBarConstraintsIfNeeded: WhenTextViewHeightDidChanged
 * 只要文本修改了就会调用，特殊情况，也会调用：刚刚进入对话追加草稿、键盘类型切换、添加表情信息
 */
- (void)textViewDidChange:(UITextView *)textView
          shouldCacheText:(BOOL)shouldCacheText {
    
    if (shouldCacheText) {
        self.cachedText = [self plainText];
    }
    
    CGRect textViewFrame = self.textView.frame;
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(textViewFrame), 1000.0f)];
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    textView.scrollEnabled = (textSize.height > kLKChatBarTextViewFrameMinHeight);
    // textView 控件的高度在 kLKChatBarTextViewFrameMinHeight 和 kLKChatBarMaxHeight-offset 之间
    CGFloat newTextViewHeight = MAX(kLKChatBarTextViewFrameMinHeight, MIN(kLKChatBarTextViewFrameMaxHeight, textSize.height));
    BOOL textViewHeightChanged = (self.oldTextViewHeight != newTextViewHeight);
    if (textViewHeightChanged) {
        //FIXME:如果有草稿，且超出了最低高度，会产生约束警告。
        self.oldTextViewHeight = newTextViewHeight;
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            CGFloat height = newTextViewHeight;
            make.height.mas_equalTo(height);
        }];
        [self chatBarFrameDidChangeShouldScrollToBottom:YES];
    }

    void(^setContentOffBlock)() = ^() {
        if (textView.scrollEnabled && self.allowTextViewContentOffset) {
            if (newTextViewHeight == kLKChatBarTextViewFrameMaxHeight) {
                [textView setContentOffset:CGPointMake(0, textView.contentSize.height - newTextViewHeight) animated:YES];
            } else {
                [textView setContentOffset:CGPointZero animated:YES];
            }
        }
    };

    //FIXME:issue #178
    //在输入换行的时候，textView的内容向上偏移，再下次输入后恢复正常，原因是高度变化后，textView更新约束，重新设置了contentOffset；我是在设置contentOffset做了0.01秒的延迟，发现能解决这个问题
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        setContentOffBlock();
    });
    
    [self refreshTextUI];
}

- (void)refreshTextUI{

    if (!self.cachedText.length) {
        return;
    }
    UITextRange *markedTextRange = [self.textView markedTextRange];
    UITextPosition *position = [self.textView positionFromPosition:markedTextRange.start offset:0];
    if (position) {
        return;     // 正处于输入拼音还未点确定的中间状态
    }
    
    NSMutableAttributedString *attributedComment = [[NSMutableAttributedString alloc] initWithString:self.plainText attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: HT_UIColorFromRGB(0x333333) }];
    
    // 匹配表情
    [[LKChatFaceManager shareInstance] configEmotionWithMutableAttributedString:attributedComment];
    self.textView.attributedText = attributedComment;
}

- (NSString *)plainText{
    
    return [self.textView.attributedText lk_plainTextForRange:NSMakeRange(0, self.textView.attributedText.length)];
}


#pragma mark - LKMP3RecordedDelegate

- (void)endConvertWithMP3FileName:(NSString *)fileName {
    if (fileName) {
        [LKChatVoiceProgressHUD dismissWithProgressState:LKChatVoiceProgressSuccess];
        [self sendVoiceMessage:fileName seconds:[LKChatVoiceProgressHUD seconds]];
    } else {
        [LKChatVoiceProgressHUD dismissWithProgressState:LKChatVoiceProgressError];
    }
}

- (void)failRecord {
    [LKChatVoiceProgressHUD dismissWithProgressState:LKChatVoiceProgressError];
}

- (void)beginConvert {
    [LKChatVoiceProgressHUD changeSubTitle:@"正在转换..."];
}

#pragma mark - LKChatFaceViewDelegate Assit Action
- (void)faceViewDidClickDeleteButton{
    
    NSRange selectedRange = self.textView.selectedRange;
    if (selectedRange.location == 0 && selectedRange.length == 0) {
        return;
    }
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    if (selectedRange.length > 0) {
        [attributedText deleteCharactersInRange:selectedRange];
        self.textView.attributedText = attributedText;
        self.textView.selectedRange = NSMakeRange(selectedRange.location, 0);
    } else {
        NSUInteger deleteCharactersCount = 1;
        
        // 下面这段正则匹配是用来匹配文本中的所有系统自带的 emoji 表情，以确认删除按钮将要删除的是否是 emoji。这个正则匹配可以匹配绝大部分的 emoji，得到该 emoji 的正确的 length 值；不过会将某些 combined emoji（如 👨‍👩‍👧‍👦 👨‍👩‍👧‍👦 👨‍👨‍👧‍👧），这种几个 emoji 拼在一起的 combined emoji 则会被匹配成几个个体，删除时会把 combine emoji 拆成个体。瑕不掩瑜，大部分情况下表现正确，至少也不会出现删除 emoji 时崩溃的问题了。
        NSString *emojiPattern1 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900-\\U0001F9FF]";
        NSString *emojiPattern2 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900–\\U0001F9FF]\\uFE0F";
        NSString *emojiPattern3 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900–\\U0001F9FF][\\U0001F3FB-\\U0001F3FF]";
        NSString *emojiPattern4 = @"[\\rU0001F1E6-\\U0001F1FF][\\U0001F1E6-\\U0001F1FF]";
        NSString *pattern = [[NSString alloc] initWithFormat:@"%@|%@|%@|%@", emojiPattern4, emojiPattern3, emojiPattern2, emojiPattern1];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:NULL];
        NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:attributedText.string options:kNilOptions range:NSMakeRange(0, attributedText.string.length)];
        for (NSTextCheckingResult *match in matches) {
            if (match.range.location + match.range.length == selectedRange.location) {
                deleteCharactersCount = match.range.length;
                break;
            }
        }
        
        [attributedText deleteCharactersInRange:NSMakeRange(selectedRange.location - deleteCharactersCount, deleteCharactersCount)];
        self.textView.attributedText = attributedText;
        self.textView.selectedRange = NSMakeRange(selectedRange.location - deleteCharactersCount, 0);
    }
    
    [self textViewDidChange:self.textView];
}

- (void)faceViewDidClickEmoji:(NSString *)faceName{

    NSRange selectedRange = self.textView.selectedRange;
    NSString *emojiString = faceName;
    NSMutableAttributedString *emojiAttributedString = [[NSMutableAttributedString alloc] initWithString:emojiString];
    [emojiAttributedString lk_setTextBackedString:[LKTextBackedString stringWithString:emojiString] range:emojiAttributedString.lk_rangeOfAll];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [attributedText replaceCharactersInRange:selectedRange withAttributedString:emojiAttributedString];
    self.textView.attributedText = attributedText;
    self.textView.selectedRange = NSMakeRange(selectedRange.location + emojiAttributedString.length, 0);
    
    [self textViewDidChange:self.textView];
}

- (void)faceViewDidClickClickSendButton{
    
    NSString *text = [self plainText];;
    if (!text || text.length == 0) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendMessage:)]) {
        [self.delegate chatBar:self sendMessage:text];
    }
    self.textView.text = @"";
    self.cachedText = @"";
    self.showType = LKFunctionViewShowFace;
}

#pragma mark - LKChatFaceViewDelegate
- (void)faceViewSendFace:(NSString *)faceName {
    
    if ([faceName isEqualToString:@"[删除]"]) {
        [self faceViewDidClickDeleteButton];
    } else if ([faceName isEqualToString:@"发送"]) {
        [self faceViewDidClickClickSendButton];
    } else {
        [self faceViewDidClickEmoji:faceName];
    }
}

#pragma mark - Public Methods

- (void)close {
    //关闭
    self.close = YES;
}

- (void)open {
    self.close = NO;
}

- (void)endInputing {
    if (self.voiceButton.selected) {
        return;
    }
    self.faceButton.selected = self.moreButton.selected = self.voiceButton.selected = NO;
    self.showType = LKFunctionViewShowNothing;
}

- (void)appendString:(NSString *)string beginInputing:(BOOL)beginInputing {
    self.allowTextViewContentOffset = YES;
    if (self.textView.text.length > 0 && [string hasPrefix:@"@"] && ![self.textView.text hasSuffix:@" "]) {
        self.textView.text = [self.textView.text stringByAppendingString:@" "];
    }
    NSString *textViewText;
    //特殊情况：处于语音按钮显示时，self.textView.text无信息，但self.cachedText有信息
    if (self.textView.text.length == 0 && self.cachedText.length > 0) {
        textViewText = self.cachedText;
    } else {
        textViewText = self.textView.text;
    }
    NSString *appendedString = [textViewText stringByAppendingString:string];
    self.cachedText = appendedString;
    self.textView.text = appendedString;
    
    if (beginInputing && self.keyboardSize.height == 0) {
        [self beginInputing];
    } else {
        [self updateChatBarConstraintsIfNeeded];
    }
}

- (void)appendString:(NSString *)string {
    [self appendString:string beginInputing:YES];
}

- (void)beginInputing {
    [self.textView becomeFirstResponder];
}

#pragma mark - Private Methods

- (void)keyboardWillHide:(NSNotification *)notification {
    NSString *reason = [NSString stringWithFormat:@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Should update on main thread"];
    NSAssert([NSThread mainThread], reason);
    if (self.iSHidden) {
        return;
    }
    self.keyboardSize = CGSizeZero;
    if (_showType == LKFunctionViewShowKeyboard) {
        _showType = LKFunctionViewShowNothing;
    }
    [self updateChatBarKeyBoardConstraints];
    [self updateChatBarConstraintsIfNeeded];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSString *reason = [NSString stringWithFormat:@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Should update on main thread"];
    NSAssert([NSThread mainThread], reason);
    if (self.iSHidden) {
        return;
    }
    CGFloat oldHeight = self.keyboardSize.height;
    self.keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //兼容搜狗输入法：一次键盘事件会通知两次，且键盘高度不一。
    if (self.keyboardSize.height != oldHeight) {
        _showType = LKFunctionViewShowNothing;
    }
    if (self.keyboardSize.height == 0) {
        _showType = LKFunctionViewShowNothing;
        return;
    }
    self.allowTextViewContentOffset = YES;
    [self updateChatBarKeyBoardConstraints];
    self.showType = LKFunctionViewShowKeyboard;
}

/**
 *  lazy load inputBarBackgroundView
 *
 *  @return UIView
 */
- (UIView *)inputBarBackgroundView {
    if (_inputBarBackgroundView == nil) {
        UIView *inputBarBackgroundView = [[UIView alloc] init];
        _inputBarBackgroundView = inputBarBackgroundView;
    }
    return _inputBarBackgroundView;
}

- (void)setup {
    self.close = NO;
    self.oldTextViewHeight = kLKChatBarTextViewFrameMinHeight;
    self.allowTextViewContentOffset = YES;
    self.MP3 = [[LKMp3Recorder alloc] initWithDelegate:self];
    [self faceView];
    [self moreView];
    [self addSubview:self.inputBarBackgroundView];

    
    if (self.isCommentMode) {
        [self.inputBarBackgroundView addSubview:self.faceButton];
        [self.inputBarBackgroundView addSubview:self.textView];
    }else{
        [self.inputBarBackgroundView addSubview:self.voiceButton];
        [self.inputBarBackgroundView addSubview:self.moreButton];
        [self.inputBarBackgroundView addSubview:self.faceButton];
        [self.inputBarBackgroundView addSubview:self.textView];
        [self.inputBarBackgroundView addSubview:self.voiceRecordButton];
    }
    
    UIImageView *topLine = [[UIImageView alloc] init];
    topLine.backgroundColor = kBasicLineBackgroundColor;
    [self.inputBarBackgroundView addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(self.inputBarBackgroundView);
        make.height.mas_equalTo(.5f);
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    self.backgroundColor = self.messageInputViewBackgroundColor;
    [self setupConstraints];
}

/**
 *  开始录音
 */
- (void)startRecordVoice {
    [LKChatVoiceProgressHUD show];
    self.voiceRecordButton.highlighted = YES;
    [self.MP3 startRecord];
}

/**
 *  取消录音
 */
- (void)cancelRecordVoice {
    [LKChatVoiceProgressHUD dismissWithMessage:@"取消录音"];
    self.voiceRecordButton.highlighted = NO;
    [self.MP3 cancelRecord];
}

/**
 *  录音结束
 */
- (void)confirmRecordVoice {
    
    [self.MP3 stopRecord];
}

/**
 *  更新录音显示状态,手指向上滑动后提示松开取消录音
 */
- (void)updateCancelRecordVoice {
    [LKChatVoiceProgressHUD changeSubTitle:@"松开取消录音"];
}

/**
 *  更新录音状态,手指重新滑动到范围内,提示向上取消录音
 */
- (void)updateContinueRecordVoice {
    [LKChatVoiceProgressHUD changeSubTitle:@"向上滑动取消录音"];
}

- (void)setShowType:(LKFunctionViewShowType)showType {
    if (_showType == showType) {
        return;
    }
    _showType = showType;
    //显示对应的View
    [self showMoreView:showType == LKFunctionViewShowMore && self.moreButton.selected];
    [self showVoiceView:showType == LKFunctionViewShowVoice && self.voiceButton.selected];
    [self showFaceView:showType == LKFunctionViewShowFace && self.faceButton.selected];

    switch (showType) {
        case LKFunctionViewShowNothing: {
            self.textView.text = self.cachedText;
            [self.textView resignFirstResponder];
        }
            break;
        case LKFunctionViewShowVoice: {
            self.cachedText = [self plainText];//self.textView.text;
            self.textView.text = nil;
            [self.textView resignFirstResponder];
        }
            break;
        case LKFunctionViewShowMore:
        case LKFunctionViewShowFace:
            self.textView.text = self.cachedText;
            [self.textView resignFirstResponder];
            break;
        case LKFunctionViewShowKeyboard:
            self.textView.text = self.cachedText;
            break;
    }
    [self updateChatBarConstraintsIfNeeded];
}

- (void)buttonAction:(UIButton *)button {
    LKFunctionViewShowType showType = button.tag;
    //更改对应按钮的状态
    if (button == self.faceButton) {
        [self.faceButton setSelected:!self.faceButton.selected];
        [self.moreButton setSelected:NO];
        [self.voiceButton setSelected:NO];
    } else if (button == self.moreButton){
        [self.faceButton setSelected:NO];
        [self.moreButton setSelected:!self.moreButton.selected];
        [self.voiceButton setSelected:NO];
    } else if (button == self.voiceButton){
        [self.faceButton setSelected:NO];
        [self.moreButton setSelected:NO];
        [self.voiceButton setSelected:!self.voiceButton.selected];
    }
    if (!button.selected) {
        showType = LKFunctionViewShowKeyboard;
        [self beginInputing];
    }
    self.showType = showType;
}

- (void)showFaceView:(BOOL)show {
    if (show) {
        self.faceView.hidden = NO;
        [UIView animateWithDuration:LKAnimateDuration animations:^{
            // FIX:Tabbar
            CGFloat safeArea = 0;
            if (self.controllerRef.tabBarController.tabBar.isHidden) {
                safeArea = [self screenInsets].bottom;
            }
            [self.faceView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.superview.mas_bottom).offset(-kLKFunctionViewHeight - safeArea);
            }];
            [self.faceView layoutIfNeeded];
        } completion:nil];

        [self.faceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.inputBarBackgroundView.mas_bottom);
        }];
    } else if (self.faceView.superview) {
        self.faceView.hidden = YES;
        [self.faceView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.and.left.mas_equalTo(self);
            make.height.mas_equalTo(kLKFunctionViewHeight);
            make.top.mas_equalTo(self.mas_bottom);
        }];
        [self.faceView layoutIfNeeded];
    }
}

/**
 *  显示moreView
 *  @param show 要显示的moreView
 */
- (void)showMoreView:(BOOL)show {
    if (show) {
        self.moreView.hidden = NO;
        [UIView animateWithDuration:LKAnimateDuration animations:^{
            [self.moreView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.superview.mas_bottom).offset(-kLKFunctionViewHeight - [self screenInsets].bottom);
            }];
            [self.moreView layoutIfNeeded];
        } completion:nil];

        [self.moreView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.inputBarBackgroundView.mas_bottom);
        }];
    } else if (self.moreView.superview) {
        self.moreView.hidden = YES;
        [self.moreView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.and.left.mas_equalTo(self);
            make.height.mas_equalTo(kLKFunctionViewHeight);
            make.top.mas_equalTo(self.mas_bottom);
        }];
        [self.moreView layoutIfNeeded];
    }
}

- (void)showVoiceView:(BOOL)show {
    self.voiceButton.selected = show;
    self.voiceRecordButton.selected = show;
    self.voiceRecordButton.hidden = !show;
    self.textView.hidden = !self.voiceRecordButton.hidden;
}

/**
 *  发送普通的文本信息,通知代理
 *
 *  @param text 发送的文本信息
 */
- (void)sendTextMessage:(NSString *)text{
    if (!text || text.length == 0 || [self isSpace:text]) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendMessage:)]) {
        [self.delegate chatBar:self sendMessage:text];
    }
    self.textView.text = @"";
    self.cachedText = @"";
    self.showType = LKFunctionViewShowKeyboard;
}

/**
 *  通知代理发送语音信息
 *
 *  @param voiceFileName 发送的语音信息data
 *  @param seconds   语音时长
 */
- (void)sendVoiceMessage:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds {
    if ((seconds > 0) && self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendVoice:seconds:)]) {
        [self.delegate chatBar:self sendVoice:voiceFileName seconds:seconds];
    }
}

/**
 *  通知代理发送图片信息
 *
 *  @param images 发送的图片
 */
- (void)sendImageMessages:(NSArray <FolderModel *>*)images {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendPictures:)]) {
        [self.delegate chatBar:self sendPictures:images];
    }
}

- (void)sendVideoMessage:(FolderModel *)video{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendVideo:)]) {
        [self.delegate chatBar:self sendVideo:video];
    }
}


- (void)sendLocationMessage:(NSDictionary *)location{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendLocation:locationText:locationImage:)]) {
        double latitude = [location[@"latitude"] doubleValue];
        double longitude = [location[@"longitude"] doubleValue];
        NSString *address = location[@"address"];
        NSData *locationImgData = location[@"locationImgData"];
        [self.delegate chatBar:self sendLocation:CLLocationCoordinate2DMake(latitude, longitude) locationText:address locationImage:locationImgData];
    }
}

- (void)chatBarFrameDidChangeShouldScrollToBottom:(BOOL)shouldScrollToBottom {
    NSString *reason = [NSString stringWithFormat:@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Should update on main thread"];
    NSAssert([NSThread mainThread], reason);
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarFrameDidChange:shouldScrollToBottom:)]) {
        [self.delegate chatBarFrameDidChange:self shouldScrollToBottom:shouldScrollToBottom];
    }
}

- (UIImage *)imageInBundlePathForImageName:(NSString *)imageName {
    UIImage *image = [UIImage lkchat_imageNamed:imageName bundleName:@"LKChatKeyboard" bundleForClass:[self class]];
    return image;
}

#pragma mark - Getters

- (LKChatFaceView *)faceView {

    if (!_faceView) {
        LKChatFaceView *faceView = [[LKChatFaceView alloc] init];
        faceView.delegate = self;
        faceView.hidden = YES;
        faceView.backgroundColor = self.backgroundColor;
        [self addSubview:(_faceView = faceView)];
    }
    return _faceView;
}
- (LKChatMoreView *)moreView {
    if (!_moreView) {
        LKChatMoreView *moreView = [[LKChatMoreView alloc] init];
        moreView.inputViewRef = self;
        moreView.hidden = YES;
        __weak typeof(self) wself = self;
        moreView.LKChatMoreViewResultBlock = ^(LKChatMoreViewItemType type, id  _Nonnull object) {
          
            if (type == LKChatMoreViewItemTypePhotoAlbum) {
                [wself sendImageMessages:object];
            }else if(type == LKChatMoreViewItemTypeTakePicture){
                [wself sendImageMessages:@[object]];
            }else if(type == LKChatMoreViewItemTypeLocation){
                [wself sendLocationMessage:object];
            }else if(type == LKChatMoreViewItemTypeVideo){
                [wself sendVideoMessage:object];
            }
            
        };
        [self addSubview:(_moreView = moreView)];
    }
    return _moreView;
}

- (HYPlaceholdTextView *)textView {
    if (!_textView) {
        _textView = [[HYPlaceholdTextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:16.0f];
        _textView.placeholdFont = [UIFont systemFontOfSize:16.0f];
        _textView.delegate = self;
        _textView.layer.cornerRadius = 4.0f;
        _textView.textColor = self.messageInputViewTextFieldTextColor;
        _textView.backgroundColor = self.messageInputViewTextFieldBackgroundColor;
        _textView.layer.borderColor = [UIColor colorWithRed:204.0/255.0f green:204.0/255.0f blue:204.0/255.0f alpha:1.0f].CGColor;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.layer.borderWidth = .5f;
        _textView.layer.masksToBounds = YES;
        _textView.scrollsToTop = NO;
        _textView.wordCount = 2000;
        _textView.hideWordCountLab = YES;
       
    }
    return _textView;
}

- (UIButton *)voiceRecordButton {
    if (!_voiceRecordButton) {
        _voiceRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceRecordButton.hidden = YES;
        _voiceRecordButton.frame = self.textView.bounds;
        _voiceRecordButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_voiceRecordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
        UIImage *voiceRecordButtonNormalBackgroundImage = [[self imageInBundlePathForImageName:@"VoiceBtn_Black"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        UIImage *voiceRecordButtonHighlightedBackgroundImage = [[self imageInBundlePathForImageName:@"VoiceBtn_BlackHL"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        [_voiceRecordButton setBackgroundImage:voiceRecordButtonNormalBackgroundImage forState:UIControlStateNormal];
        [_voiceRecordButton setBackgroundImage:voiceRecordButtonHighlightedBackgroundImage forState:UIControlStateHighlighted];
        _voiceRecordButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_voiceRecordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_voiceRecordButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
        [_voiceRecordButton addTarget:self action:@selector(startRecordVoice) forControlEvents:UIControlEventTouchDown];
        [_voiceRecordButton addTarget:self action:@selector(cancelRecordVoice) forControlEvents:UIControlEventTouchUpOutside];
        [_voiceRecordButton addTarget:self action:@selector(confirmRecordVoice) forControlEvents:UIControlEventTouchUpInside];
        [_voiceRecordButton addTarget:self action:@selector(updateCancelRecordVoice) forControlEvents:UIControlEventTouchDragExit];
        [_voiceRecordButton addTarget:self action:@selector(updateContinueRecordVoice) forControlEvents:UIControlEventTouchDragEnter];
    }
    return _voiceRecordButton;
}


- (UIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceButton.tag = LKFunctionViewShowVoice;
        _voiceButton.contentMode = UIViewContentModeCenter;
        [_voiceButton setTitleColor:self.messageInputViewRecordTextColor forState:UIControlStateNormal];
        [_voiceButton setTitleColor:self.messageInputViewRecordTextColor forState:UIControlStateHighlighted];
        [_voiceButton setImage:[self imageInBundlePathForImageName:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [_voiceButton setImage:[self imageInBundlePathForImageName:@"ToolViewKeyboard"] forState:UIControlStateSelected];
        [_voiceButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}


- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.contentMode = UIViewContentModeCenter;
        _moreButton.tag = LKFunctionViewShowMore;
        [_moreButton setImage:[self imageInBundlePathForImageName:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_moreButton setImage:[self imageInBundlePathForImageName:@"TypeSelectorBtnHL_Black"] forState:UIControlStateSelected];
        [_moreButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (UIButton *)faceButton {
    if (!_faceButton) {
        _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _faceButton.tag = LKFunctionViewShowFace;
        _faceButton.contentMode = UIViewContentModeCenter;
        [_faceButton setImage:[self imageInBundlePathForImageName:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[self imageInBundlePathForImageName:@"ToolViewKeyboard"] forState:UIControlStateSelected];
        [_faceButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];

        
    }
    return _faceButton;
}

- (CGFloat)bottomHeight {
    if (self.faceView.superview || self.moreView.superview) {
        return MAX(self.keyboardSize.height, MAX(self.faceView.frame.size.height, self.moreView.frame.size.height));
    } else {
        return MAX(self.keyboardSize.height, CGFLOAT_MIN);
    }
}

- (UIViewController *)rootViewController {
    return [[UIApplication sharedApplication] keyWindow].rootViewController;
}

#pragma mark -
#pragma mark - MessageInputView Customize UI Method

- (UIColor *)messageInputViewBackgroundColor {
    if (_messageInputViewBackgroundColor) {
        return _messageInputViewBackgroundColor;
    }
    _messageInputViewBackgroundColor = [UIColor whiteColor];
    return _messageInputViewBackgroundColor;
}

- (UIColor *)messageInputViewTextFieldTextColor {
    if (_messageInputViewTextFieldTextColor) {
        return _messageInputViewTextFieldTextColor;
    }
    _messageInputViewTextFieldTextColor = [UIColor blackColor];
    return _messageInputViewTextFieldTextColor;
}

- (UIColor *)messageInputViewTextFieldBackgroundColor {
    if (_messageInputViewTextFieldBackgroundColor) {
        return _messageInputViewTextFieldBackgroundColor;
    }
    _messageInputViewTextFieldBackgroundColor = _messageInputViewTextFieldBackgroundColor = HT_UIColorFromRGB(0xF2F3F7);
    return _messageInputViewTextFieldBackgroundColor;
}

- (UIColor *)messageInputViewRecordTextColor {
    if (_messageInputViewRecordTextColor) {
        return _messageInputViewRecordTextColor;
    }
    _messageInputViewRecordTextColor = [UIColor whiteColor];
    return _messageInputViewRecordTextColor;
}

- (UIEdgeInsets)screenInsets{
    if (@available(iOS 11.0, *)) {
        return  [UIApplication sharedApplication].keyWindow.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}


@end
