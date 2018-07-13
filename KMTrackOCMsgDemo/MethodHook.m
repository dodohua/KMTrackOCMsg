//
//  MethodHook.m
//  MyTestDemos
//
//  Created by yy on 16/4/20.
//  Copyright © 2016年 yy. All rights reserved.
//

#import "MethodHook.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <Foundation/Foundation.h>
#import "NSInvocation+OCMAdditions.h"
@implementation MethodHook

void crashFunction(id self, SEL _cmd, ...) {
    id value = nil;
    NSString *selString = NSStringFromSelector(_cmd);
    
    int cnt = 0, length = (int)selString.length;
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [selString rangeOfString: @":" options:0 range:range];
        if(range.location != NSNotFound)
        {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            cnt++;
        }
    }
    
    va_list arg_ptr;
    va_start(arg_ptr, _cmd);
    
    for(int i = 0; i < cnt; i++)
    {
        value = va_arg(arg_ptr, id);
        NSLog(@"value%d=%@", i+1, value);
    }
    va_end(arg_ptr);
    NSLog(@"程序崩溃!");
    
}

+ (void)hookMethedClass:(Class)class hookSEL:(SEL)hookSEL originalSEL:(SEL)originalSEL myselfSEL:(SEL)mySelfSEL isClassMethod:(BOOL)isClassMethod
{
    if (isClassMethod) {
        Method hookMethod = class_getClassMethod(class, hookSEL);
        Method mySelfMethod = class_getClassMethod(self, mySelfSEL);
        Class metaClass = object_getClass(class);
        IMP hookMethodIMP = method_getImplementation(hookMethod);
        class_addMethod(metaClass, originalSEL, hookMethodIMP, method_getTypeEncoding(hookMethod));
        
        IMP hookMethodMySelfIMP = method_getImplementation(mySelfMethod);
        class_replaceMethod(metaClass, hookSEL, hookMethodMySelfIMP, method_getTypeEncoding(hookMethod));
    }else
    {
        Method hookMethod = class_getInstanceMethod(class, hookSEL);
        Method mySelfMethod = class_getInstanceMethod(self, mySelfSEL);
        IMP hookMethodIMP = method_getImplementation(hookMethod);
        class_addMethod(class, originalSEL, hookMethodIMP, method_getTypeEncoding(hookMethod));
        
        IMP hookMethodMySelfIMP = method_getImplementation(mySelfMethod);
        class_replaceMethod(class, hookSEL, hookMethodMySelfIMP, method_getTypeEncoding(hookMethod));
    }
    
}
+(void)replaceAllSelector:(Class)class
{
    int i=0;
    unsigned int mc = 0;
    Method * mlist = class_copyMethodList(class, &mc);
    NSLog(@"%d methods", mc);
    for(i=0;i<mc;i++){
        NSLog(@"class %@ Method no #%d: %s",NSStringFromClass(class), i, sel_getName(method_getName(mlist[i])));
        NSString *selector = [NSString stringWithUTF8String:sel_getName(method_getName(mlist[i]))] ;
        NSString *preSelector = [selector lowercaseString];
        preSelector = [preSelector stringByTrimmingCharactersInSet:
         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([preSelector hasPrefix:@"forwardingtargetforselector"]||[preSelector hasPrefix:@"methodsignatureforselector"]||[preSelector hasPrefix:@"forwardinvocation"]||[preSelector containsString:@"retain"]||[preSelector containsString:@"release"]||[preSelector containsString:@"autorelease"]||[preSelector hasPrefix:@".cxx_"]||[preSelector containsString:@"deallocat"]||[preSelector hasPrefix:@"ORIG"]||[preSelector hasPrefix:@"dealloc"]||preSelector.length<=0) {
            continue;
        }
        //忽略set的方法,避免影响kvo
        if ([preSelector hasPrefix:@"set"])
        {
            continue;
        }
        overrideMethod(class,selector,NULL);
    }
    free(mlist); // 7
    //获取类方法  暂不支持类方法hook
    Class metaClass = object_getClass(class); // 2
    mlist = class_copyMethodList(metaClass, &mc);
    NSLog(@"%d class methods", mc);
    for(i=0;i<mc;i++){
        NSLog(@"class %@ Method no #%d: %s",NSStringFromClass(class), i, sel_getName(method_getName(mlist[i])));
        NSString *selector = [NSString stringWithUTF8String:sel_getName(method_getName(mlist[i]))] ;
        NSString *preSelector = [selector lowercaseString];
        preSelector = [preSelector stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([preSelector hasPrefix:@"forwardingtargetforselector"]||[preSelector hasPrefix:@"methodsignatureforselector"]||[preSelector hasPrefix:@"forwardinvocation"]||preSelector.length<=0) {
            continue;
        }
        overrideMethod(class,selector,NULL);
    }
    free(mlist); // 7
}
+(BOOL)hasSelector:(Class)class sel:(SEL)sel
{
    int i=0;
    unsigned int mc = 0;
    Method * mlist = class_copyMethodList(class, &mc);
    NSLog(@"%d methods", mc);
    for(i=0;i<mc;i++){
        NSLog(@"class %@ Method no #%d: %s",NSStringFromClass(class), i, sel_getName(method_getName(mlist[i])));
        NSString *selector = [NSString stringWithUTF8String:sel_getName(method_getName(mlist[i]))] ;
        if ([selector isEqualToString:NSStringFromSelector(sel)]) {
            return YES;
        }
    }
    return NO;
}
static void overrideMethod(Class cls, NSString *selectorName, const char *typeDescription)
{
    SEL selector = NSSelectorFromString(selectorName);
    Class metaClass = object_getClass(cls);
    BOOL isClassMethod = NO;
    if (!typeDescription) {
        Method method = class_getInstanceMethod(cls, selector);
        if (method==nil) {
            method = class_getClassMethod(cls, selector);
            isClassMethod = YES;
        }
        typeDescription = (char *)method_getTypeEncoding(method);
    }
    
    IMP originalImp = class_respondsToSelector(cls, selector) ? class_getMethodImplementation(cls, selector) : NULL;
    if (originalImp == NULL) {
       
        originalImp = class_respondsToSelector(metaClass, selector) ? class_getMethodImplementation(metaClass, selector) : NULL;
    }
    
    IMP msgForwardIMP = _objc_msgForward;
#if !defined(__arm64__)
    if (typeDescription!=NULL&&typeDescription[0] == '{') {
        //In some cases that returns struct, we should use the '_stret' API:
        //http://sealiesoftware.com/blog/archive/2008/10/30/objc_explain_objc_msgSend_stret.html
        //NSMethodSignature knows the detail but has no API to return, we can only get the info from debugDescription.
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:typeDescription];
        if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
            msgForwardIMP = (IMP)_objc_msgForward_stret;
        }
    }
#endif
    
    if (isClassMethod) {
        if (class_respondsToSelector(metaClass, selector)) {
            NSString *originalSelectorName = [NSString stringWithFormat:@"ORIG%@", selectorName];
            SEL originalSelector = NSSelectorFromString(originalSelectorName);
            if(!class_respondsToSelector(metaClass, originalSelector)) {
                class_addMethod(metaClass, originalSelector, originalImp, typeDescription);
            }
        }
        
        // Replace the original selector at last, preventing threading issus when
        // the selector get called during the execution of `overrideMethod`
        class_replaceMethod(metaClass, selector, msgForwardIMP, typeDescription);
    }else
    {
        if (class_respondsToSelector(cls, selector)) {
            NSString *originalSelectorName = [NSString stringWithFormat:@"ORIG%@", selectorName];
            SEL originalSelector = NSSelectorFromString(originalSelectorName);
            if(!class_respondsToSelector(cls, originalSelector)) {
                class_addMethod(cls, originalSelector, originalImp, typeDescription);
            }
        }
        
        // Replace the original selector at last, preventing threading issus when
        // the selector get called during the execution of `overrideMethod`
        class_replaceMethod(cls, selector, msgForwardIMP, typeDescription);
    }
    
}

