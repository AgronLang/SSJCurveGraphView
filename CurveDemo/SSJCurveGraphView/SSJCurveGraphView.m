//
//  SSJReportFormsCurveGraphView.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCurveGraphView.h"
#import "SSJCurveGridView.h"
#import "SSJCurveAnchorSuspensionView.h"
#import "SSJCurveCell.h"
#import "SSJCurveDot.h"
#import "SSJCurveSuspensionView.h"
#import "SSJCurveView.h"

static NSString *const kSSJReportFormsCurveCellID = @"kSSJReportFormsCurveCellID";

@interface SSJCurveGraphView () <UICollectionViewDataSource, UICollectionViewDelegate, SSJCurveGridViewDataSource>

@property (nonatomic, strong) SSJCurveGridView *gridView;

@property (nonatomic, strong) SSJCurveAnchorSuspensionView *anchorSuspensionView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) SSJCurveSuspensionView *suspensionView;

@property (nonatomic, strong) NSMutableArray<SSJCurveDot *> *dots;

@property (nonatomic, strong) NSMutableArray<UILabel *> *labels;

@property (nonatomic, strong) NSMutableArray<UIColor *> *curveColors;

@property (nonatomic, strong) NSMutableArray<SSJCurveSuspensionViewItem *> *suspensionItems;

@property (nonatomic, strong) NSMutableArray<NSArray *> *values;

@property (nonatomic, strong) NSMutableArray<SSJCurveCellItem *> *items;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *visibleIndexs;

@property (nonatomic, strong) UIColor *defaultCurveColor;

@property (nonatomic) double maxValue;

@property (nonatomic) NSUInteger axisXCount;

@property (nonatomic) NSUInteger curveCount;

@property (nonatomic) NSUInteger currentIndex;

@property (nonatomic) BOOL userScrolled;

@property (nonatomic) BOOL hasReloaded;

@end

@implementation SSJCurveGraphView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _unitAxisXLength = 50;
        _axisYCount = 6;
        _anchorPointX = 0.5;
        _curveInsets = UIEdgeInsetsMake(46, 0, 56, 0);
        _scaleColor = [UIColor lightGrayColor];
        _scaleTitleFontSize = 10;
        _showCurveShadow = YES;
        _showOriginAndTerminalCurve = NO;
        _valueColor = [UIColor blackColor];
        _valueFontSize = 12;
        
        _curveCount = 1;
        _dots = [[NSMutableArray alloc] init];
        _labels = [[NSMutableArray alloc] init];
        _curveColors = [[NSMutableArray alloc] init];
        _suspensionItems = [[NSMutableArray alloc] init];
        _values = [[NSMutableArray alloc] init];
        _items = [[NSMutableArray alloc] init];
        _visibleIndexs = [[NSMutableArray alloc] init];
        _defaultCurveColor = [UIColor redColor];
        
        [self addSubview:self.gridView];
        [self addSubview:self.collectionView];
        [self addSubview:self.suspensionView];
        [self addSubview:self.anchorSuspensionView];
        
//#warning test
//        self.anchorSuspensionView.layer.zPosition;
//        self.anchorSuspensionView.layer.borderColor = (__bridge CGColorRef _Nullable)(UIColor.redColor);
//        self.anchorSuspensionView.layer.borderWidth = 1;
    }
    return self;
}

