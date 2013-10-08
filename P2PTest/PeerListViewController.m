//
//  PeerListViewController.m
//  P2PTest
//
//  Created by KAKEGAWA Atsushi on 2013/10/05.
//  Copyright (c) 2013年 KAKEGAWA Atsushi. All rights reserved.
//

#import "PeerListViewController.h"
#import "SessionHelper.h"

@import MultipeerConnectivity;

static NSString * const CellIdentifier = @"Cell";

@interface PeerListViewController () <MCBrowserViewControllerDelegate, SessionHelperDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) SessionHelper *sessionHelper;
@property (nonatomic) MCPeerID *selectedPeerID;

- (IBAction)browseButtonDidTouch:(id)sender;

@end

@implementation PeerListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sessionHelper.connectedPeersCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    MCPeerID *peerID = [self.sessionHelper connectedPeerIDAtIndex:indexPath.row];
    cell.textLabel.text = peerID.displayName;
    
    return cell;
}

#pragma mark - UITableViewControllerDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPeerID = [self.sessionHelper connectedPeerIDAtIndex:indexPath.row];
    
    if (self.selectedPeerID) {
        UIImagePickerController *imagePickerController = [UIImagePickerController new];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - MCBrowserViewControllerDelegate methods

- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController
      shouldPresentNearbyPeer:(MCPeerID *)peerID
            withDiscoveryInfo:(NSDictionary *)info
{
    return YES;
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SessionHelperDelegate methods

- (void)sessionHelperDidChangeConnectedPeers:(SessionHelper *)sessionHelper
{
    [self.tableView reloadData];
}

- (void)sessionHelperDidRecieveImage:(UIImage *)image peer:(MCPeerID *)peerID
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), NULL);
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self.sessionHelper sendImage:image peerID:self.selectedPeerID];
    self.selectedPeerID = nil;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Handler methods

- (IBAction)browseButtonDidTouch:(id)sender
{
    MCBrowserViewController *viewController = [[MCBrowserViewController alloc] initWithServiceType:self.sessionHelper.serviceType
                                                                                           session:self.sessionHelper.session];
    viewController.delegate = self;
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)savingImageIsFinished:(UIImage *)image
     didFinishSavingWithError:(NSError *)error
                  contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"%@", error);
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"受信した画像をカメラロールに保存しました。"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Public methods

- (void)createSessionWithDisplayName:(NSString *)displayName
{
    self.sessionHelper = [[SessionHelper alloc] initWithDisplayName:displayName];
    self.sessionHelper.delegate = self;
}

@end
