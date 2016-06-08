//
//  MTTRegisterViewController.m
//  TeamTalk
//
//  Created by Donal Tong on 16/4/12.
//  Copyright © 2016年 DL. All rights reserved.
//

#import "MTTRegisterViewController.h"
#import "UIView+SDAutoLayout.h"
#import "UIView+JHFollowKeyboard.h"
@interface MTTRegisterViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UIView *avatarView;
@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UITextField *accountTF;
@property (nonatomic, strong) UITextField *nickTF;
@property (nonatomic, strong) UITextField *passTF;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *sex;
@end

@implementation MTTRegisterViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view openFollowKeyboard:JHFollowKeyboardType_Auto];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view closeFollowKeyboard];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUi];
    _avatarUrl = @"http://ww2.sinaimg.cn/mw690/668b990agw1f4eo4tvdyvj2069069aa1.jpg";
    _sex = @"1";
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)initUi
{
    self.view.backgroundColor = UIColorFromRGB(0xffffff, 1.0);
    
    _avatarView = [UIView new];
    [self.view addSubview:_avatarView];
    _avatarView.backgroundColor = UIColorFromRGB(0xf0f3f8, 1.0);
    _avatarView.sd_layout
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .topSpaceToView(self.view, 0)
    .heightIs(211*2*RATIO_HEIGHT);
    
    _avatarImageView = [UIImageView new];
    [_avatarView addSubview:_avatarImageView];
    _avatarImageView.sd_layout
    .centerXEqualToView(_avatarView)
    .widthIs(80*2*RATIO_HEIGHT)
    .heightIs(80*2*RATIO_HEIGHT)
    .topSpaceToView(_avatarView, 150*RATIO_HEIGHT)
    ;
    _avatarImageView.layer.cornerRadius = 80*RATIO_HEIGHT;
    _avatarImageView.layer.masksToBounds = YES;
    [_avatarImageView setImage:[UIImage imageNamed:@"avatar_male"]];
    
    UIButton *maleButton = [UIButton new];
    [_avatarView addSubview:maleButton];
    maleButton.sd_layout
    .leftSpaceToView(_avatarView, screenframe.size.width/2 - 30*3*RATIO_HEIGHT)
    .widthIs(30*2*RATIO_HEIGHT)
    .heightIs(30*2*RATIO_HEIGHT)
    .topSpaceToView(_avatarImageView, 20*RATIO_HEIGHT)
    ;
    [maleButton setImage:[UIImage imageNamed:@"icon_male"] forState:UIControlStateNormal];
    [maleButton addTarget:self action:@selector(changeMale) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *femaleButton = [UIButton new];
    [_avatarView addSubview:femaleButton];
    femaleButton.sd_layout
    .leftSpaceToView(maleButton, 30*2*RATIO_HEIGHT)
    .widthIs(30*2*RATIO_HEIGHT)
    .heightIs(30*2*RATIO_HEIGHT)
    .topSpaceToView(_avatarImageView, 20*RATIO_HEIGHT)
    ;
    [femaleButton setImage:[UIImage imageNamed:@"icon_female"] forState:UIControlStateNormal];
    [femaleButton addTarget:self action:@selector(changeFemale) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *editView = [UIView new];
    [self.view addSubview:editView];
    editView.sd_layout
    .topSpaceToView(_avatarView, 0)
    .rightSpaceToView(self.view, 0)
    .leftSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 0);
    
    _accountTF = [UITextField new];
    _accountTF.returnKeyType = UIReturnKeyNext;
    _accountTF.delegate = self;
    _accountTF.placeholder = @"手机号码/账号";
    [_accountTF setBorderStyle:UITextBorderStyleNone];
    [_accountTF.layer setBorderWidth:1];
    [_accountTF.layer setBorderColor:UIColorFromRGB(0xdddddd, 1.0).CGColor];
    [editView addSubview:_accountTF];
    _accountTF.sd_layout
    .leftSpaceToView(editView, 0)
    .rightSpaceToView(editView, 0)
    .topSpaceToView(editView, 0)
    .heightIs(44)
    .centerXEqualToView(editView);
    
    _nickTF = [UITextField new];
    _nickTF.returnKeyType = UIReturnKeyNext;
    _nickTF.delegate = self;
    _nickTF.placeholder = @"昵称";
    [_nickTF setBorderStyle:UITextBorderStyleNone];
    [editView addSubview:_nickTF];
    _nickTF.sd_layout
    .leftSpaceToView(editView, 0)
    .rightSpaceToView(editView, 0)
    .topSpaceToView(_accountTF, 0)
    .heightIs(44)
    .centerXEqualToView(editView);
    
    _passTF = [UITextField new];
    _passTF.delegate = self;
    _passTF.returnKeyType = UIReturnKeyDone;
    [editView addSubview:_passTF];
    [_passTF setBorderStyle:UITextBorderStyleNone];
    _passTF.placeholder = @"密码";
    [_passTF.layer setBorderWidth:1];
    [_passTF.layer setBorderColor:UIColorFromRGB(0xdddddd, 1.0).CGColor];
    _passTF.sd_layout
    .leftSpaceToView(editView, 0)
    .rightSpaceToView(editView, 0)
    .heightIs(44)
    .topSpaceToView(_nickTF, 0 )
    .centerXEqualToView(editView);
    UIView *padView1                = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, _passTF.frame.size.height)];
    _passTF.leftView              = padView1;
    _passTF.leftViewMode          = UITextFieldViewModeAlways;
    _passTF.secureTextEntry = YES;
    UIView *padView2                = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, _accountTF.frame.size.height)];
    _accountTF.leftView              = padView2;
    _accountTF.leftViewMode          = UITextFieldViewModeAlways;
    UIView *padView3                = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, _nickTF.frame.size.height)];
    _nickTF.leftView              = padView3;
    _nickTF.leftViewMode          = UITextFieldViewModeAlways;
    
    _loginButton = [UIButton new];
    [_loginButton setBackgroundColor:UIColorFromRGB(0x00abee, 1.0)];
    [_loginButton setTitle:@"注册" forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [editView addSubview:_loginButton];
    _loginButton.sd_layout
    .leftSpaceToView(editView, 20)
    .rightSpaceToView(editView, 20)
    .heightIs(44)
    .topSpaceToView(_passTF, 30)
    .centerXEqualToView(editView);
    
}

