//
//  SampleAnnotation.h
//  MapAndLocationDemo
//
//  Created by 韩威 on 16/8/8.
//  Copyright © 2016年 韩威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SampleAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *imgName;

@end
