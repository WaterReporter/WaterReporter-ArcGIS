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


/**
 * This document gets heavy really quick. In order to understand it a little better I've
 * summarized what we're doing at the top:
 *
 * [Line 159+/-] viewDidLoad: This handles the titles, the cancel, the save buttons, and the toolbar at the top of the page.
 * [Line 195+/-] viewWillAppear: This gets our attributes ready to display in the TableView. For example, if the feature exists then we're collecting the existing data from the individual fields. If it's new, we're just getting a list of empty fields for display
 *
 *
 *
 *
 */

#import "FeatureDetailsViewController.h"
#import "FeatureTypeViewController.h"
#import "ImageViewController.h"
#import "MoviePlayerViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>

#import "CodedValueUtility.h"
#import "WaterReporterFeatureLayer.h"

@interface FeatureDetailsViewController ()

-(void)doneSucceeded;
-(void)doneFailed;        

@end

@implementation FeatureDetailsViewController
@synthesize feature = _feature;
@synthesize featureGeometry = _featureGeometry;
@synthesize featureLayer = _featureLayer;
@synthesize attachments = _attachments;
@synthesize date = _date;
@synthesize dateFormat = _dateFormat;
@synthesize timeFormat = _timeFormat;
@synthesize attachmentInfos = _attachmentInfos;
@synthesize infos = _infos;
@synthesize operations = _operations;
@synthesize retrieveAttachmentOp = _retrieveAttachmentOp;

#pragma mark - helper methods

-(BOOL)filepathIsJPG:(NSString*)filepath{
	return [[[filepath pathExtension]lowercaseString] isEqualToString:@"jpg"];
}

-(BOOL)filepathIsMOV:(NSString*)filepath{
	return [[[filepath pathExtension]lowercaseString] isEqualToString:@"mov"];
}

-(NSString*)saveDataToTempFile:(NSData*)data mediaType:(NSString*)mediaType{
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureDetailsViewController:saveDataToTempFile");
	
	NSString *ext = nil;
	if ([mediaType isEqualToString:(NSString*)kUTTypeImage]){
		ext = @"jpg";
	}
	else if ([mediaType isEqualToString:(NSString*)kUTTypeMovie]){
		ext = @"mov";
	}
	
	NSString *filename = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate], ext]];
	[data writeToFile:filename atomically:NO];
	return filename;
}

-(NSString*)saveImageToTempFile:(UIImage*)image{
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureDetailsViewController:saveImageToTempFile");
	
	NSData *imageData = UIImageJPEGRepresentation(image, .35);
	return [self saveDataToTempFile:imageData mediaType:(NSString*)kUTTypeImage];
}

- (UIImage *)thumbnailForImageWithPath:(NSString*)fullPathToMainImage size:(float)size {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureDetailsViewController:thumbnailForImageWithPath");
	
	
	NSString *subdir = [fullPathToMainImage stringByDeletingLastPathComponent];
	NSString *filename = [fullPathToMainImage lastPathComponent];
	NSString *extension = [fullPathToMainImage pathExtension];
	NSString *fullPathToThumbImage = [subdir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%dx%d.%@",filename, (int)size, (int)size, extension]];
	
	UIImage *thumbnail;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:fullPathToThumbImage] == YES) {
		thumbnail = [UIImage imageWithContentsOfFile:fullPathToThumbImage];
	}
	else {
		UIImage *mainImage = [UIImage imageWithContentsOfFile:fullPathToMainImage];
		UIImageView *mainImageView = [[[UIImageView alloc] initWithImage:mainImage]autorelease];
		BOOL widthGreaterThanHeight = (mainImage.size.width > mainImage.size.height);
		float sideFull = (widthGreaterThanHeight) ? mainImage.size.height : mainImage.size.width;
		CGRect clippedRect = CGRectMake(0, 0, sideFull, sideFull);
		// creating a square context the size of the final image which we will then
		// manipulate and transform before drawing in the original image
		UIGraphicsBeginImageContext(CGSizeMake(size, size));
		CGContextRef currentContext = UIGraphicsGetCurrentContext();
		CGContextClipToRect( currentContext, clippedRect);
		CGFloat scaleFactor = size/sideFull;
		if (widthGreaterThanHeight) {
			// a landscape image – make context shift the original image to the left when drawn into the context
			CGContextTranslateCTM(currentContext, -((mainImage.size.width - sideFull) / 2) * scaleFactor, 0);
		}
		else {
			// a portrait image – make context shift the original image upwards when drawn into the context
			CGContextTranslateCTM(currentContext, 0, -((mainImage.size.height - sideFull) / 2) * scaleFactor);
		}
		// this will automatically scale any CGImage down/up to the required thumbnail side (size)
		// when the CGImage gets drawn into the context on the next line of code
		CGContextScaleCTM(currentContext, scaleFactor, scaleFactor);
		[mainImageView.layer renderInContext:currentContext];
		thumbnail = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		NSData *imageData = UIImagePNGRepresentation(thumbnail);
		[imageData writeToFile:fullPathToThumbImage atomically:YES];
		thumbnail = [UIImage imageWithContentsOfFile:fullPathToThumbImage];
	}
	return thumbnail;
}

