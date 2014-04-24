//
//  AppDelegate.m
//  TestDaemon
//
//  Created by Nguyễn Trí Hiền on 4/15/14.
//  Copyright (c) 2014 ABC. All rights reserved.
//

#import "AppDelegate.h"
#import "Common.h"
#import "ASIHTTPRequest.h"
#import "TBXML.h"
#import "CalendarObject.h"

#import "NSTimer+Blocks.h"
#import <MailCore/MailCore.h>

@interface AppDelegate(){
    
    NSTimer *myTickTimer;
    TBXML *tbXML;
    CalendarObject *calendarObejct;
    NSMutableArray *arrayCalendar;
    
    MCOIMAPFetchMessagesOperation * op;

    NSString *strEmail;
    NSString *strURI;
    NSString *strPassword;
}

@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSString *hostname;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, retain) MCOIMAPSession *session;
@property (nonatomic, retain) MCOIMAPOperation *checkOp;

@property (nonatomic, strong) NSMutableArray *arrayData;
@property (nonatomic, strong) NSMutableDictionary *dicData;

@end

@implementation AppDelegate

#pragma mark - Methods

- (NSString *) replaceTODO:(NSString *) strSource{
    
    NSString *strProperty = @"class,completed,created,description,dtstamp,dtstart,geo,last-mod,location,organizer,percent,priority,recurid,seq,status,summary,uid,url,due,duration,attach,attendee,categories,comment,contact,exdate,exrule,rstatus,related,resources,rdate,rrule,x-prop";
    
    NSArray *arraySplit = [strProperty componentsSeparatedByString:@","];
    
    for (int i = 0; i < arraySplit.count; i++) {
        
        NSString *item = [arraySplit objectAtIndex:i];

        strSource = [strSource stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@", [item uppercaseString]] withString:[NSString stringWithFormat:@"\n%@", [item uppercaseString]]];
    }
    
    return strSource;
}

- (NSString *) replaceEVENT: (NSString * ) strSource{
    
    NSString *strProperty = @"class,created,description,dtstart,geo,last-mod,location,organizer,priority,dtstamp,seq,status,summary,transp,uid,url,recurid,dtend,duration,attach,attendee,categories,comment,contact,exdate,exrule,rstatus,related,resources,rdate,rrule,x-prop";
    
    NSArray *arraySplit = [strProperty componentsSeparatedByString:@","];
    
    for (int i = 0; i < arraySplit.count; i++) {
        
        NSString *item = [arraySplit objectAtIndex:i];
        
        strSource = [strSource stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@", [item uppercaseString]] withString:[NSString stringWithFormat:@"\n%@", [item uppercaseString]]];
    }
    
    return strSource;
}

- (NSString *) stringValueFromSource:(NSString *) strSource andKeyBegin:(NSString *) strKeyBegin andKeyEnd:(NSString *) strKeyEnd andType:(NSString *) typeReplace{
    
    NSString *newSource = strSource;

    NSScanner *theScanner = [NSScanner scannerWithString:newSource];
    
    NSString *splitString;
    
    [theScanner scanUpToString:strKeyBegin intoString:&splitString];
    [theScanner scanString:splitString intoString:NULL];
    
    newSource = [newSource stringByReplacingOccurrencesOfString:splitString withString:@""];
    
    
    theScanner = [NSScanner scannerWithString:newSource];
    
    NSString *stringValue;
    [theScanner scanString:strKeyBegin intoString:NULL];
    [theScanner scanUpToString:strKeyEnd intoString:&stringValue];
    
    if (stringValue == nil || stringValue.length == 0)
        return @"";
    
    stringValue = [stringValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if ([typeReplace isEqualToString:@"VTODO"]) {
        
        stringValue = [self replaceTODO:stringValue];
    }
    else if ([typeReplace isEqualToString:@"EVENT"]){
        
        stringValue = [self replaceEVENT:stringValue];
    }
    
    

    return stringValue;
    
}

- (NSString *) getValueFromProperty:(NSString *) propertyName withStringSource:(NSString *) stringValue{
    
    NSArray *arraySplit = [stringValue componentsSeparatedByString:@"\n"];
    for (int i = 0; i < arraySplit.count; i++) {
        
        NSString *item = [arraySplit objectAtIndex:i];
        
        if ([item rangeOfString:propertyName].location != NSNotFound){
            
            NSScanner *theScanner = [NSScanner scannerWithString:item];
            NSString *strValue;
            [theScanner scanString:[NSString stringWithFormat:@"%@:", propertyName] intoString:NULL];
            [theScanner scanUpToString:[NSString stringWithFormat:@"%@:", propertyName] intoString:&strValue];
            return strValue;
        }

    }
    
    return @"";
}

- (void) traverseReportSabriList:(TBXMLElement *)element{
    
    do {
        
        NSString *elementName = [TBXML elementName:element];
        
        if ([elementName isEqualToString:@"d:response"]) {
            
            tbXML.isHaveDataResponse = TRUE;
        }
        
        if (tbXML.isHaveDataResponse){
            
            if ([elementName isEqualToString:@"d:href"]) {
                
                calendarObejct = [[CalendarObject alloc] init];
                calendarObejct.strHref = [TBXML textForElement:element];
            }
            
            if ([elementName isEqualToString:@"cal:calendar-data"]) {
            
                calendarObejct.strData = [TBXML textForElement:element];
                
                NSLog(@"%@", calendarObejct.strData);
                
                //VTODO
                if ([calendarObejct.strData rangeOfString:@"BEGIN:VTODO"].location != NSNotFound) {
                    
                     NSString *stringValue = [self stringValueFromSource:calendarObejct.strData andKeyBegin:@"BEGIN:VTODO" andKeyEnd:@"END:VTODO" andType:@"VTODO"];
                    
                    calendarObejct.strType = @"TODO";
                    
                    //SUMMARY
                    NSString *strSummary = [self getValueFromProperty:@"SUMMARY" withStringSource:stringValue];
                    
                    calendarObejct.strSummary = strSummary;
                    
                    //DESCRIPTION
                    NSString *strDescription = [self getValueFromProperty:@"DESCRIPTION" withStringSource:stringValue];
                    calendarObejct.strDescription = strDescription;
                    
                    //DTSTART
                    NSString *strStart = [self getValueFromProperty:@"DTSTART" withStringSource:stringValue];
                    calendarObejct.strStart = strStart;
                    
                }
                //EVENT
                else if ([calendarObejct.strData rangeOfString:@"BEGIN:VEVENT"].location != NSNotFound) {
                    
                    NSString *stringValue = [self stringValueFromSource:calendarObejct.strData andKeyBegin:@"BEGIN:VEVENT" andKeyEnd:@"END:VEVENT" andType:@"EVENT"];
                    
                    calendarObejct.strType = @"EVENT";
                    
                    //SUMMARY
                    NSString *strSummary = [self getValueFromProperty:@"SUMMARY" withStringSource:stringValue];
                    
                    calendarObejct.strSummary = strSummary;
                    
                    //DESCRIPTION
                    NSString *strDescription = [self getValueFromProperty:@"DESCRIPTION" withStringSource:stringValue];
                    
                    calendarObejct.strDescription = strDescription;
                    
                    //DTSTART
                    NSString *strStart = [self getValueFromProperty:@"DTSTART" withStringSource:stringValue];
                    calendarObejct.strStart = strStart;
                    
                }
                
                [arrayCalendar addObject:calendarObejct];
                
            }
        }
        
        if (element->firstChild)
            [self traverseReportSabriList:element->firstChild];
        
    } while ((element = element->nextSibling));
}

- (void) getReportSabri:(StringError) stringError{
    
    __block BOOL is_Error = FALSE;
    __block BOOL is_ShowDetail = FALSE;
    __block NSString *strStringHeader = @"";
    __block NSString *strStringDetail = @"";
    
    NSString *strUrl = [NSString stringWithFormat: @"http://192.168.1.7:8087/calendarserver.php/calendars/%@/%@", strEmail, strURI];

    NSString *strReport = [Common getReportSabri];
    
    const NSInteger length = [strReport length];
    
    //Call Service
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strUrl]];
    [request setRequestMethod:@"REPORT"];
    [request appendPostData:[strReport dataUsingEncoding:NSUTF8StringEncoding]];
    [request setTimeOutSeconds:300];
    [request addRequestHeader:@"Content-Type" value:@"application/xml"];
    [request addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%ld", (long)length]];
    [request setUsername:strEmail];
    [request setPassword:strPassword];
    
    //Success
    [request setCompletionBlock:^{
        
        NSString *responseText = [request responseString];
        NSData *xmlData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
        
        if (xmlData == nil) {
            
            is_Error = TRUE;
            is_ShowDetail = YES;
            strStringHeader = @"LỖI LẤY DỮ LIỆU ICAL SABRI";
            strStringDetail = @"Không nhận được giá trị của service";
        }
        else{
            
            tbXML = [[TBXML alloc] initWithXMLData:xmlData error:nil];
            if (tbXML.rootXMLElement) {
                [self traverseReportSabriList:tbXML.rootXMLElement];
            }
            
            if (!tbXML.isHaveDataResponse) {
                
                responseText = [NSString stringWithFormat:@"%@ \nLink URL: %@", responseText, strUrl];
                is_Error = TRUE;
                is_ShowDetail = YES;
                
                strStringHeader = @"LỖI LẤY DỮ LIỆU ICAL SABRI";
                strStringDetail = responseText;
            }
            else{
                
                if (tbXML.isError) {
                    
                    is_Error = TRUE;
                    is_ShowDetail = YES;
                    strStringHeader = @"LỖI LẤY DỮ LIỆU ICAL SABRI";
                    strStringDetail = tbXML.errorMessageString;
                }
                else{
                    
                    is_Error = FALSE;
                    is_ShowDetail = FALSE;
                    strStringHeader = @"";
                    strStringDetail = @"";
                }
            }
        }
        
        request.isFinishProcess = TRUE;
        
    }];
    
    //Error
    [request setFailedBlock:^{
        
        is_Error = TRUE;
        is_ShowDetail = YES;
        strStringHeader = @"LỖI LẤY DỮ LIỆU ICAL SABRI";
        strStringDetail = [[request error] description];
        request.isFinishProcess = TRUE;
    }];
    //Call
    [request startAsynchronous];
    
    //Waiting
    while (!request.isFinishProcess) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        }
    }
    
    stringError(is_Error, strStringHeader, strStringDetail, is_ShowDetail);
    
}