+ (void)hookNotRecognizeSelector:(Class)cls {
    [MethodHook replaceAllSelector:cls];
    [MethodHook hookMethedClass:cls hookSEL:@selector(methodSignatureForSelector:) originalSEL:@selector(methodSignatureForSelectorOriginal:) myselfSEL:@selector(methodSignatureForSelectorMySelf:) isClassMethod:NO];
    
    [MethodHook hookMethedClass:cls hookSEL:@selector(forwardInvocation:) originalSEL:@selector(forwardInvocationOriginal:) myselfSEL:@selector(forwardInvocationMySelf:) isClassMethod:NO];
    [MethodHook hookMethedClass:cls hookSEL:@selector(methodSignatureForSelector:) originalSEL:@selector(methodSignatureForSelectorOriginal:) myselfSEL:@selector(methodSignatureForSelectorMySelf:) isClassMethod:YES];
    
    [MethodHook hookMethedClass:cls hookSEL:@selector(forwardInvocation:) originalSEL:@selector(forwardInvocationOriginal:) myselfSEL:@selector(forwardInvocationMySelf:) isClassMethod:YES];
    
    
    
}
- (NSMethodSignature *)methodSignatureForSelectorMySelf:(SEL)aSelector {
    //    NSString *clsString = NSStringFromClass([self class]);
    //    if ([clsString rangeOfString:@"MF"].location == NSNotFound) {
    //        return [self methodSignatureForSelectorOriginal:aSelector];
    //    }
    NSString *sel = NSStringFromSelector(aSelector);
    NSLog(@"调用了sel:%@",sel);
    if ([self respondsToSelector:aSelector]) {
        NSString *selName = NSStringFromSelector(aSelector);
        selName = [NSString stringWithFormat:@"ORIG%@",selName];
        SEL orgSel = NSSelectorFromString(selName);
        return [self methodSignatureForSelectorOriginal:orgSel];
    } else {
        return [NSMethodSignature signatureWithObjCTypes:"@@:"];
    }
}

