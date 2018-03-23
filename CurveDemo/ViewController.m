//
//  ViewController.m
//  CurveDemo
//
//  Created by old lang on 2018/3/21.
//  Copyright © 2018年 ShanghaiWinTech. All rights reserved.
//

#import "ViewController.h"
#import "SSJCurveGraphView.h"

@interface ViewController () <SSJCurveGraphViewDataSource, SSJCurveGraphViewDelegate>

@property (nonatomic, strong) SSJCurveGraphView *graphView;

@property (nonatomic, strong) UIButton *btn;

@property (nonatomic, strong) UITextField *field1;

@property (nonatomic, strong) NSMutableArray *values;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _values = [NSMutableArray array];
    
    _graphView = [[SSJCurveGraphView alloc] init];
    _graphView.dataSource = self;
    _graphView.delegate = self;
    _graphView.axisYCount = 3;
    _graphView.showAnchorSuspensionView = YES;
    _graphView.layer.borderWidth = 2;
    _graphView.layer.borderColor = [UIColor blueColor].CGColor;
    _graphView.translatesAutoresizingMaskIntoConstraints = NO;
    _graphView.anchorPointX = 0.8;
    _graphView.horizontalLineStyle = SSJCurveGridViewLineStyleDashed;
    [self.view addSubview:_graphView];
    
    _field1 = [[UITextField alloc] init];
    _field1.borderStyle = UITextBorderStyleRoundedRect;
    _field1.keyboardType = UIKeyboardTypeNumberPad;
    _field1.placeholder = @"space";
    _field1.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_field1];
    
    _btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [_btn setTitle:@"reload" forState:(UIControlStateNormal)];
    [_btn setTitleColor:UIColor.orangeColor forState:(UIControlStateNormal)];
    [_btn addTarget:self action:@selector(reloadData) forControlEvents:(UIControlEventTouchUpInside)];
    _btn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_btn];
    
    [self.view setNeedsUpdateConstraints];
//    self.view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)updateViewConstraints {
    [NSLayoutConstraint constraintWithItem:_graphView attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:4].active = YES;
    [NSLayoutConstraint constraintWithItem:_graphView attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-4].active = YES;
    [NSLayoutConstraint constraintWithItem:_graphView attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:40].active = YES;
    [NSLayoutConstraint constraintWithItem:_graphView attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:300].active = YES;
    
    [NSLayoutConstraint constraintWithItem:_field1 attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:80].active = YES;
    [NSLayoutConstraint constraintWithItem:_field1 attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:30].active = YES;
    [NSLayoutConstraint constraintWithItem:_field1 attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:_graphView attribute:NSLayoutAttributeBottom multiplier:1 constant:20].active = YES;
    [NSLayoutConstraint constraintWithItem:_field1 attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:20].active = YES;
    
    [NSLayoutConstraint constraintWithItem:_btn attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:100].active = YES;
    [NSLayoutConstraint constraintWithItem:_btn attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:40].active = YES;
    [NSLayoutConstraint constraintWithItem:_btn attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:_field1 attribute:NSLayoutAttributeBottom multiplier:1 constant:40].active = YES;
    [NSLayoutConstraint constraintWithItem:_btn attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0].active = YES;
    
    [super updateViewConstraints];
}

- (void)reloadData {
    [_values removeAllObjects];
    for (int i = 0; i < 20; i ++) {
        uint32_t a = arc4random() % 100;
        [_values addObject:@(a)];
    }
    _graphView.unitAxisXLength = _field1.text.floatValue;
    [_graphView reloadData];
}

#pragma mark - SSJReportFormsCurveGraphViewDataSource
- (NSUInteger)numberOfAxisXInCurveGraphView:(SSJCurveGraphView *)graphView {
    return _values.count;
}

- (double)curveGraphView:(SSJCurveGraphView *)graphView valueForCurveAtIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex {
    return [_values[axisXIndex] doubleValue];
}

- (NSUInteger)numberOfCurveInCurveGraphView:(SSJCurveGraphView *)graphView {
    return 1;
}

- (nullable NSString *)curveGraphView:(SSJCurveGraphView *)graphView titleAtAxisXIndex:(NSUInteger)index {
    return [NSString stringWithFormat:@"%d", (int)index];
}

- (nullable UIColor *)curveGraphView:(SSJCurveGraphView *)graphView colorForCurveAtIndex:(NSUInteger)curveIndex {
    return UIColor.orangeColor;
}

- (nullable NSString *)curveGraphView:(SSJCurveGraphView *)graphView suspensionTitleAtAxisXIndex:(NSUInteger)index {
    if (index == 0) {
        return @"suspensionTitle";
    } else {
        return nil;
    }
}

- (BOOL)curveGraphView:(SSJCurveGraphView *)graphView shouldShowValuePointForCurveAtIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex {
    return NO;
}

#pragma mark - SSJReportFormsCurveGraphViewDelegate
- (void)curveGraphView:(SSJCurveGraphView *)graphView didScrollToAxisXIndex:(NSUInteger)index {
    
}

- (NSArray<NSString *> *)curveGraphView:(SSJCurveGraphView *)graphView titlesForAnchorSuspensionViewAtAxisXIndex:(NSUInteger)index {
    return @[@"title1", @"title2"];
}

- (nullable NSString *)curveGraphView:(SSJCurveGraphView *)graphView titleForIntersectionPointAtCurveIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex {
    return @"WTF???";
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
