//
//  ACMapViewController.h
//  YardSales
//
//  Created by Christopher Loonam on 8/1/15.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ACMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) NSArray *yardSales;
@property (strong, nonatomic) MKMapView *mapView;

@end
