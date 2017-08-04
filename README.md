/*
Title:够快云库iOS SDK使用说明
Description:
Author: Brandon
Date: 2015/07/20
Robots: noindex,nofollow
*/

# 够快云库iOS SDK使用说明

版本：1.0.1

创建：2015-07-20

修改时间:2016-05-08

##Demo
<img src="/Screenshot/1.PNG" alt="文件列表" title="文件列表" width="35%" height="35%" />

<img src="/Screenshot/2.PNG" alt="重命名、删除" title="重命名、删除" width="35%" height="35%" />

<img src="/Screenshot/3.PNG" alt="上传文件" title="上传文件" width="35%" height="35%" />

##场景使用声明
此SDK包含界面交互，适用客户端快入内嵌使用，包含文件列表、文件下载、预览、上传、文件删除和重命名功能，如果是基于文件管理的接口开发，请查看 https://github.com/gokuai/yunku-sdk-swift

##兼容性声明

	iOS 8.0+

##授权申请
登录https://www.gokuai.com/login 网址，点击后台管理tab，输入后台帐号密码，设置 -> 库开发授权 开启，然后返回 云库 -> (选择要申请开发的库) -> 授权管理 ->（点击进行开发的库）-> 授权管理 -> 点击获取ClientID和ClientSecret，记下这个两个参数，在使用SDK的时候，会使用这两个参数


##项目引用
将iOSYunkuSDK.framework、YunkuSwiftSDK.framework、CommonCrypto.framework、iOSYUnkuSDK.bundle拖曳引用至项目。

**swift&objc**

Build Phases => 在顶部添加一项 Copy Files，Destination 选择 Frameworks，将iOSYunkuSDK从项目中拖曳进去


##Example项目声明

##项目必需设置

###AppDelegate设置
在AppDelegate中预先设置sdk所需的参数。

**swift**

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        //================================需要开发者预先设置=====================
        SDKConfig.orgRootPath = "[Fullpath]"//访问文件的根目录
        SDKConfig.orgOptName = "[Name]"//操作人，例如文件上传、改名、删除等
        SDKConfig.orgRootTitle = "[Title]"//根目录标题
        SDKConfig.orgClientId = "[预先申请的CLIENT_ID]"
        SDKConfig.orgClientSecret = "[预先申请的CLIENT_SECRET]"
        
         //====================================================================
        return true
    }


**objc**

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary 	*)launchOptions {

    
    //================================需要开发者预先设置=====================
    [SDKConfig setOrgRootPath:@"[Fullpath]"];//访问文件的根目录
    [SDKConfig setOrgOptName:@"[Name]"];//操作人，例如文件上传、改名、删除等
    [SDKConfig setOrgRootTitle:@"[Title]"];//根目录标题
    [SDKConfig setOrgClientId:@"[预先申请的CLIENT_ID]"];
    [SDKConfig setOrgClientSecret:@"[预先申请的CLIENT_SECRET]"];
    
    //====================================================================

    
    return YES;
}

##类的使用说明
###YKMainViewController类

####成员option
设置开启的功能（文件重命名、文件删除、文件上传）

####成员delegate
注册hook,可以控制指定路径的文件创建、列表显示、文件上传、文件重命名、文件删除是否可以被允许执行

###HookDelegate

**swift**

	func hookInvoke(type: HookType, fullPath: String)-> Bool

**objc**

	(BOOL)hookInvoke:(enum HookType)type fullPath:(NSString *)fullPath
	
| 参数 | 类型 |说明 |
| --- | --- | --- |
| type | HookType |  hook回调的类型 |
| fullPath | string |  执行操作的路径 |

###Option类
| 属性 | 说明 |
| --- | --- |
| canDel | 是否开启删除 | 
| canRename | 是否开启重命名 | 
| canUpload | 是否可上传 | 

###HookType枚举
**swift**

| 枚举类型 | 说明 |
| --- | --- |
| FileList | 文件列表显示 | 
| Download | 文件下载 | 
| Upload | 文件上传 | 
| CreateDir |创建文件夹 |
| Rename | 重命名 |
| Delete | 文件删除 |

**objc**

| 枚举类型 | 说明 |
| --- | --- |
| HookTypeFileList | 文件列表显示 | 
| HookTypeDownload | 文件下载 | 
| HookTypeUpload | 文件上传 | 
| HookTypeCreateDir |创建文件夹 |
| HookTypeRename | 重命名 |
| HookTypeDelete | 文件删除 |
    

##相关SDK
https://github.com/gokuai/yunku-sdk-swift

