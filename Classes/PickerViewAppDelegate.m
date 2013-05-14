//
//  PickerViewAppDelegate.m
//  PickerView
//
//  Created by iPhone SDK Articles on 1/24/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import "PickerViewAppDelegate.h"
#import "PickerViewController.h"

@implementation PickerViewAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	pvController = [[PickerViewController alloc] initWithNibName:@"PickerView" bundle:[NSBundle mainBundle]];
	
	[window addSubview:pvController.view];
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
	[pvController release];
    [window release];
    [super dealloc];
}


@end
