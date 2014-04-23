//
//  Common.m
//  TestDaemon
//
//  Created by Nguyễn Trí Hiền on 4/15/14.
//  Copyright (c) 2014 ABC. All rights reserved.
//

#import "Common.h"

@implementation Common

+ (NSString *) getAllReportSabri{
    
    return @"<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n"
    @"<D:principal-match xmlns:D=\"DAV:\">"
    @"<D:self/>"
    @"<D:prop>"
    @"<C:calendar-home-set xmlns:C=\"urn:ietf:params:xml:ns:caldav\"/>"
    @"</D:prop>"
    @"</D:principal-match>";
}

+ (NSString *) getReportSabri{
    
    return @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    @"<C:calendar-query xmlns:D=\"DAV:\" xmlns:C=\"urn:ietf:params:xml:ns:caldav\">"
    @"<D:prop>"
    @"<D:getetag />"
    @"<C:calendar-data />"
    @"</D:prop>"
    @"<C:filter>"
    @"<C:comp-filter name=\"VCALENDAR\">"
    @"</C:comp-filter>"
    @"</C:filter>"
    @"</C:calendar-query>";
}

@end
