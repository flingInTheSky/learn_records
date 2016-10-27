//
//  YMAPIUpload.m
//  WaterPurifier
//
//  Created by liushilou on 16/8/16.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "YMAPIUpload.h"
#import "YMWebBaseViewController.h"

@interface YMAPIUpload()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic,copy) void (^successBlock)();
@property (nonatomic,copy) void (^faileBlock)(NSString *);

@end

@implementation YMAPIUpload

- (void)selectImage:(UIViewController *)controller successBlock:(void (^)())successBlock failBlock:(void (^)(NSString *))failBlock
{
  self.successBlock = successBlock;
  self.faileBlock = failBlock;
  
  UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  
  [sheet addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [controller presentViewController:imagePicker animated:YES completion:^{
      
    }];
  }]];
  
  
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    [sheet addAction:[UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
      imagePicker.delegate = self;
      imagePicker.allowsEditing = YES;
      imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
      [controller presentViewController:imagePicker animated:YES completion:^{
        
      }];
    }]];
  }
  
  [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    
  }]];
  
  [controller presentViewController:sheet animated:YES completion:^{
    
  }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
  UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
  
  UIImage *smallImage = [self imageCompressForSize:image targetSize:CGSizeMake(150, 150)];
//  NSLog(@"size:%lu",[UIImageJPEGRepresentation(image, 1) length]/1000);
  
//  UIImage *oimage = [info objectForKey:UIImagePickerControllerOriginalImage];
//  NSLog(@"osize:%lu",[UIImageJPEGRepresentation(oimage, 1) length]/1000);
  NSString *url = [NSString stringWithFormat:@"%@app/auth/changeIcon",YMBASEURL];
  [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
  [self uploadImageToUrl:url image:smallImage completeBlock:^(requestStatus status, NSString *message, NSDictionary *data) {
    
    [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
    [picker dismissViewControllerAnimated:YES completion:^{
      
    }];
    
    if (status == requestStatus_success) {
      NSString *accessUrl = [data notNullObjectForKey:@"accessUrl"];
      [YMUserManager shareinstance].headImg = accessUrl;
      self.successBlock();
    }else{
      self.faileBlock(message);
    }
  }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""style:UIBarButtonItemStylePlain target:nil action:nil];
}


////对图片尺寸进行压缩--
//-(UIImage*)scaleimageWithImage:(UIImage*)image
//{
//  
//  
////  // Create a graphics image context
////  UIGraphicsBeginImageContext(newSize);
////  
////  // Tell the old image to draw in this new context, with the desired
////  // new size
////  [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
////  
////  // Get the new image from the context
////  UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
////  
////  // End the context
////  UIGraphicsEndImageContext();
////  
////  // Return the new image.
////  return newImage;
//}


//等比例压缩
-(UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size{
  UIImage *newImage = nil;
  CGSize imageSize = sourceImage.size;
  CGFloat width = imageSize.width;
  CGFloat height = imageSize.height;
  CGFloat targetWidth = size.width;
  CGFloat targetHeight = size.height;
  CGFloat scaleFactor = 0.0;
  CGFloat scaledWidth = targetWidth;
  CGFloat scaledHeight = targetHeight;
  CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
  if(CGSizeEqualToSize(imageSize, size) == NO){
    CGFloat widthFactor = targetWidth / width;
    CGFloat heightFactor = targetHeight / height;
    if(widthFactor > heightFactor){
      scaleFactor = widthFactor;
    }
    else{
      scaleFactor = heightFactor;
    }
    scaledWidth = width * scaleFactor;
    scaledHeight = height * scaleFactor;
    if(widthFactor > heightFactor){
      thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
    }else if(widthFactor < heightFactor){
      thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
    }
  }
  
  UIGraphicsBeginImageContext(size);
  
  CGRect thumbnailRect = CGRectZero;
  thumbnailRect.origin = thumbnailPoint;
  thumbnailRect.size.width = scaledWidth;
  thumbnailRect.size.height = scaledHeight;
  [sourceImage drawInRect:thumbnailRect];
  newImage = UIGraphicsGetImageFromCurrentImageContext();
  
  if(newImage == nil){
    NSLog(@"scale image fail");
  }
  
  UIGraphicsEndImageContext();
  
  return newImage;
  
}

@end
