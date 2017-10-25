
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 View controller for camera interface
 */

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@import Photos;

@interface ViewController () {
    NSTimer *_labelTimer;
    IBOutlet UILabel *versionLabel;
    float blendmode;
}

@property(nonatomic, strong) IBOutlet UILabel *framerateLabel;
@property(nonatomic, strong) IBOutlet UILabel *dimensionsLabel;

@end

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    _labelTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [_labelTimer invalidate];
    _labelTimer = nil;
    [super viewDidDisappear:animated];
}

- (void)updateLabels
{
    NSString *frameRateString = [NSString stringWithFormat:@"%d FPS", (int)roundf( [self framerate] )];
    self.framerateLabel.text = frameRateString;
}

-(void)loadAsset {
    // TODO: put movie here
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingPathComponent:@"background.mov"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    //[self extractVideoURL:url];
    //[self extractPictureURL:url];
}

- (void)viewDidLoad {

    [self setVideoSessionPreset:AVCaptureSessionPreset1280x720];

    [self clearTempDirectory];
    UISlider *slider = [[UISlider alloc] init];
    slider.value = 0.1;
    [self sliderTolerance:slider];
    [self loadAlgorithm];
    [self showVersion];
    blendmode = 0.0f;

    [self loadAsset];

    [super viewDidLoad];
}

- (void)showVersion {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"];
    [versionLabel setText:[NSString stringWithFormat:@"beta %@ %@", appVersion, buildNumber]];
}

// Load the external algoritmn
-(void)loadAlgorithm {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *algorithm = [documentPath stringByAppendingPathComponent:@"algorithm.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:algorithm] == YES) {
        NSString *algorithmString = [NSString stringWithContentsOfFile:algorithm encoding:NSUTF8StringEncoding error:NULL];
        [self loadAlgorithm:algorithmString];
    }
}

-(IBAction)switchCameraToFront:(id)sender {
    [self frontCameraWithCompletion:^{
        NSLog(@"done");
    }];
}

-(IBAction)changeSaturation:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [self setSaturation:slider.value];
}

-(IBAction)cycleBlendmode:(id)sender {
    blendmode = blendmode + 1.0f;
    if( blendmode > 4.0f ){
        blendmode = 0.0f;
    }
    [self setBlendmode:blendmode];
}

-(void)recordingStoppedForMovieAtURL:(NSURL *)url {
    if( UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.relativePath) == true){
        UISaveVideoAtPathToSavedPhotosAlbum(url.relativePath, nil, nil, nil);
    }
}

-(IBAction)flipMask:(id)sender {
    UISwitch *s = (UISwitch *)sender;
    [self invertBackground:s.isOn];
}

-(IBAction)startRecording:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"RECORDING NOW" forState:UIControlStateNormal];
    [self startRecording];
}

-(IBAction)stopRecording:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.backgroundColor = [UIColor blueColor];
    [btn setTitle:@"Record" forState:UIControlStateNormal];
    [self stopRecording];
}





@end
