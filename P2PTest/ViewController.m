//
//  ViewController.m
//  P2PTest
//
//  Created by KAKEGAWA Atsushi on 2013/10/05.
//  Copyright (c) 2013年 KAKEGAWA Atsushi. All rights reserved.
//

#import "ViewController.h"
#import "PeerListViewController.h"

static NSString * const SegueIdentifierPushPeerListView = @"PushPeerListViewSegue";

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;

- (IBAction)createSessionButtonDidTouch:(id)sender;

@end

@implementation ViewController

#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SegueIdentifierPushPeerListView]) {
        PeerListViewController *viewController = segue.destinationViewController;
        [viewController createSessionWithDisplayName:self.displayNameTextField.text];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Handler methods

- (IBAction)createSessionButtonDidTouch:(id)sender
{
    if (self.displayNameTextField.text.length == 0) {
        return;
    }
    
    [self performSegueWithIdentifier:SegueIdentifierPushPeerListView sender:self];
}

@end
