//
//  MenuModel.h
//  YDL
//
//  Created by ceonfai on 2019/1/19.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MenuModel : NSObject
@property (nonatomic,copy)NSString * mTitle;
@property (nonatomic,copy)NSString * mVURL;
@property (nonatomic,copy)NSString * mAURL;
@property (nonatomic,copy)NSString * mTHMURL;
@property (nonatomic,copy)NSString * mResolution;
@property (nonatomic,copy)NSString * mSize;
@property (nonatomic,copy)NSString * mDuration;
@property (nonatomic,copy)NSString * mExtention;
@property (nonatomic,copy)NSString * mWebURL;

@property (nonatomic,assign)BOOL isSpilter;
@end

NS_ASSUME_NONNULL_END
