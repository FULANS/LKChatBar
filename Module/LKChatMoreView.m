//
//  LKChatMoreView.m
//  LiemsMobile70
//
//  Created by WZheng on 2020/4/8.
//  Copyright © 2020 Luculent. All rights reserved.
//

#import "LKChatMoreView.h"
#import "LKChatBar.h"
#import "TZImagePickerController.h"
#import "LKBDMapChooseVC.h"

@interface LKChatMoreView ()<UIScrollViewDelegate,TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (copy, nonatomic) NSArray *titles;
@property (copy, nonatomic) NSArray *images;
@property (copy, nonatomic) NSArray *types;

@property (strong, nonatomic) NSMutableArray <LKChatMoreItemView *>*itemViews; // 数据源

@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIPageControl *pageControl;

@property (assign, nonatomic) CGSize itemSize;


@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray *selectedInfos;

@end

@implementation LKChatMoreView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    UIImageView *topLine = [[UIImageView alloc] init];
    topLine.backgroundColor = HT_UIColorFromRGB(0xF2F3F7);
    [self addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.and.top.equalTo(self);
        make.height.mas_equalTo(.5f);
    }];
    
    self.edgeInsets = UIEdgeInsetsMake(10, 10, 5, 10);
    self.itemViews = [NSMutableArray array];
    self.numberPerLine = 4;
    
    [self scrollView];
    [self pageControl];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(_edgeInsets);
    }];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(0);
    }];
    self.backgroundColor = [UIColor whiteColor];
    [self reloadData];
}


#pragma mark - Public Methods
- (UIImage *)imageInBundlePathForImageName:(NSString *)imageName {
    UIImage *image = [UIImage lkchat_imageNamed:imageName bundleName:@"LKChatKeyboard" bundleForClass:[self class]];
    return image;
}

- (void)reloadData {

    CGFloat width = [UIApplication sharedApplication].keyWindow.frame.size.width;
    CGFloat height = [UIApplication sharedApplication].keyWindow.frame.size.height;
    CGFloat widthLimit = MIN(width, height);
    CGFloat itemWidth = (widthLimit - self.edgeInsets.left - self.edgeInsets.right) / self.numberPerLine;
    CGFloat itemHeight = (kLKFunctionViewHeight - 16) / 2;
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
    self.titles = @[@"相册",@"拍照",@"短视频",@"定位"];
    self.images = @[[self imageInBundlePathForImageName:@"chat_bar_icons_相册"],[self imageInBundlePathForImageName:@"chat_bar_icons_拍照"],[self imageInBundlePathForImageName:@"chat_bar_icons_短视频"],[self imageInBundlePathForImageName:@"chat_bar_icons_位置"]];
    self.types = @[@(LKChatMoreViewItemTypePhotoAlbum).description,@(LKChatMoreViewItemTypeTakePicture).description,@(LKChatMoreViewItemTypeVideo).description,@(LKChatMoreViewItemTypeLocation).description];
    [self setupItems];

}

- (void)setupItems{
    
    [self.scrollView removeAllSubviews];
    [self.itemViews removeAllObjects];
    
    __block NSUInteger line = 0;   //行数
    __block NSUInteger column = 0; //列数
    __block NSUInteger page = 0;
    
    [self.titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if (column > 3) {
            line ++ ;
            column = 0;
        }
        if (line > 1) {
            line = 0;
            column = 0;
            page ++ ;
        }
        
        CGFloat width = [UIApplication sharedApplication].keyWindow.frame.size.width;
        CGFloat scrollViewWidth = width - self.edgeInsets.left - self.edgeInsets.right;
        CGFloat scrollViewHeight = kLKFunctionViewHeight - self.edgeInsets.top - self.edgeInsets.bottom;
        CGFloat startX = column * self.itemSize.width + page * scrollViewWidth;
        CGFloat startY = line * self.itemSize.height;

        LKChatMoreItemView *itemView = [[LKChatMoreItemView alloc] initWithFrame:CGRectMake(startX, startY, self.itemSize.width, self.itemSize.height)];
        [itemView fillWithPluginTitle:obj pluginIconImage:self.images[idx] itemTyp:[self.types[idx] intValue]];
        itemView.tag = idx;
        __weak typeof(self) wself = self;
        itemView.pluginDidClicked = ^(LKChatMoreViewItemType pluginType) {
            [wself pluginDidClicked:pluginType];
        };
        [self.scrollView addSubview:itemView];
        [self.itemViews addObject:itemView];
        column ++;
        if (idx == self.titles.count - 1) {
            [self.scrollView setContentSize:CGSizeMake(width * (page + 1), scrollViewHeight)];
            self.pageControl.numberOfPages = page + 1;
            *stop = YES;
        }
    }];
    
}


