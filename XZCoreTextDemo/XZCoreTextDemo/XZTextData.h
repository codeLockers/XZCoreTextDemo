//
//  XZTextData.h
//  XZCoreTextDemo
//
//  Created by 徐章 on 16/6/23.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
@interface XZTextData : NSObject

@property (nonatomic, assign) CTFrameRef frameRef;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) NSMutableArray *imageArray;

@property (nonatomic, strong) NSMutableArray *linkArray;

@end
