//
//  YMScanView.m
//  WaterPurifier
//
//  Created by liushilou on 16/11/15.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "YMScanView.h"
#import "YMImageButton.h"

@interface YMScanView ()

@property (nonatomic, assign) CGRect scanRect;

@property (nonatomic,strong) UIImageView *lineView;
@property (nonatomic,strong) UIView *scanview;

@property (nonatomic,assign) BOOL isNotFirstAnimate;

@end


@implementation YMScanView

- (instancetype)initWithScanRect:(CGRect)rect
{
  self = [super initWithFrame:[UIScreen mainScreen].bounds];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    _scanRect = rect;
    
    self.scanview = [[UIView alloc] initWithFrame:rect];
    self.scanview.layer.borderColor = [UIColor whiteColor].CGColor;
    self.scanview.layer.borderWidth = 0.5;
    self.scanview.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scanview];
    
    UIImageView *imageview1 = [[UIImageView alloc] init];
    imageview1.image = [UIImage imageNamed:@"ym_qr_corner"];
    [self.scanview addSubview:imageview1];
    [imageview1 mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.scanview).with.offset(0);
      make.top.equalTo(self.scanview).with.offset(0);
      make.size.mas_equalTo(CGSizeMake([YMCScreenAdapter sizeBy750:48], [YMCScreenAdapter sizeBy750:48]));
    }];
    
    UIImageView *imageview2 = [[UIImageView alloc] init];
    imageview2.image = [UIImage imageNamed:@"ym_qr_corner"];
    [self.scanview addSubview:imageview2];
    imageview2.transform = CGAffineTransformMakeRotation(M_PI_2);
    [imageview2 mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(self.scanview).with.offset(0);
      make.top.equalTo(self.scanview).with.offset(0);
      make.size.mas_equalTo(CGSizeMake([YMCScreenAdapter sizeBy750:48], [YMCScreenAdapter sizeBy750:48]));
    }];
    
    UIImageView *imageview3 = [[UIImageView alloc] init];
    imageview3.image = [UIImage imageNamed:@"ym_qr_corner"];
    [self.scanview addSubview:imageview3];
    imageview3.transform = CGAffineTransformMakeRotation(M_PI);
    [imageview3 mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(self.scanview).with.offset(0);
      make.bottom.equalTo(self.scanview).with.offset(0);
      make.size.mas_equalTo(CGSizeMake([YMCScreenAdapter sizeBy750:48], [YMCScreenAdapter sizeBy750:48]));
    }];
    
    UIImageView *imageview4 = [[UIImageView alloc] init];
    imageview4.image = [UIImage imageNamed:@"ym_qr_corner"];
    [self.scanview addSubview:imageview4];
    imageview4.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [imageview4 mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.scanview).with.offset(0);
      make.bottom.equalTo(self.scanview).with.offset(0);
      make.size.mas_equalTo(CGSizeMake([YMCScreenAdapter sizeBy750:48], [YMCScreenAdapter sizeBy750:48]));
    }];
    
    self.lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scanRect.size.width, [YMCScreenAdapter sizeBy750:12])];
    self.lineView.image = [UIImage imageNamed:@"ym_qr_line"];
    [self.scanview addSubview:self.lineView];

    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"将二维码放入框内，即可自动扫描";
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.font = YMC_FONT([YMCScreenAdapter sizeBy750:28]);
    [self addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.scanview.mas_bottom).with.offset([YMCScreenAdapter sizeBy750:24]);
      make.centerX.equalTo(self);
    }];
    
    YMImageButton *lightbtn = [[YMImageButton alloc] initWithTitle:@"打开闪光灯" selectedTitle:@"关闭闪光灯" image:[UIImage imageNamed:@"ym_qr_light_off"] selectedImage:[UIImage imageNamed:@"ym_qr_light_on"]];
//    [lightbtn setImage:[UIImage imageNamed:@"ym_qr_light_off"] forState:UIControlStateNormal];
//    [lightbtn setImage:[UIImage imageNamed:@"ym_qr_light_on"] forState:UIControlStateSelected];
//    [lightbtn setTitle:@"打开闪光灯" forState:UIControlStateNormal];
//    [lightbtn setTitle:@"关闭闪光灯" forState:UIControlStateSelected];
    [lightbtn addTarget:self action:@selector(toggleLight:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lightbtn];
    [lightbtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.bottom.equalTo(self).with.offset(-80);
      make.size.mas_equalTo(CGSizeMake([YMCScreenAdapter sizeBy750:200], [YMCScreenAdapter sizeBy750:200]));
      make.centerX.equalTo(self);
    }];
    
    
    [self startAnimate];
  }
  return self;
}


- (void)drawRect:(CGRect)rect {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  [[[UIColor blackColor] colorWithAlphaComponent:0.5] setFill];
  
  CGMutablePathRef screenPath = CGPathCreateMutable();
  CGPathAddRect(screenPath, NULL, self.bounds);
  
  CGMutablePathRef scanPath = CGPathCreateMutable();
  CGPathAddRect(scanPath, NULL, self.scanRect);
  
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddPath(path, NULL, screenPath);
  CGPathAddPath(path, NULL, scanPath);
  
  CGContextAddPath(ctx, path);
  CGContextDrawPath(ctx, kCGPathEOFill);
  
  CGPathRelease(screenPath);
  CGPathRelease(scanPath);
  CGPathRelease(path);
}




- (void)startAnimate
{
  if (self.lineView.frame.origin.y > 0) {
      CGRect upreact = CGRectMake(0, 0, self.scanRect.size.width, [YMCScreenAdapter sizeBy750:12]);
      self.lineView.frame = upreact;
      [self startAnimate];
  }else{
    [UIView animateWithDuration:3.0 animations:^{
      CGRect downreact = CGRectMake(0, self.scanRect.size.height - [YMCScreenAdapter sizeBy750:12], self.scanRect.size.width, [YMCScreenAdapter sizeBy750:12]);
      self.lineView.frame = downreact;
    } completion:^(BOOL finished) {
      [self startAnimate];
    }];
  }
}

- (void)toggleLight:(UIButton *)button
{
  if (button.selected) {
    button.selected = NO;
  }else{
    button.selected = YES;
  }
  
  [self.delegate YMScanViewToggleLight];
}


@end
