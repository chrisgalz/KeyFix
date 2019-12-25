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
    NSArray *glitchedKeys;
}

static NSArray *glitchedKeys2;
static NSMutableDictionary *hasPressedDict;
static double minimumKeyRepeatRate;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    minKeyRepeatRate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"minimumKeyRepeatRate"] doubleValue];
    glitchedKeys2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"glitchedKeys"];
    minimumKeyRepeatRate = minKeyRepeatRate;
    
    [self process];
    [self beginLoop];
}

- (IBAction)saveSettings:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:_durationField.doubleValue] forKey:@"minimumKeyRepeatRate"];
    [[NSUserDefaults standardUserDefaults] setObject:[_keyField.stringValue componentsSeparatedByString:@","] forKey:@"glitchedKeys"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self process];
}

- (void)process {
    hasPressedDict = [NSMutableDictionary new];
    for (NSString *key in glitchedKeys2) {
        [hasPressedDict setObject:@NO forKey:key];
    }
    _keyField.stringValue = [glitchedKeys2 componentsJoinedByString:@","];
    _durationField.stringValue = [NSString stringWithFormat:@"%.02f", minimumKeyRepeatRate];
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
        if ([glitchedKeys2 containsObject:keyString]) {
            if ([AppDelegate hasPressedForKey:keyString]) {
                CGEventRef a = CGEventCreateKeyboardEvent(NULL, 51, true);
                CGEventRef b = CGEventCreateKeyboardEvent(NULL, 51, false);
                CGEventPost(kCGHIDEventTap, a);
                CGEventPost(kCGHIDEventTap, b);
            }
            [AppDelegate setHasPressedForKey:keyString];
        }
    }
    return event;
}

+ (BOOL)hasPressedForKey:(NSString*)key {
    return [[hasPressedDict objectForKey:key] boolValue];
}

+ (void)setHasPressedForKey:(NSString*)key {
    [hasPressedDict setObject:@YES forKey:key];
    if (@available(macOS 10.12, *)) {
        [NSTimer scheduledTimerWithTimeInterval:minimumKeyRepeatRate repeats:NO block:^(NSTimer * _Nonnull timer) {
            [self setHasNotPressedForKey:key];
        }];
    }
}

+ (void)setHasNotPressedForKey:(NSString*)key {
    [hasPressedDict setObject:@NO forKey:key];
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
