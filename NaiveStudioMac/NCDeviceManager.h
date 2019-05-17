//
//  NCDeviceManager.h
//  NaiveStudioMac
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/10.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCDeviceManager : NSObject
+(id)manager;
-(CGSize)currentDeviceSize;
@end

NS_ASSUME_NONNULL_END
