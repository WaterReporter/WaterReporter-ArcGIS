/**
 * Water Reporter
 *
 * Created by Viable Industries L.L.C. in March 2013.
 * Copyright (c) 2013 Viable Industries L.L.C. All rights reserved.
 *
 */

#import "FeatureTemplatePickerViewController.h"

@implementation FeatureTemplatePickerViewController
@synthesize featureTemplatesTableView = _featureTemplatesTableView;
@synthesize delegate = _delegate;
@synthesize infos = _infos;

- (void)viewDidLoad {

    [super viewDidLoad];

    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureTemplatePickerViewController:viewDidLoad");

    UIBarButtonItem *cancel = [[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)]autorelease];
    self.navigationItem.leftBarButtonItem = cancel;
    
    self.navigationItem.title = @"Choose Type";

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureTemplatePickerViewController:viewWillAppear");
	
	[self.tableView reloadData];
	NSDictionary* attributes = [self.feature allAttributes];
	self.navigationItem.rightBarButtonItem.enabled = (attributes!=nil && [attributes count]>0);
}

- (void) addTemplatesFromLayer:(AGSFeatureLayer*)layer {

    //Instantiate the array to hold all templates from this layer
    if(!self.infos) {
        self.infos = [[NSMutableArray alloc] init];
    }
    
    //If layer contains only templates (no feature types)
    if (layer.templates!=nil && [layer.templates count]>0) {
        //For each template that is available, at it to the list.
        for (AGSFeatureTemplate* template in layer.templates) {

            if ([template.name isEqualToString:@"Pollution Report"] || [template.name isEqualToString:@"River Event Report"]) {
                FeatureTemplatePickerInfo* info = [[FeatureTemplatePickerInfo alloc] init];
                info.featureLayer = layer;
                info.featureTemplate = template;
                info.featureType = nil;

                //Add to array
                [self.infos addObject:info];
                NSLog(@"%@", template.name);
            }
        }
    //Otherwise, if layer contains feature types
    } else {
        //For each type
        for (AGSFeatureType* type in layer.types) {
            //For each template in type
            for (AGSFeatureTemplate* template in type.templates) {
                               
                if ([template.name isEqualToString:@"Pollution Report"] || [template.name isEqualToString:@"River Event Report"]) {
                    FeatureTemplatePickerInfo* info =
                    [[FeatureTemplatePickerInfo alloc] init];
                    info.featureLayer = layer;
                    info.featureTemplate = template;
                    info.featureType = type;
                   
                    //Add to  array
                    [self.infos addObject:info];
                }
            }
        }
    }
    
}

-(void)cancel{
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController:cancel");
    
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureTemplatePickerViewController:tableView:willDisplayCell");
    
    
	
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        
        /**
         * Replace the default pinstripe background with our new linen pattern
         */
        UIView* backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundDefault.png"]];
        [tableView setBackgroundView:backgroundView];        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureTemplatePickerViewController:tableView:numberOfSectionsInTableView");

    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureTemplatePickerViewController:tableView:titleForHeaderInSection");

    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureTemplatePickerViewController:tableView:numberOfRowsInSection");
    
    return [self.infos count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 0.0;
//}
//
// This controls the appearance of the individual rows of the "Add your data" view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureTemplatePickerViewController:tableView:cellForRowAtIndexPath");
    
    //Get a cell
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

    /**
     * Remove the separators between cells in the tableView
     */
    tableView.layer.cornerRadius = 0.0;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor clearColor];
    
    /**
     * Set the label, image, etc for the templates
     */
    FeatureTemplatePickerInfo* info = [self.infos objectAtIndex:indexPath.row];    
    cell.textLabel.font = [UIFont fontWithName:@"MuseoSlab-500" size:16.0];
    
	cell.textLabel.text = info.featureTemplate.name;
    cell.imageView.image =[ info.featureLayer.renderer swatchForGraphic:info.featureTemplate.prototype geometryType:info.featureLayer.geometryType size:CGSizeMake(50, 50)];
	
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    /**
     * Now that we're finished putting our cells together,
     * filling them with content, and styling them, we need
     * to return an object that can be used
     */
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
/**
 * Display the Feature Template/Form to the user
 *
 * This is the method that responds to the user tapping on one of
 * the available editable Feature types. Once tapped the user will
 * be shown the TableView with the form fields necessary to complete their form.
 *
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Notify the delegate that the user picked a feature template
    if ([self.delegate respondsToSelector:@selector(featureTemplatePickerViewController:didSelectFeatureTemplate:forFeatureLayer:)]){
              
        FeatureTemplatePickerInfo* info = [self.infos objectAtIndex:indexPath.row];
        [self.delegate featureTemplatePickerViewController:self didSelectFeatureTemplate:info.featureTemplate forFeatureLayer:info.featureLayer];
        
        NSLog(@"Template selected");
    }
    
    //Unselect the cell
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
    
    
}

#pragma mark Action sheet delegate methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: clickedButtonAtIndex");
	
	if (buttonIndex == actionSheet.cancelButtonIndex){
		// cancel
	}
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.featureTemplatesTableView = nil;
    self.delegate = nil;
    
}


@end

@implementation FeatureTemplatePickerInfo

@synthesize featureType = _featureType;
@synthesize featureTemplate = _featureTemplate;
@synthesize featureLayer = _featureLayer;

@end