#pragma mark - Init

- (id) init {
    
	if ((self = [super init])){
        
        NSLog(@"init coiiiiii");
        
		[self performSelector:@selector(setup) withObject:self afterDelay:0.5f];
		
		return self;
	}
	return nil;
}

- (void) timerHandle:(NSTimer *) timer{
    
    //Khởi tạo lại đối tượng
    arrayCalendar = [NSMutableArray array];
    [timer invalidate];
    
    NSString *filePathUser = [self filePathUser];
    
    NSMutableDictionary* infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:filePathUser];
    
    if (infoDict != nil) {
        
        strEmail = [infoDict objectForKey:@"Email"];
        strPassword = [infoDict objectForKey:@"Password"];
        strURI = [infoDict objectForKey:@"URI"];
    }
    else{
        
        infoDict = [NSMutableDictionary dictionary];
        
        [infoDict setObject:@"trihien.nguyen@leftcoastlogic.com" forKey:@"Email"];
        [infoDict setObject:@"123456789" forKey:@"Password"];
        [infoDict setObject:@"f70dede05c0572ae7ac50275f9d3e64c" forKey:@"URI"];
        
        strEmail = @"trihien.nguyen@leftcoastlogic.com";
        strPassword = @"123456789";
        strURI = @"f70dede05c0572ae7ac50275f9d3e64c";
        
        [infoDict writeToFile:filePathUser atomically:YES];
    }
    
    [self getReportSabri:^(BOOL isError, NSString *stringHeader, NSString *stringError, BOOL showDetail){
        
        if (isError) {
            
            NSLog(@"Error: %@", stringError);
            
            myTickTimer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(timerHandle:) userInfo:nil repeats:YES];
            
            [[NSRunLoop currentRunLoop] addTimer:myTickTimer forMode:NSDefaultRunLoopMode];
        }
        else{
            
            self.arrayData = [NSMutableArray arrayWithArray:arrayCalendar];
            BOOL success = [NSKeyedArchiver archiveRootObject:self.arrayData toFile:[self filePathDB]];
            
            if (success) {
                
                myTickTimer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(timerHandle:) userInfo:nil repeats:YES];
                
                [[NSRunLoop currentRunLoop] addTimer:myTickTimer forMode:NSDefaultRunLoopMode];
                
                NSLog(@"Count: %ld", arrayCalendar.count);
            }
           
        }
        
    }];
    
}

