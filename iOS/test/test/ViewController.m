//
//  ViewController.m
//  test
//
//  Created by Tian Jin on 29/03/2014.
//  Copyright (c) 2014 A100. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (GTLCalendarEvents *) getCalendarEvents
{
    __block GTLCalendarEvents *events;
    NSString *calendarID = [NSString stringWithFormat:@"countableirrationals@gmail.com"];
    GTLQueryCalendar *eventsQuery = [GTLQueryCalendar queryForEventsListWithCalendarId:calendarID];
    eventsQuery.completionBlock = ^(GTLServiceTicket *ticket, id object, NSError *error) {
        events = object;
        NSLog(error);
    };
    GTLCalendarEvent *item = [events itemAtIndex:0];
    NSLog(item.identifier);
    return events;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self getCalendarEvents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
