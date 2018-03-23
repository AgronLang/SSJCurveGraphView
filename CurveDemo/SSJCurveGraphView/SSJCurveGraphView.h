//
//  SSJReportFormsCurveGraphView.h
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJCurveConst.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJCurveGraphView;

@protocol SSJCurveGraphViewDataSource <NSObject>

@required
- (NSUInteger)numberOfAxisXInCurveGraphView:(SSJCurveGraphView *)graphView;

- (double)curveGraphView:(SSJCurveGraphView *)graphView valueForCurveAtIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex;

@optional

/**
 返回展示多少条曲线

 @param graphView <#graphView description#>
 @return <#return value description#>
 */
- (NSUInteger)numberOfCurveInCurveGraphView:(SSJCurveGraphView *)graphView;

/**
 X轴下方显示的标题

 @param graphView <#graphView description#>
 @param index <#index description#>
 @return <#return value description#>
 */
- (nullable NSString *)curveGraphView:(SSJCurveGraphView *)graphView titleAtAxisXIndex:(NSUInteger)index;

/**
 返回曲线的颜色

 @param graphView <#graphView description#>
 @param curveIndex <#curveIndex description#>
 @return <#return value description#>
 */
- (nullable UIColor *)curveGraphView:(SSJCurveGraphView *)graphView colorForCurveAtIndex:(NSUInteger)curveIndex;

/**
 X轴下方悬浮的标题

 @param graphView <#graphView description#>
 @param index <#index description#>
 @return <#return value description#>
 */
- (nullable NSString *)curveGraphView:(SSJCurveGraphView *)graphView suspensionTitleAtAxisXIndex:(NSUInteger)index;

/**
 是否在指定曲线上的指定X轴下标展示数值

 @param graphView <#graphView description#>
 @param curveIndex <#curveIndex description#>
 @param axisXIndex <#axisXIndex description#>
 @return <#return value description#>
 */
- (BOOL)curveGraphView:(SSJCurveGraphView *)graphView shouldShowValuePointForCurveAtIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex;

/**
 是否展示X轴上的刻度；如果不实现此方法，默认NO

 @param graphView <#graphView description#>
 @param axisXIndex X轴下标
 @return <#return value description#>
 */
- (BOOL)curveGraphView:(SSJCurveGraphView *)graphView shouldShowXAxialScaleAtAxisXIndex:(NSUInteger)axisXIndex;

@end

@protocol SSJCurveGraphViewDelegate <NSObject>

@optional
- (void)curveGraphView:(SSJCurveGraphView *)graphView didScrollToAxisXIndex:(NSUInteger)index;

- (NSArray<NSString *> *)curveGraphView:(SSJCurveGraphView *)graphView titlesForAnchorSuspensionViewAtAxisXIndex:(NSUInteger)index;

- (nullable NSString *)curveGraphView:(SSJCurveGraphView *)graphView titleForIntersectionPointAtCurveIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex;

@end

@interface SSJCurveGraphView : UIView

@property (nonatomic, weak) id<SSJCurveGraphViewDataSource> dataSource;

@property (nonatomic, weak) id<SSJCurveGraphViewDelegate> delegate;

/**
 X轴每个刻度之间的距离，默认50
 */
@property (nonatomic) CGFloat unitAxisXLength;

/**
 Y轴刻度数量，默认6
 */
@property (nonatomic) NSUInteger axisYCount;

/**
 Y轴刻度上的最大值
 */
@property (nonatomic, readonly) double maxValue;

/**
 X轴的刻度数量
 */
@property (nonatomic, readonly) NSUInteger axisXCount;

/**
 曲线数量
 */
@property (nonatomic, readonly) NSUInteger curveCount;

/**
 当前滚动至锚点的X轴下标
 */
@property (nonatomic, readonly) NSUInteger currentIndex;

/**
 锚点，取值范围0～1；默认0.5
 */
@property (nonatomic) CGFloat anchorPointX;

/**
 当前可见的X轴下标
 */
@property (nonatomic, strong, readonly) NSMutableArray<NSNumber *> *visibleIndexs;

/**
 曲线的Y轴坐标浮动范围，只有top、bottom的值有效，默认{46, 0, 56, 0}
 */
@property (nonatomic) UIEdgeInsets curveInsets;

/**
 刻度值、刻度线的颜色，默认lightGrayColor
 */
@property (nonatomic, strong) UIColor *scaleColor;

/**
 X轴、Y轴刻度标题字体大小，默认10号
 */
@property (nonatomic) CGFloat scaleTitleFontSize;

/**
 是否显示锚点浮动视图，默认NO
 */
@property (nonatomic, assign) BOOL showAnchorSuspensionView;

/**
 是否在每个曲线上显示数值，默认NO；
 如果实现了数据源代理方法curveGraphView:shouldShowValuePointForCurveAtIndex:axisXIndex:就忽略此属性
 */
@property (nonatomic, assign) BOOL showValuePoint;

/**
 数值颜色，默认blackColor
 */
@property (nonatomic, strong) UIColor *valueColor;

/**
 数值字体大小，默认12
 */
@property (nonatomic, assign) CGFloat valueFontSize;

/**
 是否显示曲线的阴影，默认YES
 */
@property (nonatomic, assign) BOOL showCurveShadow;

/**
 是否显示原点到第一个值、最后一个值到终点的曲线，默认NO
 */
@property (nonatomic, assign) BOOL showOriginAndTerminalCurve;

/**
 横线样式（实线/虚线）
 */
@property (nonatomic) SSJCurveGridViewLineStyle horizontalLineStyle;

/**
 重载数据，此方法触发SSJReportFormsCurveGraphViewDelegate的方法
 */
- (void)reloadData;

/**
 滚动到指定的X轴下标，使其位于中间
 
 @param index 指定的X轴下标
 @param animted 是否显示动画效果
 */
- (void)scrollToAxisXAtIndex:(NSUInteger)index animated:(BOOL)animted;

@end

NS_ASSUME_NONNULL_END
