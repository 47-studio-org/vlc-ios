/*****************************************************************************
 * VLCOneDriveTableViewController.h
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2014 VideoLAN. All rights reserved.
 * $Id$
 *
 * Authors: Felix Paul Kühne <fkuehne # videolan.org>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#if TARGET_OS_IOS
#import "VLCCloudStorageTableViewController.h"

@interface VLCOneDriveTableViewController : VLCCloudStorageTableViewController

@end

#else
#import "VLCCloudStorageTVTableViewController.h"

@interface VLCOneDriveTableViewController : VLCCloudStorageTVTableViewController

@end

#endif
