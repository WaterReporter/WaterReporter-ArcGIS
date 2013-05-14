/**
 * Water Reporter
 *
 * Created by Viable Industries L.L.C. in March 2013.
 * Copyright (c) 2013 Viable Industries L.L.C. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@class AGSGraphic;
@class AGSFeatureLayer;
@class AGSField;

@interface CodedValueUtility : NSObject {

}

+(NSString *)getCodedValueFromFeature:(AGSGraphic *)feature forField:(NSString *)fieldName inFeatureLayer:(AGSFeatureLayer *)featureLayer;
+(AGSField*)findField:(NSString *)fieldName inFeatureLayer:(AGSFeatureLayer *)featureLayer;

@end
