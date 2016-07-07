//
//  XZTextParser.h
//  XZCoreTextDemo
//
//  Created by 徐章 on 16/6/21.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XZTextConfig.h"
#import "XZTextData.h"

@interface XZTextParser : NSObject

+ (NSDictionary *)attributesWithConfig:(XZTextConfig *)config;

+ (XZTextData *)parseContent:(NSString *)content config:(XZTextConfig *)config;
+ (XZTextData *)parseAttributedContent:(NSAttributedString *)content config:(XZTextConfig *)config;
+ (XZTextData *)parseFile:(NSString *)path config:(XZTextConfig *)config;
@end
