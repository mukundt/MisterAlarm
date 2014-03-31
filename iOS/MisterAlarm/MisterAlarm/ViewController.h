//
//  ViewController.h
//  MisterAlarm
//
//  Created by Tian Jin on 29/03/2014.
//  Copyright (c) 2014 A100. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import "AVFoundation/AVAudioPlayer.h"
#import <AVFoundation/AVPlayer.h>
#import "GTLCalendar.h"
#import <Slt/Slt.h>
#import <OpenEars/FliteController.h>
#import "STTwitter/STTwitter/STTwitter.h"

@interface ViewController : UIViewController <BLEDelegate> {
    BLE *bleShield;
    FliteController *fliteController;
    Slt *slt;
}
@property (weak, nonatomic) IBOutlet UIButton *buttonConnect;
@property (weak, nonatomic) IBOutlet UIButton *Alarm;
@property (strong, nonatomic) AVAudioPlayer *Audio;

@property (strong, nonatomic) FliteController *fliteController;
@property (strong, nonatomic) Slt *slt;

@property (weak, nonatomic) IBOutlet UILabel *bobsLabel;
@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer *pgr;
- (IBAction)labelDragged:(UIPanGestureRecognizer *)pgr;


@end
