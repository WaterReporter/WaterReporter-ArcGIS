/**
 * Water Reporter
 *
 * Created by Viable Industries L.L.C. in March 2013.
 * Copyright (c) 2013 Viable Industries L.L.C. All rights reserved.
 *
 */

#import "CodedValueUtility.h"
#import <ArcGIS/ArcGIS.h>

@implementation CodedValueUtility

+(NSString *)getCodedValueFromFeature:(AGSGraphic *)feature forField:(NSString *)fieldName inFeatureLayer:(AGSFeatureLayer *)featureLayer
{
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"CodedValueUtility: getCodedValueFromFeature");
    
    NSString *codedValue = @"";
    
    if (!feature)
    {
        //no feature yet, just return empty string
        return codedValue;
    }
    
    //get the field
    AGSField *field = [CodedValueUtility findField:fieldName inFeatureLayer:featureLayer];
    
    //get the domain for the field
    AGSCodedValueDomain *cvd = (AGSCodedValueDomain*)field.domain;
    
    //get the attribute value
    id attributeValue = [feature attributeForKey:fieldName];
    if (cvd && attributeValue && (attributeValue != (id)[NSNull null])){
        //loop through all the coded values and compare to our attribute value
        for (int i=0; i<cvd.codedValues.count; i++){
            AGSCodedValue *val = [cvd.codedValues objectAtIndex:i];
            
            //must switch on kind of object val.code is...
            if ([val.code isKindOfClass:[NSNumber class]])
            {                    
                if ([(NSNumber *)val.code intValue] == [(NSNumber *)attributeValue intValue]){
                    //we found our value, get the coded value for that...
                    codedValue = val.name;
                    break;
                }
            }
            else if ([val.code isKindOfClass:[NSString class]])
            {
                if ([val.code isEqualToString:attributeValue]){
                    //we found our value, get the coded value for that...
                    codedValue = val.name;
                    break;
                }
            }
            else {
                NSLog(@"Not implemented.");
            }
        }
    }
    
    return codedValue;
}

+(AGSField*)findField:(NSString *)fieldName inFeatureLayer:(AGSFeatureLayer *)featureLayer
{
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"CodedValueUtility: inFeatureLayer");
    
	// helper method to find the status field
	for (int i=0; i<featureLayer.fields.count; i++){
		AGSField *field = [featureLayer.fields objectAtIndex:i];
		if ([field.name isEqualToString:fieldName]){
			return field;
		}
	}
	return nil;
}

@end
