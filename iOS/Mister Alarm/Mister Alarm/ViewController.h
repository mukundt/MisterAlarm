//
//  ViewController.h
//  Mister Alarm
//
//  Created by Ashley Lai on 3/28/14.
//  Copyright (c) 2014 A100 Crew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@interface ViewController : UIViewController <BLEDelegate> {
    BLE *bleShield;
}

@end
