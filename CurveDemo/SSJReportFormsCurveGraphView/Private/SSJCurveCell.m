//
//  SSJCurveCell.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCurveCell.h"
#import "SSJCurveView.h"

#pragma mark - SSJReportFormsCurveCellItem
#pragma mark -
@implementation SSJCurveCellItem

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"title":_title ?: [NSNull null],
                                                        @"titleFont":_titleFont ?: [NSNull null],
                                                        @"titleColor":_titleColor ?: [NSNull null],
                                                        @"scaleColor":_scaleColor ?: [NSNull null],
                                                        @"scaleTop":@(_scaleTop),
                                                        @"curveItems":[_curveItems debugDescription]}];
}

@end

#pragma mark - SSJCurveCell
#pragma mark -

@interface SSJCurveCell ()

@property (nonatomic, strong) NSMutableArray<SSJCurveView *> *curveViews;

@property (nonatomic, strong) UIView *scale;

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation SSJCurveCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _curveViews = [[NSMutableArray alloc] init];
        
        _scale = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 4)];
        [self.contentView addSubview:_scale];
        
        _titleLab = [[UILabel alloc] init];
        [self.contentView addSubview:_titleLab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (SSJCurveView *curveView in _curveViews) {
        curveView.frame = self.bounds;
    }
    
    _scale.leftTop = CGPointMake(self.contentView.width, _cellItem.scaleTop);
    
    [_titleLab sizeToFit];
    _titleLab.top = _scale.bottom + 8;
    _titleLab.centerX = self.contentView.width;
}

- (void)setCellItem:(SSJCurveCellItem *)cellItem {
    _cellItem = cellItem;
    
    [_curveViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_curveViews removeAllObjects];
    
    for (SSJCurveViewItem *item in _cellItem.curveItems) {
        SSJCurveView *curveView = [[SSJCurveView alloc] init];
        curveView.item = item;
        [self addSubview:curveView];
        [_curveViews addObject:curveView];
    }
    
    _scale.backgroundColor = _cellItem.scaleColor;
    _scale.hidden = !_cellItem.scaleDisplayed;
    
    _titleLab.text = _cellItem.title;
    _titleLab.textColor = _cellItem.titleColor;
    _titleLab.font = _cellItem.titleFont;
    
    [self setNeedsLayout];
}

@end
