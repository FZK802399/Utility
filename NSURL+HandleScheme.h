//
//  NSURL+HandleScheme.h
//  XiYuWang
//
//  Created by 李胜书 on 16/5/26.
//  Copyright © 2016年 Ehsy_Sanli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (HandleScheme)

- (void)handleUrlScheme:(NSURL *)url TabbarControl:(UITabBarController *)tabbarControl Navigation:(UINavigationController *)navigation;

@end
