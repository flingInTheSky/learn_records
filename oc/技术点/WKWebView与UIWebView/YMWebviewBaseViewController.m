//
//  YMWebviewBaseViewController.m
//  WaterPurifier
//
//  Created by liushilou on 16/9/1.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "YMWebviewBaseViewController.h"
#import "WKWebViewJavascriptBridge.h"
#import "YMProjrctConfig.h"
#import "YMUserManager.h"
#import <Pingpp.h>
#import "YMAlertview.h"
#import "NSDictionary+checkNull.h"
#import "YMLoginViewController.h"
#import "YMBaseNavigationController.h"
#import "YM_WX.h"

@interface YMWebviewBaseViewController ()
{
  UIProgressView *_progressView;
}

@property WKWebViewJavascriptBridge* bridge;

@end

@implementation YMWebviewBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  [self setupViews];
  
  [self loadWebview];
  
  if (self.navigationController.viewControllers.count > 1) {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ym_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    //[[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
  }
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
//  [self.webview evaluateJavaScript:@"NativeToH5.onWebPageBack()" completionHandler:nil];
  id data = @{};
  [_bridge callHandler:@"onWebPageBack" data:data responseCallback:^(id response) {
    NSLog(@"onWebPageBack responded: %@", response);
  }];
}



-(void)dealloc{
  NSLog(@"YMWebBaseViewController dealloc");
  if (self.webview) {
    NSLog(@"webview ");
    [self.webview removeObserver:self forKeyPath:@"estimatedProgress"];
    self.webview = nil;
  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupViews
{
  self.navigationItem.title = self.navtitle;
  
  if (self.showMoreBtn) {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ym_nav_more"] style:UIBarButtonItemStyleDone target:self action:@selector(showMore)];
  }
  
  
  //实现WKWebViewConfiguration才会执行WKUIDelegate
  //需要设置configuration，否则会造成内存泄漏
  WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
  configuration.selectionGranularity = WKSelectionGranularityCharacter;
//  configuration.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
//  [configuration.userContentController addScriptMessageHandler:self name:@"H5ToNative"];
  self.webview = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
//  self.webview = [[WKWebView alloc] init];
//  self.webview.navigationDelegate = self;
  //self.webview.UIDelegate = self;
  [self.view addSubview:self.webview];
  [self.webview mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_offset(UIEdgeInsetsMake(0, 0, 0, 0));
  }];
  [self.webview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
  
  CGFloat progressBarHeight = 2.f;
  CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
  CGRect barFrame = CGRectMake(0, 0, navigationBarBounds.size.width, progressBarHeight);
  _progressView = [[UIProgressView alloc] initWithFrame:barFrame];
  //  _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  _progressView.progressTintColor = [UIColor blueColor];
  //  UIView *view = [[UIView alloc] initWithFrame:barFrame];
  //  view.backgroundColor = [UIColor redColor];
  [self.view insertSubview:_progressView aboveSubview:self.webview];
  
  
  
  
    [WKWebViewJavascriptBridge enableLogging];
  
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webview];
  
//不能设置这个，会导致congtroller释放不了，没有执行dealloc。。。
//    [_bridge setWebViewDelegate:self];
  
  
    [_bridge registerHandler:@"setItem" handler:^(id data, WVJBResponseCallback responseCallback) {
      NSLog(@"setItem: %@", data);
      NSString *key = [data notNullObjectForKey:@"key"];
      NSString *value = [data notNullObjectForKey:@"value"];
      if (!key || !value) {
        responseCallback(@"error:key 或者 value不能为空");
      }else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:value forKey:key];
        [defaults synchronize];
        responseCallback(@"setItem finish");
      }

    }];
    [_bridge registerHandler:@"getItem" handler:^(id data, WVJBResponseCallback responseCallback) {
      NSLog(@"getItem: %@", data);
      NSString *key = [data notNullObjectForKey:@"key"];
      if (!key) {
        responseCallback(nil);
      }else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *value = [defaults objectForKey:key];
        responseCallback(value);
      }
    }];
    [_bridge registerHandler:@"removeItem" handler:^(id data, WVJBResponseCallback responseCallback) {
      NSLog(@"removeItem: %@", data);
      NSString *key = [data notNullObjectForKey:@"key"];
      if (!key) {
        responseCallback(@"error:key不能为空");
      }else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:key];
        responseCallback(@"removeItem finish");
      }
    }];

  [_bridge registerHandler:@"getUserInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
    NSLog(@"getUserInfo: %@", data);
    NSString *token = [YMUserManager shareinstance].token;
    NSString *userCode = [YMUserManager shareinstance].userCode;
    NSString *account = [YMUserManager shareinstance].account;
    if (token != nil && userCode != nil) {
      NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                            userCode,@"userCode",
                            token,@"token",
                            account,@"account",
                            nil];
      
      NSError *parseError = nil;
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&parseError];
      NSString *infoString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
      if (parseError) {
        responseCallback(@"异常");
      }else{
        responseCallback(infoString);
      }
    }else{
      responseCallback(@"未登录");
    }
  }];
  
  @weakify(self);
  [_bridge registerHandler:@"onWebPageBack" handler:^(id data, WVJBResponseCallback responseCallback) {
    NSLog(@"onWebPageBack：%@", data);
    @strongify(self);
    [self backAction];
    responseCallback(@"onWebPageBack");
  }];
  [_bridge registerHandler:@"onWebPageBackToIndex" handler:^(id data, WVJBResponseCallback responseCallback) {
    NSLog(@"onWebPageBackToIndex：%@", data);
    @strongify(self);
    [self backToIndex];
    responseCallback(@"onWebPageBackToIndex");
  }];

  [_bridge registerHandler:@"onWebPageJump" handler:^(id data, WVJBResponseCallback responseCallback) {
    @strongify(self);
    NSNumber *showMoreBtn = [data objectForKey:@"showMoreBtn"];
    NSString *title = [data objectForKey:@"title"];
    NSString *url = [data objectForKey:@"url"];
    YMWebviewBaseViewController *controller = [[YMWebviewBaseViewController alloc] init];
    //NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    
    NSString *baseurl;
    if (YM_ENVIRONMENT == 2) {
      NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"testip"];
      if (!ip) {
        ip = @"192.168.31.172:3000";
      }
      baseurl = [NSString stringWithFormat:@"http://%@",ip];
    }else{
      baseurl = @"http://192.168.31.172:3000";
    }
    
    controller.url = [NSString stringWithFormat:@"%@%@",baseurl,url];
    controller.navtitle = title;
    controller.showMoreBtn = showMoreBtn.boolValue;
    controller.isLocalHtml = NO;
    //    YMWebDetailViewController *controller = [[YMWebDetailViewController alloc] init];
    //    controller.webview = self.webview;
    [controller setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:controller animated:YES];
  }];
  
  [_bridge registerHandler:@"pay" handler:^(id data, WVJBResponseCallback responseCallback) {
    NSLog(@"pay：%@", data);
    @strongify(self);
    
    NSString *charge = [data objectForKey:@"charge"];
    
    
    //Pingpp 这个支付操作存在内存泄漏。。。官方提供的demo也检测出内存泄漏。。。
    YMWebviewBaseViewController * __weak weakSelf = self;
    [Pingpp createPayment:charge
           viewController:weakSelf
             appURLScheme:@"wx0784430eaf7b2881"
           withCompletion:^(NSString *result, PingppError *error) {
             NSLog(@"completion block: %@", result);
             
             NSInteger errNo = -1;
             NSString *errMsg = @"";
             if (error) {
               errNo = error.code;
               errMsg = [error getMsg];
             }
             
             NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:
                                   result,@"result",
                                   @(errNo).stringValue,@"errNo",
                                   errMsg,@"errMsg",
                                   nil];
             
             NSError *parseError = nil;
             NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&parseError];
             NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
             
             if (!parseError) {
               responseCallback(jsonStr);
             }else{
               responseCallback(@"json转换错误");
             }
           }];
  }];
  
  [_bridge registerHandler:@"openLoginPage" handler:^(id data, WVJBResponseCallback responseCallback) {
    NSLog(@"openLoginPage");
    @strongify(self);
    YMLoginViewController *ontroller = [[YMLoginViewController alloc] init];
    YMBaseNavigationController *nav = [[YMBaseNavigationController alloc] initWithRootViewController:ontroller];
    [self presentViewController:nav animated:YES completion:^{
      
    }];

  }];
  
  [_bridge registerHandler:@"share" handler:^(id data, WVJBResponseCallback responseCallback) {
    NSLog(@"openLoginPage");
    NSString *title = [data objectForKey:@"title"];
    NSString *detail = [data objectForKey:@"detail"];
    //NSString *imageUrl = [data objectForKey:@"imageUrl"];
    NSString *webUrl = [data objectForKey:@"webUrl"];
    [[YM_WX shareinstance] share:title detail:detail image:nil url:webUrl];
    
  }];
  
  
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"estimatedProgress"]) {
    //progress是UIProgressView
    NSLog(@"estimatedProgress:%f",self.webview.estimatedProgress);
    [_progressView setProgress:self.webview.estimatedProgress animated:YES];
    if (self.webview.estimatedProgress == 1.0) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _progressView.hidden = YES;
        [_progressView setProgress:0.0 animated:NO];
      });
      
      //      if (self.webview.canGoBack) {
      //        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"test"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
      //      }else{
      //        self.navigationItem.leftBarButtonItem = nil;
      //      }
    }else if(self.webview.estimatedProgress == 0.1){
      _progressView.hidden = NO;
      //      if (self.webview.canGoBack) {
      //        self.tabBarController.tabBar.hidden = NO;
      //        [self.webview mas_updateConstraints:^(MASConstraintMaker *make) {
      //          make.edges.mas_offset(UIEdgeInsetsMake(0, 0, 0, 0));
      //        }];
      //      }else{
      //        self.tabBarController.tabBar.hidden = YES;
      //        [self.webview mas_updateConstraints:^(MASConstraintMaker *make) {
      //          make.edges.mas_offset(UIEdgeInsetsMake(0, 0, -54, 0));
      //        }];
      //      }
    }else{
      //_progressView.hidden = NO;
    }
  }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
  NSLog(@"webViewDidStartLoad");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  NSLog(@"webViewDidFinishLoad");
}


