//
//  AppDelegate.m
//  KeyFixer
//
//  Created by Chris Galzerano on 12/24/19.
//  Copyright © 2019 playr. All rights reserved.
//

#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate {
    double minKeyRepeatRate;
    NSString *glitchedKey2;
}

static NSString *glitchedKey;
static BOOL hasPressed;
static double minimumKeyRepeatRate;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    minKeyRepeatRate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"minimumKeyRepeatRate"] doubleValue];
    glitchedKey2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"glitchedKey"];
    glitchedKey = glitchedKey2;
    minimumKeyRepeatRate = minKeyRepeatRate;
    
    _keyField.stringValue = glitchedKey2;
    _durationField.stringValue = [NSString stringWithFormat:@"%.02f", minimumKeyRepeatRate];
    
    [self beginLoop];
    
}

- (IBAction)saveSettings:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:_durationField.doubleValue] forKey:@"minimumKeyRepeatRate"];
    [[NSUserDefaults standardUserDefaults] setObject:_keyField.stringValue forKey:@"glitchedKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

CGEventRef loggerCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void* context)
{
    if (type == kCGEventKeyDown) {
        UniChar str[10];
        UniCharCount strLength;
        CGEventKeyboardGetUnicodeString(event, 10, &strLength, str);
        NSString *keyString = [NSString stringWithFormat: @"%C", str[0]];
        if ([keyString isEqualToString:glitchedKey]) {
            if (hasPressed) {
                CGEventRef a = CGEventCreateKeyboardEvent(NULL, 51, true);
                CGEventRef b = CGEventCreateKeyboardEvent(NULL, 51, false);
                CGEventPost(kCGHIDEventTap, a);
                CGEventPost(kCGHIDEventTap, b);
            }
            hasPressed = YES;
            [NSTimer scheduledTimerWithTimeInterval:minimumKeyRepeatRate repeats:NO block:^(NSTimer * _Nonnull timer) {
                hasPressed = NO;
            }];
        }
    }
    return event;
}

- (void)beginLoop {
    CFMachPortRef tap = CGEventTapCreate(kCGHIDEventTap,
                                              kCGHeadInsertEventTap,
                                              0, kCGEventMaskForAllEvents,
                                              loggerCallback, NULL);
    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(tap, true);
    CFRunLoopRun();
}

@end
