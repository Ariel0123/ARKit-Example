//
//  Model3D.h
//  ARObjectivec
//
//  Created by Ariel Ortiz on 12/1/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <SceneKit/ModelIO.h>



NS_ASSUME_NONNULL_BEGIN

@interface Model3D : NSObject

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) UIImage *img;
@property (strong, nonatomic) SCNNode *node;
@property (nonatomic, assign) NSInteger selectedID;




- (instancetype)initWithModel:(NSString *)img model:(NSString *)modelName;

@end

NS_ASSUME_NONNULL_END
