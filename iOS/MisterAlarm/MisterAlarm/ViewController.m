//
//  ViewController.m
//  MisterAlarm
//
//  Created by Tian Jin on 29/03/2014.
//  Copyright (c) 2014 A100. All rights reserved.
//

#import "ViewController.h"
#import "GTLUtilities.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "AVFoundation/AVAudioPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize fliteController;
@synthesize slt;
GTMOAuth2Authentication *auth;

// HARDWARE IMPLEMENTATION //

int sensorCount = 0;
bool run = true;
bool login = true;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.buttonConnect.layer.cornerRadius = 5.0f;
    bleShield = [[BLE alloc] init];
    [bleShield controlSetup];
    bleShield.delegate = self;
}

- (IBAction)BLEShieldScan:(id)sender
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

-(void) connectionTimer:(NSTimer *)timer
{
    if(bleShield.peripherals.count > 0)
    {
        [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:0]];
    }
}

- (void) restart:(id) sender
{
    NSLog(@"C");
    run = true;
    [self alarm];
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSData *d = [NSData dataWithBytes:data length: length];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    
        if (sensorCount == 0){
            unsigned char toSend = 'B';
            NSLog(@"B");
            run = false;
            NSData *data = [NSData dataWithBytes: &toSend length: sizeof(toSend)];
            [bleShield write:data];
            [self.Audio pause];
            //[NSThread sleepForTimeInterval:4.0f];
            [NSTimer scheduledTimerWithTimeInterval:7.0f
                                         target:self selector:@selector(restart:) userInfo:nil repeats:NO];
            sensorCount++;
        }
    
        else if (sensorCount == 1){
            [self.Audio pause];
            [self textToSpeech:[self getSummary:[self dataToDictionary:[self stringToData:[self getCalendarEvents]]]]];
            [self.Audio play];
            sensorCount++;
        }
    
        else if (sensorCount == 2){
            //Horn
            unsigned char toSend = 'H';
            NSLog(@"H");
            NSData *data = [NSData dataWithBytes: &toSend length: sizeof(toSend)];
            [bleShield write:data];
            sensorCount = 0;
            //end demo here?
        }
    
}

-(void) bleDidConnect
{
    [self.buttonConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
}

- (void) bleDidDisconnect
{
    [self.buttonConnect setTitle:@"Connect" forState:UIControlStateNormal];
    [self BLEShieldScan:nil];
}

-(IBAction)alarmClick:(id)sender
{
    [self.Alarm setImage:[UIImage imageNamed:@"alarm-clock-click.png"] forState:UIControlStateNormal];
    [self alarm];
    
}

-(void) alarm
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"ontop"
                                         ofType:@"mp3"]];
    self.Audio = [[AVAudioPlayer alloc]
                  initWithContentsOfURL:url
                  error:nil];
    [self.Audio play];
    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self selector:@selector(lamp:) userInfo:nil repeats:NO];
}

- (void) lamp:(id)sender
{
    if (run){
    //Lamp
    unsigned char toSend = 'O';
    NSLog(@"O");
    NSData *data = [NSData dataWithBytes: &toSend length: sizeof(toSend)];
    [bleShield write:data];
    }
    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self selector:@selector(lampFlicker:) userInfo:nil repeats:NO];

}

- (void) lampFlicker:(id)sender
{
    if (run){
    unsigned char toSend = 'L';
    NSLog(@"L");
    NSData *data = [NSData dataWithBytes: &toSend length: sizeof(toSend)];
    [bleShield write:data];
    }
    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self selector:@selector(mister:) userInfo:nil repeats:NO];

}

- (void) mister:(id)sender
{

    //Lamp
    unsigned char toSend = 'S';
    NSLog(@"S");
    NSData *data = [NSData dataWithBytes: &toSend length: sizeof(toSend)];
    if (run){
    [bleShield write:data];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// GOOGLE API IMPLEMENTATION //

NSString *ret; //for calendar extraction fxn

- (NSString*) getCalendarEvents
{ // Returns json-formatted string of calendar events
    
    NSString *urlStr = @"https://www.googleapis.com/calendar/v3/calendars/countableirrationals%40gmail.com/events?";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"GET"];
    [auth authorizeRequest:request
         completionHandler:^(NSError *error) {
             NSString *output = nil;
             if (error) {
                 output = [error description];
             } else {
                 // Synchronous fetches like this are a really bad idea in Cocoa applications
                 // For a very easy async alternative, we could use GTMHTTPFetcher
                 NSURLResponse *response = nil;
                 NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                      returningResponse:&response
                                                                  error:&error];
                 if (data) {
                     // API fetch succeeded
                     output = [[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding] ;
                     NSLog(@"output:%@",output);
                     ret = output;
                     
                 } else {
                     // fetch failed
                     ret = [output copy];
                 }
             }
         }];
    return ret;
}

- (NSData*) stringToData:(NSString*) calendar_info
{   // Converts json string format to data
    NSData* data = [calendar_info dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (NSDictionary*) dataToDictionary:(NSData*)calendar_info
{
    // Create NSDictionary from the JSON data
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:calendar_info options:0 error:nil];
    return jsonDictionary;
}

- (NSMutableArray*) getSummary:(NSDictionary*)calendar_info
{
    // Returns array of events on calendar
    NSMutableArray* full_summary = [[NSMutableArray alloc] init];
    // Create array of dictionaries with key "items"
    NSArray* all_events = [calendar_info objectForKey:@"items"];
    // Create array of strings with key "summary";
    for (NSDictionary *event in all_events)
    {
        NSString *summary = [event objectForKey:@"summary"];
        [full_summary addObject: summary];
    }
    return full_summary; // Returns summary of strings
}

- (void) setup
{
    NSString *const kKeychainItemName = @"A100";
    
    NSString *clientID = @"56219686174-ac0e17o5elop5clqq7ctuep9f62b7t49.apps.googleusercontent.com";
    NSString *clientSecret = @"LkFdefQl6d0u8MzG8oEnmUup";
    
    NSString *scope = @"https://www.googleapis.com/auth/calendar.readonly";
    
    GTMOAuth2ViewControllerTouch *viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                                              clientID:clientID
                                                                                          clientSecret:clientSecret
                                                                                      keychainItemName:kKeychainItemName
                                                                                              delegate:self
                                                                                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [self presentModalViewController:viewController animated:YES];
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (NSMutableString*)combineString:(NSString*)event_array
{
    NSMutableString* all_events = @"Today, you have ";
    for (NSString* event in event_array)
    {
        NSString *new_event = event;
        all_events = [all_events stringByAppendingString:new_event];
        all_events = [all_events stringByAppendingString:@" and "];
        all_events = all_events.lowercaseString;
        NSLog(all_events);
        NSLog(@"ello");
    }
    all_events = [all_events stringByAppendingString:@" you better get a move on."];
    return all_events;
}

- (void)textToSpeech:(NSMutableArray*)event_array
{
    NSMutableString* combined_events = [self combineString: event_array];
    [self.fliteController say:combined_events withVoice:self.slt];
}

- (FliteController *)fliteController {
	if (fliteController == nil) {
		fliteController = [[FliteController alloc] init];
	}
	return fliteController;
}

- (Slt *)slt {
	if (slt == nil) {
		slt = [[Slt alloc] init];
	}
	return slt;
}


- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)Auth
                 error:(NSError *)error {
    if (error == nil) {
        auth = Auth;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    //[self dismissViewControllerAnimated:YES completion:nil];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    if (login)
    {
        [self setup];
        login = false;
    }
}

@end
