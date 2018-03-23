//
//  SSJReportFormsCurveBalloonView.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCurveAnchorSuspensionView.h"

#define SSJ_PROMPT_BACKGROUND_COLOR [[UIColor blackColor] colorWithAlphaComponent:0.7]

static const CGSize kTriangleSize = {8, 5};
static const UIEdgeInsets kContentInsets = {8, 4, 8, 4};
static const CGFloat kLabelsVerticalGap = 6; // label之间的垂直间距

////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJReportFormsCurveBalloonHeaderView
#pragma mark -
@interface _SSJReportFormsCurveBalloonHeaderView : UIView

@property (nonatomic, strong) NSMutableArray<UILabel *> *labels;

@end

@implementation _SSJReportFormsCurveBalloonHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _labels = [NSMutableArray array];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    __block CGFloat top = kContentInsets.top;
    [_labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.leftTop = CGPointMake(kContentInsets.left, top);
        top = CGRectGetMaxY(obj.frame) + kLabelsVerticalGap;
    }];
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kTriangleSize.height) cornerRadius:3];
    [path moveToPoint:CGPointMake((self.width - kTriangleSize.width) * 0.5, self.height - kTriangleSize.height)];
    [path addLineToPoint:CGPointMake(self.width * 0.5, self.height)];
    [path addLineToPoint:CGPointMake((self.width + kTriangleSize.width) * 0.5, self.height - kTriangleSize.height)];
    [SSJ_PROMPT_BACKGROUND_COLOR setFill];
    [path fill];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = 0, height = 0;
    for (UILabel *lab in _labels) {
        [lab sizeToFit];
        width = MAX(width, CGRectGetWidth(lab.bounds));
        height += CGRectGetHeight(lab.bounds);
    }
    height += (_labels.count - 1) * kLabelsVerticalGap;
    return CGSizeMake(width + kContentInsets.left + kContentInsets.right, height + kContentInsets.top + kContentInsets.bottom + kTriangleSize.height);
}

@end

////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJReportFormsCurveBalloonView
#pragma mark -

@implementation SSJCurveAnchorSuspensionView {
    _SSJReportFormsCurveBalloonHeaderView *_headerView;
    UIView *_verticalLine;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _headerView = [[_SSJReportFormsCurveBalloonHeaderView alloc] init];
        [self addSubview:_headerView];
        
        _verticalLine = [[UIView alloc] init];
        _verticalLine.width = 1;
        _verticalLine.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_verticalLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_headerView sizeToFit];
    [_headerView setNeedsDisplay];
    _verticalLine.top = _headerView.bottom;
    _verticalLine.height = self.height - _headerView.bottom;
    _verticalLine.centerX = self.width * 0.5;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize headerSize = [_headerView sizeThatFits:size];
    return CGSizeMake(headerSize.width, headerSize.height + _basePoint.y - _cornerPointY);
}

- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    [_headerView.labels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_headerView.labels removeAllObjects];
    for (NSString *title in titles) {
        UILabel *lab = [[UILabel alloc] init];
        lab.text = title;
        lab.font = [UIFont systemFontOfSize:9];
        lab.textColor = [UIColor whiteColor];
        [_headerView.labels addObject:lab];
        [_headerView addSubview:lab];
    }
    [_headerView sizeToFit];
    [_headerView setNeedsDisplay];
}

- (void)setBasePoint:(CGPoint)basePoint {
    _basePoint = basePoint;
    [self sizeToFit];
    [self setNeedsLayout];
    self.left = _basePoint.x - self.width * 0.5;
    self.top = _basePoint.y - self.height;
}

- (void)setCornerPointY:(CGFloat)conerPointY {
    _cornerPointY = conerPointY;
    [self sizeToFit];
    [self setNeedsLayout];
    self.top = _basePoint.y - self.height;
}

@end
