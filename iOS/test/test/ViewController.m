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




- (void) getCalendarEvents
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
    [self getCalendarEvents];
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
