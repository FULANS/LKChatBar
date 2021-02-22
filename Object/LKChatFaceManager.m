//
//  LKChatFaceManager.m
//  LiemsMobileEnterprise
//
//  Created by Sherlock on 2019/2/18.
//  Copyright © 2019 luculent. All rights reserved.
//

#import "LKChatFaceManager.h"

@implementation LKEmojiMatchingResult
@end

@interface LKChatFaceManager ()

@property (strong, nonatomic) NSArray *allEmojiFaceGroups; // Groups
@property (strong, nonatomic) NSMutableArray *allemojiFaces;    // Groups - > 数组
@property (strong, nonatomic) NSMutableArray *currentEmojiFaces;
@property (strong, nonatomic) NSMutableArray *recentEmojiFaces;

@end

@implementation LKChatFaceManager


- (instancetype)init{
    if (self = [super init]) {

        _allEmojiFaceGroups = [NSArray arrayWithContentsOfFile:[self defaultEmojiFacePath]];
        _allemojiFaces = @[].mutableCopy;
        [_allEmojiFaceGroups enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dic = (NSDictionary *)obj;
            [_allemojiFaces addObjectsFromArray:dic[kGroupsRowKey]];
        }];
        NSDictionary *firstDic = [_allEmojiFaceGroups firstObject];
        _currentEmojiFaces = [NSMutableArray array];
        [_currentEmojiFaces addObjectsFromArray:firstDic[kGroupsRowKey]];
        NSArray *recentArrays = [[NSUserDefaults standardUserDefaults] arrayForKey:@"recentEmojiFaces"];
        if (recentArrays) {
            _recentEmojiFaces = [NSMutableArray arrayWithArray:recentArrays];
        } else {
            _recentEmojiFaces = [NSMutableArray array];
        }
        
    }
    return self;
}


#pragma mark - Class Methods
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static id shareInstance;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}


#pragma mark - Emoji相关表情处理方法
- (void)updateCurrentEmojiFacesIndex:(NSInteger)index{
    
    if (index == -1) {
        self.currentEmojiFaces = self.recentEmojiFaces;
    }else{
        NSDictionary *tempDic = _allEmojiFaceGroups[index];
        self.currentEmojiFaces = [NSMutableArray array];
        [self.currentEmojiFaces addObjectsFromArray:tempDic[kGroupsRowKey]];
    }
}

