//
//  NSValue+MKMapPoint.m
//  WMSKitDemo
//
//  Created by Rameez on 1/3/18.
//  Copyright © 2018 Erik Haider Forsen. All rights reserved.
//

#import "NSValue+MKMapPoint.h"

@implementation NSValue (MKMapPoint)

+ (NSValue *)valueWithMKMapPoint:(MKMapPoint)mapPoint {
    return [NSValue value:&mapPoint withObjCType:@encode(MKMapPoint)];
}

- (MKMapPoint)MKMapPointValue {
    MKMapPoint mapPoint;
    [self getValue:&mapPoint];
    return mapPoint;
}

@end