-(NSURL*)urlFromFilePath:(NSString*)filepath{
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureDetailsViewController:urlFromFilePath");
	
	return [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",filepath]];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureDetailsViewController:viewDidLoad");
	
    if (_newFeature){
        /**
         * This is the "Cancel" button when you're adding a new feature to the map
         */
		UIBarButtonItem *cancel = [[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)]autorelease];
		self.navigationItem.leftBarButtonItem = cancel;
		
        /**
         * This is the "Commit" button when you're adding a new feature to the map
         */
		UIBarButtonItem *commit = [[[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(commit)]autorelease];
		self.navigationItem.rightBarButtonItem = commit;
		
        /**
         * This is the title of the View when you're adding a new feature to the map
         */
		self.navigationItem.title = @"New Report";
	}
	else {
        /**
         * This is the title of the View when you're viewing the details of an existing map feature
         */
		self.navigationItem.title = @"Report Details";
	}
	
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureDetailsViewController:viewWillAppear");
	
    /**
     * Reloading the data
     *
     * The Feature Detail View Controller is really just a template
     * to hold information. Since we don't know the contents of each
     * field until we select a feature, we need to make sure that we
     * are reloading the TableView to accept the new data.
     *
     * The attributes we see here are the specific Feature attributes
     * we are interested in populating our form with if the feature
     * is an existing Feature.
     *
     */
	[self.tableView reloadData];
	NSDictionary* attributes = [self.feature allAttributes];
    
    NSLog(@"Attributes: %@", attributes);
    
	self.navigationItem.rightBarButtonItem.enabled = (attributes!=nil && [attributes count]>0);
}


#pragma mark init method

-(id)initWithFeatureLayer:(WaterReporterFeatureLayer*)featureLayer feature:(AGSGraphic *)feature featureGeometry:(AGSGeometry*)featureGeometry{
	
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeatureDetailsViewController:initWithFeatureLayer");
	
	if (self = [super initWithStyle:UITableViewStylePlain]){

		self.featureLayer = featureLayer;
		self.featureLayer.editingDelegate = self;
		self.featureGeometry = featureGeometry;
        self.feature = feature;
		self.operations = [NSMutableArray array];
		
		// if the attributes are nil, it is a new feature, set flat
		if (!feature){
			_newFeature = YES;
			self.attachments = [NSMutableArray array];
		}
		
		// otherwise it is an existing feature, so we cache the objectId,
		// set the newFeature flag, and kick off an operation to get 
		// the attachments
		else {
			_objectId = [self.featureLayer objectIdForFeature:self.feature];
			_newFeature = NO;
            NSOperation* op = [self.featureLayer queryAttachmentInfosForObjectId:_objectId];
            if(op)
                [self.operations addObject:op];
		}

		// set initial date
		self.date = [NSDate dateWithTimeIntervalSinceNow:0];
		
		// set up the formatters
		self.dateFormat = [[[NSDateFormatter alloc] init] autorelease];
		[self.dateFormat setDateFormat:@"MMMM dd, yyyy"];
		
        //we're currently not using time
		self.timeFormat = [[[NSDateFormatter alloc] init] autorelease];
		[self.timeFormat setDateFormat:@"HH:mm:ss"];
	}
	
	return self;
}

#pragma mark helper methods