- (BOOL)saveRecentFace:(NSDictionary *)recentDict{
    
    for (NSDictionary *dict in self.recentEmojiFaces) {
        if ([dict[kFaceIDKey] integerValue] == [recentDict[kFaceIDKey] integerValue]) {
            HTLog(@"已经存在");
            return NO;
        }
    }
    [self.recentEmojiFaces insertObject:recentDict atIndex:0];
    if (self.recentEmojiFaces.count > 8) {
        [self.recentEmojiFaces removeLastObject];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"recentEmojiFaces"];
    [[NSUserDefaults standardUserDefaults] setObject:self.recentEmojiFaces forKey:@"recentEmojiFaces"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}


#pragma mark -
- (NSString *)defaultEmojiFacePath {
    NSBundle *bundle = [NSBundle lkchat_bundleForName:kChatEmojiBundle class:[self class]];
    NSString *defaultEmojiFacePath = [bundle pathForResource:kChatEmojiPlist ofType:@"plist"];
    return defaultEmojiFacePath;
}

- (NSString *)faceImageNameWithFaceID:(NSUInteger)faceID {
    NSString *faceImageName = @"";
    if (faceID == 999) {
        faceImageName = @"[删除]";
    }
    for (NSDictionary *faceDict in self.allemojiFaces) {
        if ([faceDict[kFaceIDKey] integerValue] == faceID) {
            faceImageName = faceDict[kFaceImageNameKey];
        }
    }
    return faceImageName;
}

- (UIImage *)faceImageWithFaceID:(NSUInteger)faceID {
    NSString *faceImageName = [self faceImageNameWithFaceID:faceID];
    UIImage *faceImage = [UIImage lkchat_imageNamed:faceImageName bundleName:kChatEmojiBundle bundleForClass:[self class]];
    return faceImage;
}

- (NSString *)faceNameWithFaceID:(NSUInteger)faceID{
    if (faceID == 999) {
        return @"[删除]";
    }
    for (NSDictionary *faceDict in self.allemojiFaces) {
        if ([faceDict[kFaceIDKey] integerValue] == faceID) {
            return faceDict[kFaceNameKey];
        }
    }
    return @"";
}

- (void)configEmotionWithMutableAttributedString:(NSMutableAttributedString *)attributeString
                                            font:(UIFont *)font {
    
    
    if (!attributeString || !attributeString.length || !font) {
        return;
    }

    NSArray<LKEmojiMatchingResult *> *matchingResults = [self matchingEmojiForString:attributeString.string];
    
    if (matchingResults && matchingResults.count){
        NSUInteger offset = 0;
        for (LKEmojiMatchingResult *result in matchingResults){
            if (result.emojiImage){
                CGFloat emojiHeight = font.lineHeight;
                NSTextAttachment *attachment = [NSTextAttachment new];
                attachment.image = result.emojiImage;
                attachment.bounds = CGRectMake(0, font.descender, emojiHeight, emojiHeight);
                NSMutableAttributedString *emojiAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                
                [emojiAttributedString lk_setTextBackedString:[LKTextBackedString stringWithString:result.showingDescription] range:NSMakeRange(0, emojiAttributedString.length)];
                
                if (!emojiAttributedString) {
                    continue;
                }
                
                NSRange actualRange = NSMakeRange(result.range.location - offset, result.showingDescription.length);
                [attributeString replaceCharactersInRange:actualRange withAttributedString:emojiAttributedString];
                offset += result.showingDescription.length - emojiAttributedString.length;
            }
        }
    }
    
}



- (void)configEmotionWithMutableAttributedString:(NSMutableAttributedString *)attributeString{
    
    [self configEmotionWithMutableAttributedString:attributeString font:[UIFont systemFontOfSize:16]];
}

- (NSArray<LKEmojiMatchingResult *> *)matchingEmojiForString:(NSString *)string{
    
    if (!string.length) {
        return nil;
    }
    // 正则:
    NSString *regex_emoji = @"face\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:0 error:NULL];
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    if (results && results.count){
        
        NSMutableArray *emojiMatchingResults = [[NSMutableArray alloc] init];
        for (NSTextCheckingResult *result in results){
            NSString *showingDescription = [string substringWithRange:result.range];
            NSDictionary *emoji = [self emojiWithEmojiDescription:showingDescription];
            // 表情文字转成 Emoji对象
            if (emoji){
                LKEmojiMatchingResult *emojiMatchingResult = [LKEmojiMatchingResult new];
                emojiMatchingResult.range = result.range;
                emojiMatchingResult.showingDescription = showingDescription;
                UIImage *faceImage = [UIImage lkchat_imageNamed:showingDescription bundleName:kChatEmojiBundle bundleForClass:[self class]];
                emojiMatchingResult.emojiImage = faceImage;
                [emojiMatchingResults addObject:emojiMatchingResult];
            }
        }
        return emojiMatchingResults;
    }
    return nil;
}

- (NSDictionary *)emojiWithEmojiDescription:(NSString *)emojiDescription{
    
    __block NSDictionary *result;
    [self.allemojiFaces enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull emoji, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([emoji[kFaceNameKey] isEqualToString:emojiDescription]) {
            result = emoji;
            *stop = YES;
        }
    }];
    return result;
}

- (NSMutableAttributedString *)emotionStrWithString:(NSString *)text {
    if (!text.length) {
        NSString *degradeContent = @"unknownMessage";
        return [[NSMutableAttributedString alloc] initWithString:degradeContent];
    }
    //1、创建一个可变的属性字符串
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    //2、通过正则表达式来匹配字符串
    NSString *regex_emoji = @"face\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (!regex) {
        HTLog(@"%@", [error localizedDescription]);
        return attributeString;
    }
    NSArray *matches = [regex matchesInString:text
                                      options:0
                                        range:NSMakeRange(0, text.length)];
    NSUInteger emojiNumbers = matches.count;
    //无表情
    if (emojiNumbers == 0) {
        return attributeString;
    }
    
    //3、获取所有的表情以及位置
    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:matches.count];
    //根据匹配范围来用图片进行相应的替换
    for(NSTextCheckingResult *match in matches) {
        //获取数组元素中得到range
        NSRange range = [match range];
        //获取原字符串中对应的值
        NSString *subStr = [text substringWithRange:range];
        for (NSDictionary *dict in self.allemojiFaces) {
            if ([dict[kFaceNameKey] isEqualToString:subStr]) {
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                textAttachment.image = [UIImage lkchat_imageNamed:dict[kFaceImageNameKey] bundleName:kChatEmojiBundle bundleForClass:[self class]];
                //调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
//                CGFloat emojiSize = 30+4;
//                textAttachment.bounds = CGRectMake(0, -8, emojiSize, emojiSize);
                textAttachment.bounds = CGRectMake(0, -4, textAttachment.image.size.width*0.6, textAttachment.image.size.height*0.6);
                //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                //把字典存入数组中
                [imageArray addObject:imageDic];
                break;
            }
        }
    }
    
    //4、从后往前替换，否则会引起位置问题
    for (int i = (int)imageArray.count -1; i >= 0; i--) {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }
    return attributeString;
}


@end
