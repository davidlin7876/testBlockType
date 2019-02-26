//
//  AppDelegate.m
//  testBlock
//
//  Created by David Lin on 2019/2/26.
//  Copyright © 2019年 NetEase (Hangzhou) Network Co., Ltd. All rights reserved.
//

#import "AppDelegate.h"

int globleInt = 0;
static int globleStaticInt = 0;

@interface AppDelegate () {
    int classVarInt;
}
@property (nonatomic,copy) NSString *propStr;
@property (nonatomic,copy) void (^testlock)();
@property (weak) IBOutlet NSWindow *window;
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
    NSLog(@"myBlock===%@",myBlock);
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
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self testStackBlock];
    [self testGlobalBlock];
    [self testHeapBlock];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