-(void)cancel{
    
    /**
     * This allows us to see what is being fired and when
     */	
    NSLog(@"FeaturesDetailsViewController:cancel");
	// this will eventually dealloc this VC and the operations that haven't completed yet
	// will be cancelled
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)commit{
	// when the commit button is pressed
	
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController:commit");
    
	// disable the commit button
	self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if (self.featureLayer.bOnline)
    {
        // kick off the add feature operation
        [self.operations addObject:[self.featureLayer addFeatures:[NSArray arrayWithObject:self.feature]]];	
    }
    else {
        //add features offline
        [self.featureLayer addOfflineFeature:self.feature withAttachments:self.attachments];
        _objectId = -1; //set up dummy id
		[self doneSucceeded];
    }
}

-(void)doneSucceeded{
    /**
     * This allows us to see what is being fired and when
     */
	// called when we are done and the feature was added successfully
    NSLog(@"FeaturesDetailsViewController:doneSucceeded");

	// pop the view controller
	[self.navigationController popViewControllerAnimated:YES];
	
    NSString *messageString = @"You have successfully added a report.";
    if (self.featureLayer.bOnline)
    {
        messageString = [messageString stringByAppendingString:[NSString stringWithFormat:@" Confirmation number: %i", _objectId]];
    }

	// show an alert
	UIAlertView *alertView = [[[UIAlertView alloc]initWithTitle:@"Report Added"
														message:messageString
													   delegate:nil
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil]autorelease];
	[alertView show];
}

-(void)doneFailed{
	// called when we are done and the feature was not successfully added
	
	// pop the view controller
	[self.navigationController popViewControllerAnimated:YES];
	
	// show an alert
	UIAlertView *alertView = [[[UIAlertView alloc]initWithTitle:@"Error"
														message:@"There was an error adding the report. Please try again."
													   delegate:nil
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil]autorelease];
	[alertView show];
}

-(void)didSelectFeatureType:(FeatureTypeViewController *)ftvc
{
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController:didSelectFeatureType");
    //get feature from FeatureTypeViewController
    self.feature = ftvc.feature;
    
    //set geometry
    self.feature.geometry = self.featureGeometry;
    
    // set the recordedon value; the other default values will come from the template
    NSTimeInterval timeInterval = [self.date timeIntervalSince1970];
    [self.feature setAttributeWithDouble:(timeInterval * 1000) forKey:@"recordedon" ];
    
    //set the callout info template to the layer's infoTemplateDelegate
    self.feature.infoTemplateDelegate = self.featureLayer.infoTemplateDelegate;
    
    //redraw the tableView
    [self.tableView reloadData];
}

