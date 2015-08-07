//
//  ACRequest.h
//  YardSales
//
//  Created by Christopher Loonam on 8/5/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ACRequestFilter)
{
    ACRequestFilterNone,
    ACRequestFilterZip,
    ACRequestFilterTown,
    ACRequestFilterState
};

@class ACYardSale;

@interface ACRequest : NSObject

+ (BOOL)uploadYardSale:(ACYardSale *)yardSale error:(NSError **)error;
+ (NSArray *)yardSalesWithFilter:(ACRequestFilter)filter object:(id)obj error:(NSError **)error;

@end
