//
//  ViewController.m
//  NSOperation
//
//  Created by apple on 2019/6/4.
//  Copyright © 2019 apple. All rights reserved.
//

#import "ViewController.h"
#import "CustomOperation.h"
@interface ViewController ()
@property (nonatomic, assign) NSInteger ticketsCount;
@property (readwrite, nonatomic, strong) NSLock *lock;
@end

@implementation ViewController
{
    dispatch_semaphore_t semaphoreLock;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //1 在当前线程使用 子类 NSInvocationOperation
    //[self userInvocationOperation];
    //2 在其他线程使用子类 NSInvocationOperation
    //[self userInvocationInOtherThread];
    //3 在当前线程使用 NSBlockOperation
    //[self userBlockOperation];
    //4 使用NSBlockOperation addExexutionBlock 方法
    //[self userBlockExecutionBlock];
    //5 使用自定义继承自 NSOperation 的子类
    //[self userCustomNSOperation];
    //6 使用addOperation 添加到a操作队列
    //[self userAddOperation];
    //7 使用addOperationWithBlock 添加到队列
    //[self useAddOperationWithBlocToQueue];
    // 8 设置最大并发数
    //[self setmaxConcurrentThread];
    // 9 设置优先级
    //[self setQuenePriority];
    // 10 添加依赖
    //[self addDependency];
    // 11 线程通信
    //[self communicationBetweenThread];
    // 12 线程执行任务结束
    //[self completionBlock];
    // 13 关于资源竞争问题  抢票
    //[self TicketsStatusNotSafe];
    // 14 线程安全
    //[self initTicketStatusSave];
    // 15 GCD 信号量 实现线程安全
    [self useGCDBuyTickets];
    
}


// 使用子类 NSInvocationOperation 方法
- (void)userInvocationOperation
{
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    [op start];    // 1 --- <NSThread: 0x60000226a940>{number = 1, name = main}
}

- (void)userInvocationInOtherThread
{
    [NSThread detachNewThreadSelector:@selector(userInvocationOperation) toTarget:self withObject:nil];
    //1 --- <NSThread: 0x6000034aed00>{number = 3, name = (null)}
}

- (void)userBlockOperation
{
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0 ; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1 --- %@",[NSThread currentThread]);
        }
    }];
    [blockOperation start];
    // 1 --- <NSThread: 0x600002c52940>{number = 1, name = main}
}

- (void)userBlockExecutionBlock
{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0 ; i < 2;  i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1 --- %@" ,[NSThread currentThread]);
        }
    }];
    
    // 添加executionBlock
    [op addExecutionBlock:^{
        for (int i = 0 ; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"2 --- %@",[NSThread currentThread]);
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0 ; i <     2 ; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3 --- %@", [NSThread currentThread]);
        }
    }];
    [op addExecutionBlock:^{
        for ( int i = 0 ; i < 2 ; i ++ ) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"4 --- %@", [NSThread currentThread]);
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0 ; i < 2 ; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"5 --- %@",[NSThread currentThread]);
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0 ; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"6 --- %@", [NSThread currentThread]);
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0 ; i < 2 ; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"7 --- %@", [NSThread currentThread]);
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0 ; i < 2 ; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"8 --- %@", [NSThread currentThread]);
        }
    }];
    [op start];
    /*  注意区分线程  具体在哪条线程执行 系统决定 多个操作开启多个线程
     NSOperation[96528:6136730] 1 --- <NSThread: 0x6000016a9080>{number = 5, name = (null)}
     NSOperation[96528:6136728] 4 --- <NSThread: 0x6000016ad080>{number = 3, name = (null)}
     NSOperation[96528:6136670] 8 --- <NSThread: 0x6000016c6800>{number = 1, name = main}
     NSOperation[96528:6136736] 5 --- <NSThread: 0x6000016fc080>{number = 9, name = (null)}
     NSOperation[96528:6136738] 6 --- <NSThread: 0x6000016a8f80>{number = 7, name = (null)}
     NSOperation[96528:6136739] 7 --- <NSThread: 0x600001697b00>{number = 8, name = (null)}
     NSOperation[96528:6136727] 2 --- <NSThread: 0x6000016c78c0>{number = 6, name = (null)}
     NSOperation[96528:6136729] 3 --- <NSThread: 0x6000016b0b40>{number = 4, name = (null)}
     NSOperation[96528:6136738] 6 --- <NSThread: 0x6000016a8f80>{number = 7, name = (null)}
     NSOperation[96528:6136728] 4 --- <NSThread: 0x6000016ad080>{number = 3, name = (null)}
     NSOperation[96528:6136730] 1 --- <NSThread: 0x6000016a9080>{number = 5, name = (null)}
     NSOperation[96528:6136739] 7 --- <NSThread: 0x600001697b00>{number = 8, name = (null)}
     NSOperation[96528:6136670] 8 --- <NSThread: 0x6000016c6800>{number = 1, name = main}
     NSOperation[96528:6136736] 5 --- <NSThread: 0x6000016fc080>{number = 9, name = (null)}
     NSOperation[96528:6136727] 2 --- <NSThread: 0x6000016c78c0>{number = 6, name = (null)}
     NSOperation[96528:6136729] 3 --- <NSThread: 0x6000016b0b40>{number = 4, name = (null)}
     */
}

- (void)userCustomNSOperation
{
    CustomOperation *customOp = [[CustomOperation alloc] init];
    [customOp start];
    //  1 --- <NSThread: 0x6000036192c0>{number = 1, name = main}
}

