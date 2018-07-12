//
//  HPMobClick+hook.m
//  IJKMediaDemo
//
//  Created by allen du on 2018/6/12.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "NSObject+hook.h"
#import <objc/runtime.h>

@implementation NSObject (hook)
+ (void)resetMobStarStatistics
{
    
    Class tarClass = NSClassFromString(@"__NSPlaceholderDictionary");
    Method srcMethod = class_getInstanceMethod([self class], @selector(st_initWithObjects:forKeys:count:));
    Method tarMethod = class_getInstanceMethod(tarClass, @selector(initWithObjects:forKeys:count:));
    method_exchangeImplementations(srcMethod, tarMethod);
    if (srcMethod != nil && tarMethod != nil) {
        NSLog(@"Registration Hook sucessed");
    }else{
        NSLog(@"Registration Hook error");
    }
    
    
}
-(instancetype)st_initWithObjects:(id *)objects forKeys:(id<NSCopying> *)keys count:(NSUInteger)count {
    NSUInteger rightCount = 0;
    for (NSUInteger i = 0; i < count; i++) {
        // 这里只做value 为nil的处理 对key为nil不做处理
        if (objects[i] == nil) {
            objects[i] = [NSNull null]  ; //有看到很多人这个地方判断了objects 和keys 如果它们中有一个为nil 那么就直接break ，但是我个人不太建议使用key的值nil的时候直接break。
            // objects[i] = @"" ; 也可以根据个人情况这样写
            return nil;
        }
        rightCount++;
    }
    return  [self st_initWithObjects:objects forKeys:keys count:rightCount];
}


//-(void)mobStarStatistics_hook
//{
//    NSLog(@"想获取用户数据，没门");
//    if([self isKindOfClass:NSClassFromString(@"HPMobClick")]){
//        [self performSelector:@selector(setInterval:) withObject:@300 afterDelay:0];
//    }
//
//}
//-(void)setInterval_hook:(NSInteger)interval
//{
//    NSLog(@"interval%lu",interval);
//    [self setInterval_hook:interval];
//}
@end
