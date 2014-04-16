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

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSString *data = @"BEGIN:VCALENDAR \
    PRODID:X-RICAL-TZSOURCE=TZINFO:mysmartday.com \
CALSCALE:GREGORIAN \
VERSION:2.0 \
BEGIN:VTIMEZONE \
    TZID:X-RICAL-TZSOURCE=TZINFO:America/Chicago \
BEGIN:DAYLIGHT \
DTSTART:20140309T020000 \
RDATE:20140309T020000 \
TZOFFSETFROM:-0600 \
TZOFFSETTO:-0500 \
TZNAME:CDT \
END:DAYLIGHT \
END:VTIMEZONE \
BEGIN:VTODO \
    CREATED:VALUE=DATE-TIME:20140415T135158Z \
    DTSTART:TZID=America/Chicago;VALUE=DATE-TIME:20140415T085158 \
UID:2a549164f479c2cad1d041c4fd696817.ics \
DESCRIPTION: \
URL: \
SUMMARY:Welcome to SmartDay! To get started , tap this Task to reveal the \
    attached note... \
LOCATION: \
SEQUENCE:2 \
END:VTODO \
END:VCALENDAR";
    
    //EKEventStore *eventDB = [[EKEventStore alloc] init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"school" ofType:@"ics"];
    
    //CGICalendar *cal = [[CGICalendar alloc] initWithString:data];
    CGICalendar *cal = [[CGICalendar alloc] initWithPath:path];
    
    //NSLog(@"%ld", [[cal objects] count]);
    
    CGICalendarObject *obj = [cal objectAtIndex:0];
    NSLog(@"%ld     %ld     %ld     %ld", [[obj events] count], [[obj todos] count] , [[obj timezones] count], [[obj freebusies] count]);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receviveFromDeamon:)
                                                 name:@"com.lcl.demo.deamonpost" object:nil];
}

- (void) receviveFromDeamon:(NSNotification *) nitif {
    NSLog(@"receive from deamon");
}

@end
