//
//  ACYardSale.m
//  YardSales
//
//  Created by Christopher Loonam on 8/1/15.
//
//

#import "ACYardSale.h"

ACLocation locationCreate(CFStringRef state, CFStringRef town, ZipCode zip, CFStringRef address)
{
    ACLocation loc;
    loc.state = state;
    loc.town = town;
    loc.zip = zip;
    loc.address = address;
    return loc;
}

ACHours hoursCreate(CFDateRef start, CFDateRef end)
{
    ACHours hours;
    hours.startTime = start;
    hours.endTime = end;
    return hours;
}

@implementation ACYardSale

- (BOOL)isOpen
{
    NSDate *currentTime = [NSDate date];
    NSDate *startTime = (__bridge NSDate *)self.hours.startTime;
    NSDate *endTime = (__bridge NSDate *)self.hours.endTime;
    
    NSTimeInterval currentSeconds = [currentTime timeIntervalSince1970];
    NSTimeInterval startSeconds = [startTime timeIntervalSince1970];
    NSTimeInterval endSeconds = [endTime timeIntervalSince1970];
    
    if (startSeconds <= currentSeconds && currentSeconds <= endSeconds)
        return YES;
    
    return NO;
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:(__bridge NSString *)self.location.town forKey:@"town"];
    [aCoder encodeObject:(__bridge NSString *)self.location.state forKey:@"state"];
    [aCoder encodeDouble:self.location.zip forKey:@"zip"];
    [aCoder encodeObject:(__bridge NSString *)self.location.address forKey:@"address"];
    
    [aCoder encodeObject:(__bridge NSDate *)self.hours.startTime forKey:@"start"];
    [aCoder encodeObject:(__bridge NSDate *)self.hours.endTime forKey:@"end"];
    
    [aCoder encodeObject:self.comments forKey:@"comments"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        NSString *state = [aDecoder decodeObjectForKey:@"state"];
        CFStringRef stateString = (__bridge CFStringRef)state;
        NSString *town = [aDecoder decodeObjectForKey:@"town"];
        CFStringRef townString = (__bridge CFStringRef)town;
        ZipCode zip = [aDecoder decodeDoubleForKey:@"zip"];
        NSString *address = [aDecoder decodeObjectForKey:@"address"];
        CFStringRef addressString = (__bridge CFStringRef)address;
        
        self.location = locationCreate(stateString, townString, zip, addressString);
        
        NSDate *start = [aDecoder decodeObjectForKey:@"start"];
        CFDateRef startDate = (__bridge CFDateRef)start;
        NSDate *end = [aDecoder decodeObjectForKey:@"end"];
        CFDateRef endDate = (__bridge CFDateRef)end;
        
        self.hours = hoursCreate(startDate, endDate);
        
        self.comments = [aDecoder decodeObjectForKey:@"comments"];
    }
    return self;
}

#pragma mark File Operations

- (void)writeToFile:(NSString *)path error:(NSError **)err
{
    BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:path];
    if (!success)
        *err = [NSError errorWithDomain:@"Unkown File Write Error" code:-1 userInfo:nil];
}

- (id)initWithContentsOfFile:(NSString *)path
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

@end
