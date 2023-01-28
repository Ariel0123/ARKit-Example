//
//  ViewController.m
//  ARObjectivec
//
//  Created by Ariel Ortiz on 12/1/22.
//

#import "ViewController.h"


@interface ViewController ()
@property (strong, nonatomic) ARSCNView *arView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray<Model3D *> *models;
@property (strong, nonatomic) Model3D *currentModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureARView];
    [self configuteCollectionView];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    
    ARWorldTrackingConfiguration *config = [ARWorldTrackingConfiguration new];
    [config setPlaneDetection: ARPlaneDetectionHorizontal];
    [config setLightEstimationEnabled:true];
    [config setEnvironmentTexturing:AREnvironmentTexturingAutomatic];
    [_arView.session runWithConfiguration:config];
    _arView.rendersMotionBlur = FALSE;
    _arView.rendersCameraGrain = FALSE;
    
    SCNCamera *camera = _arView.pointOfView.camera;
    if(camera != NULL){
        camera.wantsHDR = FALSE;
        camera.wantsDepthOfField = FALSE;
    }
    
    
    ARCoachingOverlayView *coach = [ARCoachingOverlayView new];
    coach.delegate = self;
    coach.session = _arView.session;
    coach.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    coach.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    coach.goal = ARCoachingGoalHorizontalPlane;
    coach.frame = self.view.bounds;
    [_arView addSubview:coach];
    [self setUpGestures];
   
    _models = [[NSMutableArray<Model3D *> alloc] init];
    [_models addObject:[[Model3D alloc] initWithModel:@"biplane_2x.jpg" model:@"toy_biplane"]];
    [_models addObject:[[Model3D alloc] initWithModel:@"drummertoy_2x.jpg" model:@"toy_drummer"]];
    [_models addObject:[[Model3D alloc] initWithModel:@"toycar_2x.jpg" model:@"toy_car"]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:true];
    
    [_arView.session pause];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
        
    NSMutableArray<NSLayoutConstraint *> *collectionViewConstraints = [[NSMutableArray alloc] initWithArray:@[
        [_collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_collectionView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [_collectionView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
        [_collectionView.heightAnchor constraintEqualToConstant:150]
    ]];
    
    [NSLayoutConstraint activateConstraints:collectionViewConstraints];
}

- (void)configureARView{
    _arView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_arView];
    SCNScene *scene = [SCNScene new];
    [_arView setScene:scene];

}


- (void)configuteCollectionView{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    [layout setItemSize:CGSizeMake(130, 130)];
    [layout setSectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_collectionView registerNib:[UINib nibWithNibName:@"ModelCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:ModelCollectionViewCell.identifier];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = UIColor.clearColor;
    _collectionView.translatesAutoresizingMaskIntoConstraints = FALSE;
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *viewBlur = [[UIVisualEffectView alloc] initWithEffect:effect];
    viewBlur.frame = _collectionView.bounds;
    viewBlur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.backgroundView = viewBlur;
    [self.view addSubview:_collectionView];
}

- (void)setUpGestures{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [_arView addGestureRecognizer:tap];
}

- (void)handleTap: (UITapGestureRecognizer *)recognizer {
   
    [self rayCasting:recognizer];
}

- (void)rayCasting:(UITapGestureRecognizer *)recognizer{
    
    if(_currentModel == nil){
        return;
    }
    
    CGPoint point = [recognizer locationInView:_arView];
    
    NSArray<SCNHitTestResult *> *result = [_arView hitTest:point
                                                           options:@{SCNHitTestBoundingBoxOnlyKey: @YES, SCNHitTestFirstFoundOnlyKey: @YES}];
    if (result.count == 0) {
        [self insertARObject:recognizer];
    }
    
    
    
}

- (void)insertARObject:(UITapGestureRecognizer *)recognizer {
    
    CGPoint tapPoint = [recognizer locationInView:_arView];
    ARRaycastQuery *query = [_arView raycastQueryFromPoint:tapPoint allowingTarget:ARRaycastTargetEstimatedPlane alignment:ARRaycastTargetAlignmentAny];
    
    NSArray<ARRaycastResult *> *results = [_arView.session raycast:query];

    ARRaycastResult *hitResult = [results firstObject];
    
    SCNNode *node = [_currentModel.node clone];
    node.transform = SCNMatrix4FromMat4(hitResult.worldTransform);
    node.scale = SCNVector3Make(0.01, 0.01, 0.01);
    [_arView.scene.rootNode addChildNode:node];

}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _models.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ModelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ModelCollectionViewCell.identifier forIndexPath:indexPath];

    if(cell == nil){
        return [[UICollectionViewCell alloc] init];
    }
   
    [cell configure:_models[indexPath.row].img];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    
    if(_currentModel != NULL){
        ModelCollectionViewCell *cellPrevious = (ModelCollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentModel.selectedID inSection:0]];
        if(cellPrevious == NULL){
            return;
        }
        [cellPrevious deselectedCell];
    }
    
    _currentModel = _models[indexPath.row];
    _currentModel.selectedID = indexPath.row;
    
    ModelCollectionViewCell *cell = (ModelCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if(cell == NULL){
        return;
    }
    [cell selectedCell];
   
 
    
}


@end
