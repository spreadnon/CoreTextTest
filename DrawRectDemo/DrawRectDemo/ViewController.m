//
//  ViewController.m
//  DrawRectDemo
//
//  Created by iOS123 on 2019/12/6.
//  Copyright © 2019 CQL. All rights reserved.
//

#import "ViewController.h"
#import "DrawCoreTextView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    DrawCoreTextView *textView = [[DrawCoreTextView alloc] initWithFrame:self.view.bounds];
    textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textView];
}


@end
