//
//  TestObject.h
//  BPUnrecognizedDemo
//
//  Created by yy on 16/6/2.
//  Copyright © 2016年 BP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TestObject : NSObject
-(void)testA:(NSString *)str num:(int)num frame:(CGRect)frame dic:(NSDictionary *)dic  successCallback:(void(^)(NSString *successJson,int num))successblock;
+(void)testB:(NSString *)str;
@end
