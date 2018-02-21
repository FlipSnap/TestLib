
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
    UISlider *slider = [[UISlider alloc] init];
    slider.value = 0.1;
    [self sliderTolerance:slider];
    [self loadAlgorithm];
    [self showVersion];
    blendmode = 0.0f;

    //[self depthOn:true];
    //self.maximumFramesImported = 30;

    [super viewDidLoad];
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
