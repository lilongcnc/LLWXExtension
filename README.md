# LLWXExtension
模拟用户点击屏幕/FakeTouch，抢微信红包

介绍移步这里: [iOS逆向微信红包：模仿用户点击屏幕的两个思路](https://www.jianshu.com/p/1eacd5db0299)


------
###前言
Hook微信红包的思路有很多，为了不被封号，最好还是模拟用户的点击行为。我的思路有两个，如下：
- 思路一：主动调用弹出红包view和点击领取红包的方法
- 思路二：模拟屏幕点击，点击cell，弹出红包view，直接调用领取红包

我的开发环境是
> - Xcode9.4.1
> - iOS9.1
> - 微信6.6.1 （PP助手下载）

###领取红包的流程分析
因为是直接从PP助手下载的，所以脱壳这一步可以直接省略。首先我们通过Reveal分析，可以得到相关界面的信息：
- 聊天界面控制器是“BaseMsgContentViewController”
- 领取红包view是“WCRedEnvelopesReceiveHomeView”
- 红包领取成功之后的详情界面是“WCRedEnvelopesRedEnvelopesDetailViewController.xm”

通过`logify.pl`得到用于调试输出的.xm文件，通过`nic.pl`创建Tweak项目，并且把该插件安装到手机上。 这里提一下，因为后期的安装调试插件很频繁，为了加快调试效率，我们可以设置编译完成后不重启`SpringBoard`，而是只重启微信，如下：

    after-install::
	    install.exec "killall -9 WeChat"

或者

    INSTALL_TARGET_PROCESSES = WeChat

通过上边的log打印结合IDA分析，我们可以梳理出红包调用主要流程：

![image.png](https://upload-images.jianshu.io/upload_images/594219-30439373e449d6af.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


注意：
- ChatTableViewCell中`setDelegate：`方法传入的就是已经创建好的`BaseMsgContentViewController`对象，显示的view是`WCPayC2CMessageCellView`。
- 弹出领取红包view，并不是通过tableView的`didSelectRowAtIndexPath`方法，而是在ChatTableViewCell中通过代理的形式，回调到`BaseMsgContentViewControlle`中，执行`tapAppNodeView：`方法，入参是cell中的WCPayC2CMessageCellView（带有模型数据）。
- 实际上点击cell，弹出`WCRedEnvelopesReceiveHomeView`之前， 会先`WCRedEnvelopesReceiveControlLogic`类中的方法请求接口，判断当前点击红包的状态。点击领取红包之后，也会在`WCRedEnvelopesReceiveControlLogic`调用接口领取红包，并且弹出`WCRedEnvelopesRedEnvelopesDetailViewController`。  这里我们用不到这个类，WCRedEnvelopesReceiveHomeView中初始化方法`initWithFrame:andData:delegate:`能够得到红包的数据模型，另外判断红包成功可以用`showSuccessOpenAnimation`。
- `WCRedEnvelopesRedEnvelopesDetailViewController初始化`调用了`init`方法。

###思路一
通过上边的分析，我们其实很容易得到模拟用户点击的方式，如下：
- 在ChatTableViewCell传入`model`后，调用`setDelegate `方法的时候主动调用`tapAppNodeView`方法。
- 执行`tapAppNodeView`方法，初始化`WCRedEnvelopesReceiveHomeView`后，直接调用`OnOpenRedEnvelopes`方法。
上边两步就可以实现自动抢红包了。还有几个细节需要注意一下：
- 让`WCRedEnvelopesReceiveHomeView`不显示，我们可以直接在初始化方法中，设置Frame为CGRectZero。
- 领取红包成功，拦截`WCRedEnvelopesRedEnvelopesDetailViewController`的弹出。如果采用重写`presentViewController:animated:completion:`的方式，你会发现还是会先显示一下红包详情页面，然后再消失。这是因为在执行到你重写的`present`方法的之前，`WCRedEnvelopesRedEnvelopesDetailViewController`就已经执行了`init`方法，接着又调用了初始化view、tableView的方法，界面已经绘制完成，先显示了出来。当代码执行到重写的`present`时，执行不present，让界面消失。所以你用这种方式的时候，你可以加一个是否正在领取红包的标识，如果正在领取红包，那么`init`方法直接返回nil。  或者你也可以这么做，因为`WCRedEnvelopesReceiveHomeView`和`WCRedEnvelopesRedEnvelopesDetailViewController`都是显示在`MMUIWindow`上的，你可以直接Hook`MMUIWindow`中的`addSubview`方法，不显示`WCRedEnvelopesReceiveHomeView`。

具体代码如下：
ChatTableViewCell:
```
@interface  ChatTableViewCell
- (BaseChatCellView *)cellView;
- (void)ll_getReadEnvelops:(id)arg1;
@end
@interface BaseMsgContentViewController
- (void)tapAppNodeView:(id)arg1;
@end
@interface WCPayC2CMessageCellView
-(WCPayC2CMessageViewModel *)viewModel;
-(CGRect)frame;
-(UIView *)superview;
@end
@interface WCPayC2CMessageViewModel
- (unsigned long long)bubbleType;
@end

%hook ChatTableViewCell
- (void)setDelegate:(id)arg1 { 
  %log; 
  %orig; 
  [self ll_getReadEnvelops:arg1];
}
%new
- (void)ll_getReadEnvelops:(id)arg1
{
  BaseMsgContentViewController *llsuperVC = (BaseMsgContentViewController *)arg1;
  id llcellView  =  [self cellView];
  if ([llcellView isKindOfClass:NSClassFromString(@"WCPayC2CMessageCellView")])
  {
      WCPayC2CMessageCellView *llRedCellView = (WCPayC2CMessageCellView * )llcellView;
      WCPayC2CMessageViewModel *llViewModel = [llRedCellView viewModel];
      if (4 == [llViewModel bubbleType])
      {
        HBLogDebug(@"lilong-didSelectRowAtIndexPath5-showRedView = %llu", [llViewModel bubbleType]);
        [llsuperVC tapAppNodeView:llRedCellView];
      }
  }
}
%end
```
WCRedEnvelopesReceiveControlLogic:
```
%hook WCRedEnvelopesReceiveControlLogic
- (void)closeAnimationWindowAndShowDetailView:(id)arg1 { // MMUIWindow
	%log;
	[LLRedEnvelopManager shareInstance].isGettingRedEnvelop = NO;
	%orig; 
}
%end
```
WCRedEnvelopesReceiveHomeView:
```
#import "Helper/LLRedEnvelopManager.h"
@interface WCRedEnvelopesReceiveHomeView
- (void)OnOpenRedEnvelopes;
- (void)removeView;
@end

%hook WCRedEnvelopesReceiveHomeView
- (id)initWithFrame:(struct CGRect)arg1 andData:(id)arg2 delegate:(id)arg3 { 
	%log;
	arg1 = CGRectMake(0, 0, 0, 0);
	id r = %orig;
	HBLogDebug(@" = %@", r); 
	[LLRedEnvelopManager shareInstance].isGettingRedEnvelop = YES;
	[self OnOpenRedEnvelopes]; // 领取红包
	return r; 
}
%end
```
WCRedEnvelopesRedEnvelopesDetailViewController:
```
%hook WCRedEnvelopesRedEnvelopesDetailViewController
- (id)init { 
	%log;
	if ([LLRedEnvelopManager shareInstance].isGettingRedEnvelop)
	{
		return nil;
	}
	else {
		id r = %orig;
	        HBLogDebug(@" = %@", r);
	        return r; 
	}	
}
	 
%end
```


###思路二
猴子测试会模拟用户点击屏幕，在屏幕上进行点击来模拟用户的操作行为。这个模拟用户行为就不是思路一中那样简单的调用方法了，想想一个界面那么多方法，我们每个拿出来随机调用，是一件工作量超级大而且很蠢的事情。猴子测试，是模拟我们手指点击屏幕上，屏幕点击触发我们的控制响应。好了，借助第三方框架[ZSFakeTouch](https://github.com/Roshanzs/ZSFakeTouch)，我们可以完成这个想法。  `ZSFakeTouch`同很多`FakeTouch`框架一样，都是基于国外一个[自动化测试框架](https://github.com/kif-framework/KIF)写的。 

稍微费力的是我们把`ZSFakeTouch`接入到`Theos`这一步。我们把相关的文件拖入到Tweak项目中，会发现报错找不到动态库`IOKit`或者报错：
```
Undefined symbols for architecture armv7:
  "_IOHIDEventAppendEvent", referenced from:
      _kif_IOHIDEventWithTouches in IOHIDEvent+KIF.m.f7997037.o
  "_IOHIDEventCreateDigitizerEvent", referenced from:
      _kif_IOHIDEventWithTouches in IOHIDEvent+KIF.m.f7997037.o
  "_IOHIDEventCreateDigitizerFingerEventWithQuality", referenced from:
      _kif_IOHIDEventWithTouches in IOHIDEvent+KIF.m.f7997037.o
  "_IOHIDEventSetIntegerValue", referenced from:
      _kif_IOHIDEventWithTouches in IOHIDEvent+KIF.m.f7997037.o
```

你需要进行是三个操作：
- 在`Makefile`文件中添加`LLWXExtension_FRAMEWORKS  = IOKit`，
- 下载[theos.zip](https://github.com/houshuai0816/ASO/blob/master/theos.zip)，然后
  - 将中`theos\lib`目录下的内容复制到你的`theos\lib`路径下，
  - 然后将`theos\`下的全部内容复制到你的`theos\include`中。 

然后执行Make，这时候就可以编译通过了。

ChatTableViewCell：
```

#import "ZSFakeTouch/ZSFakeTouch.h"

@class BaseChatCellView,BaseMsgContentViewController,WCPayC2CMessageCellView,WCPayC2CMessageViewModel,WCPayC2CMessageCellView;
@interface  ChatTableViewCell
- (BaseChatCellView *)cellView;
-(void)lltouchesWithPoint:(CGPoint)zspoint;
@end
@interface WCPayC2CMessageViewModel
- (unsigned long long)bubbleType;
@end

@interface WCPayC2CMessageCellView
-(WCPayC2CMessageViewModel *)viewModel;
-(UIView *)superview;
-(CGRect)frame;
@end

%hook ChatTableViewCell
- (void)layoutSubviews {
  %log; 
	%orig; 
	id llcellView  =  [self cellView];
	if ([llcellView isKindOfClass:NSClassFromString(@"WCPayC2CMessageCellView")])
	{
      WCPayC2CMessageCellView *llRedCellView = (WCPayC2CMessageCellView * )llcellView;
    	CGRect cellFrame = [[llRedCellView superview] convertRect:[llRedCellView frame]  toView:[[UIApplication sharedApplication] keyWindow]];
      WCPayC2CMessageViewModel *llViewModel = [llRedCellView viewModel];
      if (4 == [llViewModel bubbleType])
      {
          [self lltouchesWithPoint:CGPointMake(100, cellFrame.origin.y+30)];
      }
	}

}

%new
-(void)lltouchesWithPoint:(CGPoint)zspoint{
    [ZSFakeTouch beginTouchWithPoint:zspoint];
    [ZSFakeTouch endTouchWithPoint:zspoint];   
}

%end
```

两个思路这里就写完了，本文中只是提到了最基础的在聊天界面中的情况下抢红包，先后尝试了有一百多次抢红包，还没有被封号，看起来在6.6.1这个版本比较稳定。如果你想继续扩展，可以息屏、后台、或者离开聊天界面也可以抢红包。这里就要提到`CMessageMgr`这个类，它是获取消息推送的顶层的管理类。

上边用到的TweakDemo, 补充到了[这里](https://github.com/lilongcnc/LLWXExtension)

###参考
[ASO](https://kunnan.github.io/2018/06/06/aso/)
[theos.zip](https://github.com/houshuai0816/ASO/blob/master/theos.zip)


## 交流
![](http://upload-images.jianshu.io/upload_images/594219-cea3f887e6abdadc.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* * *








