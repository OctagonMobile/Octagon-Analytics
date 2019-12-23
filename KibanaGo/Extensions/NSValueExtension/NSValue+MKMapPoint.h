//
//  NSValue+MKMapPoint.h
//  WMSKitDemo
//
//  Created by Rameez on 1/3/18.
//  Copyright © 2018 Erik Haider Forsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NSValue (MKMapPoint)

+ (NSValue *)valueWithMKMapPoint:(MKMapPoint)mapPoint;
- (MKMapPoint)MKMapPointValue;

@end
