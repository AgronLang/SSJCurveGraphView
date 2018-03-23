//
//  SSJCurveSuspensionView.h
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/20.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSJCurveSuspensionViewItem : NSObject

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, assign) NSUInteger rowCount;

@end


@interface SSJCurveSuspensionView : UIView

@property (nonatomic) CGFloat unitSpace;

@property (nonatomic) CGFloat contentOffsetX;

@property (nonatomic, strong, nullable) NSArray<SSJCurveSuspensionViewItem *> *items;

@end

NS_ASSUME_NONNULL_END
