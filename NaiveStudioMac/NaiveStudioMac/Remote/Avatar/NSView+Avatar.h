//
//  NSView+Avatar.h
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/7.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSView (Avatar)


/**
 DFS递归反序列化

 @param dict <#dict description#>
 @return <#return value description#>
 */
-(void)deserializeWithDictionary:(NSDictionary*)dict;

/**
 DFS递归序列化
 
 @param dict <#dict description#>
 @return <#return value description#>
 */
-(NSString*)serialize;

@end

NS_ASSUME_NONNULL_END
