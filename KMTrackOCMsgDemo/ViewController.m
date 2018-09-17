//
//  ViewController.m
//  BPUnrecognizedDemo
//
//  Created by yy on 16/6/2.
//  Copyright © 2016年 BP. All rights reserved.
//

#import "ViewController.h"
#import <KMTrackOCMsg/KMMethodHook.h>
#import <KMTrackOCMsg/BlockHook.h>
#import "TestObject.h"
#import <WebKit/WebKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "NSObject+kmHookBlock.h"

@interface ViewController ()<WKNavigationDelegate>
@property (nonatomic,strong) WKWebView *webview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [KMMethodHook trackSelectorMsg:NSClassFromString(@"TestObject")];
//    [KMMethodHook trackSelectorMsg:[AVPlayerViewController class]];
    
//    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
//    // 允许视频播放
//    configuration.allowsAirPlayForMediaPlayback = NO;
//    // 允许在线播放
//    configuration.allowsInlineMediaPlayback = NO;
//    // 允许图片播放
//    configuration.allowsPictureInPictureMediaPlayback = NO;
//    // 允许与网页交互，选择视图
//    configuration.selectionGranularity = YES;
//    self.webview = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:configuration];
////    self.webview = [[UIWebView alloc]initWithFrame:self.view.bounds];
//    [self.view addSubview:self.webview];
//    NSURL *url = [NSURL URLWithString:@"http://m.iqiyi.com/"];
//    [self.webview loadRequest:[NSURLRequest requestWithURL:url]];
//    self.webview.navigationDelegate = self;
    
//    [NSURL hookSelectorWithBlock:PAIR_LIST {
//        @selector(fileURLWithPath:),
//        BLOCK_CAST ^id (id slf,NSString *path) {
//            id url = performSuperSelector(slf, @selector(fileURLWithPath:), id,path);
//            NSLog(@"hook URLWithString%@",url);
//            return url;
//        },
//        @selector(fileURLWithPath:isDirectory:),
//        BLOCK_CAST ^id (id slf,NSString *path,BOOL isDir) {
//            id url = performSuperSelector(slf, @selector(fileURLWithPath:isDirectory:), id,path,isDir);
//            NSLog(@"hook URLWithString%@",url);
//            return url;
//        },
//        NIL_PAIR}];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    
//    NSLog(@"NSClassFromString%@",NSClassFromString(@"WKURLSchemeHandler"));
//    [KMMethodHook trackSelectorMsg:NSClassFromString(@"WKURLSchemeHandler")];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
}



- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    TestObject *testObject = [[TestObject alloc] init];
    [TestObject testB:@"qwe"];
    
    [testObject testA:@"asd" num:2 frame:CGRectMake(1, 2, 3, 4) dic:@{@"nihao":@"你好"} successCallback:^(NSString *successJson,int num) {
        NSLog(@"block回调");
    }];
    
//    [testObject performSelector:@selector(notExistSelector:test:) withObject:@(2) withObject:@(4)];
}
@end