- (void)layoutSubviews {
    [self updateVisibleIndex];
    [self caculateCurvePoint];
    [self updateDotsAndLabelsPosition];
    [self updateAnchorSuspensionViewBasePoint];
    
    [_gridView reloadData];
    
    for (SSJCurveCellItem *item in _items) {
        item.scaleTop = self.height - _curveInsets.bottom;
    }
    
    _gridView.frame = self.bounds;
    
    [_collectionView.collectionViewLayout invalidateLayout];
    _collectionView.frame = CGRectMake(0, 0, self.width, self.height - _curveInsets.bottom + _scaleTitleFontSize + 14);
    [self updateContentInset];
    
    _suspensionView.frame = CGRectMake(0, _collectionView.bottom, self.width, self.height - _collectionView.bottom);
    
    static BOOL firstLayout = YES;
    if (firstLayout) {
        firstLayout = NO;
        _userScrolled = NO;
        [self updateContentOffset:NO];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJCurveCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSSJReportFormsCurveCellID forIndexPath:indexPath];
    if (_items.count > indexPath.item) {
        SSJCurveCellItem *item = [_items ssj_safeObjectAtIndex:indexPath.item];
        cell.cellItem = item;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < 0 || indexPath.item >= _items.count - 1) {
        return;
    }
    
    if (_currentIndex != indexPath.item) {
        for (SSJCurveDot *dot in _dots) {
            dot.hidden = YES;
        }
        for (UILabel *label in _labels) {
            label.hidden = YES;
        }
    }
    
    _userScrolled = YES;
    _currentIndex = indexPath.item;
    [self updateVisibleIndex];
    [self updateBallonAndLablesTitle];
    [self updateDotsAndLabelsPosition];
    [self updateContentOffset:YES];
}

//- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (_items.count > indexPath.item) {
//        SSJReportFormsCurveCellItem *item = [_items objectAtIndex:indexPath.item];
//        ((SSJCurveCell *)cell).cellItem = item;
//    }
//}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0 || indexPath.item == _items.count - 1) {
        return CGSizeMake(_unitAxisXLength * 0.5, _collectionView.height);
    } else {
        return CGSizeMake(_unitAxisXLength, _collectionView.height);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tracking || scrollView.dragging || scrollView.decelerating) {
        for (SSJCurveDot *dot in _dots) {
            dot.hidden = YES;
        }
        for (UILabel *label in _labels) {
            label.hidden = YES;
        }
    }
    
    _suspensionView.contentOffsetX = _collectionView.contentOffset.x;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = [self indexPathForAnchorPoint];
    if (indexPath && indexPath.item >= 0 && indexPath.item < _axisXCount) {
        _userScrolled = YES;
        _currentIndex = indexPath.item;
        [self updateVisibleIndex];
        [self updateBallonAndLablesTitle];
        [self updateDotsAndLabelsPosition];
        [self updateContentOffset:YES];
        
        if (_currentIndex == 0 || _currentIndex == _axisXCount - 1) {
            for (SSJCurveDot *dot in _dots) {
                dot.hidden = !_showAnchorSuspensionView;
            }
            
            for (UILabel *label in _labels) {
                label.hidden = !_showAnchorSuspensionView;
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(curveGraphView:didScrollToAxisXIndex:)]) {
                [_delegate curveGraphView:self didScrollToAxisXIndex:_currentIndex];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        NSIndexPath *indexPath = [self indexPathForAnchorPoint];
        if (indexPath && indexPath.item >= 0 && indexPath.item < _axisXCount) {
            _userScrolled = YES;
            _currentIndex = indexPath.item;
            [self updateVisibleIndex];
            [self updateBallonAndLablesTitle];
            [self updateDotsAndLabelsPosition];
            [self updateContentOffset:YES];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    for (SSJCurveDot *dot in _dots) {
        dot.hidden = !_showAnchorSuspensionView;
    }
    
    for (UILabel *label in _labels) {
        label.hidden = !_showAnchorSuspensionView;
    }
    
    if (_userScrolled && _delegate && [_delegate respondsToSelector:@selector(curveGraphView:didScrollToAxisXIndex:)]) {
        [_delegate curveGraphView:self didScrollToAxisXIndex:_currentIndex];
    }
}

#pragma mark - SSJReportFormsCurveGridViewDataSource
- (NSUInteger)numberOfHorizontalLineInGridView:(SSJCurveGridView *)gridView {
    return _axisYCount;
}

- (CGFloat)gridView:(SSJCurveGridView *)gridView headerSpaceOnHorizontalLineAtIndex:(NSUInteger)index {
    if (index == 0) {
        return _curveInsets.top;
    } else {
        if (_axisYCount > 1) {
            return (self.height - _curveInsets.bottom - _curveInsets.top) / (_axisYCount - 1);
        } else if (_axisYCount == 1) {
            return self.height - _curveInsets.bottom;
        } else {
            return 0;
        }
    }
}

- (nullable NSString *)gridView:(SSJCurveGridView *)gridView titleAtIndex:(NSUInteger)index {
    if (_axisYCount > 1) {
        double unitValue = _maxValue / (_axisYCount - 1);
        double value = _maxValue - unitValue * index;
        return [[NSString stringWithFormat:@"%f", value] ssj_moneyDecimalDisplayWithDigits:2];
    } else if (_axisYCount == 1) {
        return @"0.00";
    } else {
        return nil;
    }
}

#pragma mark - Pulic
- (void)setUnitAxisXLength:(CGFloat)unitAxisXLength {
    if (_unitAxisXLength != unitAxisXLength) {
        _unitAxisXLength = unitAxisXLength;
        _suspensionView.unitSpace = _unitAxisXLength;
        [self updateContentInset];
        [self updateContentOffset:NO];
        [self updateVisibleIndex];
        [self setNeedsLayout];
    }
}

- (void)setAxisYCount:(NSUInteger)axisYCount {
    if (_axisYCount != axisYCount) {
        _axisYCount = axisYCount;
        [_gridView reloadData];
    }
}

- (void)setCurveInsets:(UIEdgeInsets)curveInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_curveInsets, curveInsets)) {
        _curveInsets = curveInsets;
        [self updateAnchorSuspensionViewBasePoint];
        [self setNeedsLayout];
    }
}

