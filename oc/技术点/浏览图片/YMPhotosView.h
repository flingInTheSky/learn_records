//
//  YMPhotosView.h
//  WaterPurifier
//
//  Created by liushilou on 16/10/25.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMPhotosViewDelegate <NSObject>

@optional
- (void)YMPhotosViewDeleteImageOfIndex:(NSInteger)index;
- (void)YMPhotosViewDone;

@end



@interface YMPhotosView : UIWindow



- (void)show:(NSArray *)images localImage:(BOOL)isLocalImage navheight:(CGFloat)height index:(NSInteger)index delegate:(id<YMPhotosViewDelegate>)delegate;

- (void)hide;

@end
