//
//  BlueJet.h
//  BlueJet
//
//  Created by Przemyslaw Bobak on 13/07/2017.
//  Copyright © 2017 Spirograph Limited. All rights reserved.
//

#if !SWIFT_PACKAGE
#ifdef __APPLE__
#include "TargetConditionals.h"
#if TARGET_OS_IPHONE
// iOS
#import <UIKit/UIKit.h>
#elif TARGET_IPHONE_SIMULATOR
// iOS Simulator
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
// Other kinds of macOS
#include <Cocoa/Cocoa.h>
#else
// Unsupported platform
#endif
#endif
#endif

//! Project version number for BlueJet.
FOUNDATION_EXPORT double BlueJetVersionNumber;

//! Project version string for BlueJet.
FOUNDATION_EXPORT const unsigned char BlueJetVersionString[];

// Workaround for the following issue:
// https://github.com/agisboye/SwiftLMDB/issues/4
#define MDB_USE_POSIX_SEM 1

#import "lmdb.h"
