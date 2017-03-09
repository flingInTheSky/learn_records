//
//  YMQrCodeViewController.m
//  WaterPurifier
//
//  Created by liushilou on 16/11/15.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "YMQrCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "YMScanView.h"
#import <YMCommon/YMCWKWebviewViewController.h>
#import <YMCommon/YMCBaseNavigationController.h>
#import <YMCommon/YMCAlertViewController.h>
#import <YMCommon/YMCNavBarButton.h>
#import "YMQrLoginViewController.h"

@interface YMQrCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate,YMScanViewDelegate>


@property (nonatomic,strong) AVCaptureSession *session;

@property (nonatomic,strong) AVCaptureDevice *device;

@property (nonatomic,strong) YMScanView *scanView;

@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) BOOL isQRCodeCaptured;


  
@end

@implementation YMQrCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"二维码扫描";
  
    [self setup];
  
  self.navigationItem.rightBarButtonItem = [[YMCNavBarButton alloc] initWithTitle:@"相册" style:UIBarButtonItemStyleDone target:self action:@selector(p_imagePicker)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.session) {
        self.isQRCodeCaptured = NO;
        [self.session startRunning];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.session) {
        [self.session stopRunning];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
  
}

- (void)setup {
  //判断权限,比较费时，需要开启线程，要不然会有点卡顿。
  CGFloat size = [YMCScreenAdapter intergerSizeBy750:450];
  CGFloat x = ([UIScreen mainScreen].bounds.size.width - size)/2;
  CGRect scanRect = CGRectMake(x, [YMCScreenAdapter intergerSizeBy750:200], size, size);
  
  self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  self.indicatorView.hidesWhenStopped = YES;
  self.indicatorView.center = CGPointMake(scanRect.origin.x + scanRect.size.width/2, scanRect.origin.y + scanRect.size.height/2);
  [self.indicatorView startAnimating];
  [self.view addSubview:self.indicatorView];
  
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
      case AVAuthorizationStatusNotDetermined: {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler: ^(BOOL granted) {
          if (granted) {
            [self setupCapture];
          } else {
            NSLog(@"%@", @"访问受限");
            [self showError];
          }
        }];
        break;
      }
      case AVAuthorizationStatusAuthorized: {
        [self setupCapture];
        break;
      }
      case AVAuthorizationStatusRestricted:
      case AVAuthorizationStatusDenied: {
        NSLog(@"%@", @"访问受限");
        [self showError];
        break;
      }
      default: {
        break;
      }
    }
  });
}

- (void)showError
{
  dispatch_async(dispatch_get_main_queue(), ^{
//      [YMCAlertView showMessage:@"请在iPhone的“设置-隐私－相机”选项中，允许微信访问你的相机"];
    [self.indicatorView stopAnimating];
    
    UILabel *errorLabel = [[UILabel alloc] init];
    errorLabel.textAlignment = NSTextAlignmentCenter;
    errorLabel.numberOfLines = 0;
    errorLabel.text = @"请在iPhone的“设置-隐私－相机”选项中，允许微信访问你的相机";
    errorLabel.font = [UIFont systemFontOfSize:[YMCScreenAdapter sizeBy640:12]];
    errorLabel.textColor = [UIColor redColor];
    [self.view addSubview:errorLabel];
    [errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.view).with.offset(10);
      make.right.equalTo(self.view).with.offset(-10);
      make.centerY.equalTo(self.view);
    }];
  });
}


- (void)setupCapture {
  
  dispatch_async(dispatch_get_main_queue(), ^{
    
    [self.indicatorView stopAnimating];
    //1、创建session
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset: AVCaptureSessionPresetHigh];
    
    //2、addInput
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (deviceInput) {
		    [self.session addInput:deviceInput];
      
        //addOutput
		    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
		    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
		    [self.session addOutput:metadataOutput]; // 这行代码要在设置 metadataObjectTypes 前
      //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
      //条码扫描有问题，参考http://www.cnblogs.com/allen123/p/4519188.html
      //所以，暂时只要二维码扫描
      
//      NSMutableArray *a = [[NSMutableArray alloc] init];
//      if ([metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
//        [a addObject:AVMetadataObjectTypeQRCode];
//      }
//      if ([metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
//        [a addObject:AVMetadataObjectTypeEAN13Code];
//      }
//      if ([metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
//        [a addObject:AVMetadataObjectTypeEAN8Code];
//      }
//      if ([metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
//        [a addObject:AVMetadataObjectTypeCode128Code];
//      }
//      metadataOutput.metadataObjectTypes=a;
      
		    metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
  //@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
  //;
      
        //previewLayer
		    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
		    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		    previewLayer.frame = self.view.frame;
		    [self.view.layer insertSublayer:previewLayer atIndex:0];
      
        CGFloat size = [YMCScreenAdapter intergerSizeBy750:450];
        CGFloat x = ([UIScreen mainScreen].bounds.size.width - size)/2;
        CGRect scanRect = CGRectMake(x, [YMCScreenAdapter intergerSizeBy750:200], size, size);
//		    __weak typeof(self) weakSelf = self;
		    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                                          object:nil
                                                           queue:[NSOperationQueue currentQueue]
                                                      usingBlock: ^(NSNotification *_Nonnull note) {
                                                        
                                                          metadataOutput.rectOfInterest = [previewLayer metadataOutputRectOfInterestForRect:scanRect]; // 如果不设置，整个屏幕都可以扫
                                                      }];
        YMScanView *scanView = [[YMScanView alloc] initWithScanRect:scanRect];
        scanView.delegate = self;
        [self.view addSubview:scanView];
      
		    [self.session startRunning];
    } else {
		    NSLog(@"%@", error);
    }
  });
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
  
  AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
  NSLog(@"qwe:%@",metadataObject.stringValue);
  
  if ([self checkUrl:metadataObject.stringValue]) {
    
    if (!self.isQRCodeCaptured) {
      self.isQRCodeCaptured = YES;
      
      [self.session stopRunning];
      NSLog(@"url:%@",metadataObject.stringValue);
      
      [self p_gotoWebView:metadataObject.stringValue];
    }

  }else{
      [YMCAlertViewController showAlertview:metadataObject.stringValue];
  }
  
