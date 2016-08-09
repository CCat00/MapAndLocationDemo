//
//  SampleMapViewController.m
//  MapAndLocationDemo
//
//  Created by 韩威 on 16/8/8.
//  Copyright © 2016年 韩威. All rights reserved.
//

#import "SampleMapViewController.h"
#import <MapKit/MapKit.h>
#import "SampleAnnotation.h"

@interface SampleMapViewController () <CLLocationManagerDelegate>
{
    BOOL _firstUpdateUserLocation;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;

@end

@implementation SampleMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"定位" style:UIBarButtonItemStylePlain target:self action:@selector(updateUserLocation)];
    
    // MapView Properties
    _mapView.showsCompass = YES;
    _mapView.showsScale = YES;
    _mapView.showsUserLocation = YES;
    
    // UITapGestureRecognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    [_mapView addGestureRecognizer:tap];
    
    // CLLocationManager
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if (![self checkLocationAuthorize]) {
        [_locationManager requestWhenInUseAuthorization];
        //[_locationManager requestAlwaysAuthorization]
        NSLog(@"需要在设置里开启该APP的定位权限");
    }
    
    // CLGeocoder
    _geocoder = [[CLGeocoder alloc] init];
    
    _firstUpdateUserLocation = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (BOOL)checkLocationAuthorize {
    BOOL locationEnabled = [CLLocationManager locationServicesEnabled];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    BOOL flag = locationEnabled && (status == kCLAuthorizationStatusAuthorizedWhenInUse || kCLAuthorizationStatusAuthorizedAlways == status);
    NSLog(@"locationEnabled = %d, status = %d", locationEnabled, status);
    return flag;
}

                        
#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (_firstUpdateUserLocation) {
        _firstUpdateUserLocation = NO;
        [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
        MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, MKCoordinateSpanMake(.1, .1));
        [mapView setRegion:region animated:YES];
    }
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[SampleAnnotation class]]) {
        
        static NSString *identifier = @"identifier";
        
        MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (!view) {
            view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            view.canShowCallout = YES;
        }
        
        view.annotation = annotation;
        view.image = [UIImage imageNamed:[(SampleAnnotation *)annotation imgName]];
        
        return view;
    }
    return nil;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
}
                        
#pragma mark - Action

- (void)updateUserLocation {
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    MKCoordinateRegion region = MKCoordinateRegionMake(self.mapView.userLocation.location.coordinate, MKCoordinateSpanMake(.1, .1));
    [self.mapView setRegion:region animated:YES];
}

- (void)tapGes:(UITapGestureRecognizer *)tapGes {
    CGPoint point = [tapGes locationInView:_mapView];
    
    // 根据触摸点找到经纬度
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    // 逆地理编码
    __weak typeof(self) weakself = self;
    [self.geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"error = %@", [error localizedDescription]);
            return ;
        }
        
        if (placemarks > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"placemark = %@", placemark.name);
            
            SampleAnnotation *annotation = [[SampleAnnotation alloc] init];
            annotation.title = placemark.name;
            annotation.subtitle = placemark.thoroughfare;
            annotation.coordinate = coordinate;
            annotation.imgName = @"car.png";
            [weakself.mapView addAnnotation:annotation];
        }
        
        
        
        
    }];
    
}

@end
