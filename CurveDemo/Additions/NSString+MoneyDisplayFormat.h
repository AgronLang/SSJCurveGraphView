//
//  NSString+MoneyDisplayFormat.h
//  MoneyMore
//
//  Created by cdd on 15/10/12.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MoneyDisplayFormat)

/**
 *  金额数字超过三位，每隔3位加逗号格式化
 *
 *  @return (NSString *)格式化后的金额字符串
 */
-(NSString *)ssj_moneyDisplayFormat;

/**
 将浮点数字符串保留指定的小数位数；
 注意：直接用[NSString stringWithFormat:@"%.2f", someDoubleValue]，如果浮点数非常大，可能会导致取到的结果精度丢失

 @param digits 小数位数
 @return
 */
- (NSString *)ssj_moneyDecimalDisplayWithDigits:(int)digits;

+ (NSString *)ssj_moneyDecimalWithOrignalMoney:(double)money DisplayWithDigits:(int)digits;


/**
 * oldStr :需要转换的字符串
 * targetStr: 需要改变颜色的字符串
 * range: 需要改变文字的字符串的位置(targetStr和range传一个就可以)
 * color: 需要改变的文字颜色
 */
- (NSMutableAttributedString *)attributeStrWithTargetStr:(NSString *)targetStr range:(NSRange)range color:(UIColor *)color;


/**
 将浮点数字符串保留指定的小数位数；
 (和上面一个方法的区别，一个是使用有千分位分隔符设置的格式，这个方法是使用普通格式)
 @param digits 小数位数
 @return
 */
- (NSString *)ssj_moneyDecimalDisplayWithOutFormatDigits:(int)digits;

- (NSMutableAttributedString *)attributeStrWithTargetStr:(NSString *)targetStr range:(NSRange)range attributedDictionary:(NSDictionary *)attriDic;
@end
