//
//  ViewController.m
//  VideoEditDemo
//
//  Created by DaveLam on 2017/10/22.
//  Copyright © 2017年 org.forrest. All rights reserved.
//

#import "ViewController.h"
#import "VideoUtil.h"

@interface ViewController () {
    AVAsset *_firstAsset, *_secondAsset;
}
@property (weak, nonatomic) IBOutlet UIImageView *videoPlayImg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _firstAsset = nil;
    _secondAsset = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didMergePlayClicked:(id)sender
{
    NSLog(@"%@", [[VideoUtil sharedInstance] getAllIdentifiersFromAlbum]);
    [[VideoUtil sharedInstance] getVideoFromPhotoIdentifier:@"A8BB3AB8-E99C-4887-A624-6791FD4BFA45/L0/001" withCompleteHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        _firstAsset = asset;
        [self merge];
    }];
    [[VideoUtil sharedInstance] getVideoFromPhotoIdentifier:@"8A14F038-8F03-4241-961E-DA46D6BDDE31/L0/001" withCompleteHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        _secondAsset = asset;
        [self merge];
    }];
}

- (void)merge
{
    if (_firstAsset && _secondAsset) {
        // 路径
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *mergePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"merge_%lld.mp4", (long long int)[[NSDate date] timeIntervalSince1970] * 1000]];
        
        AVMutableComposition *composition = [AVMutableComposition composition];
        AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *firstVideoTrack = [[_firstAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        AVAssetTrack *secondVideoTrack = [[_secondAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _firstAsset.duration) ofTrack:firstVideoTrack atTime:kCMTimeZero error:nil];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _secondAsset.duration) ofTrack:secondVideoTrack atTime:_firstAsset.duration error:nil];
        
        AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *firstAudioTrack = [[_firstAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        AVAssetTrack *secondAudioTrack = [[_secondAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _firstAsset.duration) ofTrack:firstAudioTrack atTime:kCMTimeZero error:nil];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _secondAsset.duration) ofTrack:secondAudioTrack atTime:_firstAsset.duration error:nil];
        
        AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
        assetExport.outputFileType = AVFileTypeQuickTimeMovie;
        assetExport.outputURL = [NSURL fileURLWithPath:mergePath];
//        assetExport.shouldOptimizeForNetworkUse = YES;
        [assetExport exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (assetExport.status) {
                    case AVAssetExportSessionStatusFailed:
                        NSLog(@"导出失败，原因：%@", [[assetExport error] localizedDescription]);
                        break;
                    case AVAssetExportSessionStatusCancelled:
                        NSLog(@"导出取消");
                        break;
                    case AVAssetExportSessionStatusCompleted:
                        [self playWithURL:[NSURL fileURLWithPath:mergePath]];
                        break;
                    default:
                        break;
                }
            });
        }];
    }
}

- (void)playWithURL:(NSURL *)url
{
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.videoPlayImg.frame;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.videoPlayImg.layer addSublayer:playerLayer];
    [player play];
}

@end
