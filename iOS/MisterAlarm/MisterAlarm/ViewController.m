//
//  ViewController.m
//  MisterAlarm
//
//  Created by Tian Jin on 29/03/2014.
//  Copyright (c) 2014 A100. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

int sensorCount = 0;
bool run = true;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.buttonConnect.layer.cornerRadius = 5.0f;
    UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateImagePosition:)];
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
    [self alarm:nil];
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSData *d = [NSData dataWithBytes:data length: length];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSLog(s);
    
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
            //CALLING CALENDAR FUNCTION HERE
            [self.Audio play];
            sensorCount++;
        }
    
        else if (sensorCount == 2){
            //Horn
            unsigned char toSend = 'H';
            NSLog(@"H");
            NSData *data = [NSData dataWithBytes: &toSend length: sizeof(toSend)];
            run = false;
            [self.Audio pause];
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
    run = true;
    [NSTimer scheduledTimerWithTimeInterval:6.0f
                                     target:self selector:@selector(alarm:) userInfo:nil repeats:NO];
}

- (IBAction) labelDragged:(UIPanGestureRecognizer *)recognizer
{
	UILabel *label = (UILabel *)recognizer.view;
    CGPoint translation = [recognizer translationInView:self.view];
    
    int raw = MIN(MAX((translation.y + 200), 0), 400);
    int hour = raw / 33;
    int minute = raw % 33;
    if (hour == 12) {
        hour = 11;
        minute = 59;
    }
    if (hour == 0) hour = 12;

    NSString *myT = [NSString stringWithFormat:@"%d:%.2d", hour, minute];
	[label setText:myT];
}

-(IBAction)alarmClick:(id)sender
{
    [self.Alarm setImage:[UIImage imageNamed:@"alarm-clock-click.png"] forState:UIControlStateNormal];
    [self alarm:nil];
    
}

-(void) alarm:(id)sender
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"ontop"
                                         ofType:@"mp3"]];
    self.Audio = [[AVAudioPlayer alloc]
                  initWithContentsOfURL:url
                  error:nil];
    [self.Audio play];
    [NSTimer scheduledTimerWithTimeInterval:6.0f
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
    [NSTimer scheduledTimerWithTimeInterval:7.0f
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

@end
