//
//  XZTextView.m
//  XZCoreTextDemo
//
//  Created by 徐章 on 16/6/21.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZTextView.h"
#import <CoreText/CoreText.h>
#import "XZTextParser.h"
#import "XZImageData.h"
#import "XZLinkData.h"
#import "XZLinkUtils.h"
@implementation XZTextView

- (id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUpEvents];
    }
    return self;
}

- (void)setUpEvents{

    UITapGestureRecognizer * tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(userTapGestureDetected:)];
//    tapRecognizer.delegate = self;
    [self addGestureRecognizer:tapRecognizer];
    self.userInteractionEnabled = YES;
}


- (void)userTapGestureDetected:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    for (XZImageData * imageData in self.textData.imageArray) {
        // 翻转坐标系，因为 imageData 中的坐标是 CoreText 的坐标系
        CGRect imageRect = imageData.imagePosition;
        
        CGPoint imagePosition = imageRect.origin;
        
        imagePosition.y = self.bounds.size.height - imageRect.origin.y
        - imageRect.size.height;
        CGRect rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
        // 检测点击位置 Point 是否在 rect 之内
        if (CGRectContainsPoint(rect, point)) {
            // 在这里处理点击后的逻辑
            NSLog(@"bingo");
            break;
        }
    }
    
    XZLinkData *linkData = [XZLinkUtils touchInView:self atPoint:point data:self.textData];
    if (linkData) {
        NSLog(@"hint link!");
        return;
    }

}

- (void)drawRect:(CGRect)rect {
    
    
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //翻转坐标系
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    if (self.textData) {
        CTFrameDraw(self.textData.frameRef, context);
    }
    
    for (XZImageData * imageData in self.textData.imageArray) {
        UIImage *image = [UIImage imageNamed:imageData.name];
        if (image) {
            CGContextDrawImage(context, imageData.imagePosition, image.CGImage);
        }
    }
}
@end
