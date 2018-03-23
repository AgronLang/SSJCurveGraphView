//
//  Config.h
//  SuiShouJi
//
//  Created by old lang on 2017/11/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#ifndef Config_h
#define Config_h

#ifdef DEBUG

    // 打印日志开关
    #define SSJ_PRINT_ENABLE 1

    // 检测非主线程调用布局的开关
    #define SSJ_LAYOUT_THREAD_SAFTY_DETECTION 0

    // 检测内存泄漏的开关
    #define MEMORY_LEAKS_FINDER_ENABLED 1
    #define MEMORY_LEAKS_FINDER_RETAIN_CYCLE_ENABLED 1

#else

    // 打印日志开关
    #define SSJ_PRINT_ENABLE 0

    #define SSJ_LAYOUT_THREAD_SAFTY_DETECTION 0

    #define MEMORY_LEAKS_FINDER_ENABLED 0
    #define MEMORY_LEAKS_FINDER_RETAIN_CYCLE_ENABLED 0

#endif


#else


#endif /* Config_h */