#pragma mark featureLayerEditingDelegate methods

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation*)op didQueryAttachmentInfosWithResults:(NSArray *)attachmentInfos{
	
	// called by the feature layer when the queryAttachmentInfos is completed
	
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController:didQueryAttachmentInfosWithResults");
	NSLog(@"got attachment infos...");
	
	// remove the operation from the array
	[self.operations removeObject:op];
	
	// set the attachmentInfos
	self.attachmentInfos = attachmentInfos;
	
	// initialize all the attachments to NSNull
	self.attachments = [NSMutableArray arrayWithCapacity:attachmentInfos.count];
	for (int i=0; i<self.attachmentInfos.count; i++){
		[self.attachments addObject:[NSNull null]];
	}
	
	// reload the table
	[self.tableView reloadData];
}

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation *)op didFailQueryAttachmentInfosWithError:(NSError *)error{
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: didFailQueryAttachmentInfosWithError");
	// called when the featurelayer fails to query for attachments
	
	// set the attachmentInfos
	self.attachmentInfos = [NSMutableArray array];
	
	// remove the operation from the array
	[self.operations removeObject:op];
	
	// reload the table
	[self.tableView reloadData];
	
}

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation*)op didFeatureEditsWithResults:(AGSFeatureLayerEditResults *)editResults{
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: didFeatureEditsWithResults");
	// called when feature layer is done with feature edits (in this case, done adding the feature)
	
	// remove operation
	[self.operations removeObject:op];
	
	// if can't add feature, call doneFailed
	AGSEditResult *addResult = [editResults.addResults objectAtIndex:0];
	if (!addResult.success){
		NSLog(@"failed to add feature");
		[self doneFailed];
		return;
	}
	
	// if added feature, set the objectId
	NSLog(@"added feature: %d",addResult.objectId);
	_objectId = addResult.objectId;
	
	if (self.attachments.count > 0){
		// add the attachments
		for (int i=0; i<self.attachments.count; i++){
			id file = [self.attachments objectAtIndex:i];
			if ([file isKindOfClass:[NSURL class]]){
				NSData *data = [NSData dataWithContentsOfURL:file];
				[self.operations addObject:[self.featureLayer addAttachment:addResult.objectId data:data filename:[[file absoluteString]lastPathComponent] ]];
			}
			else if ([file isKindOfClass:[NSString class]]){
				[self.operations addObject:[self.featureLayer addAttachment:addResult.objectId filepath:[self.attachments objectAtIndex:i]]];
			}
		 }
	}
	else {
		// if no attachments, done
		[self doneSucceeded];
	}

}

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation*)op didFailFeatureEditsWithError:(NSError *)error{
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: didFailFeatureEditsWithError");
	// called when the feature layer fails to perform the feature edits (in the case fails to add the feature)
	
	NSLog(@"error adding feature: %@", error.description);
	
	// remove the operation, call doneFailed
	[self.operations removeObject:op];
	[self doneFailed];
}

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation*)op didAttachmentEditsWithResults:(AGSFeatureLayerAttachmentResults *)attachmentResults{
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: didAttachmentEditsWithResults");
	// called when the feature layer adds the attachment
	
	// remove the operation
	[self.operations removeObject:op];
	
	if (!attachmentResults.addResult.success){
		NSLog(@"failed to add attachment.");
	}
	else {
		NSLog(@"added attachment: %d",attachmentResults.addResult.objectId);
	}

	// as we add attachments, we are removing them from the array, so that we know when we are done adding all the attachments
	if (self.operations.count == 0){
		// if we get to 0, we are done
		[self doneSucceeded];
	}
}

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation*)op didFailAttachmentEditsWithError:(NSError *)error{
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: didFailAttachmentEditsWithError");
	// called when the feature layer fails to add the attachment
	
	NSLog(@"error adding attachment");
	
	// remove the operation
	[self.operations removeObject:op];
	
	// as we add attachments, we are removing them from the array, so that we know when we are done adding all the attachments
	if (self.operations.count == 0){
		// if we get to 0, we are done
		[self doneSucceeded];
	}	
	
}

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation*)op didRetrieveAttachmentWithData:(NSData *)attachmentData{
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: didRetrieveAttachmentWithData");
	// called when we get back the attachment data
	
	NSLog(@"got attachment data");
	
	// remove the operation
	[self.operations removeObject:op];
	
	// set cached variable to nil, so we know we aren't performing a "retrieve attachment"
	self.retrieveAttachmentOp = nil;
	
	// save image to temp file
	// add the filename to the attachments array, so we don't have to get it next time
	if (attachmentData != nil){
		AGSAttachmentInfo *ai = [self.attachmentInfos objectAtIndex:self.tableView.tag];
		if ([ai.contentType isEqualToString:@"image/jpeg"]){
			NSString *filepath = [self saveDataToTempFile:attachmentData mediaType:(NSString*)kUTTypeImage];
			[self.attachments replaceObjectAtIndex:self.tableView.tag withObject:filepath];
			
			// create an image
			UIImage *image = [UIImage imageWithData:attachmentData];
			// show the image
			ImageViewController *vc = [[[ImageViewController alloc]initWithImage:image]autorelease];
			[self.navigationController pushViewController:vc animated:YES];
		}
		else if ([ai.contentType isEqualToString:@"video/quicktime"]){
			NSString *filepath = [self saveDataToTempFile:attachmentData mediaType:(NSString*)kUTTypeMovie];
			[self.attachments replaceObjectAtIndex:self.tableView.tag withObject:filepath];
			MoviePlayerViewController *vc = [[[MoviePlayerViewController alloc]initWithURL:[self urlFromFilePath:filepath]]autorelease];
			[self.navigationController pushViewController:vc animated:YES];
		}
	}
	
}

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation*)op didFailRetrieveAttachmentWithError:(NSError *)error{
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: didFailRetrieveAttachmentWithError");
	// called when the feature layer fails to retrieve the attachment data
	NSLog(@"failed to retrieve attachment");
	
	// remove the operation
	[self.operations removeObject:op];
	
	// set the cached variable to nil, so we know we aren't performing a "retrieve attachment"
	self.retrieveAttachmentOp = nil;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: numberOfSectionsInTableView");
	return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: numberOfRowsInSection");

    // Return the number of rows in the section.
    if (section == 1){ // attachments
		if (_newFeature){
			return self.attachments.count + 1;
		}
		else {
			if (self.attachmentInfos){
				if (self.attachmentInfos.count == 0){
					return 1;
				}
				else {
					return self.attachmentInfos.count;
				}
			}
			else {
				return 1;
			}
		}

	} else if (section == 2){ // details
//		return [self.infos count];
        return 6;
	}
	
	return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 8, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.shadowColor = [UIColor clearColor];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: titleForHeaderInSection");
    
    switch (section) {
            
        case 0: // Feature Type, auto-populated with our application
            return nil;
            
        case 1:
            return @"Photo/Video"; // Photo/Video Attachments
            
        case 2:
            return @"Details"; // Feature Details
            
    }
    
	return nil;
}

