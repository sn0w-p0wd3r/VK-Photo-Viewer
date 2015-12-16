//
//  LoginViewController.m
//  VK Photo Viewer
//
//  Created by Andrii Sudoma on 12/13/15.
//  Copyright © 2015 Andrii Sudoma. All rights reserved.
//

#import "LoginViewController.h"
#import "VKSdk/VKSdk.h"

static NSString* appId = @"5186728";
static NSString* successLoginSegueName = @"Success login";
static NSArray* scope = nil;

@interface LoginViewController () <VKSdkDelegate, VKSdkUIDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (IBAction)loginButtonPressed:(UIButton *)sender {
    [[self spinner] startAnimating];
    [[self loginButton] setEnabled:NO];

    [self authorize];
}

- (void)loginSuccess {
    [self performSegueWithIdentifier:successLoginSegueName sender:self];
}

- (void)initVKSdk {
    [VKSdk initializeWithAppId:appId];
    [[VKSdk instance] registerDelegate:self];
    [[VKSdk instance] setUiDelegate:self];
}

- (void)authorize {
    if ([VKSdk accessToken]) {
        [self loginSuccess];
    } else {
        [VKSdk authorize:scope];
    }
}

- (void)tryAutologin {
    [VKSdk wakeUpSession:scope completeBlock:^(VKAuthorizationState state, NSError *error) {
        if (state == VKAuthorizationAuthorized) {
            [self loginSuccess];
        } else {
            if (error) {
                NSLog(@"Error: %@", error);
            }

            [[self spinner] stopAnimating];
            [[self loginButton] setEnabled:YES];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [[self spinner] startAnimating];
    [[self loginButton] setEnabled:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [self tryAutologin];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    scope = @[VK_PER_PHOTOS];
    [self initVKSdk];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - VK Delegates

- (void)vkSdkUserAuthorizationFailed {
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self.navigationController.topViewController presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    if (result.token) {
        [self loginSuccess];
    } else if (result.error) {
        NSLog(@"Error: %@", result.error);
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
