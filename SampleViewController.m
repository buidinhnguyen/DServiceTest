//
//  SampleViewController.m
//  DSTest
//
//  Created by Nguyễn Trí Hiền on 4/21/14.
//  Copyright (c) 2014 LCL. All rights reserved.
//

#import "SampleViewController.h"
#import "CalendarObject.h"
#import "NSDate+CGICalendar.h"

#import <MailCore/MailCore.h>

@interface SampleViewController (){
    
    NSTimer *timer;
}

@property (weak) IBOutlet NSTextField *txtEmail;
@property (weak) IBOutlet NSTextField *txtPass;
@property (weak) IBOutlet NSTextField *txtURI;

@property (weak) IBOutlet NSScrollView *tvDisplay;
@property (weak) IBOutlet NSButton *btnChange;
@property (weak) IBOutlet NSTextField *lblChangeInfomation;

@property (weak) IBOutlet NSScrollView *tvMailList;

@end

@implementation SampleViewController

- (NSString *) filePathUser{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *userPath = [NSString stringWithFormat:@"%@/DB/user.plist", [paths objectAtIndex:0]];
    
    return userPath;
    
}

- (void) saveInfo{
    
    NSString *filePathUser = [self filePathUser];
    
    NSMutableDictionary* infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:filePathUser];
    
    infoDict = [NSMutableDictionary dictionary];
    [infoDict setObject:self.txtEmail.stringValue forKey:@"Email"];
    [infoDict setObject:self.txtPass.stringValue forKey:@"Password"];
    [infoDict setObject:self.txtURI.stringValue forKey:@"URI"];
    
    [infoDict writeToFile:filePathUser atomically:YES];
    
    [self.lblChangeInfomation setHidden:YES];
}

#pragma mark - Method sync Daemon

//Start Daemon
- (void) startAppleScriptFile{
    
    sleep(1.0f);
    
     //Start SH File
     NSString * scriptPath =
     [[NSBundle mainBundle] pathForResource: @"postinstall.sh" ofType: nil];
     [NSTask launchedTaskWithLaunchPath: scriptPath arguments: [NSArray new]];
}

//Stop Daemon
- (void) stopAppleScriptFile{
    
    NSString * scriptPath =
    [[NSBundle mainBundle] pathForResource: @"stopinstall.sh" ofType: nil];
    [NSTask launchedTaskWithLaunchPath: scriptPath arguments: [NSArray new]];
    
//    NSString *scriptPath = @"/Users/Thuc/Documents/DServiceTest/com.lcl.TestDaemon.plist";
//    //Exec path
//    [self runCommand:[NSString stringWithFormat:@"launchctl unload %@", scriptPath]];
    
}

//Exec CommandLine Xcode
- (NSString *) runCommand:(NSString *) commandToRun{
    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command: %@",commandToRun);
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return output;
}

- (NSString *)getFilePath: (NSString *) path{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    
    NSString *appBundleID = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *docPath = [docDirectory stringByAppendingPathComponent:appBundleID];
    return [docPath stringByAppendingPathComponent:path];
}

#pragma mark - Init System

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (BOOL) checkFileExist:(NSString *) strPath{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:strPath]) {
        return TRUE;
    }
    return FALSE;
}

- (NSString *) filePathDB{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *desktopPath = [paths objectAtIndex:0];
    
    return [NSString stringWithFormat:@"%@/DB/info.plist", desktopPath];
}

- (NSString *) filePathEmail{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *desktopPath = [paths objectAtIndex:0];
    
    return [NSString stringWithFormat:@"%@/DB/email.plist", desktopPath];
}

- (void) handleTimer:(NSTimer *) timerID{
    
    NSMutableArray *arrayData = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathDB]];
    
    BOOL success = [NSKeyedArchiver archiveRootObject:[NSMutableArray array] toFile:[self filePathDB]];
    if (!success) {
        
        NSLog(@"Error write file");
    }
    
    if (arrayData.count > 0) {
        
        NSString *strDisplayString = @"";
        
        for (int i = 0; i < arrayData.count; i++) {
            
            CalendarObject *curCalendarObject = [arrayData objectAtIndex:i];
            
            NSDate *start = [NSDate dateWithICalendarString:curCalendarObject.strStart];
            
            NSString *strStartDate = @"";
            
            if (start != nil) {
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
                strStartDate = [dateFormatter stringFromDate:start];
            }
            else{
                
                NSArray *arraySplit = [curCalendarObject.strStart componentsSeparatedByString:@":"];
                if (arraySplit.count == 0) {
                    
                    strStartDate = curCalendarObject.strStart;
                }
                else{
                    
                    for (int k = 0; k < arraySplit.count; k++) {
                        
                        NSDate *start_ = [NSDate dateWithICalendarString:[arraySplit objectAtIndex:1]];
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
                        strStartDate = [dateFormatter stringFromDate:start_];
                        
                        //strStartDate = [NSString stringWithFormat:@"%@Z", [arraySplit objectAtIndex:1]];
                    }
                }

            }
            
            NSString *strItem = [NSString stringWithFormat:@"(%d) Descripton: %@\n    Summary: %@ \n    Date: %@ \n", i + 1, curCalendarObject.strDescription.length > 0 ?  curCalendarObject.strDescription : @"(No description)", curCalendarObject.strSummary.length > 0 ? curCalendarObject.strSummary : @"No summary", strStartDate];
            strDisplayString = strDisplayString.length == 0 ? strItem: [NSString stringWithFormat:@"%@\n\n%@",strDisplayString, strItem];
        }
        
        [self.tvDisplay.documentView setString: strDisplayString];
        [self.tvDisplay.documentView setTextColor:[NSColor blackColor]];
        
        NSLog(@"%ld", arrayData.count);
    }
    else{
        
        [self.tvDisplay.documentView setString: @"No result or error exec"];
        [self.tvDisplay.documentView setTextColor:[NSColor redColor]];
        NSLog(@"Không có sự kiện");
    }
    
    // email
    NSMutableArray *mails = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathEmail]];
    
    if (mails.count > 0) {
        
        NSMutableString *string = [NSMutableString string];
        
        for (int i = 0; i < mails.count; i++) {
            
            MCOIMAPMessage *mail = [mails objectAtIndex:i];
            
            [string appendString:[NSString stringWithFormat:@"%@\n", [[mail header] subject]]];
        }
        
        [self.tvMailList.documentView setString: string];
        [self.tvMailList.documentView setTextColor:[NSColor blackColor]];
        
        NSLog(@"mail count: %ld", mails.count);
    }
}

