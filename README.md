在App经常用到分享或被分享功能, 有的用shareSDK这样第三方功能.优点是
界面精美,功能也能做得很复杂.

但是实现起来很麻烦,每种分享机制要下载相应的SDK.申请key,各家的lib,最后折腾半天还经常失败.
实际如果简单分享一个文件图片,最简单是采用系统内建机制

## 一. 分享文件


系统代码有几种形式
一种是 采用 UIDocumentInteractionController 实现带预览的功能的分享.但这个在分享时多一个界面.而且不是缺省支持文件,还需要写预览代码

另外一种是采用 UIActivityViewController,相当简单,

```
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
    fileName = [NSString stringWithFormat:@"iOS%@-%@-%@-%@.csv",[[UIDevice currentDevice]systemVersion],[UIDeviceHardware platformString ],
                          [self.formatter stringFromDate:self.startTime],
                          [self.formatter stringFromDate:self.stopTime ]];
   
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
```

## 二. 导入文件

使用场景:假设你的app需要某种配置文件或脚本,如何快速导入App内部?

方法1 : 使用iTunes文件共享功能.
方法2:  内部建立web服务器,用户通过网页上传文件
方法3:通过AirPlay 文件传输功能
方法4: 系统代码分享功能



这里讲更为通用的特定后缀文件,在系统中注册特定后缀名后.在用微信,QQ接收文件后,点击分享,会出现你的App名字,点击即可导入他的名字

### 导入特定后缀文件

流程
1. 定义本app支持后缀名
2. 定义导入界面及处理代码


#### 1.定义UTI
需要在info.plist中的Document types 中定义相关名称和UTI

其中UTI 统一类型标识 ,类似于 http中的 mime .即在iOS中分享文件必须有一个唯一的UTI. 其中象图片,文本文件之类已经预先定义好.

但是在app采用通用UTI会有一个问题,会在QQ,微信分享列表中找不到你开发的app,所以最好是自定义一个UTI

