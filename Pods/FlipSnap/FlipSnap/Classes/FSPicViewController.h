//
//  FSPicViewController.h
//  FlipSnapLibrary
//
//  Created by Rob Newport on 9/13/17.
//  Copyright © 2017 Whisteo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPicViewController : UIViewController

// User Interface Objects
@property(nonatomic, strong) IBOutlet UISlider *toleranceSlider;

// User Interface Actions
-(void)resetColors;

// Algorithm Management
-(void)loadAlgorithmAtPath:(NSString *)algorithmPath;
-(NSString *)algorithmDescription;
-(NSString *)algorithmName;
-(NSString *)algorithmExpiration;

// Forground and Background Image Management
@property (nonatomic, getter=backgroundImage, setter=setBackgroundImage:) UIImage *backgroundImage;
@property (nonatomic, getter=image, setter=setImage:) UIImage *image;

@end
