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
    //[self presentViewController:self.featureTemplatePickerViewController animated:YES completion:nil];
    //[self.navigationController pushViewController:self.featureTemplatePickerViewController animated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"TutorialViewController:viewDidLoad");

    // TODO – fill with your photos
    NSArray *photos = [[NSArray arrayWithObjects:
                        [UIImage imageNamed:@"slide002-ChooseYourReport"],
                        [UIImage imageNamed:@"slide003-TellUsMore"],
                        [UIImage imageNamed:@"slide004-PhotoVideo"],
                        [UIImage imageNamed:@"slide005-Save"],
                        [UIImage imageNamed:@"slide006-Copyright"],
                        nil] retain];
    
    int i = 0;
    for (NSString *image in photos) {
        
        UIImage *images = [photos objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:images];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        
        CGRect frame;
        frame.origin.x = self.tutorialView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.tutorialView.frame.size;

        imageView.frame = frame;
        
        NSLog(@"%@", [photos objectAtIndex:i]);

        [self.tutorialView addSubview:imageView];
        [imageView release];
    }
    self.tutorialView.contentSize = CGSizeMake(self.tutorialView.frame.size.width * photos.count, self.tutorialView.frame.size.height);
    self.tutorialView.delegate = self;
    
    NSLog(@"Showing the tutorial");
    
    [self.tutorialView release];
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
