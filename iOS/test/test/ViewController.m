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
{
    
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
                      //
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
                          
                          
                      } else {
                          // fetch failed
                          output = [error description];
                      }
                  }
                  
              }];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //data =nil;
    
    NSArray *jsonArray = [responseString JSONValue];
    
    return output;

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


- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)Auth
                 error:(NSError *)error {
    if (error != nil) {
        NSLog(@"NOOOO!");
    } else {
        NSLog(@"Signed in");
        auth = Auth;

        
    }
    [self jSon_to_eventArray:[self getCalendarEvents]];
}



- (NSMutableArray*)jSon_to_eventArray:(NSString *)calendar_info
{
    //create an empty string array
    NSMutableArray *item_array= [NSMutableArray array];
    NSMutableArray *event_array= [NSMutableArray array];
    //loop through events in JSON
    for (NSDictionary* event in calendar_info){
        NSString *item= @"items";
        [item_array addObject:item];
        NSLog(item);
    }
    //for each event, add the string under even summary to the array
    //return the array
    return (event_array);
    
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
