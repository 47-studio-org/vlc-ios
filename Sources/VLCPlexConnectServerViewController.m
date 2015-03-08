/*****************************************************************************
 * VLCPlexConnectServerViewController.m
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2015 VideoLAN. All rights reserved.
 *
 * Authors: Felix Paul Kühne <fkuehne # videolan.org>
 *          Pierre SAGASPE <pierre.sagaspe # me.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#import "VLCPlexConnectServerViewController.h"
#import "VLCLocalPlexFolderListViewController.h"
#import "UIBarButtonItem+Theme.h"

#define kPlexMediaServerPortDefault @"32400"

@interface VLCPlexConnectServerViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSMutableArray *_bookmarkServer;
    NSMutableArray *_bookmarkPort;
}
@end

@implementation VLCPlexConnectServerViewController

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *loginDefaults = @{kVLCPLEXServer : @[], kVLCPLEXPort : @[]};
    [defaults registerDefaults:loginDefaults];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Plex Media Server";
    [self.connectButton setTitle:NSLocalizedString(@"BUTTON_CONNECT", nil) forState:UIControlStateNormal];
    self.serverAddressHelpLabel.text = NSLocalizedString(@"ENTER_SERVER_ADDRESS_HELP", nil);
    self.serverAddressLabel.text = NSLocalizedString(@"SERVER", nil);
    self.portLabel.text = NSLocalizedString(@"SERVER_PORT", nil);
    self.bookmarkLabel.text = NSLocalizedString(@"BOOKMARK", nil);

    self.serverAddressField.delegate = self;
    self.serverAddressField.returnKeyType = UIReturnKeyNext;
    self.serverAddressField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.serverAddressField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.portField.delegate = self;
    self.portField.returnKeyType = UIReturnKeyDone;
    self.portField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.portField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;

    self.serverPlexBookmark.backgroundColor = [UIColor VLCDarkBackgroundColor];

    if (SYSTEM_RUNS_IOS7_OR_LATER) {
        UIColor *color = [UIColor VLCLightTextColor];
        self.serverAddressField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"192.168.0.0" attributes:@{NSForegroundColorAttributeName: color}];
        self.portField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kPlexMediaServerPortDefault attributes:@{NSForegroundColorAttributeName: color}];

        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _bookmarkServer = [NSMutableArray arrayWithArray:[defaults objectForKey:kVLCPLEXServer]];
    _bookmarkPort = [NSMutableArray arrayWithArray:[defaults objectForKey:kVLCPLEXPort]];

    [super viewWillAppear:animated];

    if ([defaults stringForKey:kVLCLastPLEXServer])
        self.serverAddressField.text = [defaults stringForKey:kVLCLastPLEXServer];
    if ([defaults stringForKey:kVLCLastPLEXPort])
        self.portField.text = [defaults stringForKey:kVLCLastPLEXPort];

    if (self.portField.text.length < 1)
        self.portField.text = kPlexMediaServerPortDefault;
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.serverAddressField.text forKey:kVLCLastPLEXServer];
    [defaults setObject:self.portField.text forKey:kVLCLastPLEXPort];

    [super viewWillDisappear:animated];
}

#pragma mark - IBAction

- (IBAction)connectToServer:(id)sender
{
    NSString *server = [NSString stringWithFormat:@"%@", self.serverAddressField.text];
    NSString *port = [NSString stringWithFormat:@":%@", self.portField.text];

    if (![port isEqualToString:@":"] && ![server isEqualToString:@""]) {
        VLCLocalPlexFolderListViewController *targetViewController = [[VLCLocalPlexFolderListViewController alloc] initWithPlexServer:server serverAddress:server portNumber:port atPath:@""];
        [[self navigationController] pushViewController:targetViewController animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"INVALID_IP_PORT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"BUTTON_OK", nil) otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)savePlexServer:(id)sender
{
    if (![self.serverAddressField.text isEqualToString:@""] && ![self.portField.text isEqualToString:@""]) {
        [_bookmarkServer addObject:self.serverAddressField.text];
        [_bookmarkPort addObject:self.portField.text];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSArray arrayWithArray:_bookmarkServer] forKey:kVLCPLEXServer];
        [defaults setObject:[NSArray arrayWithArray:_bookmarkPort] forKey:kVLCPLEXPort];
        [defaults synchronize];
        [self.serverPlexBookmark reloadData];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"INVALID_IP_PORT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"BUTTON_OK", nil) otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - text view delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.serverAddressField isFirstResponder]) {
        [self.serverAddressField resignFirstResponder];
        [self.portField becomeFirstResponder];
    } else if ([self.portField isFirstResponder]) {
        [self.portField resignFirstResponder];
    }
    return NO;
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _bookmarkServer.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PLEXbookmarkCell";

    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor VLCLightTextColor];
    }

    NSInteger row = indexPath.row;
    cell.textLabel.text = _bookmarkServer[row];
    cell.detailTextLabel.text = _bookmarkPort[row];

    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = (indexPath.row % 2 == 0)? [UIColor blackColor]: [UIColor VLCDarkBackgroundColor];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_bookmarkServer removeObjectAtIndex:indexPath.row];
        [_bookmarkPort removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSArray arrayWithArray:_bookmarkServer] forKey:kVLCPLEXServer];
        [defaults setObject:[NSArray arrayWithArray:_bookmarkPort] forKey:kVLCPLEXPort];
        [defaults synchronize];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.serverAddressField setText:_bookmarkServer[indexPath.row]];
    [self.portField setText:_bookmarkPort[indexPath.row]];

    [self.serverPlexBookmark deselectRowAtIndexPath:indexPath animated:NO];
}

@end