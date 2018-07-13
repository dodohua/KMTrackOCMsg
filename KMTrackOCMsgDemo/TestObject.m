//
//  TestObject.m
//  BPUnrecognizedDemo
//
//  Created by yy on 16/6/2.
//  Copyright © 2016年 BP. All rights reserved.
//

#import "TestObject.h"

@implementation TestObject
-(void)testA:(NSString *)str num:(int)num frame:(CGRect)frame dic:(NSDictionary *)dic  successCallback:(void(^)(NSString *successJson,int num))successblock
{
    NSLog(@"testA:%@",str);
    successblock(@"testString",123);
}
+(void)testB:(NSString *)str;
{
    NSLog(@"testB:%@",str);
}
@end
