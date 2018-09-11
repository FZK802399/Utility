//
//  NSURL+HandleScheme.m
//  XiYuWang
//
//  Created by 李胜书 on 16/5/26.
//  Copyright © 2016年 Ehsy_Sanli. All rights reserved.
//

#import "NSURL+HandleScheme.h"
#import "NSArray+Extension.h"
#import "CategorysDetailRootViewModel.h"
#import <objc/runtime.h>

@implementation NSURL (HandleScheme)

- (void)handleUrlScheme:(NSURL *)url TabbarControl:(UITabBarController *)tabbarControl Navigation:(UINavigationController *)navigation {
    NSString *host = url.host;
    NSString *path = url.path;
    NSString *query = url.query;
    CacheFileName *cfn = [[CacheFileName alloc]init];
    NSDictionary *schemeDic = [[WriteCacheUtil ShareInstance]readDocumentDictionary:cfn.cacheSchemeDicName];
    NSString *dicClassKeyName;//通过dic获取controller类名，此处为dic的keypath
    if (!schemeDic) {
        schemeDic = @{@"home":@{@"controller":@"RootPageViewController"},
                      @"home/summerSale": @{@"controller": @"SummerSaleController"},
                      @"product/category": @{@"controller": @"RootPageCategorysSpecialViewController",
                                             @"model": @[@"RootPageCategorysSpecialModel", @"LastListModel"]},
                      @"home/allCategory": @{@"controller": @"RootPageAllCategorysViewController",
                                             @"model": @"RootPagePersonalCategoryModel"},
                      @"product/brand": @{@"controller": @"RootPageBrandSpecialViewController",
                                          @"model": @[@"RootPageBrandSpecialViewModel", @"RootPageBrandModel"]},
                      @"home/selectCity": @{@"controller": @"RootPageSelectCityViewController"},
                      @"home/quickBought": @{@"controller": @"QuickBoughtRootViewController",
                                             @"model": @"QuickBoughtRootViewModel"},
                      @"home/openWebRemind": @{@"controller": @"RootPageOpenWebRemindViewController"},
                      @"home/promotion": @{@"controller": @"RootPagePromotionViewController"},
                      @"product/list":@{@"controller":@"CategorysDetailRootViewController",
                                        @"model":@"CategorysDetailRootViewModel"},
                      @"product/category":@{@"controller":@"CategorysViewController"},
                      @"product/detail":@{@"controller":@"CategorysProductDetailViewController",
                                          @"model":@"CategorysProductDetailViewModel"},
                      @"my":@{@"controller":@"MyCenterViewController"},
                      @"user/login":@{@"controller":@"LoginRootViewController"},
                      @"user/register":@{@"controller":@"RegistRootViewController"},
                      @"my/notice":@{@"controller":@"MessageCenterViewController"},
                      @"my/account":@{@"controller":@"MySettingViewController"},
                      @"my/address":@{@"controller":@"AddressListController"},
                      @"my/invoice":@{@"controller":@"InvoceListController"},
                      @"my/history":@{@"controller":@"MyFootController"},
                      @"my/coupon":@{@"controller":@"CouponsController"},
                      @"my/order":@{@"controller":@"AllOrdersController"},
                      };
    }
    if (![host isEqualToString:@""] && host) {
        if ([path isEqualToString:@""]) {
            dicClassKeyName = host;
        }else {
            dicClassKeyName = [NSString stringWithFormat:@"%@%@",host,path];
        }
        NSDictionary *classDic = schemeDic[dicClassKeyName];
        NSString *className = classDic[@"controller"];
        id modelObj = classDic[@"model"];
        NSString *modelName;
        NSArray *modelArr;
        if ([modelObj isKindOfClass:[NSString class]]) {
            modelName = modelObj;
        }else {
            modelArr = modelObj;
        }
        Class Controller = NSClassFromString(className);
        if ([className isEqualToString:@"RootPageViewController"]||[className isEqualToString:@"CategorysViewController"]||[className isEqualToString:@"XYFindViewController"]||[className isEqualToString:@"XYCartViewController"]||[className isEqualToString:@"MyCenterViewController"]) {
            //除了首页之外的其它四个基础页（分类页之类的），其它的都用navigation跳转，tabbarcontroller用来跳这四个基础页
            if ([className isEqualToString:@"RootPageViewController"]) {
                [navigation popToRootViewControllerAnimated:YES];
                [tabbarControl setSelectedIndex:0];
            }else if ([className isEqualToString:@"CategorysViewController"]) {
                [tabbarControl setSelectedIndex:1];
            }else if ([className isEqualToString:@"XYFindViewController"]) {
                [tabbarControl setSelectedIndex:2];
            }else if ([className isEqualToString:@"XYCartViewController"]) {
                [tabbarControl setSelectedIndex:3];
            }else if ([className isEqualToString:@"MyCenterViewController"]) {
                [tabbarControl setSelectedIndex:4];
            }
        }else {
            UIViewController *h5PushNativeView;
            if ([className isEqualToString:@"CategorysDetailRootViewController"]) {//此处要考虑sb的界面,除掉几个sb界面跳转
                UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                h5PushNativeView = [main instantiateViewControllerWithIdentifier:@"categorysrootview"];
            }else {
                h5PushNativeView = [[Controller alloc]init];
            }
            if (![query isEqualToString:@""]) {
                if (modelName) {
                    [self assiValueToModel:modelName Query:query ClassName:className];
                }else {
                    for (int i = 0; i < modelArr.count; i++) {
                        [self assiValueToModel:modelArr[i] Query:query ClassName:className];
                    }
                }
                [self assiValueToModel:className Query:query ClassName:className];
            }
            [navigation pushViewController:h5PushNativeView animated:YES];
        }
    }else {
        [navigation popToRootViewControllerAnimated:YES];
        [tabbarControl setSelectedIndex:0];
    }
}

