//
//  TestObject.m
//  BPUnrecognizedDemo
//
//  Created by yy on 16/6/2.
//  Copyright © 2016年 BP. All rights reserved.
//

#import "TestObject.h"

@implementation TestObject
-(void)testA:(NSString *)str
{
    NSLog(@"testA:%@",str);
}
+(void)testB:(NSString *)str;
{
    NSLog(@"testB:%@",str);
}
@end