- (void)setScaleColor:(UIColor *)scaleColor {
    if (!CGColorEqualToColor(_scaleColor.CGColor, scaleColor.CGColor)) {
        _scaleColor = scaleColor;
        _gridView.titleColor = _scaleColor;
        _gridView.lineColor = _scaleColor;
        
        for (SSJCurveCellItem *item in _items) {
            item.scaleColor = _scaleColor;
            item.titleColor = _scaleColor;
        }
    }
}

- (void)setScaleTitleFontSize:(CGFloat)scaleTitleFontSize {
    if (_scaleTitleFontSize != scaleTitleFontSize) {
        _scaleTitleFontSize = scaleTitleFontSize;
        _gridView.titleFont = [UIFont systemFontOfSize:_scaleTitleFontSize];
        [_items makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:_scaleTitleFontSize]];
    }
}

- (void)setAnchorPointX:(CGFloat)anchorPointX {
    _anchorPointX = anchorPointX;
    [self updateAnchorSuspensionViewBasePoint];
}

- (void)setShowAnchorSuspensionView:(BOOL)showBalloon {
    if (_showAnchorSuspensionView != showBalloon) {
        _showAnchorSuspensionView = showBalloon;
        [_dots makeObjectsPerformSelector:@selector(setHidden:) withObject:@(!_showAnchorSuspensionView)];
        [_labels makeObjectsPerformSelector:@selector(setHidden:) withObject:@(!_showAnchorSuspensionView)];
        _anchorSuspensionView.hidden = !_showAnchorSuspensionView;
        [self updateBallonAndLablesTitle];
    }
}

- (void)setShowValuePoint:(BOOL)showValuePoint {
    if (_showValuePoint != showValuePoint) {
        _showValuePoint = showValuePoint;
        
        if ([_dataSource respondsToSelector:@selector(curveGraphView:shouldShowValuePointForCurveAtIndex:axisXIndex:)]) {
            return;
        }
        
        for (SSJCurveCellItem *cellItem in _items) {
            for (SSJCurveViewItem *curveItem in cellItem.curveItems) {
                curveItem.showDot = _showValuePoint;
                curveItem.showValue = _showValuePoint;
            }
        }
    }
}