- (void) setup{
    
    myTickTimer = [NSTimer timerWithTimeInterval:5.0f target:self selector:@selector(timerHandle:) userInfo:nil repeats:YES];
    
	[[NSRunLoop currentRunLoop] addTimer:myTickTimer forMode:NSDefaultRunLoopMode];
    
    // login to imap server
    [self loginImap:^(bool status){
        if(!status) {
            NSLog(@"login IMap failed");
            return;
        }
        
        [self getEmailData];
    }];
}

- (void) getEmailData {
    __block BOOL isGetting = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:5.0 block:^
     {
         if(!isGetting) {
             isGetting = YES;
             __block NSMutableArray *data = [NSMutableArray array];
             
             self.session = [[MCOIMAPSession alloc] init];
             [self.session setHostname:self.hostname];
             [self.session setPort:993];
             
             
             [self.session setUsername:self.login];
             [self.session setPassword:self.password];
             
             [_session setConnectionType:MCOConnectionTypeTLS];
             
             // xu ly email:
             // get email
             MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
             (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
              MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
              MCOIMAPMessagesRequestKindFlags);
             
             op = [_session fetchMessagesByUIDOperationWithFolder:@"INBOX" requestKind:requestKind uids:[MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)]];
             [op setProgress:^(unsigned int current){
                 //NSLog(@"progress: %u", current);
             }];
             [op start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
                 // Sort the messages with the most recent first.
                 //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
                 //data = [messages sortedArrayUsingDescriptors:@[sort]];
                 
                 NSLog(@"error: %@", error);
                 NSLog(@"%i messages", (int) [messages count]);
                 //NSLog(@"%@", _messages);
                 
                 for (MCOIMAPMessage * msg in messages) {
                     [data addObject:msg];
                     
                     NSLog(@"message: %@", [[msg header] subject]);
                 }
                 
                 // parse email
                 // save to local
                 // tick tiep...
                 BOOL success = [NSKeyedArchiver archiveRootObject:data toFile:[self filePathEmail]];
                 if(success)
                     isGetting = NO;
             }];
         }
     }
                                    repeats:YES];
}

