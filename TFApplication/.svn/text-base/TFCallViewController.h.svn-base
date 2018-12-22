//
//  TFCallViewController.h
//  MZSJ
//
//  Created by sqy on 16/7/21.
//  Copyright © 2016年 李小龙. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    customerType,//客户
    accountType //员工
} JumpType;

@interface TFCallViewController : UIViewController

/**
 *  打电话
 *
 *  @param tel            固话
 *  @param mobile         手机
 *  @param viewController 控制器
 *  @param auditStr       插入审计表的第一个参数  客户传：customer_id   员工：usercode
 *  @param type           什么页面跳转
 */
+ (void)callWithTel:(NSString *)tel Mobile:(NSString *)mobile viewController:(UIViewController *)viewController audit:(NSString *)auditStr jumpType:(JumpType)type;

@end
