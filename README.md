# Windows电脑壁纸
使用Python脚本自动设置Windows电脑壁纸和锁屏壁纸。

感谢`拾光壁纸`提供API：[timeline.ink](https://timeline.ink/)
*特别注明：图源均为来自网络，本应用无权且不提供商用授权，所以请勿用于商业用途，仅供学习交流。欢迎分享图源*

## 使用方法
1. 安装Python3
2. 安装依赖库
    ```bash
    pip install requests pywin32
    ```
3. 修改`main.py`中的`main`函数，设置下载文件夹和图源 ID
4. 自行修改`main.py`中的`main`函数，可以选择设置`桌面壁纸`或`锁屏壁纸`
5. 自行修改`main.py`中的`getImage`函数，获取更多图源的壁纸
6. 利用任务计划程序，每天自动运行`main.py`脚本
> 关键词：用任务计划程序运行python脚本

## 注意事项
1. 本脚本仅适用于Windows电脑
2. 本脚本不保证所有图源都能正常获取壁纸
3. 测试时间：2025年6月
4. 作者：[github.com/jinsexinfeng](https://github.com/jinsexinfeng)
