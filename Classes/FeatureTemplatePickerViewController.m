/**
 * Water Reporter
 *
 * Created by Viable Industries L.L.C. in March 2013.
 * Copyright (c) 2013 Viable Industries L.L.C. All rights reserved.
 *
 */

#import "FeatureTemplatePickerViewController.h"
#import "WaterReporterViewController.h"

#define DEFAULT_TEXT_COLOR [UIColor colorWithRed:46.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0]
#define DEFAULT_LABEL_COLOR [UIColor colorWithRed:181.0/255.0 green:181.0/255.0 blue:181.0/255.0 alpha:1.0]
#define DEFAULT_BODY_FONT [UIFont fontWithName:@"Helvetica-Bold" size:13.0]
#define DEFAULT_TITLE_FONT [UIFont fontWithName:@"MuseoSlab-500" size:15.0]
#define DEFAULT_LABEL_FONT [UIFont fontWithName:@"MuseoSlab-500" size:16.0]
#define BACKGROUND_LINEN_LIGHT [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundDefault"]]
#define ACTIVITY_REPORT_FEATURE_LAYER @"Activity Report"
#define POLLUTION_REPORT_FEATURE_LAYER @"Pollution Report"

@implementation FeatureTemplatePickerViewController

@synthesize cachedFeatureLayerTemplates;

@synthesize curatedMapViewController = _curatedMapViewController;

@synthesize featureTemplatesTableView = _featureTemplatesTableView;
@synthesize delegate = _delegate;
@synthesize infos = _infos;
@synthesize curatedMapActivated = _curatedMapActivated;

- (void)viewDidLoad {

    [super viewDidLoad];

    UIBarButtonItem *cancel = [[[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)]autorelease];
    self.navigationItem.leftBarButtonItem = cancel;
    
    /**
     * Initialize the curated map view so that we can show it later when needed
     */
    self.curatedMapViewController =  [[[CuratedMapViewController alloc] initWithNibName:@"CuratedMapViewController" bundle:nil] autorelease];
    
    self.navigationItem.title = @"Choose Report";
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
	
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

            if ([template.name isEqualToString:POLLUTION_REPORT_FEATURE_LAYER] || [template.name isEqualToString:ACTIVITY_REPORT_FEATURE_LAYER]) {
                FeatureTemplatePickerInfo* info = [[FeatureTemplatePickerInfo alloc] init];
                info.featureLayer = layer;
                info.featureTemplate = template;
                info.featureType = nil;

                //Add to array
                [self.infos addObject:info];
                [info release];
            }
        }
    //Otherwise, if layer contains feature types
    } else {
        //For each type
        for (AGSFeatureType* type in layer.types) {
            //For each template in type
            for (AGSFeatureTemplate* template in type.templates) {
                               
                if ([template.name isEqualToString:POLLUTION_REPORT_FEATURE_LAYER] || [template.name isEqualToString:ACTIVITY_REPORT_FEATURE_LAYER]) {
                    FeatureTemplatePickerInfo* info =
                    [[FeatureTemplatePickerInfo alloc] init];
                    info.featureLayer = layer;
                    info.featureTemplate = template;
                    info.featureType = type;
                   
                    //Add to  array
                    [self.infos addObject:info];
                    [info release];
                }
            }
        }
    }
}

-(void)cancel{
    
    /**
     * If we are using the Feature Template Picker that was
     * loaded by the curated map, then all we need to do is 
     * pop the view controller.
     */
    if (self.curatedMapActivated) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    /**
     * But if we are using the Feature Template Picker that was
     * loaded by the Tutorial/Root View Controller, then we
     * need to load the curated map view controller.
     */
    else {
        // Display the modal ... see FeatureTemplatePickerViewController.xib for layout
        self.curatedMapViewController.cachedFeatureLayerTemplates = self.cachedFeatureLayerTemplates;
        self.curatedMapViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.navigationController pushViewController:self.curatedMapViewController animated:YES];
        self.curatedMapActivated = YES;
    }
    
}

#pragma mark -
#pragma mark UITableViewDataSource

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        
        /**
         * Replace the default pinstripe background with our new linen pattern
         */
        UIView* backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundDefault"]];
        [tableView setBackgroundView:backgroundView];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"What would you like to report?";
}

/**
 * Implements viewForHeaderInSection:(NSInteger)section
 *
 * Set the properties for the Header of each section so
 * they display consistently.
 *
 * @param NSInteger
 *   The ID of the table view section
 *
 * @return view
 *   The View to be render later in the table view
 *
 */
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 8, 280, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = DEFAULT_TEXT_COLOR;
    label.shadowColor = [UIColor clearColor];
    label.font = DEFAULT_LABEL_FONT;
    label.text = sectionTitle;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];

    /**
     * Review the Tutorial/How-To
     */
    UIButton *buttonDisplayTutorial = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonDisplayTutorial.frame = CGRectMake(10, 0, (tableView.frame.size.width-20), 44);
    buttonDisplayTutorial.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"buttonTutorial"]];

    buttonDisplayTutorial.userInteractionEnabled = YES;
    [buttonDisplayTutorial addTarget:self action:@selector(presentTutorialViewController) forControlEvents:UIControlEventAllEvents];
    [buttonDisplayTutorial setTitle:@"\n\n\n" forState:UIControlStateNormal];
    [buttonDisplayTutorial setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    buttonDisplayTutorial.titleLabel.font = DEFAULT_BODY_FONT;
    buttonDisplayTutorial.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;

    [view addSubview:buttonDisplayTutorial];
    
    return [view autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 80;
}

/**
 * Add a new feature
 *
 * The action for the "+" button that allows
 * the user to select what kind of Feature
 * they would like to add to the map
 *
 */
-(void)presentTutorialViewController {
    // Display the modal ... see FeatureTemplatePickerViewController.xib for layout
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.infos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    cell.textLabel.textColor = DEFAULT_TEXT_COLOR;
    cell.textLabel.font = DEFAULT_TITLE_FONT;
    
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
        
    }
    
    //Unselect the cell
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
    
}

#pragma mark Action sheet delegate methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == actionSheet.cancelButtonIndex){
		// cancel
	}
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {    

    self.curatedMapViewController = nil;
    self.cachedFeatureLayerTemplates = nil;
	self.featureTemplatesTableView = nil;
    self.curatedMapViewController = nil;
    self.delegate = nil;
    self.infos = nil;

    [super viewDidUnload];
}

- (void)dealloc {    

    self.curatedMapViewController = nil;
    self.cachedFeatureLayerTemplates = nil;
	self.featureTemplatesTableView = nil;
    self.curatedMapViewController = nil;
    self.delegate = nil;
    self.infos = nil;

    [super dealloc];
}


@end

@implementation FeatureTemplatePickerInfo

@synthesize featureType = _featureType;
@synthesize featureTemplate = _featureTemplate;
@synthesize featureLayer = _featureLayer;

- (void)dealloc {
    
    self.featureLayer = nil;
	self.featureType = nil;
    self.featureTemplate = nil;

    [super dealloc];
}

@end