-(AGSField*)findStatusField{

    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: findStatusField");

	// helper method to find the status field
	for (int i=0; i<self.featureLayer.fields.count; i++){
		AGSField *field = [self.featureLayer.fields objectAtIndex:i];
		if ([field.name isEqualToString: @"status"]){
			return field;
		}
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: cellForRowAtIndexPath");
	
	UITableViewCell *cell = nil;
        
    /**
     * Replace the default pinstripe background with our new linen pattern
     */
    UIView* backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundDefault.png"]];
    [tableView setBackgroundView:backgroundView];
	
	// section 1 is the attachments
	if (indexPath.section == 1){
		
		static NSString *attachmentsCellIdentifier = @"attachmentsCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:attachmentsCellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:attachmentsCellIdentifier] autorelease];
		}
        cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"buttonCamera.png"]];		
		
        cell.imageView.image = nil;
		cell.textLabel.text = nil;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// for creating a new feature, we allow them to add a picture
		// and view or remove pictures
		if (_newFeature){
			if (indexPath.row == self.attachments.count){
				cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                cell.accessoryType = UITableViewCellAccessoryNone;
				cell.textLabel.text = @"Add a photo or video";
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.backgroundColor =  [UIColor clearColor];
                cell.textLabel.backgroundColor = [UIColor clearColor];
                cell.textLabel;
			}
			else {
				NSString *filepath = [self.attachments objectAtIndex:indexPath.row];
				if ([self filepathIsJPG:filepath]){
					cell.textLabel.text = [NSString stringWithFormat:@"%@ %d",@"Picture",indexPath.row + 1];
					cell.imageView.image = [self thumbnailForImageWithPath:[self.attachments objectAtIndex:indexPath.row] size:36];
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				}
				else {
					cell.textLabel.text = [NSString stringWithFormat:@"%@ %d",@"Video",indexPath.row + 1];
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				}

			}
		}
		
		// for viewing attributes of an existing feature, we need to show them either
		// a "loading" message, "none" message, or list of media attachments
		else {
			if (self.attachmentInfos == nil){
				cell.textLabel.text = @"Loading...";
			}
			else if (self.attachmentInfos.count == 0){
				cell.textLabel.text = @"None";
			}
			else {
				AGSAttachmentInfo *ai = [self.attachmentInfos objectAtIndex:indexPath.row];
				cell.textLabel.text = ai.name;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
				// if we've already retrieved the photo, show a thumbnail
				if ([ai.contentType isEqualToString:@"image/jpeg"] && [self.attachments objectAtIndex:indexPath.row] != [NSNull null]){
					cell.imageView.image = [self thumbnailForImageWithPath:[self.attachments objectAtIndex:indexPath.row] size:36];
				}
			}
		}
	}
	
	// section 2 is the feature details
	if (indexPath.section == 2){
		static NSString *detailsCellIdentifier = @"detailsCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:detailsCellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:detailsCellIdentifier] autorelease];
		}
		
		cell.imageView.image = nil;
		cell.textLabel.text = nil;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
        AGSField *field = nil;
		if (indexPath.row == 0){
			cell.detailTextLabel.text = [CodedValueUtility getCodedValueFromFeature:self.feature forField:@"condition" inFeatureLayer:self.featureLayer];
            field = [CodedValueUtility findField:@"condition" inFeatureLayer:self.featureLayer];
			cell.textLabel.text = field.alias;
		}
		else if (indexPath.row == 1){
            BOOL exists;
            NSNumber *recorededOn =
            [NSNumber numberWithDouble:[self.feature attributeAsDoubleForKey:@"recordedon" exists:&exists]];
            NSString *detailString = @"";
            if (recorededOn && (recorededOn != (id)[NSNull null]))
            {
                //attribute dates/times are in milliseconds; NSDate dates are in seconds
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:([recorededOn doubleValue] / 1000.0)];
                detailString = [self.dateFormat stringFromDate:date];
            }
			cell.detailTextLabel.text = detailString;
            
            field = [CodedValueUtility findField:@"recordedon" inFeatureLayer:self.featureLayer];
			cell.textLabel.text = field.alias;
		}
		else if (indexPath.row == 2){
			cell.detailTextLabel.text = [CodedValueUtility getCodedValueFromFeature:self.feature forField:@"difficulty" inFeatureLayer:self.featureLayer];
            field = [CodedValueUtility findField:@"difficulty" inFeatureLayer:self.featureLayer];
			cell.textLabel.text = field.alias;
		}
		else if (indexPath.row == 3){
            NSString *value = [self.feature attributeAsStringForKey:@"notes"];
			cell.detailTextLabel.text = (value == (id)[NSNull null] ? @"" : value);
            field = [CodedValueUtility findField:@"notes" inFeatureLayer:self.featureLayer];
			cell.textLabel.text = field.alias;
		}
        
