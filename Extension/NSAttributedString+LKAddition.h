//
//  NSAttributedString+LKAddition.h
//  LKChartBar
//
//  Created by Sherlock on 2019/3/20.
//  Copyright © 2019 王郑. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKTextBackedString.h"

@interface NSAttributedString (LKAddition)

- (NSRange)lk_rangeOfAll;

- (nullable NSString *)lk_plainTextForRange:(NSRange)range;

@end


@interface NSMutableAttributedString (LKAddition)

- (void)lk_setTextBackedString:(nullable LKTextBackedString *)textBackedString range:(NSRange)range;

@end

/*
 我们设置到输入框的NSAttributedString中的每一个NSTextAttachment都有一个"隐藏的"属性-—表情的文本描述，这里对NSAttributedString进行拓展就能实现。lk_setTextBackedString可以对NSAttributedString的指定range设置一个LKTextBackedString类型的属性，而lk_plainTextForRange能拿到NSAttributedString指定range的纯文本。
 */
