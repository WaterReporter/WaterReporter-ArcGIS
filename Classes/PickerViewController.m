//
//  PickerViewController.m
//  PickerView
//
//  Created by iPhone SDK Articles on 1/24/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import "PickerViewController.h"


@implementation PickerViewController


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	arrayColors = [[NSMutableArray alloc] init];
	[arrayColors addObject:@"Red"];
	[arrayColors addObject:@"Orange"];
	[arrayColors addObject:@"Yellow"];
	[arrayColors addObject:@"Green"];
	[arrayColors addObject:@"Blue"];
	[arrayColors addObject:@"Indigo"];
	[arrayColors addObject:@"Violet"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[arrayColors release];
    [super dealloc];
}

#pragma mark -
#pragma mark Picker View Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	
	return [arrayColors count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	return [arrayColors objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayColors objectAtIndex:row], row);
}

@end
