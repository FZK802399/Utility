//
//  UIImage+GetColor.h
//  预习-01-UIPopoverController
//
//  Created by Apple on 15-7-25.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GetColor)
/**
 *  获得某个像素的颜色
 *
 *  @param point 像素点的位置
 */
- (UIColor *)pixelColorAtLocation:(CGPoint)point;

@end
