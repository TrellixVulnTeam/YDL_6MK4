//
//  MediaTool.h
//  TubeD
//
//  Created by Damon on 2018/8/22.
//  Copyright © 2018年 Damon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaTool : NSObject
NS_ASSUME_NONNULL_BEGIN
-(NSDictionary *)readVideoInfoWithPath:(NSString *)path;
//将H264的视频流与AAC音频流混合 输出MP4文件
-(void)mixVideo:(NSString *)vPath WithAudio:(NSString *)aPath toPath:(NSString *)outPath Results:(nullable void (^)(BOOL isSuccess))results;
//将MP4文件的音频分离出来 输出AAC文件
-(void)separateAudioFromVideo:(NSString *)vPath toPath:(NSString *)outPath Results:(nullable void (^)(BOOL isSuccess))results;
NS_ASSUME_NONNULL_END
@end