- (void)pluginDidClicked:(LKChatMoreViewItemType)pluginType{

    if (pluginType == LKChatMoreViewItemTypeTakePicture) {
        // 拍照
        [self takePhoto];
        
    }else if (pluginType == LKChatMoreViewItemTypePhotoAlbum) {
        // 相册
        [self chooseImage];
        
    }else if (pluginType == LKChatMoreViewItemTypeVideo) {
        // 短视频
        [self takeVideo];
        
    }else if (pluginType == LKChatMoreViewItemTypeLocation) {
        // 定位
        [self chooseLocation];
    }
    
}

- (void)chooseLocation{
    
    LKBDMapChooseVC *map = [[LKBDMapChooseVC alloc] initWithMapTyp:(LKMapTypeLocationChoose) originLocation:nil];
    map.needLocationImg = YES;
    [map createDismissItemWhenPresentModeCompletion:nil];
    WEAK_SELF
    map.chooseBlock = ^(LKBDMapChooseModel *model) {
        NSDictionary *modelDic = [model mj_keyValues];
        !wself.LKChatMoreViewResultBlock ? : wself.LKChatMoreViewResultBlock(LKChatMoreViewItemTypeLocation,modelDic);
    };
    LKBaseNavigationController *navc = [[LKBaseNavigationController alloc] initWithRootViewController:map];
        navc.modalPresentationStyle = UIModalPresentationFullScreen;// iOS13适配
    [self.inputViewRef.controllerRef presentViewController:navc animated:YES completion:nil];
 
}

- (void)takeVideo{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSMutableArray *mediaTypes = [NSMutableArray array];
        [mediaTypes addObject:(NSString *)kUTTypeMovie];
        picker.mediaTypes = mediaTypes;
        picker.videoMaximumDuration = 1*10;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.inputViewRef.controllerRef.navigationController presentViewController:picker animated:YES completion:^{}];
    }
    else{
        //如果没有提示用户
        UIAlertController *alert = [UIAlertController LK_AlertControllerWithTitle:LKString(@"选LiEMS Mobile") message:LKString(@"您的设备暂不支持相机拍摄！") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *commit = [UIAlertAction actionWithTitle:LKString(@"确定") style:(UIAlertActionStyleCancel) handler:nil];
        [alert addAction:commit];
        [self.inputViewRef.controllerRef presentViewController:alert animated:YES completion:nil];
    }
}

- (void)takePhoto{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.inputViewRef.controllerRef.navigationController presentViewController:picker animated:YES completion:^{}];
    }
    else{
        //如果没有提示用户
        UIAlertController *alert = [UIAlertController LK_AlertControllerWithTitle:LKString(@"选LiEMS Mobile") message:LKString(@"您的设备暂不支持相机拍摄！") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *commit = [UIAlertAction actionWithTitle:LKString(@"确定") style:(UIAlertActionStyleCancel) handler:nil];
        [alert addAction:commit];
        [self.inputViewRef.controllerRef presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    tzImagePickerVc.sortAscendingByModificationDate = YES;
    [tzImagePickerVc showProgressHUD];
    if ([type isEqualToString:@"public.image"]) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image completion:^(PHAsset *asset, NSError *error){
            [tzImagePickerVc hideProgressHUD];
            if (error) {
                NSLog(@"图片保存失败 %@",error);
            } else {
                TZAssetModel *assetModel = [[TZImageManager manager] createModelWithAsset:asset];
                BOOL allowCrop = NO; // 允许裁剪
                BOOL needCircleCrop = NO; // 圆形裁剪
                if (allowCrop) {
                    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
                        [self refreshCollectionViewWithAddedAsset:asset image:cropImage];
                    }];
                    imagePicker.allowPickingImage = YES;
                    imagePicker.needCircleCrop = needCircleCrop;
                    imagePicker.circleCropRadius = 100;
                    [self.inputViewRef.controllerRef presentViewController:imagePicker animated:YES completion:nil];
                } else {
                    [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                }
            }
        }];
        
    }else if ([type isEqualToString:@"public.movie"]) {
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        if (videoUrl) {

            [[TZImageManager manager] saveVideoWithUrl:videoUrl completion:^(PHAsset *asset, NSError *error) {

                [tzImagePickerVc hideProgressHUD];
                if (!error) {
                    
                    TZAssetModel *assetModel = [[TZImageManager manager] createModelWithAsset:asset];
                    [[TZImageManager manager] getPhotoWithAsset:assetModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                        if (!isDegraded && photo) {
                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:photo];
                        }
                    }];
  
                }
            }];
        }
    }
}

