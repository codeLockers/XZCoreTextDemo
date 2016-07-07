//
//  XZLinkUtils.h
//  XZCoreTextDemo
//
//  Created by 徐章 on 16/7/4.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XZLinkData.h"
#import "XZTextData.h"


@interface XZLinkUtils : NSObject
+ (XZLinkData *)touchInView:(UIView *)view atPoint:(CGPoint)point data:(XZTextData *)data;
@end
