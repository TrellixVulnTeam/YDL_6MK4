//
//  PythonManager.m
//  YDL
//
//  Created by ceonfai on 2018/12/27.
//  Copyright © 2018 Ceonfai. All rights reserved.
//

#import "PythonManager.h"
#import <Python/Python.h>
#import "MenuModel.h"
#import <SSZipArchive/SSZipArchive.h>
typedef void (^YDLProgressBlock)(NSString *progress);
typedef void (^YDLFinishBlock)(BOOL isError);
@interface PythonManager ()
@property(nonatomic,copy)YDLProgressBlock progressCallBack;
@property(nonatomic,copy)YDLFinishBlock finishCallBack;
@end

@implementation PythonManager{
@protected PyObject *pyObj;//用于执行脚本
@protected NSURLSession *_session;
}

-(BOOL)configPythonEnv{
    
    //将资源中的python.frameworks拷贝到沙盒
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *resourcePath = [mainBundle pathForResource:@"PythonEnvironment" ofType:@"bundle"];
    NSBundle *envBundle = [NSBundle bundleWithPath:resourcePath];
    NSString *PythonPath = [envBundle pathForResource:@"Python" ofType:@"framework"];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:PythonPath];
    if (!isExist) {
        return NO;
    }
    
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *newFrameworkPath = [docPath stringByAppendingPathComponent:@"Python.framework"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:newFrameworkPath]) {
        NSError * error;
        [[NSFileManager defaultManager] copyItemAtPath:PythonPath toPath:newFrameworkPath error:&error];
        if (error) {
            return NO;
        }
    }
    //设置Python Home的位置
    const char * frameworkPath = [[NSString stringWithFormat:@"%@/Resources",newFrameworkPath] UTF8String];
    wchar_t  *pythonHome = _Py_char2wchar(frameworkPath, NULL);
    Py_SetPythonHome(pythonHome);
    
    //初始化Python
    Py_Initialize();
    PyEval_InitThreads();
    
    BOOL isPyInit = Py_IsInitialized();
    NSLog(@"初始化环境:%@",isPyInit?@"成功":@"失败");
    
    _isInit = isPyInit;
    
    return isPyInit;
}

