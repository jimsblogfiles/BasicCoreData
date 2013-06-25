//
//  BCDViewController.m
//  BasicCoreData
//
//  Created by James Border on 6/24/13.
//  Copyright (c) 2013 James Border. All rights reserved.
//

#import "BCDViewController.h"
#import "AppData.h"

@interface BCDViewController () {

    AppData *appData;

}

@property (weak, nonatomic) IBOutlet UITextView *txtFeedback;

@end

@implementation BCDViewController

- (void)viewDidLoad
{

    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillAppear:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    appData = [AppData sharedData];

    if ( ! appData || [appData isEqual:[NSNull null]] ) {

        @throw [NSException exceptionWithName:@"AppData sharedData" reason:@"AppData sharedData does not exist" userInfo:nil];

    }

}

-(void)viewWillAppear:(BOOL)animated {
    
    _txtFeedback.text = [appData rawLaunchData];
    
}

-(void)viewDidAppear:(BOOL)animated {}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
