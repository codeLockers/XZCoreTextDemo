//
//  XZLinkUtils.m
//  XZCoreTextDemo
//
//  Created by 徐章 on 16/7/4.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZLinkUtils.h"
#import "XZLinkData.h"
#import "XZTextData.h"

@implementation XZLinkUtils

+ (XZLinkData *)touchInView:(UIView *)view atPoint:(CGPoint)point data:(XZTextData *)data{
    
    CFIndex idx = [self touchContentOffsetInView:view atPoint:point data:data];
    if (idx == -1) {
        return nil;
    }
    
    XZLinkData *foundLink = [self linkAtIndex:idx linkArray:data.linkArray];

    
    
    return foundLink;
}

//将点击的位置转换成字符串的偏移量，如果没有找到就返回－1
+ (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(XZTextData *)data{

    CTFrameRef textFrame = data.frameRef;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    
    if (!lines) {
        return -1;
    }
    
    CFIndex count = CFArrayGetCount(lines);
    
    //获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    //翻转坐标系
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, view.frame.size.height);
    transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
    
    CFIndex idx = -1;
    for (int i = 0; i<count; i++) {
        
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        //获得每一行的CGRect的信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        if (CGRectContainsPoint(rect, point)) {
            
            //将点击的坐标转换成相当于当前行的坐标
            CGPoint relativePoint = CGPointMake(point.x - CGRectGetMinX(rect), point.y - CGRectGetMinY(rect));
            
            //获取当前点击坐标对应的字符串偏移
            idx = CTLineGetStringIndexForPosition(line, relativePoint);
        }
        
    }
    return idx;
}

+ (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point{

    CGFloat ascent = 0.0f;
    CGFloat desent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &desent, &leading);
    CGFloat height = ascent - desent;
    
    return CGRectMake(point.x, point.y, width, height);
}

+ (XZLinkData *)linkAtIndex:(CFIndex)i linkArray:(NSArray *)linkArray{

    XZLinkData *link = nil;
    for (XZLinkData *data in linkArray) {
        if (NSLocationInRange(i, data.range)) {
            link = data;
            break;
        }
    }
    return link;
}

@end
