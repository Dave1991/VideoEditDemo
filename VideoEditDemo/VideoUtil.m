//
//  VideoUtil.m
//  VideoEditDemo
//
//  Created by DaveLam on 2017/10/22.
//  Copyright © 2017年 org.forrest. All rights reserved.
//

#import "VideoUtil.h"
#import <Photos/Photos.h>

@implementation VideoUtil

static VideoUtil *instance;
- (PHAsset *)getVideoAssetFromPhotoIdentifier:(NSString *)identifier
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:fetchOptions];
    PHAsset *retAsset = nil;
    if (fetchResult.count > 0) {
        retAsset = fetchResult.firstObject;
    }
    return retAsset;
}

- (NSMutableArray *)getAllIdentifiersFromAlbum
{
    PHFetchResult *videoAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumVideos options:nil];
    NSMutableArray *retArray = [NSMutableArray new];
    [videoAlbums enumerateObjectsUsingBlock:^(PHCollection *collection, NSUInteger idx, BOOL *stop) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger assetIdx, BOOL *stop) {
                NSLog(@"PHAsset: %@", asset);
                [retArray addObject:asset];
            }];
        } else {
            NSLog(@"Fetch collection not PHAssetCollection: %@", collection);
        }
    }];
    return retArray;
}

- (void)getVideoFromPhotoIdentifier:(NSString *)identifier withCompleteHandler:(void (^)(AVAsset *, AVAudioMix *, NSDictionary *)) completeHandler
{
    PHAsset *phasset = [self getVideoAssetFromPhotoIdentifier:identifier];
    [[PHImageManager defaultManager] requestAVAssetForVideo:phasset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        completeHandler(asset, audioMix, info);
    }];
}

+ (VideoUtil *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VideoUtil alloc] init];
    });
    return instance;
}

@end
