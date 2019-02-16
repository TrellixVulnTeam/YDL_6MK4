//
//  MediaFormatter.h
//  TubeD
//
//  Created by Damon on 2018/8/22.
//  Copyright © 2018年 Damon. All rights reserved.
//

#ifndef MediaFormatter_h
#define MediaFormatter_h

#include <stdio.h>
int MuxH264VideoWithAudioToOutputPath(const char *vPath,const char *aPath,const char *outPath);
int DemuxAudioToOutputPath(const char *vPath,const char *outPath);
int convertVideoToAAC(const char *vPath,const char *outPath);
#endif /* MediaFormatter_h */
