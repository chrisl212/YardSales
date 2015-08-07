//
//  ACRequest.m
//  YardSales
//
//  Created by Christopher Loonam on 8/5/15.
//
//

#import "GZIP.h"
#import "ACRequest.h"
#import "ACYardSale.h"

@implementation ACRequest

+ (BOOL)uploadYardSale:(ACYardSale *)yardSale error:(NSError **)error
{
    NSString *address = (__bridge NSString *)yardSale.location.address;
    NSString *state = (__bridge NSString *)yardSale.location.state;
    NSString *town = (__bridge NSString *)yardSale.location.town;
    ZipCode zipCode = yardSale.location.zip;
    
    NSTimeInterval startDate = [(__bridge NSDate *)yardSale.hours.startTime timeIntervalSince1970];
    NSTimeInterval endDate = [(__bridge NSDate *)yardSale.hours.endTime timeIntervalSince1970];

    NSString *comments = yardSale.comments;
    
    NSString *requestURLString = [[NSString stringWithFormat:@"http://a-cstudios.com/ysales/new.php?address=%@&state=%@&town=%@&zip=%f&startDate=%f&endDate=%f&comments=%@", address, state, town, zipCode, startDate, endDate, comments] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *requestURL = [NSURL URLWithString:requestURLString];

    NSError *err;
    NSData *responseData = [NSData dataWithContentsOfURL:requestURL options:kNilOptions error:&err];
    if (err && error)
    {
        *error = err;
        return NO;
    }
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    if ([responseString rangeOfString:@"Success"].location == NSNotFound && error)
    {
        *error = [NSError errorWithDomain:@"Unkown error uploading yard sale" code:-1 userInfo:nil];
        return NO;
    }
    
    return YES;
}

+ (NSArray *)yardSalesWithFilter:(ACRequestFilter)filter object:(id)obj error:(NSError **)error
{
    NSString *requestURLString;
    NSMutableArray *retval = [NSMutableArray array];
    
    switch (filter)
    {
        case ACRequestFilterNone:
            requestURLString = @"http://a-cstudios.com/ysales/sales.php";
            break;
            
        case ACRequestFilterState:
            requestURLString = [NSString stringWithFormat:@"http://a-cstudios.com/ysales/sales.php?state=%@", obj];
            break;
            
        case ACRequestFilterTown:
            requestURLString = [NSString stringWithFormat:@"http://a-cstudios.com/ysales/sales.php?town=%@", obj];
            break;
            
        case ACRequestFilterZip:
            requestURLString = [NSString stringWithFormat:@"http://a-cstudios.com/ysales/sales.php?zip=%ld", (long)[obj integerValue]];
            break;
            
        default:
            break;
    }
    
    NSURL *requestURL = [NSURL URLWithString:requestURLString];
    NSError *err;
    NSData *responseData = [[NSData dataWithContentsOfURL:requestURL options:kNilOptions error:&err] gunzippedData];
    if (err && error)
    {
        *error = err;
        return nil;
    }
    
    NSArray *results = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&err];
    if (err && error)
    {
        *error = err;
        return nil;
    }
    
    for (NSDictionary *yardSaleDictionary in results)
    {
        ACYardSale *yardSale = [[ACYardSale alloc] init];
        yardSale.comments = yardSaleDictionary[@"comments"];
        
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[yardSaleDictionary[@"startDate"] doubleValue]];
        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[yardSaleDictionary[@"endDate"] doubleValue]];
        yardSale.hours = hoursCreate((__bridge CFDateRef)startDate, (__bridge CFDateRef)endDate);
        
        NSString *address = yardSaleDictionary[@"address"];
        NSString *town = yardSaleDictionary[@"town"];
        NSString *state = yardSaleDictionary[@"state"];
        NSNumber *zipCode = yardSaleDictionary[@"zip"];
        
        yardSale.location = locationCreate((__bridge CFStringRef)state, (__bridge CFStringRef)town, [zipCode doubleValue], (__bridge CFStringRef)address);
        
        [retval addObject:yardSale];
    }
    
    return [[NSArray alloc] initWithArray:retval];
}

@end
