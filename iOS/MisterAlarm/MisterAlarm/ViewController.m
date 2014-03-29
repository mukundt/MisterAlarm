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

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    
    if (sensorCount == 0){
        unsigned char toSend = 'B';
        NSData *data = [NSData dataWithBytes: &toSend length: sizeof(toSend)];
        [bleShield write:data];
        sensorCount++;
    }
    
    else if (sensorCount == 1){
        
        NSString *eventURL = @"http://translate.google.com/translate_tts?ie=UTF-8&q=Um,%20are%20you%20sure%20you%20want%20to%20do%20that?&tl=en-us";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:eventURL, [[NSBundle mainBundle] resourcePath]]];
        NSError *error;
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        audioPlayer.numberOfLoops = 1;
        
        if (audioPlayer == nil)
            NSLog([error description]);
        else
            [audioPlayer play];
        sensorCount++;
    }
    
    else if (sensorCount == 2){
        NSString *eventURL = @"http://translate.google.com/translate_tts?ie=UTF-8&q=We%20wanred%20you.&tl=en-us";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:eventURL, [[NSBundle mainBundle] resourcePath]]];
        NSError *error;
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        audioPlayer.numberOfLoops = 1;
        
        if (audioPlayer == nil)
            NSLog([error description]);
        else
            [audioPlayer play];
        //Horn
        unsigned char toSend = 'H';
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
}

-(IBAction)alarmClick:(id)sender
{
    [self.alarm setImage:[UIImage imageNamed:@"alarm-clock-click.png"] forState:UIControlStateNormal];
    
}

- (void) alarm
{
    //Lamp
    unsigned char toSend = 'L';
    NSData *data = [NSData dataWithBytes: &toSend length: sizeof(toSend)];
    [bleShield write:data];
    
    //Mister
    toSend = 'S';
    data = [NSData dataWithBytes: &toSend length: sizeof(toSend)];
    [bleShield write:data];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"ontop"
                                         ofType:@"mp3"]];
    self.Audio = [[AVAudioPlayer alloc]
                  initWithContentsOfURL:url
                  error:nil];
    [self.Audio play];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end