- (void)refreshCollectionViewWithAddedAsset:(PHAsset *)asset image:(UIImage *)image {
    
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        
        [[TZImageManager manager] getVideoOutputPathWithAsset:asset success:^(NSString *outputPath) {
            
            NSData *fileData = [NSData dataWithContentsOfFile:outputPath];
            FolderModel *model = [[FolderModel alloc] init];
            model.fileData = fileData;
            NSString *filename = [asset valueForKey:@"filename"];
            model.fileName = filename;
            model.fileExtName = @"mp4";
            model.fileSize = @(fileData.length).description;
            model.path = outputPath;
            model.coverImgData = UIImageJPEGRepresentation(image,0.5);
            !self.LKChatMoreViewResultBlock ? : self.LKChatMoreViewResultBlock(LKChatMoreViewItemTypeVideo,model);
            
        } failure:^(NSString *errorMessage, NSError *error) {
            
        }];
        
    }else{
        
        NSData *fileData = UIImageJPEGRepresentation(image,0.5);
        FolderModel *model = [[FolderModel alloc] init];
        model.fileData = fileData;
        NSString *filename = [asset valueForKey:@"filename"];
        model.fileName = filename;
        model.fileExtName = @"jpg";
        model.fileSize = @(fileData.length).description;
        model.path = filename;
        !self.LKChatMoreViewResultBlock ? : self.LKChatMoreViewResultBlock(LKChatMoreViewItemTypeTakePicture,model);
    }
   
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}



- (void)chooseImage{
    TZImagePickerController *picker = [[TZImagePickerController alloc]initWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    picker.navigationBar.translucent = NO;
    picker.selectedAssets = @[].mutableCopy; // 目前已经选中的图片数组
    picker.allowPickingOriginalPhoto = NO;
    picker.sortAscendingByModificationDate = NO;
    picker.allowTakeVideo = NO;
    picker.allowPickingGif = NO;
    picker.allowPickingVideo = NO;
    picker.allowTakePicture = NO;
    picker.showSelectedIndex = YES;
    picker.showPhotoCannotSelectLayer = YES;
    picker.allowPickingMultipleVideo = NO;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.inputViewRef.controllerRef presentViewController:picker animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    self.selectedPhotos = [NSMutableArray arrayWithArray:photos];
    self.selectedAssets = [NSMutableArray arrayWithArray:assets];
    self.selectedInfos = [NSMutableArray arrayWithArray:infos];

    NSMutableArray *tempArr = [NSMutableArray array];
    for (UIImage *item in self.selectedPhotos) {
        NSInteger index = [self.selectedPhotos indexOfObject:item];
        NSData *fileData = UIImageJPEGRepresentation(item,0.5);
        FolderModel *model = [[FolderModel alloc] init];
        model.fileData = fileData;
        PHAsset *asset = self.selectedAssets[index];
        NSString *filename = [asset valueForKey:@"filename"];
        model.fileName = filename;
        model.fileExtName = @"jpg";
        model.fileSize = @(fileData.length).description;
        model.path = filename;
        [tempArr addObject:model];
    }
    !self.LKChatMoreViewResultBlock ? : self.LKChatMoreViewResultBlock(LKChatMoreViewItemTypePhotoAlbum,tempArr);
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.pageControl setCurrentPage:scrollView.contentOffset.x / scrollView.frame.size.width];
}


#pragma mark - Getters
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        [self addSubview:(_scrollView = scrollView)];
    }
    return _scrollView;
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];//WithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 20)];
        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        pageControl.hidesForSinglePage = YES;
        [self addSubview:(_pageControl = pageControl)];
    }
    return _pageControl;
}






@end
