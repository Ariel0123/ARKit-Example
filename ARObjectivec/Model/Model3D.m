//
//  Model3D.m
//  ARObjectivec
//
//  Created by Ariel Ortiz on 12/1/22.
//

#import "Model3D.h"

@implementation Model3D

- (instancetype)initWithModel:(NSString *)img model:(NSString *)modelName{
    if((self = [super init])){
        NSUUID *uuid = [NSUUID UUID];
        NSString *str = [uuid UUIDString];
        _id = str;
        
        _img = [UIImage imageNamed:img];

        NSString *filePath = [[NSBundle mainBundle] pathForResource:modelName ofType:@"usdz"];
        
        NSURL *url = [NSURL fileURLWithPath:filePath];
        MDLAsset *asset = [[MDLAsset alloc]initWithURL:url];
        [asset loadTextures];
        _node = [SCNNode nodeWithMDLObject:[asset objectAtIndex:0]];
        
    }
    return self;
}

@end
