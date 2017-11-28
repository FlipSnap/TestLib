//
//  AVPlayerViewController.m
//  TestLib
//
//  Created by Rob Newport on 11/27/17.
//  Copyright © 2017 Whisteo. All rights reserved.
//

#import "AVViewController.h"

@interface AVViewController ()

@end

@implementation AVViewController 
@synthesize videoURL;

- (void)viewDidLoad {

    [super viewDidLoad];

    NSAssert(self.videoURL, @"Expected not nil video url");

    _playerViewController = [[AVPlayerViewController alloc] init];
    _playerViewController.player = [AVPlayer playerWithURL:self.videoURL];
    _playerViewController.view.frame = self.view.bounds;
    _playerViewController.showsPlaybackControls = YES;

    [self.view addSubview:_playerViewController.view];
    self.view.autoresizesSubviews = YES;

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setTitle:@"SAVE" forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(20, 60, 100, 35);
    saveButton.backgroundColor = UIColor.blackColor;
    [self.view addSubview:saveButton];

    [saveButton addTarget:self action:@selector(didSaveWithSender:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didSaveWithSender:(id)sender {
    UISaveVideoAtPathToSavedPhotosAlbum(self.videoURL.relativePath, nil, nil, nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
