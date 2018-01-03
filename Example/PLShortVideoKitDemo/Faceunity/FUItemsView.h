//
//  FUItemsView.h
//  UI
//
//  Created by L on 2017/12/25.
//  Copyright © 2017年 L. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FUItemsViewDelegate <NSObject>

@optional
- (void)FUItemsViewDidSelecItem:(NSString *)itemName ;

@end

@class BottomModel ;
@interface FUItemsView : UIView

@property (nonatomic, strong) NSArray <BottomModel *>*dataArray ;

@property (nonatomic, assign) id<FUItemsViewDelegate>delegate ;

@end



@interface TopModel : NSObject

@property (nonatomic, assign) BOOL isSelected ;
@property (nonatomic, copy) NSString *itemName ;
@end

@interface TopCell : UICollectionViewCell

@property (nonatomic, strong) TopModel *model ;
@property (nonatomic, strong) UIImageView *imageView ;
@end



@interface BottomModel : NSObject

@property (nonatomic, assign) BOOL isSelected ;
@property (nonatomic, copy) NSString *itemName ;
@property (nonatomic, strong) NSArray <TopModel *> *topsArray ;

@end

@interface BottomCell : UICollectionViewCell

@property (nonatomic, strong) BottomModel *model ;
@property (nonatomic, strong) UILabel *itemsTitle ;
@end