-(BOOL)loadPythonModule{
    
    putenv("PYTHONDONTWRITEBYTECODE=1");
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString * resourcePath = [docPath stringByAppendingString:@"/Python.framework/Resources"];
    NSString * python_path = [NSString stringWithFormat:@"PYTHONPATH=%@/python_scripts:%@/Resources/lib/python3.4/site-packages/", resourcePath, resourcePath, nil];
    NSLog(@"PYTHONPATH is: %@", python_path);
    putenv((char *)[python_path UTF8String]);
    
    pyObj = PyImport_ImportModule("ParseVideo");
    BOOL isImportSuccess = (pyObj == NULL?NO:YES);
    if (!isImportSuccess)
    {
        PyErr_Print();
    }
    
    NSLog(@"导入YDL Module:%@",isImportSuccess?@"成功":@"失败");
    return isImportSuccess;
}
//解释视频 并将JSON数据返回
-(NSDictionary *)parseVideos:(NSString *)videoURL{
    
    NSString *parseURL = videoURL;
    NSString *listChar = @"list=";
    if([parseURL containsString:listChar]){
        NSString *vKey = @"v=";
        if([parseURL containsString:vKey]){
            NSRange rangeOfVkey = [parseURL rangeOfString:vKey];
            NSInteger cutIndex = rangeOfVkey.location+rangeOfVkey.length + 11;//11是youtube的视频ID长度
            parseURL = [parseURL substringToIndex:cutIndex];
        }
    }
    
    NSString *proxyString = [self getProxyString];
    char *cProxy = [proxyString isEqualToString:@""]?NULL:(char *)[proxyString UTF8String];
    PyObject *result = PyObject_CallMethod(self->pyObj, "SniffingURL","(s)", [parseURL UTF8String],cProxy);
    
    if (result == NULL) {
        free(result);
        return nil;
    }
    // 获取JSON
    char * resultCString = NULL;
    PyArg_Parse(result, "s", &resultCString);
    if (resultCString == NULL) {
        free(result);
        return nil;
    }
    NSError *error = nil;
    NSString *resultJsonString = [NSString stringWithUTF8String:resultCString];
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *jsonPath = [docPath stringByAppendingPathComponent:@"my.json"];
    [resultJsonString writeToFile:jsonPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSData *resultJsonData = [resultJsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *infoDict = [NSJSONSerialization JSONObjectWithData:resultJsonData options:kNilOptions error:&error];
    
    //解释数据
    _parseDatas = [NSMutableDictionary dictionary];
    NSMutableArray *videoModels = [NSMutableArray array];
    NSString *title = [infoDict valueForKey:@"title"];
    NSString  *thm  = [infoDict valueForKey:@"thumbnail"];
    NSArray  *formats = [infoDict valueForKey:@"formats"];
    NSString *duration;
    if ([infoDict[@"duration"] isKindOfClass:[NSNull class]]) {
        duration = @"未知时长";
    }else{
        duration = [self formatTimeIntervel:[infoDict[@"duration"] floatValue]];
    }
    [self.parseDatas setValue:title forKey:@"title"];
    [self.parseDatas setValue:thm forKey:@"thumbnailURL"];
    [self.parseDatas setValue:duration forKey:@"duration"];
    
    NSLog(@"==========EXT:======\n");
    for (NSDictionary *oneFormat in formats) {
        
        //预读数据
        NSString  *ext = [oneFormat valueForKey:@"ext"];
        
        //printf("%s\nVideo:%s\nAudio:%s\n\n",[ext UTF8String],[[oneFormat valueForKey:@"vcodec"] UTF8String],[[oneFormat valueForKey:@"acodec"] UTF8String]);
        long long fileSizeL;
        @try {
            fileSizeL = [oneFormat[@"filesize"] longLongValue];
        }
        @catch (NSException *exception) {
            
            NSLog(@"exception");
            fileSizeL = 0;
        }
        
        NSString *fileSizeStr = [[[NSByteCountFormatter stringFromByteCount:fileSizeL countStyle:NSByteCountFormatterCountStyleFile]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"Zero" withString:@"0"];
        NSString *vcodec = [oneFormat valueForKey:@"vcodec"];
        NSString *acodec = [oneFormat valueForKey:@"acodec"];
        BOOL isVideoWithoutAudio = ([vcodec isEqualToString:@"none"]||[acodec isEqualToString:@"none"])?YES:NO;
        BOOL isAudio = ([vcodec isEqualToString:@"none"]||[acodec isEqualToString:@"YES"])?YES:NO;
        //过滤音频
        if(isAudio){
            continue;
        }
        BOOL isM3U8 = [[[oneFormat objectForKey:@"url"] pathExtension]isEqualToString:@"m3u8"]?YES:NO;
        if(isM3U8){
            continue;
        }
        
        MenuModel *mModel = [[MenuModel alloc] init];
        mModel.mWebURL = videoURL;
        mModel.mVURL = [oneFormat objectForKey:@"url"];
        mModel.mTitle = [title stringByAppendingString:[NSString stringWithFormat:@".%@",ext]];
        mModel.mDuration = duration;
        mModel.mTHMURL = thm;
        mModel.mExtention = ext;
        mModel.isSpilter = isVideoWithoutAudio;
        mModel.mSize = fileSizeStr;
        mModel.mResolution = [NSString stringWithFormat:@"%@x%@",[oneFormat valueForKey:@"width"],[oneFormat valueForKey:@"height"]];
        mModel.mWebURL = parseURL;
        
        if (isVideoWithoutAudio) {
            
            if([ext isEqualToString:@"MP4"]||[ext isEqualToString:@"mp4"]){
                for (NSDictionary *oneFormat in formats) {
                    if([oneFormat[@"ext"] isEqualToString:@"m4a"]){
                        mModel.mAURL = oneFormat[@"url"];
                    }
                }
            }
            else if([ext isEqualToString:@"webm"]||[ext isEqualToString:@"WEBM"]){
                for (NSDictionary *oneFormat in formats) {
                    if([[oneFormat valueForKey:@"acodec"] isEqualToString:@"opus"]){
                        mModel.mAURL = oneFormat[@"url"];
                    }
                }
            }
            
            
        }
        [videoModels addObject:mModel];
    }
    if(videoModels.count>0){
        NSDictionary *results = [self parseDataTobeGroup:videoModels];
        [self.parseDatas setValue:results forKey:@"EXTGroup"];
        [self.parseDatas setValue:@(videoModels.count) forKey:@"all"];
    }else{
        [self.parseDatas removeAllObjects];
    }
    
    free(result);
    return self.parseDatas;
    
}

- (NSMutableDictionary *)parseDataTobeGroup:(NSArray *)videoModels
{
    NSMutableArray *keyArray = [NSMutableArray array];
    NSMutableDictionary *extDatas = [NSMutableDictionary dictionary];
    
    //获取不同的格式
    for (MenuModel *oneModel in videoModels) {
        
        if([keyArray containsObject:oneModel.mExtention]){
            continue;
        }
        [keyArray addObject:oneModel.mExtention];
    }
    for (NSString *oneExt in keyArray) {
        //某个格式的所有资源
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"mExtention==%@",oneExt];
        NSArray* predicateData = [videoModels filteredArrayUsingPredicate:predicate];
        [extDatas setValue:predicateData forKey:oneExt];
    }
    return extDatas;
}

#pragma mark -单例
static PythonManager* pyManager = nil;
+(PythonManager*)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pyManager = [[self alloc] init];
    });
    return pyManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (pyManager == nil) {
            pyManager = [super allocWithZone:zone];
            return pyManager;
        }
    }
    return nil;
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(NSString *)getProxyString{
    NSDictionary *proxySettings = (__bridge NSDictionary *)CFNetworkCopySystemProxySettings();
    NSArray * proxies = (__bridge NSArray *)CFNetworkCopyProxiesForURL((__bridge CFURLRef)[NSURL URLWithString:@"https://www.apple.com"], (__bridge CFDictionaryRef)proxySettings);
    
    NSDictionary *settings = [proxies objectAtIndex:0];
    
    if(settings){
        NSLog(@"\n\n代理:\n%@\n\n",settings);
        NSString *hostName = [settings valueForKey:@"kCFProxyHostNameKey"];
        int port = [[settings valueForKey:@"kCFProxyPortNumberKey"] intValue];
        NSString *proxyString = [NSString stringWithFormat:@"%@:%d",hostName,port];
        return proxyString;
    }
    return nil;
    
}
-(NSString *)formatTimeIntervel:(float)seconds{
    seconds = MAX(0, seconds);
    if(seconds == 0){
        return @"--:--";
    }
    NSInteger s = seconds;
    NSInteger m = s / 60;
    NSInteger h = m / 60;
    s = s % 60;
    m = m % 60;
    
    NSMutableString *formatString = [(seconds <0 ? @"-" : @"") mutableCopy];
    if(h>0){
        [formatString appendFormat:@"%ld:%0.2ld", (long)h, (long)m];
        [formatString appendFormat:@":%0.2ld", (long)s];
    }else{
        [formatString appendFormat:@"%0.2ld", (long)m];
        [formatString appendFormat:@":%0.2ld", (long)s];
    }
    return formatString;
}