- (void)setValueColor:(UIColor *)valueColor {
    if (!CGColorEqualToColor(_valueColor.CGColor, valueColor.CGColor)) {
        _valueColor = valueColor;
        
        for (SSJCurveCellItem *cellItem in _items) {
            for (SSJCurveViewItem *curveItem in cellItem.curveItems) {
                curveItem.valueColor = _valueColor;
            }
        }
    }
}

- (void)setValueFontSize:(CGFloat)valueFontSize {
    if (_valueFontSize != valueFontSize) {
        _valueFontSize = valueFontSize;
        
        for (SSJCurveCellItem *cellItem in _items) {
            for (SSJCurveViewItem *curveItem in cellItem.curveItems) {
                curveItem.valueFont = [UIFont systemFontOfSize:_valueFontSize];
            }
        }
    }
}

- (void)setShowCurveShadow:(BOOL)showCurveShadow {
    if (_showCurveShadow != showCurveShadow) {
        _showCurveShadow = showCurveShadow;
        
        for (SSJCurveCellItem *cellItem in _items) {
            for (SSJCurveViewItem *curveItem in cellItem.curveItems) {
                curveItem.showShadow = _showCurveShadow;
            }
        }
    }
}

- (void)setShowOriginAndTerminalCurve:(BOOL)showOriginAndTerminalCurve {
    if (_showOriginAndTerminalCurve != showOriginAndTerminalCurve) {
        _showOriginAndTerminalCurve = showOriginAndTerminalCurve;
        
        for (int cellIdx = 0; cellIdx < _items.count; cellIdx ++) {
            
            SSJCurveCellItem *cellItem = _items[cellIdx];
            
            for (SSJCurveViewItem *curveItem in cellItem.curveItems) {
                
                if (_showOriginAndTerminalCurve) {
                    curveItem.showCurve = YES;
                    curveItem.showShadow = _showCurveShadow;
                } else {
                    if (cellIdx > 0 && cellIdx < _axisXCount) {
                        curveItem.showCurve = YES;
                        curveItem.showShadow = _showCurveShadow;
                    } else {
                        curveItem.showCurve = NO;
                        curveItem.showShadow = NO;
                    }
                }
            }
        }
    }
}

- (void)setHorizontalLineStyle:(SSJCurveGridViewLineStyle)horizontalLineStyle {
    _horizontalLineStyle = horizontalLineStyle;
    _gridView.lineStyle = horizontalLineStyle;
}

- (void)reloadData {
    if (!_dataSource
        || ![_dataSource respondsToSelector:@selector(numberOfAxisXInCurveGraphView:)]
        || ![_dataSource respondsToSelector:@selector(curveGraphView:valueForCurveAtIndex:axisXIndex:)]) {
        return;
    }
    
    _hasReloaded = YES;
    _maxValue = 0;
    _currentIndex = 0;
    [self updateVisibleIndex];
    
    [_curveColors removeAllObjects];
    [_values removeAllObjects];
    [_items removeAllObjects];
    
    [_dots makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_dots removeAllObjects];
    
    [_labels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_labels removeAllObjects];
    
    [_suspensionItems removeAllObjects];
    
    _anchorSuspensionView.titles = nil;
    
    _axisXCount = [_dataSource numberOfAxisXInCurveGraphView:self];
    if (_axisXCount == 0) {
        [_collectionView reloadData];
        _suspensionView.items = nil;
        _anchorSuspensionView.hidden = YES;
        return;
    }
    
    if ([_dataSource respondsToSelector:@selector(numberOfCurveInCurveGraphView:)]) {
        _curveCount = [_dataSource numberOfCurveInCurveGraphView:self];
        if (_curveCount == 0) {
            [_collectionView reloadData];
            _suspensionView.items = nil;
            _anchorSuspensionView.hidden = YES;
            return;
        }
    }
    
    _anchorSuspensionView.hidden = !_showAnchorSuspensionView;
    
    [self updateVisibleIndex];
    
    [self updateContentOffset:NO];
    
    [self reorganiseCurveColors];
    
    [self reorganiseValues];
    
    [self reorganiseItems];
    
    [self reorganiseSuspensionViewItem];
    
    [self reorganiseDotsAndLabels];
    
    [self updateBallonAndLablesTitle];
    
    int approach = pow(10, (int)log10(_maxValue));
    double remainder = _maxValue / approach - (int)(_maxValue / approach);
    _maxValue = remainder == 0 ? _maxValue : ((int)(_maxValue / approach) + 1.0) * approach;
    
    [self caculateCurvePoint];
    [self updateDotsAndLabelsPosition];
    
    [_gridView reloadData];
    [_collectionView reloadData];
    _suspensionView.items = _suspensionItems;
}

