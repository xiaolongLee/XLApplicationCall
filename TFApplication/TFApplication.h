//
//  TFApplication.h
//  MZSJ
//
//  Created by 吴伯程 on 16/4/22.
//  Copyright © 2016年 李小龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFApplication : UIApplication

+ (instancetype)defaultApplication;
/** 不用管tel和mobile是否为nil或为一个空格 此方法自会判断
 如果明确只需拨打一个电话 则传一个参数, 另一个参数传nil */
- (void)callWithTel:(NSString *)tel Mobile:(NSString *)mobile;

@end
