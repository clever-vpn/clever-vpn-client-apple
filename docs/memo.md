# clevervpnEx 目标的调试说明
1. 由于需要system extension的app的调试运行必须安装在/Applications目录下，并且需要签名认证。我们在build setting中添加了一个自定义参数NOTARIZE_DEBUG_APP，如果是YES，它会自动完成签名认证，并同步到/Applications目录下。这样就可以直接在Xcode中调试运行了。
其中
2. 对system extension的安装，要在/Application下运行，它才能正确安装
3. 前台应用可以在xcode下Debug。因为它和后台是两个进程。



