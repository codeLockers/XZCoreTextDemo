//
//  XZTextParser.m
//  XZCoreTextDemo
//
//  Created by 徐章 on 16/6/21.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZTextParser.h"
#import <CoreText/CoreText.h>
#import "XZImageData.h"
#import <UIKit/UIKit.h>
#import "XZLinkData.h"

@implementation XZTextParser

+ (NSDictionary *)attributesWithConfig:(XZTextConfig *)config{

    CGFloat fontSize = config.fontSize;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    
    CGFloat lineSpace = config.lineSpace;
    
    CTParagraphStyleSetting paragraphSetting[3] = {
    
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpace },
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpace },
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpace }
    };
    
    CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(paragraphSetting, 3);
    
    UIColor *textColor = config.textColor;
    
    NSDictionary *dic = @{
                          (id)kCTForegroundColorAttributeName:(id)textColor.CGColor,
                          (id)kCTFontAttributeName:(__bridge id)fontRef,
                          (id)kCTParagraphStyleAttributeName:(__bridge id)paragraphRef
                          };
    
    CFRelease(paragraphRef);
    CFRelease(fontRef);
    return dic;
}

+ (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter config:(XZTextConfig *)config height:(CGFloat)height{
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, config.containerHeight));
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CFRelease(path);
    
    return frameRef;
}

+ (XZTextData *)parseContent:(NSString *)content config:(XZTextConfig *)config{

    NSAttributedString *contentString = [[NSAttributedString alloc] initWithString:content attributes:[self attributesWithConfig:config]];
    
    return [self parseAttributedContent:contentString config:config];
}

+ (XZTextData *)parseAttributedContent:(NSAttributedString *)content config:(XZTextConfig *)config{
    
    //创建CTFramesetterRef
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    //获得绘制的高度
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, 0), nil, CGSizeMake(config.width, CGFLOAT_MAX), nil);
    CGFloat textHeight = coreTextSize.height;
    
    //创建CTFrameRef
    CTFrameRef frameRef = [self createFrameWithFramesetter:framesetterRef config:config height:textHeight];
    
    XZTextData *textData = [[XZTextData alloc] init];
    textData.frameRef = frameRef;
    textData.height = textHeight;
    
    CFRelease(frameRef);
    CFRelease(framesetterRef);
    
    return textData;
}

+ (XZTextData *)parseFile:(NSString *)path config:(XZTextConfig *)config{
    
    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableArray *linkArray = [NSMutableArray array];
    
    NSAttributedString *content = [self loadTemplateFile:path config:config imageArray:imageArray linkArray:linkArray];
    
    XZTextData *textData = [self parseAttributedContent:content config:config];
    
    textData.imageArray = imageArray;
    textData.linkArray = linkArray;
    
    return textData;
}

+ (NSAttributedString *)loadTemplateFile:(NSString *)path config:(XZTextConfig *)config imageArray:(NSMutableArray *)imageArray linkArray:(NSMutableArray *)linkArray{

    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    if (data) {
        
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if ([array isKindOfClass:[NSArray class]]) {
            
            for (NSDictionary *dic in array) {
                
                NSString *type = dic[@"type"];
                if ([type isEqualToString:@"txt"]) {
                    
                    NSAttributedString *string = [self parseAttributeContentFromDictionary:dic config:config];
                    [result appendAttributedString:string];
                }
                if ([type isEqualToString:@"img"]) {
                    
                    XZImageData *imageData = [[XZImageData alloc] init];
                    imageData.name = dic[@"name"];
//                    imageData.position = [result length];
                    [imageArray addObject:imageData];
                    
                    //创建空白占位符，并设置CTRunDelegate
                    NSAttributedString *string = [self parseAttributeImageFromDictionary:dic config:config];
                    [result appendAttributedString:string];
                }
                if ([type isEqualToString:@"link"]) {
                    
                    NSUInteger startPos = result.length;
                    NSAttributedString *as =
                    [self parseAttributeContentFromDictionary:dic
                                                          config:config];
                    [result appendAttributedString:as];
                    // 创建 CoreTextLinkData
                    NSUInteger length = result.length - startPos;
                    NSRange linkRange = NSMakeRange(startPos, length);
                    XZLinkData *linkData = [[XZLinkData alloc] init];
                    linkData.title = dic[@"content"];
                    linkData.url = dic[@"url"];
                    linkData.range = linkRange;
                    [linkArray addObject:linkData];
                }
            }
        }
    }
    return result;
}

static CGFloat ascentCallback(void *ref){

    return [[(__bridge NSDictionary *)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *red){
    
    return 0;
}

static CGFloat widthCallback(void *ref){
    return [[(__bridge NSDictionary *)ref objectForKey:@"width"] floatValue];
}

+ (NSAttributedString *)parseAttributeImageFromDictionary:(NSDictionary *)dic config:(XZTextConfig *)config{
    
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(dic));
    
    //使用0xFFFC作为空白的占位符
    UniChar replacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&replacementChar length:1];
    
    NSDictionary *attributeDic = [self attributesWithConfig:config];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content attributes:attributeDic];
    
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}

+ (NSAttributedString *)parseAttributeContentFromDictionary:(NSDictionary *)dic config:(XZTextConfig *)config{
    
    NSMutableDictionary *attributesDic = [[self attributesWithConfig:config] mutableCopy];
    //set Color
    UIColor *color = [self colorFromTemplate:dic[@"color"]];
    if (color) {
        attributesDic[(id)kCTForegroundColorAttributeName] = (__bridge id _Nullable)(color.CGColor);
    }
    
    //set Font
    CGFloat fontSize = [dic[@"size"] floatValue];
    if (fontSize>0) {
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attributesDic[(id)kCTFontAttributeName] = (__bridge id _Nullable)(fontRef);
        CFRelease(fontRef);
    }
    
    NSString *content = dic[@"content"];
    return [[NSAttributedString alloc] initWithString:content attributes:attributesDic];
}

+ (UIColor *)colorFromTemplate:(NSString *)name{

    if ([name isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    }
    if ([name isEqualToString:@"red"]) {
        return [UIColor redColor];
    }
    if ([name isEqualToString:@"black"]) {
        return [UIColor blackColor];
    }
    return nil;
}
@end