- (void)userAddOperation
{
    // 创建队列
    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
     // 创建操作
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task2) object:nil];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0 ; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3 --- %@", [NSThread currentThread]);
        }
    }];
    
    [op3 addExecutionBlock:^{
        for ( int i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"4 --- %@", [NSThread currentThread]);
        }
    }];
    
    [opQueue addOperation:op1];
    [opQueue addOperation:op2];
    [opQueue addOperation:op3];   // 默认s执行 start 操作
}

- (void)useAddOperationWithBlocToQueue
{
    // 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1 --- %@",[NSThread currentThread]);
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2 ; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"2 --- %@", [NSThread currentThread]);
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2 ; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3 --- %@" ,[NSThread currentThread]);
        }
    }];
    
 }

- (void)setmaxConcurrentThread
{
    // 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 8;  //1 2 3 4 8
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1 --- %@",[NSThread currentThread]);
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2 ; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"2 --- %@", [NSThread currentThread]);
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2 ; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3 --- %@" ,[NSThread currentThread]);
        }
    }];
}

- (void)setQuenePriority
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
        for ( int i = 0 ; i < 2 ; i ++) {
            NSLog(@"1 --- %@",[NSThread currentThread]);
            [NSThread sleepForTimeInterval:2];
        }
    }];
    
    [blockOperation1 setQueuePriority:NSOperationQueuePriorityLow];
    
    NSBlockOperation *blockOperation2 = [NSBlockOperation blockOperationWithBlock:^{
        for ( int i = 0 ; i < 2 ; i ++) {
            NSLog(@"2 --- %@",[NSThread currentThread]);
            [NSThread sleepForTimeInterval:2];
        }
    }];
    [blockOperation2 setQueuePriority:NSOperationQueuePriorityHigh];
    [queue addOperation:blockOperation1];
    [queue addOperation:blockOperation2];
}

- (void)addDependency
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 添加依赖
    [op2 addDependency:op1];
    [queue addOperation:op1];
    [queue addOperation:op2];
}

- (void)communicationBetweenThread
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue addOperationWithBlock:^{
       //  异步耗时操作
        for ( int i = 0 ; i <2 ; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1 --- %@",[NSThread currentThread]);
        }
        
        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //
            for ( int i = 0 ; i <2 ; i ++) {
                [NSThread sleepForTimeInterval:2];
                NSLog(@"back to main --- %@",[NSThread currentThread]);
            }
        }];
    }];
    
}

- (void)completionBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1 --- %@",[NSThread currentThread]);
        }
    }];
    
    op1.completionBlock = ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    };
    [queue addOperation:op1];
}

- (void)TicketsStatusNotSafe
{
    NSLog(@"currentThread --- %@",[NSThread currentThread]);
    self.ticketsCount = 50;
    
    // op1 售票窗口1
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    
    // 售票
    __weak typeof(self) weakSelf = self;
    NSBlockOperation * op1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketsNotSafe];
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketsNotSafe];
    }];
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}

// 非线程安全
- (void)saleTicketsNotSafe
{
    while (1) {
        if (self.ticketsCount > 0) {
            self.ticketsCount -= 1;
            NSLog(@"%@",[NSString stringWithFormat:@"剩余票数:%ld  窗口:%@",(long)self.ticketsCount,[NSThread currentThread]]);
        } else {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

// 线程安全：使用 nslock 加锁
- (void)initTicketStatusSave
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    self.ticketsCount = 50;
    self.lock = [[NSLock alloc]init];
    
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketSafe];
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketSafe];
    }];
    
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
    
}

/**
 * 售卖火车票(线程安全)
 */
- (void)saleTicketSafe {
    while (1) {
        // 加锁
        [self.lock lock];
        if (self.ticketsCount > 0) {
            self.ticketsCount --;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%ld 窗口:%@", (long)self.ticketsCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }
        [self.lock unlock];
        if (self.ticketsCount <= 0) {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

- (void)task1
{
    for (int i = 0; i < 2 ; i ++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"1 --- %@", [NSThread currentThread]);  // 打印线程
    }
}

- (void)task2
{
    for (int i = 0; i < 2 ; i ++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"2 --- %@", [NSThread currentThread]);  // 打印线程
    }
}

// 线程安全
- (void)useGCDBuyTickets
{
    semaphoreLock = dispatch_semaphore_create(1);
    self.ticketsCount = 50;
    
    // 售票窗口1
    dispatch_queue_t queue1 = dispatch_queue_create("test1", DISPATCH_QUEUE_SERIAL);
    // 售票窗口2
    dispatch_queue_t queue2 = dispatch_queue_create("test2", DISPATCH_QUEUE_CONCURRENT);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue1, ^{
        [weakSelf saleTicketUseGCDSemaphore];
    });
 
    dispatch_async(queue2, ^{
        [weakSelf saleTicketUseGCDSemaphore];
    });
}

- (void)saleTicketUseGCDSemaphore
{
    while (1) {
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
        
        if (self.ticketsCount >= 0) {
            self.ticketsCount --;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", (long)self.ticketsCount, [NSThread currentThread]]);
        } else {
            NSLog(@"票已经售完");
            dispatch_semaphore_signal(semaphoreLock);
        }
        dispatch_semaphore_signal(semaphoreLock);
    }
}
@end
