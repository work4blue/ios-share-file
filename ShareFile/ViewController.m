//
//  ViewController.m
//  ShareFile
//
//  Created by PRO on 19/6/18.
//  Copyright © 2018年 bluedrum. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // self.textView.text = @"abcefg";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onShareFile:(id)sender{
    NSData * data = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
    NSURL * fileUrl = [self exportLog:data fileName:nil];
    [self shareLog:fileUrl];
}

-(void)shareLog:(NSURL *)fileURL{
    
    //在iOS 11不显示分享选项了
    //定义URL数组
    NSArray *urls=@[fileURL];
    //创建分享的类型,注意这里没有常见的微信,朋友圈以QQ等,但是罗列完后,实际运行是相应按钮的,所以可以运行.
    
    UIActivityViewController *activituVC=[[UIActivityViewController alloc]initWithActivityItems:urls applicationActivities:nil];
    NSArray *cludeActivitys=@[UIActivityTypePostToFacebook,
                              UIActivityTypePostToTwitter,
                              UIActivityTypePostToWeibo,
                              UIActivityTypePostToVimeo,
                              UIActivityTypeMessage,
                              UIActivityTypeMail,
                              UIActivityTypeCopyToPasteboard,
                              UIActivityTypePrint,
                              UIActivityTypeAssignToContact,
                              UIActivityTypeSaveToCameraRoll,
                              UIActivityTypeAddToReadingList,
                              UIActivityTypePostToFlickr,
                              UIActivityTypePostToTencentWeibo];
    activituVC.excludedActivityTypes=cludeActivitys;
    
    //显示分享窗口
    [self presentViewController:activituVC animated:YES completion:nil];
    
}

//创建沙盒文件
-(NSURL *)exportLog:(NSData *)logData fileName:(NSString *)fileName{
    
    NSString *finalPath;
    
    if(fileName == nil)
        fileName = @"share.gpr";
//        fileName = [NSString stringWithFormat:@"iOS%@-%@-%@.gamepro",[[UIDevice currentDevice]systemVersion],
//                    [self.formatter stringFromDate:self.startTime],
//                    [self.formatter stringFromDate:self.stopTime ]];
    
    //形成一个完整沙盒路径
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    finalPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:finalPath]){
        [ fileManager removeItemAtPath:finalPath error:NULL];
    }
    
    
    
    
    
    [fileManager createFileAtPath:finalPath contents:nil attributes:nil];
    
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath:finalPath];
    [fileHandle seekToEndOfFile];
    
    [fileHandle writeData:logData];
    //写入标题
    //    [fileHandle writeData:[self.title dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [fileHandle closeFile];
    
    
    
    return [ NSURL fileURLWithPath:finalPath];
}



@end
