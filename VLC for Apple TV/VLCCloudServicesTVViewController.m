/*****************************************************************************
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2015 VideoLAN. All rights reserved.
 * $Id$
 *
 * Authors: Felix Paul Kühne <fkuehne # videolan.org>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#import "VLCCloudServicesTVViewController.h"
#import <DropboxTVSDK/DropboxSDK.h>
#import "VLCDropboxController.h"
#import "VLCDropboxTableViewController.h"
#import "SSKeychain.h"
#import "VLCPlayerDisplayController.h"
#import "VLCOneDriveController.h"
#import "VLCOneDriveTableViewController2.h"
#import "VLCBoxTableViewController.h"
#import "VLCBoxController.h"

@interface VLCCloudServicesTVViewController ()
{
    VLCOneDriveController *_oneDriveController;
    VLCBoxController *_boxController;
}
@end

@implementation VLCCloudServicesTVViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(oneDriveSessionUpdated:) name:VLCOneDriveControllerSessionUpdated object:nil];
    [center addObserver:self selector:@selector(boxSessionUpdated:) name:VLCBoxControllerSessionUpdated object:nil];

    _oneDriveController = [VLCOneDriveController sharedInstance];
    _boxController = [VLCBoxController sharedInstance];
    [_boxController startSession];

    self.dropboxButton.enabled = self.gDriveButton.enabled = NO;
    [self oneDriveSessionUpdated:nil];
    [self boxSessionUpdated:nil];

    [self performSelector:@selector(updateDropbox) withObject:nil afterDelay:0.1];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)title
{
    return NSLocalizedString(@"CLOUD_SERVICES", nil);
}

- (IBAction)dropbox:(id)sender
{
    VLCDropboxTableViewController *targetViewController = [[VLCDropboxTableViewController alloc] initWithPath:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

- (void)updateDropbox
{
    self.dropboxButton.enabled = [[VLCDropboxController sharedInstance] restoreFromSharedCredentials];
}

- (void)oneDriveSessionUpdated:(NSNotification *)aNotification
{
    self.oneDriveButton.enabled = _oneDriveController.activeSession;
}

- (void)boxSessionUpdated:(NSNotification *)aNotification
{
    self.boxButton.enabled = YES;
}

- (IBAction)onedrive:(id)sender
{
    VLCOneDriveTableViewController2 *newKid = [[VLCOneDriveTableViewController2 alloc] initWithOneDriveObject:nil];
    [self.navigationController pushViewController:newKid animated:YES];
}

- (IBAction)box:(id)sender
{
    VLCBoxTableViewController *targetViewController = [[VLCBoxTableViewController alloc] initWithPath:@""];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

- (IBAction)gdrive:(id)sender
{
    // TODO
}

@end
