//
//  ViewController.m
//  ScreenShotsDemo
//
//  Created by pzj on 2017/5/26.
//  Copyright © 2017年 pzj. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+QRCode.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface ViewController ()

@property (nonatomic, strong) UIButton *creatQrBtn;
@property (nonatomic, strong) UIImageView *qrCodeImage;
@property (nonatomic, strong) UIButton *saveBtn;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *qrCodeImg;
@property (nonatomic, strong) UIImageView *iconImg;
@property (nonatomic, strong) UILabel *descLabel;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initViews];
}
- (void)initViews
{
    self.title = @"截图保存相册";
    [self.view addSubview:[self creatQrBtn]];
    [self.view addSubview:[self qrCodeImage]];
    [self.view addSubview:[self saveBtn]];

    
    [[self creatQrBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(100);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    [[self qrCodeImage] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.creatQrBtn.mas_bottom).offset(20);
        make.height.mas_equalTo(150);
        make.width.mas_equalTo(150);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];

    [[self saveBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(50);
    }];
}

- (void)creatQrBtnClick
{
    NSLog(@"点击生成二维码。。。");
    NSString *str = @"点击生成二维码。。。";
    self.qrCodeImage.image = [UIImage qrImageByContent:str];
    [self creatImage];
}

- (void)saveBtnClcik
{
    NSLog(@"保存图片到相册");
    [self saveImageToAlbum];
}

- (void)creatImage
{
    [self.view addSubview:[self bgView]];
    [[self bgView] addSubview:[self titleLabel]];
    [[self bgView] addSubview:[self qrCodeImg]];
    [[self qrCodeImg] addSubview:[self iconImg]];
    [[self bgView] addSubview:[self descLabel]];
    [self qrCodeImg].image = self.qrCodeImage.image;
    self.iconImg.backgroundColor = [UIColor brownColor];
    
    [[self bgView] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(SCREENHEIGHT);
        make.height.mas_equalTo(300);
        make.width.mas_equalTo(300);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    [[self titleLabel] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
    }];
    
    [[self qrCodeImg] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(150);
        make.width.mas_equalTo(150);
        make.centerX.mas_equalTo(self.bgView.mas_centerX);
    }];
    
    [[self iconImg] mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat h = 30;
        CGFloat w = 30;
        make.height.mas_equalTo(h);
        make.width.mas_equalTo(w);
        make.centerY.mas_equalTo(self.qrCodeImg.mas_centerY);
        make.centerX.mas_equalTo(self.qrCodeImg.mas_centerX);
    }];
    
    [[self descLabel]mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.qrCodeImg.mas_bottom).offset(10);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(40);
        make.centerX.mas_equalTo(self.bgView.mas_centerX);
    }];
}

#pragma mark - 保存图片到相册
//保存图片到相册
- (void)saveImageToAlbum
{
    UIImage *viewImage = [self imageFromView:self.bgView];
    NSData *data = UIImagePNGRepresentation(viewImage);
    UIImage *resultImg = [UIImage imageWithData:data];
    
    NSMutableArray *imageIds = [NSMutableArray array];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //写入图片到相册
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:resultImg];
        //记录本地标识，等待完成后取到相册中的图片对象
        [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success = %d,error = %@",success, error);
        if (success) {
            //成功后取相册中的图片对象
            __block PHAsset *imageAsset = nil;
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageIds options:nil];
            [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                imageAsset = obj;
                *stop = YES;
            }];
            if (imageAsset) {
                //加载图片数据
                [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    NSLog(@"PHImageFileURLKey = %@",info[@"PHImageFileURLKey"]);
                    NSString *imagePath = info[@"PHImageFileURLKey"];
                    NSLog(@"保存成功。。。");
            
                    //从路径中获得完整的文件名(带后缀)对从相册中取出的图片，视频都有效。
                    NSString *fileName = [imagePath lastPathComponent];
                    NSLog(@"图片名称 ---- fileName = %@",fileName);
                    
                }];
            }
        }else{
            NSLog(@"保存失败。。。");
        }
    }];
    

    
}

/*
 * UIView 转成 UIImage
 */
- (UIImage *)imageFromView:(UIView *)view
{
//下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO,否则传YES。第三个参数就是屏幕密度了。
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsGetCurrentContext();
    return image;
}


- (UIButton *)creatQrBtn
{
    if (!_creatQrBtn) {
        _creatQrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_creatQrBtn setTitle:@"生成二维码" forState:UIControlStateNormal];
        [_creatQrBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_creatQrBtn addTarget:self action:@selector(creatQrBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _creatQrBtn;
}

- (UIImageView *)qrCodeImage
{
    if (!_qrCodeImage) {
        _qrCodeImage = [[UIImageView alloc] init];
    }
    return _qrCodeImage;
}

- (UIButton *)saveBtn
{
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setTitle:@"保存图片" forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_saveBtn addTarget:self action:@selector(saveBtnClcik) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIImageView alloc] init];
        _bgView.backgroundColor = [UIColor lightGrayColor];
    }
    return _bgView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.text = @"title...3";
    }
    return _titleLabel;
}

- (UIImageView *)qrCodeImg
{
    if (!_qrCodeImg) {
        _qrCodeImg = [[UIImageView alloc] init];
    }
    return _qrCodeImg;
}

- (UIImageView *)iconImg
{
    if (!_iconImg) {
        _iconImg = [[UIImageView alloc] init];
    }
    return _iconImg;
}

- (UILabel *)descLabel
{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.text = @"描述。。。";
        _descLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _descLabel;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
