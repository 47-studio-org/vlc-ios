/*****************************************************************************
 * VLCEqualizerView.h
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2015 VideoLAN. All rights reserved.
 * $Id$
 *
 * Authors: Felix Paul Kühne <fkuehne # videolan dot org>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#import <UIKit/UIKit.h>
#import "VLCFrostedGlasView.h"

@protocol VLCEqualizerViewDelegate <NSObject>

@required
@property (readwrite) CGFloat preAmplification;
- (void)setAmplification:(CGFloat)amplification forBand:(unsigned)index;
- (CGFloat)amplificationOfBand:(unsigned)index;
- (NSArray *)equalizerProfiles;
- (void)resetEqualizerFromProfile:(unsigned)profile;

@end

@interface VLCEqualizerView : VLCFrostedGlasView

@property (weak) id <VLCEqualizerViewDelegate>delegate;

- (void)reloadData;

@end
