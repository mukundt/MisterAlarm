/* Copyright (c) 2013 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <UIKit/UIKit.h>


// Controller for the third splash view screen in the
// tutorial
@interface Splash3ViewController : UIViewController

// Outlet for the title label on the view
@property(weak, nonatomic) IBOutlet UILabel *titleLabel;

// Outlet for the larger message area on the view
@property(weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