- (void)assiValueToModel:(NSString *)modelName Query:(NSString *)query ClassName:(NSString *)className {
    Class Model = NSClassFromString(modelName);
    SEL ShareInstance = @selector(ShareInstance);
    IMP instance = [Model methodForSelector:ShareInstance];
    NSObject *h5NativeModel;
    if ([Model respondsToSelector:ShareInstance]) {
        h5NativeModel = instance(Model,ShareInstance,nil);
    }else {
        h5NativeModel = [[Model alloc]init];
    }
    if (h5NativeModel) {
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
        NSArray *dataFormat = [query componentsSeparatedByString:@"&"];
        for (int i = 0; i < dataFormat.count; i++) {
            NSString *data = dataFormat[i];
            NSArray *dataArray = [data componentsSeparatedByString:@"="];
            if (dataArray.count == 2) {
                NSString *dataName = dataArray[0];
                NSString *dataValue = dataArray[1];
                if (dataName && dataValue) {
                    if ([dataName isEqualToString:@"bid"]) {
                        dataDic[@"brandID"] = dataValue;
                    }else if ([dataName isEqualToString:@"cid"]) {
                        dataDic[@"catID"] = dataValue;
                    }else if ([dataName isEqualToString:@"k"]) {
                        dataDic[@"searchKeyWords"] = dataValue;
                    }else if ([dataName isEqualToString:@"user"]) {
                        dataDic[@"user"] = dataValue;
                    }else if ([dataName isEqualToString:@"type"]) {
#warning 要分不同url处理，即className
                        dataDic[@"type"] = dataValue;
                    }else if ([dataName isEqualToString:@"s"]) {
//                        dataDic[@"catID"] = dataValue;
                    }else if ([dataName isEqualToString:@"f"]) {
//                        dataDic[@"catID"] = dataValue;
                    }else if ([dataName isEqualToString:@"pid"]) {
#warning 要分不同url处理，即className
                        dataDic[@"categorysSKUCode"] = dataValue;
                    }else if ([dataName isEqualToString:@"page"]) {
//                        dataDic[@"catID"] = dataValue;
                    }else if ([dataName isEqualToString:@"n"]) {
//                        dataDic[@"catID"] = dataValue;
                    }else if ([dataName isEqualToString:@"callback"]) {
//                        dataDic[@"catID"] = dataValue;
                    }
                    if ([className isEqualToString:@"CategorysDetailRootViewController"]) {//此处要考虑sb的界面,除掉几个sb界面跳转
                        [CategorysDetailRootViewModel ShareInstance].isSearchProduct = NO;
                    }
                }
            }
        }
        [h5NativeModel assginToPropertyWithDictionary:dataDic];
    }
}

@end

