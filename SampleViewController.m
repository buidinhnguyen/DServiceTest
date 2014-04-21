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
    
    /*
     //Start SH File
     NSString * scriptPath =
     [[NSBundle mainBundle] pathForResource: @"postinstall.sh" ofType: nil];
     [NSTask launchedTaskWithLaunchPath: scriptPath arguments: [NSArray new]];
     */
    
    NSString *scriptPath = @"/Users/Thuc/Documents/DServiceTest/com.lcl.TestDaemon.plist";
    //Exec path
    [self runCommand:[NSString stringWithFormat:@"launchctl load %@", scriptPath]];
}

//Stop Daemon
- (void) stopAppleScriptFile{
    
    NSString *scriptPath = @"/Users/Thuc/Documents/DServiceTest/com.lcl.TestDaemon.plist";
    //Exec path
    [self runCommand:[NSString stringWithFormat:@"launchctl unload %@", scriptPath]];
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

- (NSString *) filePathDB{
    
    return @"/Users/Thuc/Desktop/DB/info.plist";
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
    
    [self startAppleScriptFile];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}

@end