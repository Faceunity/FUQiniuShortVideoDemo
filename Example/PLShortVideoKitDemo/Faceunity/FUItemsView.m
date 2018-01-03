//
//  FUItemsView.m
//  UI
//
//  Created by L on 2017/12/25.
//  Copyright © 2017年 L. All rights reserved.
//

#import "FUItemsView.h"

@interface FUItemsView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *topCollection ;

@property (nonatomic, strong) UICollectionView *bottomCollection ;

@end

@implementation FUItemsView
{
    // bottom collection select index
    NSInteger bottomIndex ;
    // section for selected bottom, row for selected top
    NSIndexPath *selectIndex ;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        
        bottomIndex = 0;
        
        selectIndex = [NSIndexPath indexPathForRow:1 inSection:0];
        
        [self addSubUI];
    }
    return self ;
}


- (void)addSubUI {
    
    [self addSubview:self.topCollection];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(8, 75, self.frame.size.width - 16, 1)];
    line.backgroundColor = [UIColor whiteColor];
    [self addSubview:line];
    
    [self addSubview:self.bottomCollection];
}

-(void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray ;
    
    [self.bottomCollection reloadData];
    
    [self.topCollection reloadData];
}

-(UICollectionView *)topCollection {
    if (!_topCollection) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 8.0 ;
        layout.minimumInteritemSpacing = 12 ;
        layout.itemSize = CGSizeMake(60, 60) ;
        layout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
        
        _topCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 74) collectionViewLayout:layout];
        _topCollection.backgroundColor = [UIColor clearColor];
        _topCollection.showsVerticalScrollIndicator = NO ;
        _topCollection.showsHorizontalScrollIndicator = NO ;
        _topCollection.bounces = YES ;
        _topCollection.delegate = self ;
        _topCollection.dataSource = self ;
        [_topCollection registerClass:[TopCell class] forCellWithReuseIdentifier:@"TopCell"];
    }
    return _topCollection ;
}

-(UICollectionView *)bottomCollection {
    if (!_bottomCollection) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 16.0 ;
        layout.minimumInteritemSpacing = 12 ;
        layout.itemSize = CGSizeMake(72, 34) ;
        layout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
        
        _bottomCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 76, self.frame.size.width, 34) collectionViewLayout:layout];
        _bottomCollection.backgroundColor = [UIColor clearColor];
        _bottomCollection.showsVerticalScrollIndicator = NO ;
        _bottomCollection.showsHorizontalScrollIndicator = NO ;
        _bottomCollection.bounces = YES ;
        _bottomCollection.delegate = self ;
        _bottomCollection.dataSource = self ;
        [_bottomCollection registerClass:[BottomCell class] forCellWithReuseIdentifier:@"BottomCell"];
    }
    return _bottomCollection ;
}

