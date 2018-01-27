
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

// Load the external algoritmn
-(void)loadAlgorithm {
//    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *algorithm = [documentPath stringByAppendingPathComponent:@"algorithm.txt"];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if([fileManager fileExistsAtPath:algorithm] == YES) {
//        NSString *algorithmString = [NSString stringWithContentsOfFile:algorithm encoding:NSUTF8StringEncoding error:NULL];
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
