//
//  ViewController.h
//  LZHSideCollectionView
//
//  Created by 换个名称 on 15-1-13.
//  Copyright (c) 2015年 换个名称. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol my <NSObject>

- (void)LZHSideCollectionView:(NSString *)str;


@end

@interface ViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@end
