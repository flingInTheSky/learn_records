//
//  YMWebBaseViewController.m
//  WaterPurifier
//
//  Created by liushilou on 16/8/9.
//  Copyright © 2016年 Facebook. All rights reserved.
//  加载进度参考NJKWebViewProgress

#import "YMWebBaseViewController.h"
#import "YMLoginViewController.h"

@interface YMWebBaseViewController ()
{
  UIProgressView *_progressView;
}

@end

@implementation YMWebBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
  
  [self setupViews];
  
  [self loadWebview];
 // [self loadExamplePage];

  
}

-(void)dealloc{
  NSLog(@"YMWebBaseViewController dealloc");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  //在释放self前，需要removeScriptMessageHandlerForName:@"H5ToNative"，否则会引起循环引用，导致内存泄露
  //如果webview页面没有实现其他页面跳转逻辑，在这里处理就可以，否则逻辑需要修改，保证在释放self前执行
  [self removeAllScriptMsgHandle];
}

- (void)setupViews
{
  self.navigationItem.title = self.navtitle;
  
  CGFloat progressBarHeight = 2.f;
  CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
  CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
  _progressView = [[UIProgressView alloc] initWithFrame:barFrame];
  _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  _progressView.progressTintColor = [UIColor blueColor];
  [self.navigationController.navigationBar addSubview:_progressView];
  
  
  //实现WKWebViewConfiguration才会执行WKUIDelegate
  WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
 [configuration.userContentController addScriptMessageHandler:self name:@"H5ToNative"];
  self.webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
  self.webview.navigationDelegate = self;
  self.webview.UIDelegate = self;
  [self.view addSubview:self.webview];
//  [self.webview mas_makeConstraints:^(MASConstraintMaker *make) {
//    make.edges.mas_offset(UIEdgeInsetsMake(0, 0, 0, 0));
//  }];
  [self.webview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
  
  
//  [WKWebViewJavascriptBridge enableLogging];
//  
//  _bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webview];
//  [_bridge setWebViewDelegate:self];
//
//  [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
//    NSLog(@"testObjcCallback called: %@", data);
//    responseCallback(@"Response from testObjcCallback");
//  }];
//  
//  [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
//  
//  [self loadExamplePage:webView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"estimatedProgress"]) {
    //progress是UIProgressView
    [_progressView setProgress:self.webview.estimatedProgress animated:YES];
    if (self.webview.estimatedProgress == 1.0) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.webview removeObserver:self forKeyPath:@"estimatedProgress"];
        [_progressView removeFromSuperview];
        
        // Remove progress view
        // because UINavigationBar is shared with other ViewControllers
      });
    }
  }
}


#pragma mark -
#pragma mark WKNavigationDelegate

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{

}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{

}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self sendSetupDatas];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{

}

//// 接收到服务器跳转请求之后调用
//- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
//{
//
//}
//// 在收到响应后，决定是否跳转
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
//{
//
//}
//// 在发送请求之前，决定是否跳转
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
//{
////    if ([request.URL.absoluteString isEqualToString:YMWebviewCompleteUrl]) {
////      [self completeProgress];
////      return NO;
////    }
////  
////    BOOL ret = YES;
////    BOOL isFragmentJump = NO;
////    if (request.URL.fragment) {
////      NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
////      isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
////    }
////  
////    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
////  
////    BOOL isHTTP = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
////    if (ret && !isFragmentJump && isHTTP && isTopLevelNavigation) {
////      _currentURL = request.URL;
////      [self reset];
////    }
////    return ret;
//}


#pragma WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{

  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    completionHandler();
  }]];
  [self presentViewController:alert animated:YES completion:^{
    
  }];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    completionHandler(NO);
  }]];
  [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    completionHandler(YES);
  }]];
  [self presentViewController:alert animated:YES completion:^{
    
  }];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler
{
  //
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt message:defaultText preferredStyle:UIAlertControllerStyleAlert];
  [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    textField.textColor = [UIColor redColor];
  }];
  [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    completionHandler(alert.textFields[0].text);
  }]];

  [self presentViewController:alert animated:YES completion:^{
    
  }];
}


#pragma WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
  
  NSLog(@"如果要接收h5消息，子类需要实现%s",__func__);
  
//  [self.webview evaluateJavaScript:@"hi(12232434)" completionHandler:nil];

}

- (void)sendSetupDatas
{

}

- (void)loadWebview
{
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
  [self.webview loadRequest:request];
}


//用于test
- (void)loadExamplePage {
  NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
  NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
  NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
  [self.webview loadHTMLString:appHtml baseURL:baseURL];
}

-(void)removeAllScriptMsgHandle{
  WKUserContentController *controller = self.webview.configuration.userContentController;
  [controller removeScriptMessageHandlerForName:@"H5ToNative"];
}

@end
