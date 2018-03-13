
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 View controller for camera interface
 */

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AVViewController.h"
@import Photos;

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    NSTimer *_labelTimer;
    IBOutlet UILabel *versionLabel;
    float blendmode;
    UIImagePickerController *picker;
    IBOutlet UISlider *slider1;
    IBOutlet UISlider *slider2;
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

- (void)viewDidLoad {

    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];

    //picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    //[self setVideoSessionPreset:AVCaptureSessionPreset1280x720];

    [self clearTempDirectory];
    //UISlider *slider = [[UISlider alloc] init];
    //slider.value = 0.1;
    //[self sliderTolerance:slider];
    [self loadAlgorithm];
    [self showVersion];
    blendmode = 0.0f;

    //[self depthOn:true];
    //self.maximumFramesImported = 30;

    [super viewDidLoad];
}

-(IBAction)sliderToleranceHSV:(id)sender {
    [self toleranceSettingForHue:slider1.value saturation:slider2.value vibrance:slider2.value];
}

- (IBAction)depth:(UISwitch *)sender {
    [self depthOn:sender.isOn];
}

- (IBAction)depthFilterSwitch:(UISwitch *)sender {
    [self depthFiltered:sender.isOn];
}

- (IBAction)selectPhoto:(UIButton *)sender {
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)rotateBackgroundPress:(UIButton *)sender {
    NSLog(@"starting");
    [self rotateBackgroundWithCompletion:^{
        NSLog(@"done");
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self extractVideoURL:videoURL withCompletion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [picker dismissViewControllerAnimated:YES completion:NULL];
            });
        }];
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)showVersion {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"];
    [versionLabel setText:[NSString stringWithFormat:@"beta %@ %@", appVersion, buildNumber]];
}

-(void)loadAlgorithm {
        [self loadAlgorithm:@"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"];
}

-(IBAction)switchCameraToFront:(id)sender {
    [self frontCameraWithCompletion:^{
        NSLog(@"switchCameraToFront");
    }];
}

-(IBAction)switchCameraToBack:(id)sender {
    [self backCameraWithCompletion:^{
        NSLog(@"switchCameraToBack");
    }];
}

-(IBAction)switchCameraToDepthFront:(id)sender {
    [self frontDepthCameraWithCompletion:^{
        NSLog(@"switchCameraToFront");
    }];
}

-(IBAction)switchCameraToDepthBack:(id)sender {
    [self backDepthCameraWithCompletion:^{
        NSLog(@"switchCameraToBack");
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
        //UISaveVideoAtPathToSavedPhotosAlbum(url.relativePath, nil, nil, nil);
        [self performSegueWithIdentifier:@"avplayer" sender:url];
    }
}

-(IBAction)flipMask:(id)sender {
    UISwitch *s = (UISwitch *)sender;
    [self invertBackground:s.isOn];
}

-(IBAction)startPicture {
    [self startPictureWithCompletion:^(UIImage *image){
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"avplayer"] == true){
        AVViewController *avviewcontroller = [segue destinationViewController];
        NSURL *url = (NSURL *)sender;
        avviewcontroller.videoURL = url;
    }
}



@end