//        UITableViewCellAccessoryType accType = UITableViewCellAccessoryNone;
//        if (field && field.editable)
//        {
//            accType = UITableViewCellAccessoryDisclosureIndicator;
//        }
//        
//        //set the accessory type based on whether the field is editable or not.
//        //note:  currently we don't do any editing of attributes...
//        cell.accessoryType = accType;
    }
    /**
     * Remove the separators between cells in the tableView
     */
    [tableView.layer setCornerRadius:0.0f];

    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor clearColor];
    
    /**
     * Set the label, image, etc for the templates
     */
    cell.textLabel.font = [UIFont fontWithName:@"MuseoSlab-500" size:14.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: accessoryButtonTappedForRowWithIndexPath");
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: didSelectRowAtIndexPath");
	
	// don't allow selection if it is a new feature and we are in the process of committing
	if (_newFeature && self.operations.count > 0){
		return;
	}
	
	if (_newFeature && indexPath.section == 0){
		// if creating a new feature and they clicked on the feature type, then let them choose a
		// feature template
		FeatureTypeViewController *ftvc = [[[FeatureTypeViewController alloc]init]autorelease];
		ftvc.featureLayer = self.featureLayer;
		ftvc.feature = self.feature;
        ftvc.completedDelegate = self;
		
		[self.navigationController pushViewController:ftvc animated:YES];
	}
	
	else if (indexPath.section == 1){
		
		if (_newFeature){ 
			// if creating a new feature and they click on an attachment
			
			if (indexPath.row == self.attachments.count){
				// if they click on "Add"
				UIImagePickerController *imgPicker = [[[UIImagePickerController alloc] init]autorelease];
				imgPicker.delegate = self;
				if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
					imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
					imgPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imgPicker.sourceType];
					imgPicker.allowsEditing = NO;
					imgPicker.videoQuality = UIImagePickerControllerQualityTypeLow;
					imgPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imgPicker.sourceType];
				}
				else {
					imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				}

				[self presentModalViewController:imgPicker animated:YES];
			}
			else {
				// if they click on an existing media attachment
				UIActionSheet *actionSheet = [[[UIActionSheet alloc]initWithTitle:@"What would you like to do?"
																			delegate:self
															   cancelButtonTitle:@"Cancel"
														  destructiveButtonTitle:@"Remove"
																otherButtonTitles:@"View",nil]autorelease];
				actionSheet.tag = indexPath.row;
				[actionSheet showInView:self.view];
			}
		}
		else {
			// if they are viewing an existing feature
			
			if (self.attachmentInfos.count > 0){
				
				// first cancel any retrieve operation already going on
				if (self.retrieveAttachmentOp != nil){
					[self.retrieveAttachmentOp cancel];
					[self.operations removeObject:self.retrieveAttachmentOp];
					self.retrieveAttachmentOp = nil;
				}
				
				if ([self.attachments objectAtIndex:indexPath.row] == [NSNull null]){
					
					// if they click on a photo/video that we don't have, retrieve it
					
					// set tag to be used later
					self.tableView.tag = indexPath.row;
					
					// kick off operation
					AGSAttachmentInfo *ai = [self.attachmentInfos objectAtIndex:indexPath.row];
					if ([ai.contentType isEqualToString:@"image/jpeg"]){
						self.retrieveAttachmentOp = [self.featureLayer retrieveAttachmentForObjectId:_objectId attachmentId:ai.attachmentId];
						[self.operations addObject:self.retrieveAttachmentOp];
					}
					else if([ai.contentType isEqualToString:@"video/quicktime"]){
						self.retrieveAttachmentOp = [self.featureLayer retrieveAttachmentForObjectId:_objectId attachmentId:ai.attachmentId];
						[self.operations addObject:self.retrieveAttachmentOp];
					}
				}
				else {
					AGSAttachmentInfo *ai = [self.attachmentInfos objectAtIndex:indexPath.row];
					if ([ai.contentType isEqualToString:@"image/jpeg"]){
						// if we already have the image, show it
						UIImage *image = [UIImage imageWithContentsOfFile:[self.attachments objectAtIndex:indexPath.row]];
						ImageViewController *vc = [[[ImageViewController alloc]initWithImage:image]autorelease];
						[self.navigationController pushViewController:vc animated:YES];
					}
					else if ([ai.contentType isEqualToString:@"video/quicktime"]){
						// if we already have the video, show it
						NSString *filepath = [self.attachments objectAtIndex:indexPath.row];
						MoviePlayerViewController *vc = [[[MoviePlayerViewController alloc]initWithURL:[self urlFromFilePath:filepath]]autorelease];
						[self.navigationController pushViewController:vc animated:YES];
					}
				}

			}
		}
	}	
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
	else if (buttonIndex == actionSheet.destructiveButtonIndex){
		// remove media attachment
		[self.attachments removeObjectAtIndex:actionSheet.tag];
		[self.tableView reloadData];
	}
	else{
		// view media attachment
		// For existing features, if it is a picture, it will be a string
		// if it is a quicktime video, it will be a URL
		id filepath = [self.attachments objectAtIndex:actionSheet.tag];
		if ([filepath isKindOfClass:[NSString class]]){
			UIImage *image = [UIImage imageWithContentsOfFile:[self.attachments objectAtIndex:actionSheet.tag]];
			ImageViewController *vc = [[[ImageViewController alloc]initWithImage:image]autorelease];
			[self.navigationController pushViewController:vc animated:YES];
		}
		else if ([filepath isKindOfClass:[NSURL class]]){
			MoviePlayerViewController *vc = [[[MoviePlayerViewController alloc]initWithURL:filepath]autorelease];
			[self.navigationController pushViewController:vc animated:YES];
		}
	}
}

