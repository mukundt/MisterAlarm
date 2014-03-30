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

@interface ViewController : UIViewController <BLEDelegate> {
    BLE *bleShield;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonConnect;
@property (weak, nonatomic) IBOutlet UIButton *Alarm;
@property (strong, nonatomic) AVAudioPlayer *Audio;
@property (weak, nonatomic) IBOutlet UILabel *bobsLabel;
@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer *pgr;
- (IBAction)labelDragged:(UIPanGestureRecognizer *)pgr;
=======

@property (strong, nonatomic) FliteController *fliteController;
@property (strong, nonatomic) Slt *slt;

>>>>>>> 21e8b27641bc579dc0b18bda7a55e029b4a56c9a

@end
