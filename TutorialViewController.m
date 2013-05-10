//
//  TutorialViewController.m
//  WaterReporter
//
//  Created by viableindustries on 5/9/13.
//
//

#import "TutorialViewController.h"

@implementation TutorialViewController

@synthesize tutorialView;
@synthesize featureTemplatePickerViewController = _featureTemplatePickerViewController;

- (IBAction) dismissTutorialViewController {
    [self dismissViewControllerAnimated:NO completion:nil];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
}

- (IBAction) presentFeatureTemplatePickerViewController {
    [self presentViewController:self.featureTemplatePickerViewController animated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"TutorialViewController:viewDidLoad");

    NSArray *colors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], [UIColor blueColor], nil];
    for (int i = 0; i < colors.count; i++) {
        CGRect frame;
        frame.origin.x = self.tutorialView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.tutorialView.frame.size;
        
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        subview.backgroundColor = [colors objectAtIndex:i];
        [self.tutorialView addSubview:subview];
        [subview release];
    }
    
    self.tutorialView.contentSize = CGSizeMake(self.tutorialView.frame.size.width * colors.count, self.tutorialView.frame.size.height);

    //self.tutorialView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundTutorial@2x.png"]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"TutorialViewController:didReceiveMemoryWarning");
    
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"TutorialViewController:viewDidUnload");
    
    self.tutorialView = nil;
}

- (void)dealloc {
    [tutorialView release];
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"TutorialViewController:dealloc");
    
    [super dealloc];
}

@end
