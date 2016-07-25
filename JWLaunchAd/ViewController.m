//
//  ViewController.m
//  JWLaunchAd
//
//  Created by GJW on 16/7/8.
//  Copyright © 2016年 JW. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    [_webView setUserInteractionEnabled:YES];             //是否支持交互
    [_webView setOpaque:YES];                              //Opaque为不透明的意思
    [_webView setScalesPageToFit:YES];                    //自动缩放以适应屏幕
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/JWXIAN/JWLaunchAd.git"]]];
}
@end