- (void)scrollToAxisXAtIndex:(NSUInteger)index animated:(BOOL)animted {
    if (index >= _axisXCount) {
        NSLog(@"index必须小于%d", (int)_axisXCount);
        return;
    }
    
    if (animted && _currentIndex != index) {
        for (SSJCurveDot *dot in _dots) {
            dot.hidden = YES;
        }
        
        for (UILabel *label in _labels) {
            label.hidden = YES;
        }
    }
    
    _userScrolled = NO;
    _currentIndex = index;
    [self updateVisibleIndex];
    [self updateBallonAndLablesTitle];
    [self updateDotsAndLabelsPosition];
    [self updateContentOffset:animted];
}

#pragma mark - Private
- (void)reorganiseCurveColors {
    for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
        UIColor *curveColor = [_dataSource curveGraphView:self colorForCurveAtIndex:curveIdx];
        [_curveColors addObject:(curveColor ?: _defaultCurveColor)];
    }
}

- (void)reorganiseValues {
    NSMutableArray *originValues = [[NSMutableArray alloc] initWithCapacity:_curveCount];
    for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
        [originValues addObject:@0];
    }
    [_values addObject:originValues];
    
    for (int axisXIdx = 0; axisXIdx < _axisXCount; axisXIdx ++) {
        NSMutableArray *valuesPerAxisX = [[NSMutableArray alloc] initWithCapacity:_curveCount];
        for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
            double value = [_dataSource curveGraphView:self valueForCurveAtIndex:curveIdx axisXIndex:axisXIdx];
            [valuesPerAxisX addObject:@(value)];
            _maxValue = MAX(value, _maxValue);
        }
        [_values addObject:valuesPerAxisX];
    }
    
    NSMutableArray *terminalValues = [[NSMutableArray alloc] initWithCapacity:_curveCount];
    for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
        [terminalValues addObject:@0];
    }
    [_values addObject:terminalValues];
}

