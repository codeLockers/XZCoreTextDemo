//
//  ViewController.m
//  XZCoreTextDemo
//
//  Created by 徐章 on 16/6/21.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "ViewController.h"
#import "XZTextView.h"
#import "XZTextParser.h"
#import "XZTextData.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XZTextView *textView = [[XZTextView alloc] initWithFrame:CGRectMake(0, 0, 300, 500)];
    
    textView.center = self.view.center;
    textView.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:textView];
    
    XZTextConfig *config = [[XZTextConfig alloc] init];
    config.width = textView.frame.size.width;
    config.containerHeight = textView.frame.size.height;
    
    /*
    XZTextData *textData = [XZTextParser parseContent:@"按照以上原则，我们将`CTDisplayView`中的部分内容拆开。" config:config];
    textView.textData = textData;
    [textView setNeedsDisplay];
    */
    
    /*
    NSString *string  = @"fsfsdfaffjashfjahsfljsahfjdshfksfasdghfgjsgdjhfsgfsjhfsgfdhfhdhhhdfagdlaffhefhuuewufgwiefbwbjdbcbvnbcx,mvbsfshdfjahwuehfuwaefhwhfshdjfbdvbnxmcbvasjfasgfgksdgfksdkjcbsdmnvbshdfgliaeuufhsjdbcnmxbvashgfiwauefhkdsbcmn";

    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{
                                                                                                               NSFontAttributeName : [UIFont systemFontOfSize:16]}];
    
    [aString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 10)];
    
    XZTextData *textData = [XZTextParser parseAttributedContent:aString config:config];
    textView.textData = textData;
    [textView setNeedsDisplay];
    */
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"json"];
    XZTextData *textData = [XZTextParser parseFile:path config:config];
    
    textView.textData = textData;
    [textView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
