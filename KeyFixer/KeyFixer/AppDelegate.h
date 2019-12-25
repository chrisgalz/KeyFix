//
//  AppDelegate.h
//  KeyFixer
//
//  Created by Chris Galzerano on 12/24/19.
//  Copyright © 2019 playr. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) IBOutlet NSTextField *keyField;
@property (nonatomic, strong) IBOutlet NSTextField *durationField;

- (IBAction)saveSettings:(id)sender;

@end