//  if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode] && !self.isQRCodeCaptured) {
//    self.isQRCodeCaptured = YES;
//    
//    [self.session stopRunning];
//    NSLog(@"url:%@",metadataObject.stringValue);
//    
//    [self p_gotoWebView:metadataObject.stringValue];
//  }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
  
  CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy:CIDetectorAccuracyHigh }];
  CIImage *image = [[CIImage alloc] initWithImage:originalImage];
  NSArray *features = [detector featuresInImage:image];
  CIQRCodeFeature *feature = [features firstObject];
  if (feature) {
    NSLog(@"url:%@",feature.messageString);
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    if ([self checkUrl:feature.messageString]) {
      if (!self.isQRCodeCaptured) {
        self.isQRCodeCaptured = YES;
        [self.session stopRunning];
        [self p_gotoWebView:feature.messageString];
      }
    }else{
      [YMCAlertViewController showAlertview:feature.messageString];
    }
  } else {
    NSLog(@"没有二维码");
    [picker dismissViewControllerAnimated:YES completion:^{
      [YMCAlertViewController showAlertview:@"该图片没有二维码"];
    }];
  }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma YMScanViewDelegate

- (void)YMScanViewToggleLight
{
  AVCaptureDevice *device = self.device;
  
  //修改前必须先锁定
  [self.device lockForConfiguration:nil];
  
  //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
  if ([self.device hasFlash]) {
    
    if (self.device.flashMode == AVCaptureFlashModeOff) {
      self.device.flashMode = AVCaptureFlashModeOn;
      self.device.torchMode = AVCaptureTorchModeOn;
    } else if (self.device.flashMode == AVCaptureFlashModeOn) {
      self.device.flashMode = AVCaptureFlashModeOff;
      self.device.torchMode = AVCaptureTorchModeOff;
    }
    
  }
  [device unlockForConfiguration];
}

#pragma UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}



#pragma private method
- (void)p_imagePicker
{
  
  UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
  imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  imagePickerController.delegate = self;
  //	imagePickerController.allowsEditing = YES;
  [self presentViewController:imagePickerController animated:YES completion:nil];
}


- (void)p_gotoWebView:(NSString *)url
{
    NSURL *curl = [NSURL URLWithString:url];
    if ([curl.host isEqualToString:@"auth.mi-ae.net"] || [curl.path isEqualToString:@"vmall-auth.mi-ae.net"]) {
        [self scanLogin:curl];
    }else{
        YMCWKWebviewViewController *controller = [[YMCWKWebviewViewController alloc] init];
        controller.url = url;
        controller.isBackToIndex = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (BOOL)checkUrl:(NSString *)url
{
  if ([url rangeOfString:@"http://"].location != NSNotFound || [url rangeOfString:@"https://"].location != NSNotFound) {
    return YES;
  }else{
    return NO;
  }
}


//扫码登录
- (void)scanLogin:(NSURL *)url
{
    NSString *query = url.query;
    NSArray *querys = [query componentsSeparatedByString:@"&"];
    NSString *clientID = @"";
    for (NSString *item in querys) {
        NSArray *itemarray = [item componentsSeparatedByString:@"="];
        
        if (itemarray.count > 1) {
            if ([itemarray[0] isEqualToString:@"clientID"]) {
                clientID = itemarray[1];
            }
        }
    }

    YMQrLoginViewController *controller = [[YMQrLoginViewController alloc] init];
    controller.clientID = clientID;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
