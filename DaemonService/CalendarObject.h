//
//  CalendarObject.h
//  TestDaemon
//
//  Created by Nguyễn Trí Hiền on 4/16/14.
//  Copyright (c) 2014 ABC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarObject : NSObject

@property (nonatomic, strong) NSString *strHref;
@property (nonatomic, strong) NSString *strData;
@property (nonatomic, strong) NSString *strStart;
@property (nonatomic, strong) NSString *strEnd;
@property (nonatomic, strong) NSString *strDescription;
@property (nonatomic, strong) NSString *strSummary;
@property (nonatomic, strong) NSString *strType;

@end