-(void)changeMale
{
    [_avatarImageView setImage:[UIImage imageNamed:@"avatar_male"]];
    _avatarUrl = @"http://ww2.sinaimg.cn/mw690/668b990agw1f4eo4tvdyvj2069069aa1.jpg";
    _sex = @"1";
    [self.view endEditing:YES];
}

-(void)changeFemale
{
    [_avatarImageView setImage:[UIImage imageNamed:@"avatar_female"]];
    _avatarUrl = @"http://ww4.sinaimg.cn/mw690/668b990agw1f4mhehi0njj205k05kt94.jpg";
    [self.view endEditing:YES];
    _sex = @"2";
}

-(void)login
{
    NSString *account = _accountTF.text;
    NSString *password = _passTF.text;
    NSString *nickname = _nickTF.text;
    if (!(account.trim.length > 0) || !(password.trim.length > 0) || !(nickname.trim.length > 0)) {
        [OHAlertView showAlertWithTitle:@"提示" message:@"" dismissButton:@"好的"];
        return;
    }
    [SVProgressHUD show];
    [[ApiClient sharedInstance] registerUser:account
                                    password:password
                                    nickname:nickname
                                      avatar:_avatarUrl
                                         sex:_sex
                                     Success:^(id model) {
                                         [SVProgressHUD dismiss];
                                         if ([[model valueForKey:@"status"] integerValue] == 0) {
                                             [self.navigationController popViewControllerAnimated:YES];
                                         }
                                         else {
                                             [OHAlertView showAlertWithTitle:@"提示" message:[model valueForKey:@"msg"] dismissButton:@"好的"];
                                         }
                                     }
                                     failure:^(NSString *message) {
                                         [SVProgressHUD dismiss];
                                         [OHAlertView showAlertWithTitle:@"提示" message:message dismissButton:@"好的"];
                                     }];
}

@end
