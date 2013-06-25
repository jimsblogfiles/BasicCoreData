//
//  AppStatus.h
//  BasicCoreData
//
//  Created by James Border on 6/24/13.
//  Copyright (c) 2013 James Border. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AppLaunches;

@interface AppStatus : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) AppLaunches *appLaunches;

@end
