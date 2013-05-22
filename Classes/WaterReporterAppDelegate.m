/**
 * Water Reporter
 *
 * Created by Viable Industries L.L.C. in March 2013.
 * Copyright (c) 2013 Viable Industries L.L.C. All rights reserved.
 *
 */

#import "WaterReporterAppDelegate.h"
#import "WaterReporterViewController.h"

@implementation WaterReporterAppDelegate

@synthesize viewController;
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterAppDelegate:didFinishLaunchingWithOptions");
    
    // Add the view controller's view to the window and display.
    [window setRootViewController:viewController];
    [window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterAppDelegate:applicationWillResignActive");
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterAppDelegate:applicationDidEnterBackground");
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterAppDelegate:applicationWillEnterForeground");
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterAppDelegate:applicationDidBecomeActive");
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterAppDelegate:applicationWillTerminate");
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterAppDelegate:applicationDidReceiveMemoryWarning");

}

- (void)dealloc {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterAppDelegate: dealloc");
    
    [viewController release];
    [window release];
    [super dealloc];
}


@end