#pragma mark Image Picker delegate methods
									  
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: didFinishPickingMediaWithInfo");

	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	
	NSLog(@"%@",[info objectForKey:UIImagePickerControllerMediaType]);
	NSLog(@"%@",info);
	
	if ([mediaType isEqualToString:(NSString*)kUTTypeImage]){
		// once they take/choose a picture, add it to the attachments collection and reload the table data
		UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
		
		// save image to tmp folder
		NSString *filename = [self saveImageToTempFile:image];
		
		// add filename to attachments
		[self.attachments addObject:filename];
	}
	else if ([mediaType isEqualToString:(NSString*)kUTTypeMovie]){
		// save image to tmp folder
		NSURL *fileurl = [info objectForKey:UIImagePickerControllerMediaURL];
		// add filename to attachments
		[self.attachments addObject:fileurl];
	}
	
	[self.tableView reloadData];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: imagePickerControllerDidCancel");
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: didReceiveMemoryWarning");

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: viewDidUnload");

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"FeaturesDetailsViewController: dealloc");
    
	// cancel any ongoing operations
	for (NSOperation *op in self.operations){
		[op cancel];
	}
	
	self.retrieveAttachmentOp = nil;
	
	// set delegate to nil so that the feature layer doesn't try to access
	// a dealloc'd object
	self.featureLayer.editingDelegate = nil;
	
	self.feature = nil;
	self.featureGeometry = nil;
	self.featureLayer = nil;
	self.attachments = nil;
	self.date = nil;
	self.dateFormat = nil;
	self.timeFormat = nil;
	self.attachmentInfos = nil;
	self.operations = nil;
    [super dealloc];
}


@end