- (void)reorganiseItems {
    BOOL responseToTitleAtAxisXIndex = [_dataSource respondsToSelector:@selector(curveGraphView:titleAtAxisXIndex:)];
    BOOL responseToShouldShowXAxialScale = [_dataSource respondsToSelector:@selector(curveGraphView:shouldShowXAxialScaleAtAxisXIndex:)];
    BOOL responseToShouldShowValuePoint = [_dataSource respondsToSelector:@selector(curveGraphView:shouldShowValuePointForCurveAtIndex:axisXIndex:)];
    
    for (int axisXIdx = 0; axisXIdx < _axisXCount + 1; axisXIdx ++) {
        SSJCurveCellItem *cellItem = [[SSJCurveCellItem alloc] init];
        NSMutableArray *curveItems = [[NSMutableArray alloc] initWithCapacity:_curveCount];
        
        if (axisXIdx < _axisXCount) {
            if (responseToTitleAtAxisXIndex) {
                cellItem.title = [_dataSource curveGraphView:self titleAtAxisXIndex:axisXIdx];
                cellItem.titleFont = [UIFont systemFontOfSize:_scaleTitleFontSize];
                cellItem.titleColor = _scaleColor;
            }
            
            if (responseToShouldShowXAxialScale) {
                cellItem.scaleDisplayed = [_dataSource curveGraphView:self shouldShowXAxialScaleAtAxisXIndex:axisXIdx];
                cellItem.scaleColor = _scaleColor;
                cellItem.scaleTop = self.height - _curveInsets.bottom;
            }
        }
        
        for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
            SSJCurveViewItem *curveItem = [[SSJCurveViewItem alloc] init];
            curveItem.curveColor = [_curveColors objectAtIndex:curveIdx];
            curveItem.curveWidth = 1;
            curveItem.shadowWidth = 3;
            curveItem.shadowOffset = CGSizeMake(0, 10);
            curveItem.shadowAlpha = 0.2;
            curveItem.valueColor = _valueColor;
            curveItem.valueFont = [UIFont systemFontOfSize:_valueFontSize];
            curveItem.dotColor = [_curveColors objectAtIndex:curveIdx];
            curveItem.dotAlpha = 0.3;
            
            if (_showOriginAndTerminalCurve) {
                curveItem.showCurve = YES;
                curveItem.showShadow = _showCurveShadow;
            } else {
                if (axisXIdx > 0 && axisXIdx < _axisXCount) {
                    curveItem.showCurve = YES;
                    curveItem.showShadow = _showCurveShadow;
                } else {
                    curveItem.showCurve = NO;
                    curveItem.showShadow = NO;
                }
            }
            
            if (axisXIdx < _axisXCount) {
                NSArray *valuesPerAxis = _values[axisXIdx + 1];
                double value = [valuesPerAxis[curveIdx] doubleValue];
                curveItem.value = [[NSString stringWithFormat:@"%f", value] ssj_moneyDecimalDisplayWithDigits:2];
                BOOL showValuePoint = _showValuePoint;
                if (responseToShouldShowValuePoint) {
                    showValuePoint = [_dataSource curveGraphView:self shouldShowValuePointForCurveAtIndex:curveIdx axisXIndex:axisXIdx];
                }
                curveItem.showValue = showValuePoint;
                curveItem.showDot = showValuePoint;
            }
            
            [curveItems addObject:curveItem];
        }
        
        cellItem.curveItems = curveItems;
        [_items addObject:cellItem];
    }
}

- (void)reorganiseDotsAndLabels {
    NSUInteger currentIndex = _currentIndex + 1;
    if (_values.count <= currentIndex) {
        return;
    }
    
    NSArray *values = _values[currentIndex];
    if (![values isKindOfClass:[NSArray class]]) {
        return;
    }
    
    for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
        
        UIColor *color = _curveColors[curveIdx];
        
        double value = [values[curveIdx] doubleValue];
        CGFloat maxCurveHeight = (self.height - _curveInsets.top - _curveInsets.bottom);
        CGFloat y = self.height - _curveInsets.bottom;
        y = _maxValue == 0 ?: y - value / _maxValue * maxCurveHeight;
        
        SSJCurveDot *dot = [[SSJCurveDot alloc] init];
        dot.outerColorAlpha = 0.2;
        dot.dotColor = color;
        dot.center = CGPointMake(self.width * 0.5, y);
        dot.hidden = !_showAnchorSuspensionView;
        [self addSubview:dot];
        [_dots addObject:dot];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:_valueFontSize];
        label.textColor = color;
        label.hidden = !_showAnchorSuspensionView;
        [self addSubview:label];
        [_labels addObject:label];
    }
}

