//
//  SSJUtil.m
//  CurveDemo
//
//  Created by old lang on 2018/3/21.
//  Copyright © 2018年 ShanghaiWinTech. All rights reserved.
//

#import "SSJUtil.h"

void SSJSwizzleSelector(Class className, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(className, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(className, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@implementation SSJUtil

@end
