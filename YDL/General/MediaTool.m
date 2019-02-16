//
//  MediaTool.m
//  TubeD
//
//  Created by Damon on 2018/8/22.
//  Copyright © 2018年 Damon. All rights reserved.
//

#import "MediaTool.h"
#import "MediaFileInfo.h"
#import "PythonManager.h"
#import "MediaFormatter.h"

@implementation MediaTool
-(NSDictionary *)readVideoInfoWithPath:(NSString *)path{
    
    NSMutableDictionary *fileInfo = [NSMutableDictionary dictionary];
    
    MYMediaInfo *info = AllocMediaInfo();
    InitMyMediaInfo(info);
    SetThumbnailDimension(info, 320, 240);
    GetMediaInfo([path UTF8String], info);
    
    //缩略图
    unsigned long imageSize = 0;
    unsigned char *imageData = GenerateBmp(info, &imageSize);
    NSData *binaryIMG = (imageData != NULL)?[NSData dataWithBytes:imageData length:imageSize]:nil;
    
    //大小
    NSString *size = [NSByteCountFormatter stringFromByteCount:info->file_size countStyle:NSByteCountFormatterCountStyleBinary];
    //时长
    NSString *duration = [[PythonManager shared] formatTimeIntervel:info->duration/1000/1000];
    //分辨率
    NSString *resolution = [NSString stringWithFormat:@"%d x %d",info->videoinfo.width,info->videoinfo.height];
    
    [fileInfo setValue:size forKey:@"size"];
    [fileInfo setValue:duration forKey:@"duration"];
    [fileInfo setValue:resolution forKey:@"resolution"];
    [fileInfo setValue:binaryIMG forKey:@"thumbnail"];

    FreeMediaInfo(info);
    
    return fileInfo;
}

-(void)mixVideo:(NSString *)vPath WithAudio:(NSString *)aPath toPath:(NSString *)outPath Results:(nullable void (^)(BOOL isSuccess))results{
 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int ret = MuxH264VideoWithAudioToOutputPath([vPath UTF8String],[aPath UTF8String],[outPath UTF8String]);
        dispatch_async(dispatch_get_main_queue(), ^{
            if(results)results(ret==0?YES:NO);
        });
    });
}
-(void)separateAudioFromVideo:(NSString *)vPath toPath:(NSString *)outPath Results:(nullable void (^)(BOOL isSuccess))results{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int ret = DemuxAudioToOutputPath([vPath UTF8String],[outPath UTF8String]);
        //int ret = convertVideoToAAC([vPath UTF8String], [outPath UTF8String]);
        dispatch_async(dispatch_get_main_queue(), ^{
            if(results)results(ret==0?YES:NO);
        });
    });
}

@end
