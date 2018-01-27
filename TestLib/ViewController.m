
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
