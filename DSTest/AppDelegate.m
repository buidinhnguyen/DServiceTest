//
//  AppDelegate.m
//  DSTest
//
//  Created by Nguyen Bui on 4/15/14.
//  Copyright (c) 2014 LCL. All rights reserved.
//

#import "AppDelegate.h"
#import <EventKit/EventKit.h>
#import "CGICalendar.h"
#import "SampleViewController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"2a549164f479c2cad1d041c4fd696817" ofType:@"ics"];
    
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"2a549164f479c2cad1d041c4fd696817" ofType:@"ics"];
//    
//    //CGICalendar *cal = [[CGICalendar alloc] initWithString:data];
//    CGICalendar *cal = [[CGICalendar alloc] initWithPath:path];
//    
//    //NSLog(@"%ld", [[cal objects] count]);
//    
//    CGICalendarObject *obj = [cal objectAtIndex:0];
//    NSLog(@"%ld     %ld     %ld     %ld", [[obj events] count], [[obj todos] count] , [[obj timezones] count], [[obj freebusies] count]);
    
    SampleViewController *sampleViewController = [[SampleViewController alloc] init];
    [self.window.contentView addSubview:sampleViewController.view];

}

@end
