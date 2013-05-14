//
//  PickerViewController.h
//  PickerView
//
//  Created by iPhone SDK Articles on 1/24/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import <UIKit/UIKit.h>

@interface PickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
	
	IBOutlet UIPickerView *pickerView;
	NSMutableArray *arrayColors;
}

@end