- (NSMethodSignature *)methodSignatureForSelectorOriginal:(SEL)aSelector {
    return nil;
}

- (void)forwardInvocationMySelf:(NSInvocation *)anInvocation {
    //    if ([anInvocation.target respondsToSelector:anInvocation.selector]) {
    //        NSString *selName = NSStringFromSelector(anInvocation.selector);
    //        selName = [NSString stringWithFormat:@"ORIG%@",selName];
    //        SEL orgSel = NSSelectorFromString(selName);
    //        NSMethodSignature *methodSignature = [self methodSignatureForSelectorOriginal:orgSel];
    //        if (!methodSignature) {
    //            NSLog(@"");
    //            return;
    //        }
    //        NSInvocation *forwardInv= [NSInvocation invocationWithMethodSignature:methodSignature];
    //        [forwardInv setTarget:self];
    //        [forwardInv setSelector:orgSel];
    //        [forwardInv setArgument:&anInvocation atIndex:2];
    //        [forwardInv invokeWithTarget:forwardInv.target];
    //
    //    }
    Class cls = [anInvocation.target class];
    if ([anInvocation.target respondsToSelector:anInvocation.selector]) {
        //打印参数
        NSLog(@"value:%@",[anInvocation invocationDescription]);
        
        NSString *selName = NSStringFromSelector(anInvocation.selector);
        selName = [NSString stringWithFormat:@"ORIG%@",selName];
        SEL orgSel = NSSelectorFromString(selName);
        IMP originalImp = class_respondsToSelector(cls, orgSel) ? class_getMethodImplementation(cls, orgSel) : NULL;
        Method method = class_getInstanceMethod(cls, orgSel);
        const char *typeDescription = (char *)method_getTypeEncoding(method);
        class_replaceMethod(cls, anInvocation.selector, originalImp, typeDescription);
        [anInvocation invokeWithTarget:anInvocation.target];
        overrideMethod(cls,NSStringFromSelector(anInvocation.selector) ,typeDescription);
        
        
//        __unsafe_unretained NSString * firstArgument = nil;
//        __unsafe_unretained NSString * secondArgument = nil;
//        [anInvocation getArgument:&firstArgument atIndex:2];
//        NSLog(@"value%@",firstArgument);
//        https://github.com/erikdoe/ocmock/blob/master/Source/OCMock/NSInvocation%2BOCMAdditions.m
        return;
    }
    
    
    
    if (![anInvocation.target respondsToSelector:anInvocation.selector]) {
        class_addMethod(cls, anInvocation.selector, (IMP)crashFunction, "v@:@@");
    }
    
    if ([anInvocation.target respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:anInvocation.target];
    }
}

