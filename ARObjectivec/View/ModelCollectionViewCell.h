//
//  ModelCollectionViewCell.h
//  ARObjectivec
//
//  Created by Ariel Ortiz on 12/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ModelCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;

- (void)configure:(UIImage *)img;

- (void)selectedCell;
- (void)deselectedCell;

@end

NS_ASSUME_NONNULL_END
