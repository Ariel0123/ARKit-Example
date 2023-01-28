//
//  ModelCollectionViewCell.m
//  ARObjectivec
//
//  Created by Ariel Ortiz on 12/1/22.
//

#import "ModelCollectionViewCell.h"


@interface ModelCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation ModelCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 20;
    self.contentMode = UIViewContentModeScaleToFill;
    self.clipsToBounds = true;
}

+ (NSString *)identifier{
    return NSStringFromClass([self class]);
}

- (void)configure:(UIImage *)img{
    _imgView.image = img;
}


- (void)selectedCell{
    self.layer.borderWidth = 3;
    self.layer.borderColor = UIColor.systemBlueColor.CGColor;
}

- (void)deselectedCell{
    self.layer.borderWidth = 0;
    self.layer.borderColor = NULL;
}


@end
