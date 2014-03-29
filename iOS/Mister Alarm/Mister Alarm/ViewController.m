//
//  ViewController.m
//  Mister Alarm
//
//  Created by Ashley Lai on 3/28/14.
//  Copyright (c) 2014 A100 Crew. All rights reserved.
//

#import "ViewController.h"
#import "GTLCalendar.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    bleShield = [[BLE alloc] init];
    [bleShield controlSetup];
    bleShield.delegate = self;
    
    [self BLEShieldScan];
}

- (void)BLEShieldScan
{
    if (bleShield.activePeripheral)
        if (bleShield.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
            return;
        }
    
    if (bleShield.peripherals)
        bleShield.peripherals = nil;
    
    [bleShield findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
}


// Called when scan period is over to connect to the first found peripheral
-(void) connectionTimer:(NSTimer *)timer
{
    if(bleShield.peripherals.count > 0)
    {
        [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:0]];
    }
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
}

-(void) bleDidConnect
{
}

- (void) bleDidDisconnect
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray*) getCalendarEvents
{
    
    /* returns array of strings with calendar events for the day */
    //NSMutableArray* all_events = [NSMutableArray arrayWithObjects: nil];
    //NSDictionary* events = service.events().list(calendarId="countableirrationals@gmail.com", orderBy="startTime", singleEvents=true).execute();
    //NSArray* items = [events objectForKey:@"items"];
    //for (NSDictionary *item in items)
    //{
    //    NSString* single_event = [item objectForKey:@"summary"]; /* extract name of event */
    //    [all_events addObject:single_event]; /* add it to the list of events */
    //}
    //return all_events;
}

@end
