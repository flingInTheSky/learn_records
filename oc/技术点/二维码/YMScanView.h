//
//  YMScanView.h
//  WaterPurifier
//
//  Created by liushilou on 16/11/15.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol YMScanViewDelegate <NSObject>

- (void)YMScanViewToggleLight;

@end



@interface YMScanView : UIView

@property (nonatomic,assign) id<YMScanViewDelegate> delegate;

- (instancetype)initWithScanRect:(CGRect)rect;


@end
