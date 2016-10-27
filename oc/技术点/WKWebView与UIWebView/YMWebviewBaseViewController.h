//
//  YMWebviewBaseViewController.h
//  WaterPurifier
//
//  Created by liushilou on 16/9/1.
//  Copyright © 2016年 Facebook. All rights reserved.
// 该类用户加载商城相关web view，不使用YMWebBaseViewController.h是因为h5的localstore存在延时性问题（在分别创建2个WKwebview的时候，也就是跳转页面的时候），所以采用iOS 的nsuserdefaults来给h5提供接口，引入库WKWebViewJavascriptBridge比较方便处理h5与OC的交互

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface YMWebviewBaseViewController : UIViewController<WKNavigationDelegate>

@property (nonatomic,strong) WKWebView *webview;


@property (nonatomic,strong) NSString *navtitle;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,assign) BOOL showMoreBtn;
@property (nonatomic,assign) BOOL isLocalHtml;

@end
