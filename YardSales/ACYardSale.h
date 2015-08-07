//
//  ACYardSale.h
//  YardSales
//
//  Created by Christopher Loonam on 8/1/15.
//
//

#import <Foundation/Foundation.h>

typedef double ZipCode;

typedef struct
{
    CFStringRef state;
    CFStringRef town;
    ZipCode zip;
    CFStringRef address;
} ACLocation;

ACLocation locationCreate(CFStringRef state, CFStringRef town, ZipCode zip, CFStringRef address);

typedef struct
{
    CFDateRef startTime;
    CFDateRef endTime;
} ACHours;

ACHours hoursCreate(CFDateRef start, CFDateRef end);

@interface ACYardSale : NSObject <NSCoding>

@property (nonatomic) ACLocation location;
@property (nonatomic) ACHours hours;
@property (strong, nonatomic) NSString *comments;

- (BOOL)isOpen;
- (void)writeToFile:(NSString *)path error:(NSError **)err;
- (id)initWithContentsOfFile:(NSString *)path;

@end
