//
//  YMPhotosView.m
//  WaterPurifier
//
//  Created by liushilou on 16/10/25.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "YMPhotosView.h"
#import <Photos/Photos.h>
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>

@interface YMPhotosView()<UIScrollViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) NSMutableArray *imageViews;

@property (nonatomic,assign) BOOL isLocalImage;

@property (nonatomic,strong) NSMutableArray *images;

@property (nonatomic,assign) CGFloat navheight;


@property (nonatomic,strong) UIScrollView *parrentScrollview;

@property (nonatomic,strong) UIView *topView;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,assign) NSInteger currentIndex;

@property (nonatomic,assign) id<YMPhotosViewDelegate> delegate;

@property (nonatomic,strong) UIButton *deleteBtn;

@end


@implementation YMPhotosView


- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.windowLevel = UIWindowLevelNormal;
    self.parrentScrollview = [[UIScrollView alloc] initWithFrame:frame];
    self.parrentScrollview.tag = -1;
    self.parrentScrollview.pagingEnabled = YES;
    self.parrentScrollview.delegate = self;
    [self addSubview:self.parrentScrollview];

    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self).with.offset(0);
      make.top.equalTo(self).with.offset(0);
      make.right.equalTo(self).with.offset(0);
      make.height.mas_equalTo(64);
    }];
    
    
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat top = rectStatus.size.height;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [backBtn setTintColor:[UIColor whiteColor]];
    [backBtn setImage:[UIImage imageNamed:@"ym_nav_back"] forState:UIControlStateNormal];
    [backBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.topView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.topView).with.offset(5);
      make.top.equalTo(self.topView).with.offset(top);
      make.bottom.equalTo(self.topView).with.offset(0);
      make.width.mas_equalTo(60);
    }];
    
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.deleteBtn setTintColor:[UIColor whiteColor]];
    [self.deleteBtn setImage:[UIImage imageNamed:@"ym_photo_delete"] forState:UIControlStateNormal];
    [self.deleteBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    self.deleteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.topView addSubview:self.deleteBtn];
    [self.deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(self.topView).with.offset(-5);
      make.top.equalTo(self.topView).with.offset(top);
      make.bottom.equalTo(self.topView).with.offset(0);
      make.width.mas_equalTo(60);
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:[YMScreenAdapter sizeBy640:16]];
    [self.topView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.topView).with.offset(top);
      make.centerX.mas_equalTo(self.topView);
      make.bottom.equalTo(self.topView).with.offset(0);
    }];
    
    self.imageViews = [[NSMutableArray alloc] init];
  }
  
  return self;
}

- (void)drawRect:(CGRect)rect
{
  for (UIView *view in self.parrentScrollview.subviews) {
    [view removeFromSuperview];
  }
  [self.imageViews removeAllObjects];
  
  self.parrentScrollview.contentSize = CGSizeMake(rect.size.width * self.images.count, rect.size.height);
  
  CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
  NSUInteger height = rectStatus.size.height;
//  self.topView.frame = CGRectMake(0, 0, rect.size.width, self.navheight + height);
  [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
    make.height.mas_equalTo(self.navheight + height);
  }];
  
//  [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//    make.height.mas_equalTo(self.navheight);
//  }];
  self.titleLabel.text = [NSString stringWithFormat:@"%d/%d",(int)self.currentIndex + 1,(int)self.images.count];
  self.parrentScrollview.contentOffset = CGPointMake([UIScreen mainScreen].bounds.size.width * self.currentIndex, 0);
  
  CGFloat px = 0;
  for (NSInteger i = 0; i < self.images.count; i++) {

    UIScrollView *scrollview = [[UIScrollView alloc]  initWithFrame:CGRectMake(px, 0, rect.size.width, rect.size.height)];
    scrollview.tag = i;
    [self.parrentScrollview addSubview:scrollview];
    
    px += rect.size.width;
    
    scrollview.delegate = self;
    scrollview.maximumZoomScale = 3.0;
    scrollview.minimumZoomScale = 1.0;
//    scrollview.backgroundColor = [UIColor redColor];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    [scrollview addSubview:imageview];
    [self.imageViews addObject:imageview];
    
    
    if (self.isLocalImage) {
      PHAsset *asset = [self.images objectAtIndex:i];
      PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
      // 同步获得图片, 只会返回1张图片
      options.synchronous = YES;
      [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (result) {
          CGFloat width = 0,height = 0;
          if (result.size.width > rect.size.width) {
            width = rect.size.width;
            CGFloat scaleHeight = (result.size.height/result.size.width) * width;
            if (scaleHeight > rect.size.height) {
              height = rect.size.height;
            }else{
              height = scaleHeight;
            }
          }else{
            width = result.size.width;
            //        CGFloat scaleHeight = (result.size.height/result.size.width) * width;
            if (result.size.height > rect.size.height) {
              height = rect.size.height;
            }else{
              height = result.size.height;
            }
          }
          
          //      CGFloat x = (rect.size.width - width)/2;
          //      CGFloat y = (rect.size.height - height)/2;
          
          
          
          imageview.image = result;
          scrollview.contentSize = CGSizeMake(width, height);
          
        }else{
          imageview.image = [UIImage imageNamed:@"tips_login_info"];
          imageview.contentMode = UIViewContentModeCenter;
          scrollview.delegate = nil;
          scrollview.maximumZoomScale = 1.0;
          scrollview.minimumZoomScale = 1.0;
        }

      }];
    }else{
      NSString *url = [self.images objectAtIndex:i];
      //下载完之后设置圆角 image
     // @weakify(self);
      
      MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:scrollview animated:YES];
      hud.mode = MBProgressHUDModeDeterminate;
      //[MBProgressHUD HUDForView:scrollview].progress = 0.0;
      
      //需要加这句，，要不然下载图片有很大的几率失败，应该与URL返回的图片格式有关
      [SDWebImageDownloader.sharedDownloader setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
                                   forHTTPHeaderField:@"Accept"];
      
      [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageDelayPlaceholder progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        //需要乘以1.0，否则progress为0.
        float progress = (receivedSize * 1.0)/expectedSize;
        hud.progress = progress;
        
      } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
       // @strongify(self);
        [hud hideAnimated:YES];
        if (image) {
          [[SDWebImageManager sharedManager] saveImageToCache:image forURL:[NSURL URLWithString:url]];
          CGFloat width = 0,height = 0;
          if (image.size.width > rect.size.width) {
            width = rect.size.width;
            CGFloat scaleHeight = (image.size.height/image.size.width) * width;
            if (scaleHeight > rect.size.height) {
              height = rect.size.height;
            }else{
              height = scaleHeight;
            }
          }else{
            width = image.size.width;
            //        CGFloat scaleHeight = (result.size.height/result.size.width) * width;
            if (image.size.height > rect.size.height) {
              height = rect.size.height;
            }else{
              height = image.size.height;
            }
          }
          
          //      CGFloat x = (rect.size.width - width)/2;
          //      CGFloat y = (rect.size.height - height)/2;
          
          imageview.image = image;
          scrollview.contentSize = CGSizeMake(width, height);
          
        }else{
          imageview.image = [UIImage imageNamed:@"tips_login_info"];
          imageview.contentMode = UIViewContentModeCenter;
          scrollview.delegate = nil;
          scrollview.maximumZoomScale = 1.0;
          scrollview.minimumZoomScale = 1.0;
          
        }
      }];
    }
    

    
    
  }
}




