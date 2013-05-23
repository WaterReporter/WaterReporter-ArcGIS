//
//  PopupViewController.m
//  WaterReporter
//
//  Created by Joshua Powell on 5/22/13.
//
//

#import "PopupViewController.h"
#import "CodedValueUtility.h"

@implementation PopupViewController

@synthesize feature = _feature;
@synthesize featureLayer = _featureLayer;

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"PopupViewController:viewDidLoad");

}

-(id)initWithExistingFeature:(AGSGraphic *)feature {

    /**
     * Replace the default pinstripe background with our new linen pattern
     */
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundDefault"]];
    
    self.feature = feature;
    
    NSDictionary *attributes = [self.feature allAttributes];
    
    NSLog(@"Popup Details: %@", attributes);
        
    [self.view addSubview:backgroundView];
    
    /**
     * Display the first image to the users
     */
    UIImage *mainImage = [UIImage imageWithContentsOfFile:[attributes objectForKey:@"image1"]];
    
    UIImageView *mainImageView = [[UIImageView alloc] initWithImage:mainImage];

    [mainImageView setImage:mainImage];
    [backgroundView addSubview:mainImageView];
    
    return self;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}

@end