- (void)forwardInvocationOriginal:(NSInvocation *)anInvocation {
    
}
+ (NSMethodSignature *)methodSignatureForSelectorMySelf:(SEL)aSelector {
//    NSString *clsString = NSStringFromClass([self class]);
//    if ([clsString rangeOfString:@"MF"].location == NSNotFound) {
//        return [self methodSignatureForSelectorOriginal:aSelector];
//    }
    NSString *sel = NSStringFromSelector(aSelector);
    NSLog(@"调用了class sel:%@",sel);
    if ([self respondsToSelector:aSelector]) {
        NSString *selName = NSStringFromSelector(aSelector);
        selName = [NSString stringWithFormat:@"ORIG%@",selName];
        SEL orgSel = NSSelectorFromString(selName);
        return [self methodSignatureForSelectorOriginal:orgSel];
    } else {
        return [NSMethodSignature signatureWithObjCTypes:"@@:"];
    }
}

+ (NSMethodSignature *)methodSignatureForSelectorOriginal:(SEL)aSelector {
    return nil;
}

+ (void)forwardInvocationMySelf:(NSInvocation *)anInvocation {
//    if ([anInvocation.target respondsToSelector:anInvocation.selector]) {
//        NSString *selName = NSStringFromSelector(anInvocation.selector);
//        selName = [NSString stringWithFormat:@"ORIG%@",selName];
//        SEL orgSel = NSSelectorFromString(selName);
//        NSMethodSignature *methodSignature = [self methodSignatureForSelectorOriginal:orgSel];
//        if (!methodSignature) {
//            NSLog(@"");
//            return;
//        }
//        NSInvocation *forwardInv= [NSInvocation invocationWithMethodSignature:methodSignature];
//        [forwardInv setTarget:self];
//        [forwardInv setSelector:orgSel];
//        [forwardInv setArgument:&anInvocation atIndex:2];
//        [forwardInv invokeWithTarget:forwardInv.target];
//        
//    }
    Class cls = [anInvocation.target class];
    if ([anInvocation.target respondsToSelector:anInvocation.selector]) {
        cls = object_getClass(cls);
        NSString *selName = NSStringFromSelector(anInvocation.selector);
        selName = [NSString stringWithFormat:@"ORIG%@",selName];
        SEL orgSel = NSSelectorFromString(selName);
        IMP originalImp = class_respondsToSelector(cls, orgSel) ? class_getMethodImplementation(cls, orgSel) : NULL;
        Method method = class_getClassMethod(cls, orgSel);
        const char *typeDescription = (char *)method_getTypeEncoding(method);
        class_replaceMethod(cls, anInvocation.selector, originalImp, typeDescription);
        [anInvocation invokeWithTarget:anInvocation.target];
    overrideMethod(cls,NSStringFromSelector(anInvocation.selector) ,typeDescription);
        
        NSLog(@"value:%@",[anInvocation invocationDescription]);
        return;
    }
    
    
    
    if (![anInvocation.target respondsToSelector:anInvocation.selector]) {
        class_addMethod(cls, anInvocation.selector, (IMP)crashFunction, "v@:@@");
    }
    
    if ([anInvocation.target respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:anInvocation.target];
    }
}

+ (void)forwardInvocationOriginal:(NSInvocation *)anInvocation {
    
}
@end