-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
  if (scrollView.tag != -1) {
    UIImageView *imageview = [self.imageViews objectAtIndex:scrollView.tag];
    return imageview;
  }else{
    return nil;
  }
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if (scrollView.tag == -1) {
    CGFloat offset = scrollView.contentOffset.x;
    
    int index = round(offset/[UIScreen mainScreen].bounds.size.width) + 1;
    if (index <= 0) {
      index = 1;
    }
    if (index >= self.images.count + 1) {
      index = (int)self.images.count + 1;
    }
    self.currentIndex = index - 1;
    
    self.titleLabel.text = [NSString stringWithFormat:@"%d/%d",index,(int)self.images.count];
  }
  
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
  if (scrollView.tag == -1) {
    return;
  }
  
  UIImageView *imageview = [self.imageViews objectAtIndex:scrollView.tag];
  UIImage *image = imageview.image;
  
  CGFloat scaleWidth = [UIScreen mainScreen].bounds.size.width * scrollView.zoomScale;
  CGFloat scaleHeight = (image.size.height/image.size.width) * scaleWidth;
  
  //NSLog(@"imageviewwidth:%f,scaleWidth:%f，scaleHeight：%f",imageview.frame.size.width,scaleWidth,scaleHeight);
  
  
  CGFloat width = 0,height = 0;
  if (scaleWidth > [UIScreen mainScreen].bounds.size.width) {
    width = scaleWidth;
  }else{
    width = [UIScreen mainScreen].bounds.size.width;
  }
  
  if (scaleHeight > [UIScreen mainScreen].bounds.size.height) {
    height = scaleHeight;
  }else{
    height = [UIScreen mainScreen].bounds.size.height;
  }
  
  
  [UIView animateWithDuration:0.2 animations:^{
    scrollView.contentSize = CGSizeMake(scaleWidth, scaleHeight);
    imageview.frame = CGRectMake(0, 0, width, height);
  } completion:^(BOOL finished) {
    
  }];
  
}



- (void)show:(NSArray *)images localImage:(BOOL)isLocalImage navheight:(CGFloat)height index:(NSInteger)index delegate:(id<YMPhotosViewDelegate>)delegate
{
  self.images = [NSMutableArray arrayWithArray:images];
  self.isLocalImage = isLocalImage;
  self.navheight = height;
  self.currentIndex = index;
  self.delegate = delegate;
  
  if (!isLocalImage) {
    self.deleteBtn.hidden = YES;
  }
  
  self.hidden = NO;
  
  [self setNeedsDisplay];
}
- (void)hide
{
  if ([self.delegate respondsToSelector:@selector(YMPhotosViewDone)]) {
    [self.delegate YMPhotosViewDone];
  }
  
  self.hidden = YES;
  
}

- (void)deleteAction
{
//  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"删除该图片" preferredStyle:UIAlertControllerStyleAlert];
//  [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//    
//  }]];
//  [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//    
//    PHAsset *asset = [self.images objectAtIndex:self.currentIndex];
//    [self.images removeObject:asset];
//    
//    self.currentIndex -= 1;
//    
//    [self setNeedsDisplay];
//  }]];
//  
//  [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:^{
//    
//  }];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"删除该图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
  [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1) {
    PHAsset *asset = [self.images objectAtIndex:self.currentIndex];
    [self.images removeObject:asset];
    
    if ([self.delegate respondsToSelector:@selector(YMPhotosViewDeleteImageOfIndex:)]) {
      [self.delegate YMPhotosViewDeleteImageOfIndex:self.currentIndex];
    }
    
  
    self.currentIndex -= 1;
    if (self.currentIndex < 0) {
      self.currentIndex = 0;
    }
    if (self.images.count == 0) {
      [self hide];
    }else{
      [self setNeedsDisplay];
    }
  }
}
@end