![image.png](https://upload-images.jianshu.io/upload_images/1493747-aee97f00946d427d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这里定义两个后缀名,其中UTTypeConformsTo 表示本UTI基于哪个基本的UTI, UTTypeIdentifier是全局唯一的url 名称即可.

UTTypeTagSpecification 指明后缀名(public.filename-extension)和mime名称(public.mime-type)

```xml
<key>UTExportedTypeDeclarations</key>
	<array>
		<dict>
			<key>UTTypeConformsTo</key>
			<array>
				<string>public.plain-text</string>
				<string>public.text</string>
			</array>
			<key>UTTypeDescription</key>
			<string>TSC Printer Basic Command Script</string>
			<key>UTTypeIdentifier</key>
			<string>cn.bluedrum.printer.tscbas</string>
			<key>UTTypeTagSpecification</key>
			<dict>
				<key>public.filename-extension</key>
				<string>tscbas</string>
				<key>public.mime-type</key>
				<string>tsc/x-bas</string>
			</dict>
		</dict>
		<dict>
			<key>UTTypeConformsTo</key>
			<array>
				<string>public.plain-text</string>
				<string>public.text</string>
			</array>
			<key>UTTypeDescription</key>
			<string>CPCL Printer Basic Command Script</string>
			<key>UTTypeIdentifier</key>
			<string>cn.bluedrum.printer.cpclbas</string>
			<key>UTTypeTagSpecification</key>
			<dict>
				<key>public.filename-extension</key>
				<string>cpclbas</string>
				<key>public.mime-type</key>
				<string>cpcl/x-bas</string>
			</dict>
		</dict>
	</array>
```
####2.定义app支持文档
然后在info.plist 中应文档类型,如果UTI是用通用的,可以跳开上一步,否则这里引用前面定义UTI,

   需要在info.plist中的Document types 中定义相关名称
![image.png](https://upload-images.jianshu.io/upload_images/1493747-ba8be8454006574c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这个还定义在分享界面显示的图标
以下是定义两个文档类型
```xml
<key>CFBundleDocumentTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeIconFiles</key>
			<array>
				<string>doc_22x29.png</string>
				<string>doc_44x58.png</string>
				<string>doc_64x64.png</string>
				<string>doc_320x320.png</string>
			</array>
			<key>CFBundleTypeName</key>
			<string>TSC Printer Basic Command Script</string>
			<key>LSHandlerRank</key>
			<string>default</string>
			<key>LSItemContentTypes</key>
			<array>
				<string>cn.bluedrum.printer.tscbas</string>
			</array>
		</dict>
		<dict>
			<key>CFBundleTypeIconFiles</key>
			<array>
				<string>doc_22x29.png</string>
				<string>doc_44x58.png</string>
				<string>doc_64x64.png</string>
				<string>doc_320x320.png</string>
			</array>
			<key>CFBundleTypeName</key>
			<string>CPCL Printer Basic Command Script</string>
			<key>LSHandlerRank</key>
			<string>default</string>
			<key>LSItemContentTypes</key>
			<array>
				<string>cn.bluedrum.printer.cpclbas</string>
			</array>
		</dict>
	</array>
```

如果非自定义UTI,直接在 LSItemContentTypes写上缺省类型,如
<key>LSItemContentTypes</key>
			<array>
				<string>public.text</string>
			</array>
#### 3.定义接收界面.

接收界同在发出分享的app执行分享动作后,接收分享的app弹出界面. 通常接收app本身也有正在执行工作,为不破坏当前状态,接收界面通常是弹出一个新界面来处理,处理完毕后再返回原来界面,参见

比如京东,百度网盘就是这样做的

用于触发接收处理,是在AppDelegate 中的



> - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options


其中的 url 即是分享过来文件,系统会在当前app沙盒目录中直接创建
类似于  //file:///private/var/mobile/Containers/Data/Application/0EB380E2-C7AF-4D0C-B396-8426E2C6E9D2/Documents/Inbox/haibo_bitmap-2.tscbas
的文件

方法中处理.这个方法是iOS9才有,因此需要单独处理一下

```
#if __IPHONE_OS_VERSION_MAX_ALLOWED >=__IPHONE_9_0

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
 
    

   
    
    NSString * urlPath = [url absoluteString];
    
    NSString * fileName = [urlPath lastPathComponent];
    

    NSString *fileExtension = [[fileName pathExtension] lowercaseString];
    
    //file:///private/var/mobile/Containers/Data/Application/0EB380E2-C7AF-4D0C-B396-8426E2C6E9D2/Documents/Inbox/haibo_bitmap-2.tscbas
    
//根据后缀名执行不同操作
    if([fileExtension isEqualToString:@"tscbas"])
        [ PrinterManager sharedInstance].scriptCmdSet = PrinterCmdTSC;
    else if([fileExtension isEqualToString:@"cpclbas"])
        [ PrinterManager sharedInstance].scriptCmdSet = PrinterCmdCPCL;
    
//取得分享内容
     NSData * data = [NSData dataWithContentsOfURL:url];
    
    NSLog(@"printScript %ld",[data length]);
   
//转换成字符串
   NSString * strData = [[NSString alloc] initWithData:[ data  encoding:NSUTF8StringEncoding];
    
   //把数据保存在一个全局变量里
 // self.shareData  <<===strData;
 
//弹出界面写法,因是全局方法,这里如果需要弹storyboard 中某个窗口,必须指明是哪UIStoryboard ,即便当前界面也是Main,也是如此.
    
    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    
   
//找到storyboard 某个controller 
    
    ScriptViewController* scriptController = [secondStoryBoard instantiateViewControllerWithIdentifier:@"scriptPagePrint"];
    
 //直接在当前界面弹出,数据直接从全局变量取,因为这里弹出界面并未创建,无法用对对象赋值的方法传值,因此只能用全局变量来传输
    [vc.navigationController pushViewController:scriptController animated:YES];
    
    return YES;
}
#endif
```

注意,如果希望当前界面处理这个分享,可以用如下方法找到最前的controller ,交给他处理也可.
> UIViewController * vc = [application.keyWindow visibleViewController] 来取得当前controller 


完整代码参见 https://github.com/work4blue/ios-share-file