<div>

[**English**](README.md)

</div>

> [!IMPORTANT]
> **💡 关于此定制分支**
> 
> **🇨🇳 中文说明：**
> 本项目基于 [FlClash](https://github.com/chen08209/FlClash) 并集成 [vernesong/mihomo](https://github.com/vernesong/mihomo) 内核（有修改），额外支持 **Smart (智能节点优选) 路由策略**。


## FlClash

[![Downloads](https://img.shields.io/github/downloads/Satar07/FlClashSmart/total?style=flat-square&logo=github)](https://github.com/Satar07/FlClashSmart/releases/)[![Last Version](https://img.shields.io/github/release/Satar07/FlClashSmart/all.svg?style=flat-square)](https://github.com/Satar07/FlClashSmart/releases/)[![License](https://img.shields.io/github/license/Satar07/FlClashSmart?style=flat-square)](LICENSE)

基于ClashMeta的多平台代理客户端，简单易用，开源无广告。

on Desktop:
<p style="text-align: center;">
    <img alt="desktop" src="snapshots/desktop.gif">
</p>

on Mobile:
<p style="text-align: center;">
    <img alt="mobile" src="snapshots/mobile.gif">
</p>

## Features

✈️ 多平台: Android, Windows, macOS and Linux

💻 自适应多个屏幕尺寸,多种颜色主题可供选择

💡 基本 Material You 设计, 类[Surfboard](https://github.com/getsurfboard/surfboard)用户界面

☁️ 支持通过WebDAV同步数据

✨ 支持一键导入订阅, 深色模式

## Use

### Linux

⚠️ 使用前请确保安装以下依赖

   ```bash
    sudo apt-get install libayatana-appindicator3-dev
    sudo apt-get install libkeybinder-3.0-dev
   ```

### Android

支持下列操作

   ```bash
    com.flsmart.clash.action.START
    
    com.flsmart.clash.action.STOP
    
    com.flsmart.clash.action.TOGGLE
   ```

## Download

<a href="https://github.com/Satar07/FlClashSmart/releases"><img alt="Get it on GitHub" src="snapshots/get-it-on-github.svg" width="200px"/></a>

## Build

1. 更新 submodules
   ```bash
   git submodule update --init --recursive
   ```

2. 安装 `Flutter` 以及 `Golang` 环境

3. 构建应用

    - android

        1. 安装  `Android SDK` ,  `Android NDK`

        2. 设置 `ANDROID_NDK` 环境变量

        3. 运行构建脚本

           ```bash
           dart setup.dart android
           ```

    - windows

        1. 你需要一个windows客户端

        2. 安装 `GCC`，`Inno Setup`

        3. 运行构建脚本

           ```bash
           dart setup.dart windows
           ```

    - linux

        1. 你需要一个linux客户端

        2. 依赖会由 setup 脚本自动安装，也可以手动安装：
           ```bash
           sudo apt-get install -y libayatana-appindicator3-dev libkeybinder-3.0-dev
           ```

        3. 运行构建脚本

           ```bash
           dart setup.dart linux
           ```

    - macOS

        1. 你需要一个macOS客户端

        2. 运行构建脚本

           ```bash
           dart setup.dart macos
           ```

## Star

支持开发者的最简单方式是点击页面顶部的星标（⭐）。

<p style="text-align: center;">
    <a href="https://api.star-history.com/svg?repos=Satar07/FlClashSmart&Date">
        <img alt="start" width=50% src="https://api.star-history.com/svg?repos=Satar07/FlClashSmart&Date"/>
    </a>
</p>
