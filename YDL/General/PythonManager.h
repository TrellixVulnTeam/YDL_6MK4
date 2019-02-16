//
//  PythonManager.h
//  YDL
//
//  Created by ceonfai on 2018/12/27.
//  Copyright © 2018 Ceonfai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PythonManager : NSObject<NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSMutableDictionary *parseDatas;
@property (assign, nonatomic) BOOL isInit;
+(PythonManager*)shared;
-(BOOL)configPythonEnv;
-(BOOL)loadPythonModule;
-(NSDictionary *)parseVideos:(NSString *)videoURL;
-(NSString *)formatTimeIntervel:(float)seconds;
-(void)updateYDLWithProgress:(void (^)(NSString *progresstext))progressHandle
           completionHandler:(void (^)(BOOL isError))completeHandle;
@end

NS_ASSUME_NONNULL_END