#define kPathTemp     NSTemporaryDirectory()
#define kPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
-(void)updateYDLWithProgress:(void (^)(NSString *progresstext))progressHandle
                     completionHandler:(void (^)(BOOL isError))completeHandle{
    NSString *downloadAdress = @"https://codeload.github.com/rg3/youtube-dl/zip/master";
    NSURL *downloadURL = [NSURL URLWithString:downloadAdress];
    
    //实例化一个session对象
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //指定回调方法工作的线程
    _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    //发起并且继续任务
    NSURLSessionDownloadTask *task = [_session downloadTaskWithURL:downloadURL];
    [task resume];
    
    self.progressCallBack = ^(NSString *progress) {
        if(progressHandle){
            progressHandle(progress);
        }
    };
    
    self.finishCallBack = ^(BOOL isError) {
        if(completeHandle){
            completeHandle(isError);
        }
    };
}

#pragma mark - NSURLSessionDownloadDelegate
/**
 *  1.下载完成后被调用的方法（iOS7和iOS8都必须实现）
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    
    NSLog(@"下载完成");
    
    NSString *downloadDes = location.path;
    NSString *copyZipToTem = [kPathTemp stringByAppendingString:@"youtube-dl-master.zip"];
    NSError *error = nil;
    //先尝试移除再尝试移动
    [[NSFileManager defaultManager] removeItemAtPath:copyZipToTem error:nil];
    [[NSFileManager defaultManager] moveItemAtPath:downloadDes toPath:copyZipToTem error:&error];
    
    BOOL isSuccess = [SSZipArchive unzipFileAtPath:copyZipToTem toDestination:kPathTemp];
    
    //解压文件出错
    if(!isSuccess){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.finishCallBack){
                self.finishCallBack(!isSuccess);
            }
        });
        return;
    }
    
    //获得新版与旧版路径
    NSString *sitePath = [kPathDocument stringByAppendingString:@"/Python.framework/Resources/lib/python3.4/site-packages/youtube_dl"];
    NSString *lastVersionPath = [[copyZipToTem stringByDeletingPathExtension] stringByAppendingString:@"/youtube_dl"];
    
    //先尝试移除 以免拷贝出错
    [[NSFileManager defaultManager] removeItemAtPath:sitePath error:nil];
    
    NSError *copyError = nil;
    //替换新旧版本
    [[NSFileManager defaultManager] copyItemAtPath:lastVersionPath toPath:sitePath error:&copyError];
    
    //删除下载缓存zip与解压文件夹
    [[NSFileManager defaultManager] removeItemAtPath:copyZipToTem error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[copyZipToTem stringByDeletingPathExtension] error:nil];
    
    BOOL isInstallError = copyError?true:false;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.finishCallBack){
            self.finishCallBack(isInstallError);
        }
    });
  
    if(isInstallError == false){
        [self loadPythonModule];
    }
}

/**
 *  2.下载进度变化的时候被调用。多次调用。（iOS8可以不实现）
 *
 *  @param bytesWritten              本次写入的字节数
 *  @param totalBytesWritten         已经写入的字节数
 *  @param totalBytesExpectedToWrite 总的下载字节数
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"%@",downloadTask.response);
    //float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    NSString *downloadSize = [[NSByteCountFormatter stringFromByteCount:totalBytesWritten countStyle:NSByteCountFormatterCountStyleFile] stringByReplacingOccurrencesOfString:@"Zero" withString:@"0"];
    NSString *maxSize = [[NSByteCountFormatter stringFromByteCount:totalBytesExpectedToWrite countStyle:NSByteCountFormatterCountStyleFile] stringByReplacingOccurrencesOfString:@"Zero" withString:@"0"];
    NSString *progressTitle = [NSString stringWithFormat:@"%@ / %@",downloadSize,maxSize];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.progressCallBack){
            self.progressCallBack(progressTitle);
        }
    });
    
}
@end
