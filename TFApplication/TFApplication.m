//
//  TFApplication.m
//  MZSJ
//
//  Created by 吴伯程 on 16/4/22.
//  Copyright © 2016年 李小龙. All rights reserved.
//

#import "TFApplication.h"

@interface TFApplication ()<UIAlertViewDelegate, NSCopying> {
    UIAlertView *_alertView;
    int _checkNumber;
    NSString *_tel;
    NSString *_mobile;
}

@end

@implementation TFApplication

//完全单例
static TFApplication *app = nil;
+ (instancetype)defaultApplication {
    if (!app) {
        app = [self new];
    }
    return app;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app = [super allocWithZone:zone];
    });
    return app;
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)sendEvent:(UIEvent *)event {
    if (event.type == UIEventTypeTouches) {
        if ([[event.allTouches anyObject] phase] == UITouchPhaseBegan) {
            if (_alertView) {
                [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(check) userInfo:nil repeats:NO];
            }
        }
    }
    
    [super sendEvent:event];
}

#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    _alertView.tag = buttonIndex;
    _alertView = nil;
    
    NSString *code = nil;
    if (buttonIndex == 1 || _checkNumber == 2) {
        //拨打移动电话
        code = _mobile;
    }else {
        //拨打固话
        code = _tel;
    }
    
    //正则干掉所有非数字的字符
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:0 error:&error];
    if (code.length > 0) {
        code = [regex stringByReplacingMatchesInString:code options:0 range:NSMakeRange(0, code.length) withTemplate:@""];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel://" stringByAppendingString:code]]];
    }
    //MYLog(@"拨打 %@ ...", code);
}

#pragma mark - 自定义

- (void)check {
    if (_alertView.tag == -1) {
        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
        _alertView = nil;
    }
}

- (void)callWithTel:(NSString *)tel Mobile:(NSString *)mobile {
    _checkNumber = 0;
    _tel = tel;
    _mobile = mobile;
    if (tel.length > 0 && ![tel isEqualToString:@" "]) {
        //固话存在
        _checkNumber = _checkNumber | 1;
    }
    if (mobile.length > 0 && ![mobile isEqualToString:@" "]) {
        //移动电话存在
        _checkNumber = _checkNumber | (1 << 1);
    }
    if (_checkNumber == 0) {
        //MYLog(@"此处无电话，不该显示电话icon");
        return;
    }
    switch (_checkNumber) {
        case 1:
            //只存在固话
            _alertView = [[UIAlertView alloc] initWithTitle:@"拨打电话" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:tel, nil];
            break;
        case 2:
            //只存在移动电话
            _alertView = [[UIAlertView alloc] initWithTitle:@"拨打电话" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:mobile, nil];
            break;
        case 3:
            //两个电话都存在
            _alertView = [[UIAlertView alloc] initWithTitle:@"拨打电话" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:tel, mobile, nil];
            break;
    }
    _alertView.delegate = self;
    [_alertView show];
    _alertView.tag = -1;
}

@end
