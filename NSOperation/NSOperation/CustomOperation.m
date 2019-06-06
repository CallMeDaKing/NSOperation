//
//  CustomOperation.m
//  NSOperation
//
//  Created by apple on 2019/6/4.
//  Copyright © 2019 apple. All rights reserved.
//

#import "CustomOperation.h"

@implementation CustomOperation
- (void)main {
    if (!self.isCancelled) {
        for ( int i = 0;  i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1 --- %@", [NSThread currentThread]);
        }
    }
}
@end
