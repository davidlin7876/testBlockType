# OC中的Block的三种类型

OC中，一般Block就分为以下3种:

### _NSConcreteStackBlock
>存放在栈区,生命周期由系统控制的，一旦返回之后，就被系统销毁了。
copy操作后复制到堆

1. 拥有局部变量(自动变量)或者成员属性变量(即使被strong或者copy修饰的成员变量)
2. 没有被强引用

### _NSConcreteGlobalBlock
>存储在程序的数据区域（跟函数存储在一起),生命周期从创建到应用程序结束。
全局block的copy是个空操作

1. block中没有用到任何block内部以外的变量
2. block内部仅仅用到了全局变量/静态全局变量,静态变量

### _NSConcreteMallocBlock：
>存放在堆区,没有强指针引用即销毁，生命周期由程序员控制。
copy操作后计数加1。
堆中的block无法直接创建，其需要由_NSConcreteStackBlock类型的block拷贝而来

在ARC环境下，以下几种情况,编译器会自动的判断，把Block自动的从栈copy到堆
1. 手动调用copy的栈block
2. 栈Block被强引用，被赋值给__strong或者id类型
3. 被copy修饰的成员属性引用
3. Block是函数的返回值
4. 调用系统API入参中含有usingBlcok的方法，以及GCD方法

```
int globleInt = 0;
static int globleStaticInt = 0;

@interface AppDelegate () {
    int classVarInt;
}
@property (nonatomic,copy) NSString *propStr;
@property (nonatomic,copy) void (^testlock)();
@end

@implementation AppDelegate
- (void(^)())test {
    int a;
    return ^{a;};
}
- (void)testStackBlock {
    int funcVarInt = 10;
    //1.拥有局部变量
    NSLog(@"funcVarInt:%@", ^{funcVarInt;});
    //2.拥有成员变量
    NSLog(@"classVarInt:%@", ^{classVarInt;});
    //3.拥有成员属性变量
    NSLog(@"propStr:%@", ^{ _propStr;} );
    //4.没有被强引用
    __weak void (^weakBlock)() = ^{funcVarInt;};
    NSLog(@"weakBlockPtr:%@", weakBlock);
    __block int blockfuncVarInt = 10;
    NSLog(@"blockfuncVar:%@", ^{ blockfuncVarInt = 1;} );
}
- (void)testGlobalBlock {
    //1.仅用了全局变量、静态全局变量和静态变量
    static int staticInt = 1;
    void (^myBlock)(void) = ^{
        NSLog(@"Block中 变量 = %d %d %d",globleInt ,globleStaticInt, staticInt);
    };
    myBlock();
    NSLog(@"myBlock:%@",myBlock);
    //2. 没有用到block以外的变量
    void (^block2)(void) = ^{
        int i = 0;
    };
    NSLog(@"block2===%@",block2);
    self.testlock = ^{
    };
    NSLog(@"copyProp:%@", _testlock);
}
- (void)testHeapBlock {
    int i = 10;
    //1.手动调用copy的栈block
    NSLog(@"copy:%@", [^{i;} copy]);
    //2.被强引用，被赋值给__strong或者id类型
    void (^block)() = ^{i;};
    NSLog(@"strong:%@", block);
    //3.copy修饰的成员属性引用stack型Block
    self.testlock = ^{
        i;
    };
    NSLog(@"copyProp:%@", _testlock);
    //4.Block是函数的返回值
    NSLog(@"funcReturn:%@", [self test]);
}
@end
```
