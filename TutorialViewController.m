//
//  TutorialViewController.m
//  WaterReporter
//
//  Created by viableindustries on 5/9/13.
//
//

#import "TutorialViewController.h"

@implementation TutorialViewController

@synthesize tutorialView = _tutorialView;
@synthesize pageControl = _pageControl;

- (IBAction) dismissTutorialViewController {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction) presentFeatureTemplatePickerViewController {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
//    FeatureTemplatePickerViewController *featureTemplatePickerViewController = [[[FeatureTemplatePickerViewController alloc] init] autorelease];
//    self.featureTemplatePickerViewController = featureTemplatePickerViewController;
//    
//    [self.navigationController pushViewController:self.featureTemplatePickerViewController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"TutorialViewController:viewDidLoad");


    [self setupScrollView];
}

-(void) setupScrollView {

    //add the scrollview to the view
    self.tutorialView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -45, self.view.frame.size.width, (self.view.frame.size.height - 145))];
    self.tutorialView.contentSize = CGSizeMake(self.tutorialView.contentSize.width,self.tutorialView.frame.size.height);
    self.tutorialView.pagingEnabled = YES;
    self.tutorialView.delegate = self;
    [self.tutorialView setAlwaysBounceVertical:NO];

    //setup internal views
    NSInteger numberOfViews = 6;
    for (int i = 0; i < numberOfViews; i++) {
        CGFloat xOrigin = i * self.view.frame.size.width;
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.view.frame.size.width, self.view.frame.size.height)];
        image.image = [UIImage imageNamed:[NSString stringWithFormat:@"slide_%d", i+1]];
        image.contentMode = UIViewContentModeScaleAspectFit;
        [self.tutorialView addSubview:image];
    }
    //set the scroll view content size
    self.tutorialView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfViews, self.view.frame.size.height);
    [self.tutorialView setShowsHorizontalScrollIndicator:NO];
    [self.tutorialView setShowsVerticalScrollIndicator:NO];

    //add the scrollview to this view
    [self.view addSubview:self.tutorialView];
    
    [self.view insertSubview:self.tutorialView belowSubview:self.pageControl];
    
    self.pageControl = [[[UIPageControl alloc] init] autorelease];
    self.pageControl.frame = CGRectMake(((self.view.frame.size.width-100)/2),(self.view.frame.size.height-185),100,50);
    self.pageControl.numberOfPages = 6;
    self.pageControl.currentPage = 0;
    
    [self.view addSubview:self.pageControl];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.tutorialView.frame.size.width;
    float fractionalPage = self.tutorialView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
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
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"TutorialViewController:dealloc");
    
    self.tutorialView = nil;

    [super dealloc];
}

@end