#pragma mark ------ UICollectionViewDelegate UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1 ;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView == self.topCollection) {
        
        BottomModel *model = self.dataArray[bottomIndex] ;
        return model.topsArray.count ;
        
    } else if (collectionView == self.bottomCollection) {
        
        return self.dataArray.count ;
    }
    return 0 ;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.topCollection) {
        
        TopCell *cell = [self.topCollection dequeueReusableCellWithReuseIdentifier:@"TopCell" forIndexPath:indexPath];
        
        BottomModel *bottomModel = self.dataArray[bottomIndex] ;
        if (indexPath.row < bottomModel.topsArray.count) {
            TopModel *model = bottomModel.topsArray[indexPath.row];
            if (selectIndex.section == bottomIndex && selectIndex.row == indexPath.row) {
                model.isSelected = YES ;
            }
            
            cell.model = model ;
        }
        
        return cell ;
    }else if (collectionView == self.bottomCollection) {
        
        BottomCell *cell = [self.bottomCollection dequeueReusableCellWithReuseIdentifier:@"BottomCell" forIndexPath:indexPath];
        
        if (indexPath.row < self.dataArray.count) {
            BottomModel *model = (BottomModel *)self.dataArray[indexPath.row] ;
            model.isSelected = indexPath.row == bottomIndex ;
            cell.model = model ;
        }
        return cell ;
    }
    return nil ;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.topCollection) {
        
        if (selectIndex.section == bottomIndex && selectIndex.row == indexPath.row ) {
            return ;
        }
        // 取消之前的
        BottomModel *lastBottom = self.dataArray[selectIndex.section] ;
        TopModel *lastModel = lastBottom.topsArray[selectIndex.row];
        lastModel.isSelected = NO ;
        if (bottomIndex == selectIndex.section) {
            NSIndexPath *lastCellPath = [NSIndexPath indexPathForRow:selectIndex.row inSection:0];
            TopCell *lastCell = (TopCell *)[self.topCollection cellForItemAtIndexPath:lastCellPath];
            lastCell.model = lastModel ;
        }
        
        BottomModel *bottomModel = self.dataArray[bottomIndex] ;
        TopModel *model = bottomModel.topsArray[indexPath.row];
        model.isSelected = YES ;
        TopCell *cell = (TopCell *)[self.topCollection cellForItemAtIndexPath:indexPath];
        cell.model = model ;
        
        selectIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:bottomIndex];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(FUItemsViewDidSelecItem:)]) {
            [self.delegate FUItemsViewDidSelecItem:model.itemName];
        }
        
        
        
    }else if (collectionView == self.bottomCollection) {
        
        if (indexPath.row == bottomIndex) {
            return ;
        }
        // 取消选择上一个
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:bottomIndex inSection:0];
        BottomCell *lastCell = (BottomCell *)[self.bottomCollection cellForItemAtIndexPath:indexP];
        BottomModel *lastModel = self.dataArray[bottomIndex] ;
        lastModel.isSelected = NO ;
        lastCell.model = lastModel ;
        
        // 选中当前个
        BottomCell *cell = (BottomCell *)[self.bottomCollection cellForItemAtIndexPath:indexPath];
        BottomModel *model = self.dataArray[indexPath.row] ;
        model.isSelected = YES ;
        cell.model = model ;
        
        bottomIndex = indexPath.row ;
        
        [self.topCollection reloadData];
    }
}


@end


@implementation TopModel
@end

@implementation TopCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageView];
    }
    return self ;
}

-(void)setModel:(TopModel *)model {
    _model = model ;
    
    self.imageView.image = [UIImage imageNamed:_model.itemName];
    
    if (_model.isSelected) {
        self.imageView.layer.borderWidth = 2.0 ;
        self.imageView.layer.borderColor = [UIColor colorWithRed:236/255.0 green:187/255.0 blue:76/255.0 alpha:1.0].CGColor;
    }else {
        self.imageView.layer.borderWidth = 0.0 ;
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

-(UIImageView *)imageView {
    if (!_imageView) {
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _imageView.layer.masksToBounds = YES ;
        _imageView.layer.cornerRadius = 30.0 ;
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView ;
}

@end


@implementation BottomModel
@end


@implementation BottomCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.itemsTitle];
    }
    return self ;
}

-(void)setModel:(BottomModel *)model {
    _model = model ;
    
    self.itemsTitle.textColor = _model.isSelected ? [UIColor colorWithRed:238/255.0 green:188/255.0 blue:73/255.0 alpha:1.0] : [UIColor whiteColor] ;
    self.itemsTitle.text = _model.itemName ;
}

-(UILabel *)itemsTitle {
    if (!_itemsTitle) {
        _itemsTitle = [[UILabel alloc] initWithFrame:self.bounds];
        _itemsTitle.backgroundColor = [UIColor clearColor];
        _itemsTitle.font = [UIFont systemFontOfSize:16];
        _itemsTitle.textColor = [UIColor whiteColor];
        _itemsTitle.textAlignment = NSTextAlignmentCenter ;
    }
    return _itemsTitle ;
}

@end
