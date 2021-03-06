//
//  HomeViewController.m
//  SRTTest
//
//  Created by Lide on 2020/5/13.
//  Copyright © 2020 Lide. All rights reserved.
//

#import "HomeViewController.h"
#import "CameraDetailViewController.h"
#import "LMP2PClient.h"

@interface HomeViewController () {
    UIButton    *_createButton;
    UIButton    *_connectButton;
    LMP2PClient *_client;
    UILabel     *_localAddressLabel;
    UITextField *_ipTextField;
    UIButton    *_sendButton;
    UIButton    *_receiveButton;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Home";
    self.view.backgroundColor = [UIColor whiteColor];

    _createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _createButton.frame = CGRectMake(40, 100, 100, 40);
    _createButton.backgroundColor = [UIColor blackColor];
    [_createButton setTitle:@"Create" forState:UIControlStateNormal];
    [_createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_createButton addTarget:self action:@selector(clickCreateButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_createButton];

    _connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _connectButton.frame = CGRectMake(40, 160, 100, 40);
    _connectButton.backgroundColor = [UIColor blackColor];
    [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [_connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_connectButton addTarget:self action:@selector(clickConnectButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_connectButton];

    _ipTextField = [[UITextField alloc] initWithFrame:CGRectMake(160, 160, 200, 40)];
    _ipTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_ipTextField];

    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self.view addGestureRecognizer:tapView];

    _client = [[LMP2PClient alloc] init];
    _localAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 220, 300, 40)];
    _localAddressLabel.backgroundColor = [UIColor clearColor];
    _localAddressLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_localAddressLabel];

    [self showLocalAddress];

    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.frame = CGRectMake(40, 280, 100, 40);
    _sendButton.backgroundColor = [UIColor blackColor];
    [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(clickSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_sendButton];

    _receiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _receiveButton.frame = CGRectMake(160, 280, 100, 40);
    _receiveButton.backgroundColor = [UIColor blackColor];
    [_receiveButton setTitle:@"Receive" forState:UIControlStateNormal];
    [_receiveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_receiveButton addTarget:self action:@selector(clickReceiveButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_receiveButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.view endEditing:YES];
}

- (void)clickCreateButton:(id)sender {
    CameraDetailViewController *cameraDetailVC = [[CameraDetailViewController alloc] init];
    [self.navigationController pushViewController:cameraDetailVC animated:YES];
}

- (void)clickConnectButton:(id)sender {
    NSString *address = _ipTextField.text;
    BOOL success = [_client connectWithAddress:address];
    if (!success) {
        
    }
}

- (void)showLocalAddress {
    _localAddressLabel.text = [_client getLocalAddress];
}

- (void)tapView:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.view == self.view) {
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self.view endEditing:YES];
        }
    }
}

- (void)clickSendButton:(id)sender {
    [_client sendMessage:@"Hello, my friend!!!"];
}

- (void)clickReceiveButton:(id)sender {

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
