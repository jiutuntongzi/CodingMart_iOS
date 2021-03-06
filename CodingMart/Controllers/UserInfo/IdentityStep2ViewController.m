//
//  IdentityStep2ViewController.m
//  CodingMart
//
//  Created by Ease on 2016/10/25.
//  Copyright © 2016年 net.coding. All rights reserved.
//

#import "IdentityStep2ViewController.h"
#import "UITTTAttributedLabel.h"
#import "UIImageView+WebCache.h"
#import "Coding_NetAPIManager.h"
#import "IdentityPassedViewController.h"
#import "WechatTipViewController.h"
#import <BlocksKit/UIView+BlocksKit.h>

@interface IdentityStep2ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *codeImageV;
@property (weak, nonatomic) IBOutlet UILabel *tip1L;
@property (weak, nonatomic) IBOutlet UILabel *tip2L;
@property (weak, nonatomic) IBOutlet UITTTAttributedLabel *agreementL;
@property (weak, nonatomic) IBOutlet UITTTAttributedLabel *wechatTipL;

@end

@implementation IdentityStep2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    WEAKSELF
    [_agreementL addLinkToStr:@"《身份认证授权与承诺书》" value:nil hasUnderline:NO clickedBlock:^(id value) {
        [weakSelf goToAgreement];
    }];
    [_wechatTipL addLinkToStr:@"如何扫描二维码？" value:nil hasUnderline:NO clickedBlock:^(id value) {
        [weakSelf goToWechatTipVC];
    }];
    [_codeImageV bk_whenTapped:^{
        [weakSelf showSaveImageTip];
    }];
    [self updateQRCodeV];
    [self.tableView eaAddPullToRefreshAction:@selector(becomeActiveRefresh) onTarget:self];//下拉刷新一下进度
}

- (void)updateQRCodeV{
    if (_info.qrCodeLinkStr.length > 0) {
        [_codeImageV sd_setImageWithURL:[NSURL URLWithString:_info.qrCodeLinkStr]];
    }
}

- (void)showSaveImageTip{
    if (_codeImageV.image) {
        WEAKSELF
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"是否保存二维码到相册？" buttonTitles:@[@"保存"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf saveQRImage];
            }
        }];
        [actionSheet showInView:self.view];
    }
}

- (void)saveQRImage{
    if (_codeImageV.image) {
        UIImageWriteToSavedPhotosAlbum(_codeImageV.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    [NSObject showHudTipStr:error? @"保存失败": @"已保存到相册"];
}

- (void)becomeActiveRefresh{
    WEAKSELF
    [[Coding_NetAPIManager sharedManager] get_IdentityInfoBlock:^(id data, NSError *error) {
        [weakSelf.tableView.pullRefreshCtrl endRefreshing];
        if (data) {
            weakSelf.info = data;
            [weakSelf updateQRCodeV];
            if ([[(IdentityInfo *)data status] isEqualToString:@"Checked"]) {
                [weakSelf goToPassedVC];
            }
        }
    }];
}

- (void)goToPassedVC{
    IdentityPassedViewController *vc = [IdentityPassedViewController vcInStoryboard:@"UserInfo"];
    vc.info = _info;
    UINavigationController *nav = self.navigationController;
    [nav popViewControllerAnimated:NO];
    [nav pushViewController:vc animated:YES];
}

#pragma mark Table
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0? 1.0/[UIScreen mainScreen].scale: 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0/[UIScreen mainScreen].scale;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat rowH;
    if (indexPath.section == 0) {
        rowH = 130;
    }else{
        rowH = 400 - 85;//现高度 减去 两个 label 的高度
        rowH += [_tip1L.text getHeightWithFont:_tip1L.font constrainedToSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX)];
        rowH += [_tip2L.text getHeightWithFont:_tip2L.font constrainedToSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX)];
        rowH = MAX(rowH, kScreen_Height -[self navBottomY] - 130 - 10);
    }
    return rowH;
}

#pragma mark VC
- (void)goToAgreement{
    [self goToWebVCWithUrlStr:_info.agreementLinkStr title:@"身份认证授权与承诺书"];
}
- (void)goToWechatTipVC{
    WechatTipViewController *vc = [WechatTipViewController vcInStoryboard:@"UserInfo"];
    vc.qrCodeLinkStr = self.info.qrCodeLinkStr;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
