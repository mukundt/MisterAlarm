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

@interface ViewController : UIViewController <BLEDelegate> {
    BLE *bleShield;
}
@property (weak, nonatomic) IBOutlet UIButton *buttonConnect;
@property (weak, nonatomic) IBOutlet UIButton *alarm;
@property (strong, nonatomic) AVAudioPlayer *Audio;


@end