- (void) loadView{
    
    [super loadView];
    
    [self.lblChangeInfomation setHidden:YES];
    [self.btnChange setTarget:self];
    [self.btnChange setAction:@selector(saveInfo)];
    
    //NSString *pathExecDaemon = [[NSBundle mainBundle] pathForResource:@"TestDaemon" ofType:nil];
    
    NSString *pathPlistDaemon = [[NSBundle mainBundle] pathForResource:@"com.lcl.TestDaemon.plist" ofType:nil];

    NSString * output = nil;
    NSString * processErrorDescription = nil;
    
    NSMutableArray *arrayScript = [NSMutableArray array];
    
    BOOL existDaemon = [self checkFileExist:@"/Library/LaunchDaemons/com.lcl.TestDaemon.plist"];
    
    if (!existDaemon) {
     
        [arrayScript addObject: [NSString stringWithFormat:@"'cp' %@ /Library/LaunchDaemons", pathPlistDaemon]];
    }
    
    BOOL existAgent = [self checkFileExist:@"/Library/LaunchAgents/com.lcl.TestDaemon.plist"];
    
    if (!existAgent) {
        
        [arrayScript addObject: [NSString stringWithFormat:@"'cp' %@ /Library/LaunchAgents", pathPlistDaemon]];
    }
    
    /*
    BOOL existDaemonBin = [self checkFileExist:@"/usr/local/bin/TestDaemon"];
    
    if (!existDaemonBin) {
        
         [arrayScript addObject: [NSString stringWithFormat:@"'cp' %@ /usr/local/bin", pathExecDaemon]];
    }
     */
    
    if (arrayScript.count > 0) {
        
        
        BOOL success = [self runProcessAsAdministratorWithArrayScript:arrayScript output:&output errorDescription:&processErrorDescription];
        
        if (!success){
            NSLog(@"Fail to exec");
        }
        else{
            
            [self startAppleScriptFile];
            timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
        }
    }
    else{
        
        [self startAppleScriptFile];
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    }
    
    NSMutableDictionary * infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:[self filePathUser]];
    
    if (infoDict != nil) {
        
        self.txtEmail.stringValue = [infoDict objectForKey:@"Email"];
        self.txtPass.stringValue = [infoDict objectForKey:@"Password"];
        self.txtURI.stringValue = [infoDict objectForKey:@"URI"];
    }
    else{
        
        self.txtEmail.stringValue = @"trihien.nguyen@leftcoastlogic.com";
        self.txtPass.stringValue = @"123456789";
        self.txtURI.stringValue = @"f70dede05c0572ae7ac50275f9d3e64c";
    }
    
    
}

- (BOOL) runProcessAsAdministratorWithArrayScript:(NSMutableArray *) arrayScript
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription {
    
    if (arrayScript.count == 0) {
        
        return NO;
    }
    
    NSString *strFullScript = @"";
    
    for (int i = 0; i < arrayScript.count; i++) {
        
        NSString *scriptItem = [arrayScript objectAtIndex:i];
        
        strFullScript = strFullScript.length == 0 ? scriptItem : [NSString stringWithFormat:@"%@ && %@", strFullScript, scriptItem];
    }
    
    NSDictionary *errorInfo = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", strFullScript];
    
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
    
    // Check errorInfo
    if (! eventResult){
        
        // Describe common errors
        *errorDescription = nil;
        if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
        {
            NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
            if ([errorNumber intValue] == -128)
                *errorDescription = @"The administrator password is required to do this.";
        }
        
        // Set error message from provided message
        if (*errorDescription == nil){
            
            if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
                *errorDescription =  (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
        }
        
        return NO;
    }
    else{
        
        // Set output to the AppleScript's output
        *output = [eventResult stringValue];
        return YES;
    }
}

- (BOOL) runProcessAsAdministrator:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription {
    
    NSString * allArgs = [arguments componentsJoinedByString:@" "];
    NSString * fullScript = [NSString stringWithFormat:@"'%@' %@", scriptPath, allArgs];
    
    NSDictionary *errorInfo = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
    
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
    
    // Check errorInfo
    if (! eventResult){
        
        // Describe common errors
        *errorDescription = nil;
        if ([errorInfo valueForKey:NSAppleScriptErrorNumber]){
            
            NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
            if ([errorNumber intValue] == -128)
                *errorDescription = @"The administrator password is required to do this.";
        }
        
        // Set error message from provided message
        if (*errorDescription == nil){
            
            if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
                *errorDescription =  (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
        }
        
        return NO;
    }
    else{
        
        // Set output to the AppleScript's output
        *output = [eventResult stringValue];
        return YES;
    }
}

@end