- (void)reorganiseSuspensionViewItem {
    if (![_dataSource respondsToSelector:@selector(curveGraphView:suspensionTitleAtAxisXIndex:)]) {
        return;
    }
    
    SSJCurveSuspensionViewItem *item = nil;
    NSUInteger rowCount = 0;
    
    for (int axisXIdx = 0; axisXIdx < _axisXCount; axisXIdx ++) {
        NSString *suspensionTitle = [_dataSource curveGraphView:self suspensionTitleAtAxisXIndex:axisXIdx];
        if (suspensionTitle) {
            if (item) {
                item.rowCount = rowCount;
                [_suspensionItems addObject:item];
            }
            item = [[SSJCurveSuspensionViewItem alloc] init];
            item.titleColor = _scaleColor;
            item.titleFont = [UIFont systemFontOfSize:_scaleTitleFontSize];
            item.title = suspensionTitle;
            rowCount = 0;
        } else {
            if (!item) {
                item = [[SSJCurveSuspensionViewItem alloc] init];
                item.titleColor = _scaleColor;
                item.titleFont = [UIFont systemFontOfSize:_scaleTitleFontSize];
            }
            rowCount ++;
        }
    }
    
    if (item) {
        item.rowCount = rowCount;
        [_suspensionItems addObject:item];
    }
}

- (void)caculateCurvePoint {
    for (int cellIdx = 0; cellIdx < _items.count; cellIdx ++) {
        SSJCurveCellItem *cellItem = _items[cellIdx];
        
        NSArray *startValues = _values[cellIdx];
        NSArray *endValues = _values[cellIdx + 1];
        
        SSJCurveCellItem *preItem = nil;
        if (cellIdx > 0) {
            preItem = [_items ssj_safeObjectAtIndex:cellIdx - 1];
        }
        
        for (int curveIdx = 0; curveIdx < cellItem.curveItems.count; curveIdx ++) {
            CGFloat maxCurveHeight = self.height - _curveInsets.top - _curveInsets.bottom;
            double startValue = [startValues[curveIdx] doubleValue];
            double startPintY = self.height - (startValue / _maxValue) * maxCurveHeight - _curveInsets.bottom;
            double endValue = [endValues[curveIdx] doubleValue];
            CGFloat endPintY = self.height - _curveInsets.bottom;
            endPintY = _maxValue == 0 ?: endPintY - (endValue / _maxValue) * maxCurveHeight;
            CGFloat endPointX = (cellIdx == 0 || cellIdx == _items.count - 1) ? _unitAxisXLength * 0.5 : _unitAxisXLength;
            
            SSJCurveViewItem *curveItem = cellItem.curveItems[curveIdx];
            curveItem.startPoint = CGPointMake(0, startPintY);
            curveItem.endPoint = CGPointMake(endPointX, endPintY);
            
            if (preItem) {
                SSJCurveViewItem *preCurveItem = preItem.curveItems[curveIdx];
                if (curveItem.showValue && preCurveItem.showValue) {
                    [curveItem testOverlapPreItem:preCurveItem space:_unitAxisXLength];
                }
            }
        }
    }
}

