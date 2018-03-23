//
//  SSJUtil.h
//  CurveDemo
//
//  Created by old lang on 2018/3/21.
//  Copyright © 2018年 ShanghaiWinTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

FOUNDATION_EXPORT void SSJSwizzleSelector(Class className, SEL originalSelector, SEL swizzledSelector);

@interface SSJUtil : NSObject

@end
