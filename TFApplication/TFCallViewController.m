//
//  TFCallViewController.m
//  MZSJ
//
//  Created by sqy on 16/7/21.
//  Copyright © 2016年 李小龙. All rights reserved.
//

#import "TFCallViewController.h"
#import "Masonry.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@interface TFCallViewController ()

@property (weak, nonatomic) IBOutlet UIView *numberView;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) IBOutlet UIView *secondNumberView;
@property (weak, nonatomic) IBOutlet UILabel *firstNumberLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstNumberLabelBottom;
@property (weak, nonatomic) IBOutlet UILabel *secondNumberLabel;

@property (assign, nonatomic) NSInteger checkNumber;
@property (strong, nonatomic) NSString *tel;
@property (strong, nonatomic) NSString *mobile;

@property (nonatomic,copy) NSString *beginTimeStr;//审计开始时间
@property (nonatomic,copy) NSString *auditStr;//插入审计表的第一个参数
@property (assign, nonatomic) JumpType currentType;//跳转类型

@end

@implementation TFCallViewController

#pragma mark - ui events

- (IBAction)firstNumberLabelClick:(UITapGestureRecognizer *)sender {
    if (_checkNumber == 2) {
        [self callWithNumber:_mobile];
    } else {
        [self callWithNumber:_tel];
    }
}

- (IBAction)secondNumberLabelClick:(UITapGestureRecognizer *)sender {
    [self callWithNumber:_mobile];
}

- (IBAction)clickBlanket:(UITapGestureRecognizer *)sender {
    [_viewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - private method

- (void)configUI {
    //弹出框的宽度为屏幕的2/3
    [_numberView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kScreenWidth * 2 / 3));
    }];
    
    _checkNumber = 0;
    if (_tel.length > 0 && ![_tel isEqualToString:@" "]) {
        //固话存在
        _checkNumber = _checkNumber | 1;
    }
    if (_mobile.length > 0 && ![_mobile isEqualToString:@" "]) {
        //移动电话存在
        _checkNumber = _checkNumber | (1 << 1);
    }
    
    if (_checkNumber == 3) { //有2个号码，加一个按钮
        [_numberView addSubview:_secondNumberView];
        
        [_secondNumberView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_firstNumberLabel.mas_bottom).with.offset(13);
            make.left.equalTo(_numberView.mas_left).with.offset(0);
            make.bottom.equalTo(_numberView.mas_bottom).with.offset(0);
            make.right.equalTo(_numberView.mas_right).with.offset(0);
        }];
    }
    
    switch (_checkNumber) {
        case 1: //只有固话
            _firstNumberLabel.text = _tel;
            break;
        case 2: //只有手机
            _firstNumberLabel.text = _mobile;
            break;
        case 3: //有2个号码
            _firstNumberLabel.text = _tel;
            _secondNumberLabel.text = _mobile;
            break;
        default:
            break;
    }
}

//call
- (void)callWithNumber:(NSString *)number {
    //如果检测不到有插手机卡 则中止拨打
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    if (!networkInfo.subscriberCellularProvider.mobileNetworkCode) { //没有插卡
        [TFTipLabel loadTipWithContent:@"未安装SIM卡"];
        return;
    }
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:0 error:&error];
    number = [regex stringByReplacingMatchesInString:number options:0 range:NSMakeRange(0, number.length) withTemplate:@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel://" stringByAppendingString:number]]];
    if (self.currentType == customerType) {
        [AuditManager auditWithCode:@"10100102M_CUSTOMER_CALL" op_time:_beginTimeStr op_parameter:[NSString stringWithFormat:@"%@|%@",_auditStr,number] limitLength:256];
    }else if(self.currentType == accountType){
        [AuditManager auditWithCode:@"10100105M_ACCOUNT_CALL" op_time:_beginTimeStr op_parameter:[NSString stringWithFormat:@"%@|%@",_auditStr,number] limitLength:256];
    }

}

#pragma mark - public method

+ (void)callWithTel:(NSString *)tel Mobile:(NSString *)mobile viewController:(UIViewController *)viewController audit:(NSString *)auditStr jumpType:(JumpType)type{
    TFCallViewController *vc = [[self alloc] init];
    vc.viewController = viewController;
    vc.tel = tel;
    vc.mobile = mobile;
    vc.auditStr = auditStr;
    vc.currentType = type;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [viewController presentViewController:vc animated:NO completion:nil];
}

#pragma mark - view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    _beginTimeStr = [AuditManager createStartTime];
    _numberView.layer.masksToBounds = YES;
    _numberView.layer.cornerRadius = 10;
    
    [self configUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    //MYLog(@"%s", __func__);
}

@end
