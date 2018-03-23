//
//  SSJCurveGridView.h
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJCurveConst.h"

NS_ASSUME_NONNULL_BEGIN


@class SSJCurveGridView;

@protocol SSJCurveGridViewDataSource <NSObject>

/**
 返回横线条数

 @param gridView <#gridView description#>
 @return <#return value description#>
 */
- (NSUInteger)numberOfHorizontalLineInGridView:(SSJCurveGridView *)gridView;

/**
 返回当前下标的横线与上一条横线的间距（如果index为0，就是第一条横线与顶部的间距）

 @param gridView <#gridView description#>
 @param index <#index description#>
 @return <#return value description#>
 */
- (CGFloat)gridView:(SSJCurveGridView *)gridView headerSpaceOnHorizontalLineAtIndex:(NSUInteger)index;

/**
 返回指定下标横线左侧的标题

 @param gridView <#gridView description#>
 @param index <#index description#>
 @return <#return value description#>
 */
- (nullable NSString *)gridView:(SSJCurveGridView *)gridView titleAtIndex:(NSUInteger)index;

@optional
//- (UIColor *)gridView:(SSJCurveGridView *)gridView titleColorAtIndex:(NSUInteger)index;
//
//- (UIColor *)gridView:(SSJCurveGridView *)gridView horizontalLineColorAtIndex:(NSUInteger)index;

@end

@interface SSJCurveGridView : UIView

@property (nonatomic, weak) id <SSJCurveGridViewDataSource> dataSource;

@property (nonatomic) SSJCurveGridViewLineStyle lineStyle;

/**
 默认systemFontOfSize:12
 */
@property (nonatomic, strong) UIFont *titleFont;

/**
 默认grayColor
 */
@property (nonatomic, strong) UIColor *titleColor;

/**
 默认grayColor
 */
@property (nonatomic, strong) UIColor *lineColor;

/**
 默认1
 */
@property (nonatomic) CGFloat lineWith;

/**
 重载数据
 */
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
