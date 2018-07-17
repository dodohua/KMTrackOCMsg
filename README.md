# KMTrackOCMsg
OC runtime to track  object call selector msg  
support class method and instance method    
使用OC写的黑盒追踪基于NSObject的方法调用   
## 🌟 Features
- [x] 追踪一个class调用方法.
- [x] 支持类发放和实例方法.
- [x] 支持block.
- [x] 支持方法的value值print和block调用的arg值打印.
## 🌟 Notice
- 为了打印block的参数值，使用libffi的ios编译好的静态库
- 打印block使用的源码基于[BlockHook](https://github.com/yulingtianxia/BlockHook).
- 打印参数值使用的源码基于OCMock，做了改动

## 🐒 使用方法
```
[KMMethodHook trackSelectorMsg:[TestObject class]];
//or [KMMethodHook trackSelectorMsg:NSClassFromString(@"TestObject")];
```

打印的log：
```
2018-07-17 16:05:02.812575+0800 KMTrackOCMsgDemo[3213:181213] value:_loadPlaybackControlsControllersIfNeeded:not args
2018-07-17 16:05:02.813398+0800 KMTrackOCMsgDemo[3213:181213] block:<__NSMallocBlock__: 0x60400045ac10> sel:v@?B@"NSError" argValue:YESnil
```
