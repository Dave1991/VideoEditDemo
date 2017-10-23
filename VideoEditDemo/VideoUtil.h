//
//  VideoUtil.h
//  VideoEditDemo
//
//  Created by DaveLam on 2017/10/22.
//  Copyright © 2017年 org.forrest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface VideoUtil : NSObject

+ (VideoUtil *)sharedInstance;
- (NSMutableArray *)getAllIdentifiersFromAlbum;
- (void)getVideoFromPhotoIdentifier:(NSString *)identifier withCompleteHandler:(void (^)(AVAsset *, AVAudioMix *, NSDictionary *)) completeHandler;

@end
