//
//  MethodHook.h
//  MyTestDemos
//
//  Created by yy on 16/4/20.
//  Copyright © 2016年 yy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMMethodHook : NSObject

+ (void)trackSelectorMsg:(Class)cls;//跟踪所有的方法
+(void)trackSelectorMsg:(Class)cls selectors:(NSArray *)selectors;
@end
