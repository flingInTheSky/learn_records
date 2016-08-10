//
//  YMWebBaseViewController.h
//  WaterPurifier
//
//  Created by liushilou on 16/8/9.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface YMWebBaseViewController : UIViewController<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic,strong) WKWebView *webview;


@property (nonatomic,strong) NSString *navtitle;
@property (nonatomic,strong) NSString *url;

//如果需要向h5传递初始化信息，子类需要实现
- (void)sendSetupDatas;

@end
