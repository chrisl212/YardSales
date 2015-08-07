//
//  ACMapViewController.m
//  YardSales
//
//  Created by Christopher Loonam on 8/1/15.
//
//

#import "ACMapViewController.h"
#import "ACRequest.h"
#import "ACYardSale.h"
#import "ACYardSaleCreateViewController.h"

@implementation ACMapViewController
{
    BOOL displayedUserLocation;
}

- (instancetype)init
{
    if (self = [super init])
    {
        displayedUserLocation = NO;
        
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
        self.mapView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapView.frame = self.view.bounds;
    [self.view addSubview:self.mapView];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentYardSaleCreateController)];
}

- (void)presentYardSaleCreateController
{
    ACYardSaleCreateViewController *yardSaleCreateController = [[ACYardSaleCreateViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:yardSaleCreateController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        if (!self.mapView.showsUserLocation)
            self.mapView.showsUserLocation = YES;
    }
}

#pragma mark - Map View Delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!displayedUserLocation)
    {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 50, 50);
        [mapView setRegion:region animated:YES];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        __block ZipCode zip;
        
        [geocoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (error)
                 return;
             for (CLPlacemark *place in placemarks)
             {
                 zip = [place.postalCode doubleValue];
             }
             self.yardSales = [ACRequest yardSalesWithFilter:ACRequestFilterNone object:@(zip) error:nil];
         }];
        displayedUserLocation = YES;
    }
}

@end
