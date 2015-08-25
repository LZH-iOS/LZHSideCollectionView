//
//  ViewController.m
//  LZHSideCollectionView
//
//  Created by 换个名称 on 15-1-13.
//  Copyright (c) 2015年 换个名称. All rights reserved.
//

#import "ViewController.h"
#import "MyCollectionViewCell.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property(nonatomic, strong, readonly)UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong)UIView *cellFakeView;

@property (nonatomic,strong) NSIndexPath *sourseIndexPath;

@property (nonatomic, strong) NSMutableArray *datas;


@end

@implementation UIImageView (CellCopiedImage)

- (void)setCellCopiedImage:(UICollectionViewCell *)cell {
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 4.f);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = image;
}

@end


@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _datas = [[NSMutableArray alloc]initWithObjects:@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10), nil];
    
    [self setUpGesture];
}

- (void)setUpGesture
{
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.collectionView addGestureRecognizer:_longPressGesture];

}


- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture
{
    NSIndexPath  *indexPath = [self.collectionView indexPathForItemAtPoint:[longPressGesture locationInView:self.collectionView]];
     CGPoint location = [longPressGesture locationInView:self.collectionView];
    
        switch (longPressGesture.state) {
            case UIGestureRecognizerStateBegan:
            if (indexPath) {
            {
                _sourseIndexPath = indexPath;
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                
                _cellFakeView = [[UIView alloc] initWithFrame:cell.frame];
                _cellFakeView.layer.shadowColor = [UIColor blackColor].CGColor;
                _cellFakeView.layer.shadowOffset = CGSizeMake(0, 0);
                _cellFakeView.layer.shadowOpacity = 0.5f;
                _cellFakeView.layer.shadowRadius = 3.0f;
                
                UIImageView *cellFakeImgView = [[UIImageView alloc]initWithFrame:cell.bounds];
                
                UIImageView *highlightedImageView = [[UIImageView alloc] initWithFrame:cell.bounds];
                
                cellFakeImgView.contentMode = UIViewContentModeScaleAspectFill;
                highlightedImageView.contentMode = UIViewContentModeScaleAspectFill;
                cellFakeImgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                highlightedImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                
                cell.highlighted = YES;
                [highlightedImageView setCellCopiedImage:cell];
                cell.highlighted = NO;
                [cellFakeImgView setCellCopiedImage:cell];
                
                
                [self.collectionView addSubview:_cellFakeView];
                [_cellFakeView addSubview:cellFakeImgView];
                [_cellFakeView addSubview:highlightedImageView];
                
                
                [UIView animateKeyframesWithDuration:.3f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                    _cellFakeView.center = cell.center;
                    _cellFakeView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                    highlightedImageView.alpha = 0;
                    cell.alpha = 0;
                
                } completion:^(BOOL finished) {
                    [highlightedImageView removeFromSuperview];
                    
                }];
            }
            }
                break;
            case UIGestureRecognizerStateChanged:
            {
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:_sourseIndexPath];
                cell.alpha = 0;
                _cellFakeView.center = CGPointMake(location.x,location.y);
                [self moveItemIfNeeded];
                break;
            }
            default:
            {
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:_sourseIndexPath];
                [UIView animateKeyframesWithDuration:.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    _cellFakeView.transform = CGAffineTransformIdentity;
                    _cellFakeView.frame = cell.frame;
                    cell.alpha = 1;
                    
                } completion:^(BOOL finished) {
                    [_cellFakeView removeFromSuperview];
                    _cellFakeView = nil;
                    _sourseIndexPath = nil;
                }];
            }
                break;
        }
}

- (void)moveItemIfNeeded
{
    NSIndexPath *atIndexPath = _sourseIndexPath;
    NSIndexPath *toIndexPath = [self.collectionView indexPathForItemAtPoint:_cellFakeView.center];
    if (toIndexPath == nil || [atIndexPath isEqual:toIndexPath] || atIndexPath == nil) {
        return;
    }
    [self.collectionView performBatchUpdates:^{
        _sourseIndexPath = toIndexPath;
        [self.collectionView moveItemAtIndexPath:atIndexPath toIndexPath:toIndexPath];
    
    } completion:^(BOOL finished) {
        id obj = self.datas[atIndexPath.row];
        if (atIndexPath.row > toIndexPath.row) {
            [self.datas insertObject:obj atIndex:toIndexPath.row];
            [self.datas removeObjectAtIndex:atIndexPath.row + 1];
        } else if (atIndexPath.row < toIndexPath.row) {
            [self.datas insertObject:obj atIndex:toIndexPath.row + 1];
            [self.datas removeObjectAtIndex:atIndexPath.row];
        }
        NSLog(@"%@",self.datas);
    }];
}






#pragma mark - dataSourse
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _datas.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseIdentifier = @"Cell";
    
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath ];
    cell.backgroundColor = [UIColor redColor];
    cell.label.text = [NSString stringWithFormat:@"%@",self.datas[indexPath.row]];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _datas.count-1) {
            [_datas addObject:@(_datas.count+1)];
            [self.collectionView reloadData];

    }
    if (indexPath.row == 0) {
        [_datas removeObjectAtIndex:_datas.count-1];
        [self.collectionView reloadData];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
