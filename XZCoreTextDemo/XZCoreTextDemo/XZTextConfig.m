//
//  XZTextConfig.m
//  XZCoreTextDemo
//
//  Created by 徐章 on 16/6/23.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZTextConfig.h"

@implementation XZTextConfig

- (id)init{

    self = [super init];
    if (self) {
        
        self.width = 200.0f;
        self.fontSize = 16.0f;
        self.lineSpace = 8.0f;
        self.textColor = [UIColor blackColor];
    }
    return self;
}

@end