- (void)loadWebview
{
  if (!self.isLocalHtml) {
    NSLog(@"weburl:%@",self.url);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
    [self.webview loadRequest:request];
  }else{
    //    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSLog(@"weburl:%@",self.url);
    NSString* appHtml = [NSString stringWithContentsOfFile:self.url encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:self.url];
    [self.webview loadHTMLString:appHtml baseURL:baseURL];
  }
  
}

- (void)showMore {
  
  id data = @{};
  [_bridge callHandler:@"showMoreMenu" data:data responseCallback:^(id response) {
    NSLog(@"testJavascriptHandler responded: %@", response);
  }];
  

}

- (void)backAction
{
  [self.navigationController popViewControllerAnimated:YES];

}

- (void)backToIndex
{
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)pay:(NSString *)charge
{
//  NSString *charge = @"{  \"id\": \"ch_KWTGO0Du9un1ybr90Kfb5qPO\",  \"object\": \"charge\",  \"created\": 1472202203,  \"livemode\": false,  \"paid\": false,  \"refunded\": false,  \"app\": \"app_9S4CyHqnT8mDbHev\",  \"channel\": \"alipay\",  \"order_no\": \"100010000\",  \"client_ip\": \"127.0.0.1\",  \"amount\": 1000,  \"amount_settle\": 1000,  \"currency\": \"cny\",  \"subject\": \"subject\",  \"body\": \"body\",  \"time_paid\": null,  \"time_expire\": 1472288603,  \"time_settle\": null,  \"transaction_no\": null,  \"refunds\": {    \"object\": \"list\",    \"url\": \"/v1/charges/ch_KWTGO0Du9un1ybr90Kfb5qPO/refunds\",    \"has_more\": false,    \"data\": []  },  \"amount_refunded\": 0,  \"failure_code\": null,  \"failure_msg\": null,  \"metadata\": {},  \"credential\": {    \"object\": \"credential\",    \"alipay\": {      \"orderInfo\": \"_input_charset=\\\"utf-8\\\"&body=\\\"body\\\"&it_b_pay=\\\"2016-08-27 17:03:23\\\"&notify_url=\\\"https%3A%2F%2Fapi.pingxx.com%2Fnotify%2Fcharges%2Fch_KWTGO0Du9un1ybr90Kfb5qPO\\\"&out_trade_no=\\\"100010000\\\"&partner=\\\"2008754335451103\\\"&payment_type=\\\"1\\\"&seller_id=\\\"2008754335451103\\\"&service=\\\"mobile.securitypay.pay\\\"&subject=\\\"subject\\\"&total_fee=\\\"10.00\\\"&sign=\\\"YnZ2dnpETGFQOENHSHlYbmJMQ0dtYlQ0\\\"&sign_type=\\\"RSA\\\"\"    }  },  \"extra\": {},  \"description\": null}";
  NSLog(@"charge:%@",charge);

}

@end
