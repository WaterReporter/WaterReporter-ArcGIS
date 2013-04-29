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
    
    UIBarButtonItem *commit = [[[UIBarButtonItem alloc]initWithTitle:@"Commit" style:UIBarButtonItemStylePlain target:self action:@selector(commit)]autorelease];
    self.navigationItem.rightBarButtonItem = commit;
    
    self.navigationItem.title = @"New Report";

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
    if(!self.infos)
        self.infos = [[NSMutableArray alloc] init];
    
    //If layer contains only templates (no feature types)
    if (layer.templates!=nil && [layer.templates count]>0) {
        
        
        
        //For each template
        for (AGSFeatureTemplate* template in layer.templates) {

            if ([template.name isEqualToString:@"Pollution Report"] || [template.name isEqualToString:@"River Event Report"]) {
                FeatureTemplatePickerInfo* info = [[FeatureTemplatePickerInfo alloc] init];
                info.featureLayer = layer;
                info.featureTemplate = template;
                info.featureType = nil;

                //Add to array
                [self.infos addObject:info];
                NSLog(@">>%@", template.name);
            } else {
                NSLog(@"%@ is an invalid field type", template.name);
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (IBAction) dismiss {
    //Notify the delegate that user tried to dismiss the view controller
	if ([self.delegate respondsToSelector:@selector(featureTemplatePickerViewControllerWasDismissed:)]){
		[self.delegate featureTemplatePickerViewControllerWasDismissed:self];
	}
}

#pragma mark -
#pragma mark UITableViewDataSource

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        
        UIBarButtonItem *cancel = [[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)]autorelease];
        self.navigationItem.leftBarButtonItem = cancel;
        
        UIBarButtonItem *commit = [[[UIBarButtonItem alloc]initWithTitle:@"Commit" style:UIBarButtonItemStylePlain target:self action:@selector(commit)]autorelease];
        self.navigationItem.rightBarButtonItem = commit;
        
        self.navigationItem.title = @"New Trail";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //return @"Select a report to add";
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.infos count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 0.0;
//}
//
// This controls the appearance of the individual rows of the "Add your data" view
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
    
    //Set its label, image, etc for the template
    FeatureTemplatePickerInfo* info = [self.infos objectAtIndex:indexPath.row];    
    cell.textLabel.font = [UIFont fontWithName:@"MuseoSlab-500" size:16.0];
    
	cell.textLabel.text = info.featureTemplate.name;
    cell.imageView.image =[ info.featureLayer.renderer swatchForGraphic:info.featureTemplate.prototype geometryType:info.featureLayer.geometryType size:CGSizeMake(50, 50)];
	
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
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
