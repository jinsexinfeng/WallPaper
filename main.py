#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import sys
import json
import requests
import win32gui, win32con, win32api
import subprocess


# 获取图片
def getImage(downloadFolder, provider):
    # 定义图片下载的URL和提供者，参考https://doc.timeline.ink/#/api-image?id=图源-id
    url = "https://api.nguaduot.cn"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
    }
    # 拼接搜索URL
    searchURL = url + "/" + provider + "/random?json=1"
    print("正在获取图片URL...")
    # 发送GET请求获取图片数据
    response = requests.get(searchURL, headers=headers)
    if response.status_code == 200:
        print("请求成功，正在解析数据...")
        # 解析JSON数据
        result = json.loads(response.text)
        data = result["data"]
        imgURL = data["imgurl"]
        imgid = data["id"]
        print("图片URL为:%s" % imgURL)
    else:
        print("请求失败，请检查网络连接")
        return None

    # 打印正在下载的图片URL
    print("正在为您下载图片...")
    # 发送GET请求获取图片文件
    responseImg = requests.get(imgURL, headers=headers)

    # 定义图片文件名
    jpgFile = imgid + ".jpg"
    # 拼接图片文件路径
    jpgFile = os.path.join(downloadFolder, jpgFile)
    # 保存图片文件
    with open(jpgFile, "wb") as file:
        file.write(responseImg.content)
    # 返回图片文件路径
    print("图片下载完成，文件路径为:%s" % jpgFile)
    return jpgFile


# 设置桌面壁纸
def setWallpaper(filePath):
    # 参考https://github.com/qinyuanpei/WallPaper/
    print("正在设置桌面壁纸...")
    key = win32api.RegOpenKeyEx(
        win32con.HKEY_CURRENT_USER, "Control Panel\\Desktop", 0, win32con.KEY_SET_VALUE
    )
    # 设置壁纸风格 (1 = 居中, 2 = 拉伸, 6 = 适应, 10 = 填充)
    win32api.RegSetValueEx(key, "WallpaperStyle", 0, win32con.REG_SZ, "10")
    win32api.RegSetValueEx(key, "TileWallpaper", 0, win32con.REG_SZ, "0")
    win32gui.SystemParametersInfo(win32con.SPI_SETDESKWALLPAPER, filePath, 1 + 2)
    print("成功应用图片:%s为桌面壁纸" % filePath)


# 设置锁屏壁纸
def set_lock_screen_wallpaper(filePath):
    # 参考https://github.com/shaiksamad/lockscreen-magic
    print("正在设置锁屏壁纸...")
    # 使用igcmdWin10.exe设置锁屏壁纸
    # 默认在当前目录下，先拼接路径
    igcmdWin10Path = os.path.join(sys.path[0], "igcmdWin10.exe")
    if not os.path.exists(igcmdWin10Path):
        print("igcmdWin10.exe不存在，请先下载")
        return
    subprocess.run(
        f"{igcmdWin10Path} setlockimage {os.path.abspath(filePath)}",
        shell=True,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    print("成功应用图片:%s为锁屏壁纸" % filePath)


# 主程序入口
def main():
    downloadFolder = "download"
    # 定义图源 ID，参考https://doc.timeline.ink/#/api-image?id=图源-id
    provider = "ymyouli"
    # 获取下载文件夹路径
    downloadFolder = os.path.join(sys.path[0], downloadFolder)
    # 如果下载文件夹不存在，则创建
    if not os.path.exists(downloadFolder):
        os.mkdir(downloadFolder)
    # 获取图片文件
    imageFile = getImage(downloadFolder, provider)
    # 如果图片文件存在，则设置壁纸
    if imageFile != None:
        # 设置壁纸
        setWallpaper(imageFile)
        # 设置锁屏壁纸
        set_lock_screen_wallpaper(imageFile)


if __name__ == "__main__":
    main()
