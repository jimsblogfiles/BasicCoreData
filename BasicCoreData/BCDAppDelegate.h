//
//  BCDAppDelegate.h
//  BasicCoreData
//
//  Created by James Border on 6/24/13.
//  Copyright (c) 2013 James Border. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppData;

@interface BCDAppDelegate : UIResponder <UIApplicationDelegate> {

    AppData *appData;

}

@property (strong, nonatomic) UIWindow *window;

@end
