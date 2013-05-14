//
//  PickerViewAppDelegate.h
//  PickerView
//
//  Created by iPhone SDK Articles on 1/24/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import <UIKit/UIKit.h>

@class PickerViewController;

@interface PickerViewAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	PickerViewController *pvController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

