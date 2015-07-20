//
//  ViewController.m
//  SDKObjectCTester
//
//  Created by Brandon on 15/7/20.
//  Copyright (c) 2015年 goukuai. All rights reserved.
//

#import "ViewController.h"

#define FORBIDDEN_PATH @"FilePath"
#define FILELIST_ACCESS YES
#define DOWNLOAD_ACCESS YES
#define UPLOAD_ACCESS YES
#define CREATE_DIR_ACCESS YES
#define RENAME_ACCESS YES
#define DELETE_ACCESS YES

@interface ViewController () {

}
@property (weak, nonatomic) IBOutlet UIButton *TestBtn;
- (IBAction)onTestClick:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}
- (IBAction)onTestClick:(id)sender {
    
    //设置是否开启日志的等级
    [SDKConfig setLogLevel:SDKLogLevelInfo];
    [SDKConfig setLogPrint:NO];
    
    //设置是否开启日志
    YKMainViewController *control = [[YKMainViewController alloc] init];
    
    //设置显需要的功能
    Option *option = [[Option alloc] init];
    [option setCanDel:YES];
    [option setCanUpload:YES];
    [option setCanRename:YES];
    [control setOption:option];
    
    control.delegate = self;
    
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:control];
    [self presentViewController:navC animated:YES completion:nil];
    
    //navigation control push
    //[self.navigationController pushViewController:control animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)hookInvoke:(enum HookType)type fullPath:(NSString * __nonnull)fullPath {
    NSLog(@"fullPath:%@",fullPath);

    if ([fullPath isEqualToString:FORBIDDEN_PATH]) {
        BOOL  access = YES;
        switch (type){
            case HookTypeFileList:
                access = FILELIST_ACCESS;
                break;
            case HookTypeDownload:
                access = DOWNLOAD_ACCESS;
                break;
            case HookTypeUpload:
                access = UPLOAD_ACCESS;
                break;
            case HookTypeCreateDir:
                access = CREATE_DIR_ACCESS;
                break;
            case HookTypeRename:
                access = RENAME_ACCESS;
                break;
            case HookTypeDelete:
                access = DELETE_ACCESS;
                break;
        }

        if (!access){

            [[[UIAlertView alloc] initWithTitle:nil message:@"" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
        }

        return  access;

    }



    return YES;
}



@end
