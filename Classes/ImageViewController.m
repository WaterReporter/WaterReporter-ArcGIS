// Copyright 2012 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//

#import "ImageViewController.h"


@implementation ImageViewController

@synthesize image = _image;
@synthesize imageView = _imageView;

-(id)initWithImage:(UIImage*)image{
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"ImageViewController: initWithImage");
    
	if (self = [super init]){
		self.image = image;
	}
	return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"ImageViewController: viewDidLoad");
    
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.imageView.image = self.image;
	UIScrollView *sv = (UIScrollView*)self.view;
	sv.contentSize = self.imageView.frame.size;
	
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"ImageViewController: didReceiveMemoryWarning");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"ImageViewController: viewDidUnload");
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"ImageViewController: dealloc");
    
	self.image = nil;
	self.imageView = nil;
    [super dealloc];
}


@end
