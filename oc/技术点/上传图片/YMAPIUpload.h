//
//  YMAPIUpload.h
//  WaterPurifier
//
//  Created by liushilou on 16/8/16.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "YMBaseAPIManager.h"

@interface YMAPIUpload : YMBaseAPIManager<UIImagePickerControllerDelegate,UINavigationBarDelegate>


- (void)selectImage:(UIViewController *)controller successBlock:(void (^)())successBlock failBlock:(void (^)(NSString *message))failBlock;


@end
