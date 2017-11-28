//
//  AVPlayerViewController.h
//  TestLib
//
//  Created by Rob Newport on 11/27/17.
//  Copyright © 2017 Whisteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface AVViewController : UIViewController

@property (nonatomic, retain) AVPlayerViewController *playerViewController;
@property (nonatomic, retain) NSURL *videoURL;

@end
