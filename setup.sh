#!/bin/bash

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 打印带颜色的信息
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查必要的工具是否安装
check_requirements() {
    info "检查必要的工具..."
    
    # 检查 CocoaPods
    if ! command -v pod &> /dev/null; then
        error "CocoaPods 未安装，请先安装 CocoaPods"
        echo "可以使用以下命令安装："
        echo "  sudo gem install cocoapods"
        exit 1
    fi
    
    # 检查 Flutter
    if ! command -v flutter &> /dev/null; then
        error "Flutter 未安装，请先安装 Flutter"
        echo "请参考 Flutter 官方文档进行安装："
        echo "  https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    
    # 检查 Xcode 命令行工具
    if ! xcode-select -p &> /dev/null; then
        error "Xcode 命令行工具未安装"
        echo "请使用以下命令安装："
        echo "  xcode-select --install"
        exit 1
    fi
    
    info "所有必要工具已安装 ✅"
}

# 安装 Flutter 依赖
setup_flutter() {
    info "设置 Flutter 模块..."
    
    cd flutter_module || {
        error "Flutter 模块目录不存在"
        exit 1
    }
    
    info "获取 Flutter 依赖..."
    flutter pub get
    
    if [ $? -ne 0 ]; then
        error "Flutter 依赖安装失败"
        exit 1
    fi
    
    info "Flutter 模块设置完成 ✅"
    cd ..
}

# 安装 iOS 依赖
setup_ios() {
    info "设置 iOS 项目..."
    
    info "安装 CocoaPods 依赖..."
    pod install
    
    if [ $? -ne 0 ]; then
        error "CocoaPods 依赖安装失败"
        exit 1
    fi
    
    info "iOS 项目设置完成 ✅"
}

# 清理缓存（可选）
clean_cache() {
    info "清理缓存..."
    
    # 清理 Flutter 缓存
    cd flutter_module || exit 1
    flutter clean
    cd ..
    
    # 清理 CocoaPods 缓存
    rm -rf Pods
    rm -f Podfile.lock
    
    info "缓存清理完成 ✅"
}

# 主函数
main() {
    echo "========================================"
    echo "     SwiftFlutter 项目依赖安装脚本      "
    echo "========================================"
    
    # 检查参数
    if [ "$1" == "--clean" ]; then
        clean_cache
    fi
    
    # 检查必要工具
    check_requirements
    
    # 设置 Flutter 模块
    setup_flutter
    
    # 设置 iOS 项目
    setup_ios
    
    echo ""
    info "所有依赖安装完成! 🎉"
    echo ""
    echo "你可以使用以下命令打开 Xcode 项目:"
    echo "  open SwiftFlutter.xcworkspace"
    echo ""
}

# 执行主函数
main "$@" 