//
//  CalendarObject.m
//  TestDaemon
//
//  Created by Nguyễn Trí Hiền on 4/16/14.
//  Copyright (c) 2014 ABC. All rights reserved.
//

#import "CalendarObject.h"

@implementation CalendarObject


- (id)initWithCoder:(NSCoder *)decoder
{
    self.strHref = [decoder decodeObjectForKey:@"strHref"];
    self.strData = [decoder decodeObjectForKey:@"strData"];
    self.strStart = [decoder decodeObjectForKey:@"strStart"];
    self.strEnd = [decoder decodeObjectForKey:@"strEnd"];
    self.strDescription = [decoder decodeObjectForKey:@"strDescription"];
    self.strSummary = [decoder decodeObjectForKey:@"strSummary"];
    self.strType = [decoder decodeObjectForKey:@"strType"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.strHref forKey:@"strHref"];
    [encoder encodeObject:self.strData forKey:@"strData"];
    [encoder encodeObject:self.strStart forKey:@"strStart"];
    [encoder encodeObject:self.strEnd forKey:@"strEnd"];
    [encoder encodeObject:self.strDescription forKey:@"strDescription"];
    [encoder encodeObject:self.strSummary forKey:@"strSummary"];
    [encoder encodeObject:self.strType forKey:@"strType"];
}


@end
