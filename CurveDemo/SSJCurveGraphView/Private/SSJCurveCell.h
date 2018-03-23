//
//  SSJCurveCell.h
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

@class SSJCurveCellItem;

@interface SSJCurveCell : UICollectionViewCell

@property (nonatomic, strong) SSJCurveCellItem *cellItem;

@end

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

@class SSJCurveViewItem;

@interface SSJCurveCellItem : NSObject

@property (nonatomic, strong) NSArray<SSJCurveViewItem *> *curveItems;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) UIFont *titleFont;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIColor *scaleColor;

@property (nonatomic, assign) CGFloat scaleTop;

@property (nonatomic, assign) BOOL scaleDisplayed;

@end
