//
//  main.m
//  KeyFixer
//
//  Created by Chris Galzerano on 12/24/19.
//  Copyright © 2019 playr. All rights reserved.
//
//  Based on code from https://gist.github.com/indragiek/4166038
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>
#import <ApplicationServices/ApplicationServices.h>
#include <stdio.h>

const double minimumKeyRepeatRate = 0.3;
NSString *glitchedKey = @"b";

static BOOL hasPressed;

CGEventRef loggerCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void* context)
{
    if (type == kCGEventKeyDown) {
        UniChar str[10];
        UniCharCount strLength;
        CGEventKeyboardGetUnicodeString(event, 10, &strLength, str);
        NSString *keyString = [NSString stringWithFormat: @"%C", str[0]];
        if ([keyString isEqualToString:glitchedKey]) {
            if (hasPressed) {
                //Send backspace event
                NSLog(@"should backspace");
                NSAppleScript* appleScript = [[NSAppleScript alloc] initWithSource:
                    @"tell application \"System Events\""
                    "key code 51"
                    "end tell"];
                [appleScript executeAndReturnError:nil];
            }
            hasPressed = YES;
            [NSTimer scheduledTimerWithTimeInterval:minimumKeyRepeatRate repeats:NO block:^(NSTimer * _Nonnull timer) {
                hasPressed = NO;
            }];
        }
    }
    return event;
}

int main(int argc, const char * argv[])
{
    CFMachPortRef tap = CGEventTapCreate(kCGHIDEventTap,
                                              kCGHeadInsertEventTap,
                                              0, kCGEventMaskForAllEvents,
                                              loggerCallback, NULL);
    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(tap, true);
    CFRunLoopRun();

    return 0;
}
