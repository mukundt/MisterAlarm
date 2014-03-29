//
//  ViewController.m
//  test
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


GTLCalendarCalendarList *calendarList;
NSError *calendarListFetchError;
GTLServiceTicket *calendarListTicket;
GTLCalendarEvents *events;
GTLServiceTicket *eventsTicket;
NSError *eventsFetchError;
GTMOAuth2Authentication *auth;




- (NSString*) getCalendarEvents
{ // Returns json-formatted string of calendar events
    
    NSString *urlStr = @"https://www.googleapis.com/calendar/v3/calendars/countableirrationals%40gmail.com/events?";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"GET"];
    __block NSMutableString *outp;
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
                          outp = output;
                          
                      } else {
                          // fetch failed
                          output = [error description];
                      }
                  }
              }];
    return outp;
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
        NSLog(@"Please work!");
    }
    return full_summary; // Returns summary of strings
}

/*- (NSMutableArray*) jSon_to_eventArray:(NSDictionary *)calendar_info
{
    //create an empty string array
    NSMutableArray *item_array= [NSMutableArray array];
    NSMutableArray *event_array= [NSMutableArray array];
    //loop through events in JSON
    NSLog(@"is this getting here");
    for (NSDictionary* event in calendar_info){
        NSArray *item= [event objectForKey:@"items"];
        [item_array addObject:item];
        NSLog(@"Everything is error!");
        NSLog(item);
    }
    NSLog(@"how about here?");
    //for each event, add the string under even summary to the array
    //return the array
    return (event_array);
    
} */

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


- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)Auth
                 error:(NSError *)error {
    if (error != nil) {
        NSLog(@"NOOOO!");
    } else {
        NSLog(@"Signed in");
        auth = Auth;

        
    }
    [self getSummary:[self dataToDictionary:[self stringToData:[self getCalendarEvents]]]];
}

AVAudioPlayer *audioPlayer;


- (void)textToSpeech:(NSMutableArray *)event_array
{
    for (NSString* event_str in event_array){
        NSString *eventURL = @"http://translate.google.com/translate_tts?ie=UTF-8&q=word&tl=en-us";
        eventURL=[eventURL stringByReplacingOccurrencesOfString:@"word"withString:event_str];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:eventURL, [[NSBundle mainBundle] resourcePath]]];
        
        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        audioPlayer.numberOfLoops = -1;
        
        if (audioPlayer == nil)
            NSLog([error description]);
        else 
            [audioPlayer play];
        
        /*NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:@"TestSound"
                                             ofType:@"m4a"]];
        self.Audio = [[AVAudioPlayer alloc]
                      initWithContentsOfURL:url
                      error:nil];
        [self.Audio play];*/
        
        /*AVPlayer *player = [[AVPlayer playerWithURL:[NSURL  URLWithString:@URL]] retain];
        [player play];*/
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setup];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
