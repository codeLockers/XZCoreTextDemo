//
//  XZTextData.m
//  XZCoreTextDemo
//
//  Created by 徐章 on 16/6/23.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZTextData.h"
#import "XZImageData.h"

@implementation XZTextData

- (void)setFrameRef:(CTFrameRef)frameRef{

    if (_frameRef != frameRef) {
        if (_frameRef != nil) {
            CFRelease(_frameRef);
        }
        CFRetain(frameRef);
        _frameRef = frameRef;
    }
}

- (void)dealloc{

    if (_frameRef != nil) {
        CFRelease(_frameRef);
        _frameRef = nil;
    }
}

- (void)setImageArray:(NSMutableArray *)imageArray{
    
    _imageArray = imageArray;
    [self fillImagePosition];
}

- (void)fillImagePosition{
    
    if (self.imageArray.count == 0) {
        return;
    }
    
    NSArray *lines = (NSArray *)CTFrameGetLines(self.frameRef);
    NSInteger lineCount = lines.count;
    
    CGPoint lineOrigins[lineCount];
    
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), lineOrigins);
    
    int imgIndex = 0;
    XZImageData *imageData = self.imageArray[0];
    
    for (int i =0 ; i < lineCount;i++) {
        
        if (!imageData) {
            break;
        }
        
        CTLineRef line = (__bridge CTLineRef)lines[i];
        
        NSArray *runArray = (NSArray *)CTLineGetGlyphRuns(line);
        for (id runObj in runArray) {
            
            CTRunRef run = (__bridge CTRunRef)runObj;
            NSDictionary *runAttribute = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttribute valueForKey:(id)kCTRunDelegateAttributeName];
            
            if (!delegate) {
                continue;
            }
            
            NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate);
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;
            
            CGPathRef pathRef = CTFrameGetPath(self.frameRef);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            
            imageData.imagePosition = delegateBounds;
            imgIndex++;
            if (imgIndex == self.imageArray.count) {
                imageData = nil;
                break;
            } else {
                imageData = self.imageArray[imgIndex];
            }
        }
    }
}

@end
