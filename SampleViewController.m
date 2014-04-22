//
//  SampleViewController.m
//  DSTest
//
//  Created by Nguyễn Trí Hiền on 4/21/14.
//  Copyright (c) 2014 LCL. All rights reserved.
//

#import "SampleViewController.h"
#import "CalendarObject.h"

@interface SampleViewController (){
    
    NSTimer *timer;
}

@property (weak) IBOutlet NSScrollView *tvDisplay;

@end

@implementation SampleViewController

#pragma mark - Method sync Daemon

//Start Daemon
- (void) startAppleScriptFile{
    
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
            
            NSString *strItem = [NSString stringWithFormat:@"(%d) Descripton: %@\n    Summary: %@", i + 1, curCalendarObject.strDescription.length > 0 ?  curCalendarObject.strDescription : @"(No description)", curCalendarObject.strSummary.length > 0 ? curCalendarObject.strSummary : @"No summary"];
            strDisplayString = strDisplayString.length == 0 ? strItem: [NSString stringWithFormat:@"%@\n\n%@",strDisplayString, strItem];
        }
        
        [self.tvDisplay.documentView setString: strDisplayString];
        
        NSLog(@"%ld", arrayData.count);
    }
    else{
        NSLog(@"Không có sự kiện");
    }
}

- (void) loadView{
    
    [super loadView];
    
    NSString *pathExecDaemon = [[NSBundle mainBundle] pathForResource:@"TestDaemon" ofType:nil];
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
    
    BOOL existDaemonBin = [self checkFileExist:@"/usr/local/bin/TestDaemon"];
    
    if (!existDaemonBin) {
        
         [arrayScript addObject: [NSString stringWithFormat:@"'cp' %@ /usr/local/bin", pathExecDaemon]];
    }
    
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