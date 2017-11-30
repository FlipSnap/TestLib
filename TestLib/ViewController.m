
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

    [self setVideoSessionPreset:AVCaptureSessionPreset1280x720];

    [self clearTempDirectory];
    UISlider *slider = [[UISlider alloc] init];
    slider.value = 0.1;
    [self sliderTolerance:slider];
    [self loadAlgorithm];
    [self showVersion];
    blendmode = 0.0f;

    //self.maximumFramesImported = 30;

    [super viewDidLoad];
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
        //UISaveVideoAtPathToSavedPhotosAlbum(url.relativePath, nil, nil, nil);
        [self performSegueWithIdentifier:@"avplayer" sender:url];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"avplayer"] == true){
        AVViewController *avviewcontroller = [segue destinationViewController];
        NSURL *url = (NSURL *)sender;
        avviewcontroller.videoURL = url;
    }
}



@end