- (NSString *) filePathDB{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *desktopPath = [NSString stringWithFormat:@"%@/DB", [paths objectAtIndex:0]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:desktopPath]) {
     
        [fileManager createDirectoryAtPath:desktopPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return [NSString stringWithFormat:@"%@/info.plist", desktopPath];
    
}

- (NSString *) filePathEmail{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *desktopPath = [NSString stringWithFormat:@"%@/DB", [paths objectAtIndex:0]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:desktopPath]) {
        
        [fileManager createDirectoryAtPath:desktopPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return [NSString stringWithFormat:@"%@/email.plist", desktopPath];
    
}
    
    - (NSString *) filePathUser{
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
        NSString *desktopPath = [NSString stringWithFormat:@"%@/DB", [paths objectAtIndex:0]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:desktopPath]) {
            
            [fileManager createDirectoryAtPath:desktopPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        return [NSString stringWithFormat:@"%@/user.plist", desktopPath];
        
    }

- (void) loginImap:(void (^)(bool status))inBlock {
    // papcui1@gmail.com
    // 1234@cuimia
    self.login = @"papcui1@gmail.com";
    self.password = @"1234@cuimia";
    self.hostname = @"imap.gmail.com";
    
    self.session = [[MCOIMAPSession alloc] init];
    [self.session setHostname:self.hostname];
    [self.session setPort:993];
    
    
        [self.session setUsername:self.login];
        [self.session setPassword:self.password];
    
    [self.session setConnectionType:MCOConnectionTypeTLS];
    self.checkOp = [self.session checkAccountOperation];
	self.session.connectionLogger = ^(void * connectionID, MCOConnectionLogType type, NSData * data) {
        if (type != MCOConnectionLogTypeSentPrivate) {
            NSLog(@"event logged:%p %i withData: %@", connectionID, type, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
    };
	
	NSLog(@"start op");
    [self.checkOp start:^(NSError * error) {
		[self willChangeValueForKey:@"loggingIn"];
        
        self.checkOp = nil;
        self.session = nil;
		
		[self didChangeValueForKey:@"loggingIn"];
		
		NSLog(@"op done (error: %@)", error);
		//if (error != nil)
		//	[_accountWindow makeKeyAndOrderFront:nil];
        //[_msgListViewController connectWithHostname:self.hostname login:self.login password:self.password oauth2Token:self.oauth2Token];
        
        if(error!=nil) {
            inBlock(false);
        }
        else {
            inBlock(true);
        }
	}];
}

@end