- (void)updateContentOffset:(BOOL)animated {
    CGFloat offsetX = (_currentIndex + 0.5) * _unitAxisXLength - _collectionView.width * _anchorPointX;
    [_collectionView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
}

- (void)updateContentInset {
    CGFloat left = _collectionView.width * _anchorPointX - _unitAxisXLength * 0.5;
    CGFloat right = _collectionView.width * (1 - _anchorPointX) - _unitAxisXLength * 0.5;
    _collectionView.contentInset = UIEdgeInsetsMake(0, left, 0, right);
}

- (void)updateDotsAndLabelsPosition {
    if (_maxValue == 0) {
        return;
    }
    
    NSUInteger currentIndex = _currentIndex + 1;
    if (_values.count <= currentIndex) {
        return;
    }
    
    NSArray *values = _values[currentIndex];
    if (![values isKindOfClass:[NSArray class]]) {
        return;
    }
    
    CGFloat cornerPointY = CGFLOAT_MAX;
    for (int idx = 0; idx < _dots.count; idx ++) {
        if (values.count <= idx) {
            return;
        }
        
        double value = [values[idx] doubleValue];
        CGFloat maxCurveHeight = (self.height - _curveInsets.top - _curveInsets.bottom);
        CGFloat y = self.height - _curveInsets.bottom - value / _maxValue * maxCurveHeight;
        cornerPointY = MIN(cornerPointY, y);
        
        SSJCurveDot *dot = _dots[idx];
        dot.center = CGPointMake(_anchorPointX * self.width, y);
        
        UILabel *label = _labels[idx];
        if (idx % 2 == 0) {
            label.left = dot.right + 2;
            label.centerY = dot.centerY;
        } else {
            label.right = dot.left - 2;
            label.centerY = dot.centerY;
        }
    }
    
    if (cornerPointY != CGFLOAT_MAX) {
        _anchorSuspensionView.cornerPointY = cornerPointY - 20;
    }
}

- (void)updateBallonAndLablesTitle {
    if (!_showAnchorSuspensionView || !_hasReloaded) {
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(curveGraphView:titlesForAnchorSuspensionViewAtAxisXIndex:)]) {
        _anchorSuspensionView.titles = [_delegate curveGraphView:self titlesForAnchorSuspensionViewAtAxisXIndex:_currentIndex];
    }
    
    for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
        if (_labels.count <= curveIdx) {
            break;
        }
        UILabel *label = _labels[curveIdx];
        if (_delegate && [_delegate respondsToSelector:@selector(curveGraphView:titleForIntersectionPointAtCurveIndex:axisXIndex:)]) {
            label.text = [_delegate curveGraphView:self titleForIntersectionPointAtCurveIndex:curveIdx axisXIndex:_currentIndex];
            [label sizeToFit];
        }
    }
}

- (void)updateVisibleIndex {
    if (_unitAxisXLength <= 0 || _axisXCount == 0) {
        return;
    }
    
    [_visibleIndexs removeAllObjects];
    int indexOffset1 = floor(_anchorPointX * self.width / _unitAxisXLength);
    int indexOffset2 = floor((1 - _anchorPointX) * self.width / _unitAxisXLength);
    int minIndex = MAX((int)_currentIndex - indexOffset1, 0);
    int maxIndex = MIN((int)_axisXCount - 1, (int)_currentIndex + indexOffset2);
    for (NSUInteger idx = minIndex; idx <= maxIndex; idx ++) {
        [_visibleIndexs addObject:@(idx)];
    }
}

- (NSIndexPath *)indexPathForAnchorPoint {
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:CGPointMake(_collectionView.width * _anchorPointX + _collectionView.contentOffset.x, 0)];
    if (indexPath) {
        UICollectionViewLayoutAttributes *layout = [_collectionView layoutAttributesForItemAtIndexPath:indexPath];
        CGFloat centerX = _collectionView.width * 0.5 + _collectionView.contentOffset.x;
        if (centerX < CGRectGetMidX(layout.frame)) {
            indexPath = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
        }
        return indexPath;
    }
    
    return nil;
}

- (void)updateAnchorSuspensionViewBasePoint {
    _anchorSuspensionView.basePoint = CGPointMake(_anchorPointX * self.width, self.height - _curveInsets.bottom);
}

#pragma mark - LazyLoading
- (SSJCurveGridView *)gridView {
    if (!_gridView) {
        _gridView = [[SSJCurveGridView alloc] init];
        _gridView.dataSource = self;
    }
    return _gridView;
}

- (SSJCurveAnchorSuspensionView *)anchorSuspensionView {
    if (!_anchorSuspensionView) {
        _anchorSuspensionView = [[SSJCurveAnchorSuspensionView alloc] init];
        _anchorSuspensionView.hidden = !_showAnchorSuspensionView;
    }
    return _anchorSuspensionView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[SSJCurveCell class] forCellWithReuseIdentifier:kSSJReportFormsCurveCellID];
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

- (SSJCurveSuspensionView *)suspensionView {
    if (!_suspensionView) {
        _suspensionView = [[SSJCurveSuspensionView alloc] init];
        _suspensionView.unitSpace = _unitAxisXLength;
    }
    return _suspensionView;
}

@end
