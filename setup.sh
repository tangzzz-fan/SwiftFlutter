#!/bin/bash

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    
    # 检查 Node.js (用于 backend)
    if ! command -v node &> /dev/null; then
        warn "Node.js 未安装，backend 服务将无法运行"
        echo "请参考 Node.js 官方文档进行安装："
        echo "  https://nodejs.org/"
    else
        info "Node.js 版本: $(node --version)"
    fi
    
    # 检查 npm (用于 backend)
    if ! command -v npm &> /dev/null; then
        warn "npm 未安装，backend 服务依赖将无法安装"
    else
        info "npm 版本: $(npm --version)"
    fi
    
    info "所有必要工具已安装 ✅"
}

# 安装 Flutter 依赖
setup_flutter() {
    info "设置 Flutter 模块..."
    
    # 检查 flutter_module 目录是否存在
    if [ ! -d "${SCRIPT_DIR}/../flutter_module" ]; then
        error "Flutter 模块目录不存在: ${SCRIPT_DIR}/../flutter_module"
        exit 1
    fi
    
    cd "${SCRIPT_DIR}/../flutter_module" || {
        error "无法进入 Flutter 模块目录"
        exit 1
    }
    
    info "获取 Flutter 依赖..."
    flutter pub get
    
    if [ $? -ne 0 ]; then
        error "Flutter 依赖安装失败"
        exit 1
    fi
    
    # 运行 Riverpod Generator 构建
    info "构建 Riverpod Generator 代码..."
    dart run build_runner build --delete-conflicting-outputs
    
    if [ $? -ne 0 ]; then
        warn "Riverpod Generator 构建失败，但这不会影响基本功能"
    else
        info "Riverpod Generator 代码构建完成 ✅"
    fi
    
    info "Flutter 模块设置完成 ✅"
    cd "${SCRIPT_DIR}"
}

# 安装 iOS 依赖
setup_ios() {
    info "设置 iOS 项目..."
    
    # 检查当前目录是否为 iOS 项目目录
    if [ ! -f "${SCRIPT_DIR}/Podfile" ]; then
        error "当前目录不是 iOS 项目目录"
        exit 1
    fi
    
    info "安装 CocoaPods 依赖..."

    cd "${SCRIPT_DIR}" || {
        error "无法进入 iOS 项目目录"
        exit 1
    }
    pod install
    
    if [ $? -ne 0 ]; then
        error "CocoaPods 依赖安装失败"
        exit 1
    fi
    
    info "iOS 项目设置完成 ✅"
    cd "${SCRIPT_DIR}"
}

# 安装 Backend 依赖
setup_backend() {
    info "设置 Backend 服务..."
    
    # 检查 backend 目录是否存在
    if [ ! -d "${SCRIPT_DIR}/../backend_module" ]; then
        warn "Backend 目录不存在，跳过 Backend 依赖安装"
        return
    fi
    
    cd "${SCRIPT_DIR}/../backend_module" || {
        error "无法进入 Backend 目录"
        exit 1
    }
    
    if ! command -v npm &> /dev/null; then
        warn "npm 未安装，跳过 Backend 依赖安装"
        cd "${SCRIPT_DIR}"
        return
    fi
    
    info "安装 Backend 依赖..."
    npm install
    
    if [ $? -ne 0 ]; then
        error "Backend 依赖安装失败"
        cd "${SCRIPT_DIR}"
        exit 1
    fi
    
    info "Backend 服务设置完成 ✅"
    cd "${SCRIPT_DIR}"
}

# 清理缓存（可选）
clean_cache() {
    info "清理缓存..."
    
    # 清理 Flutter 缓存
    if [ -d "${SCRIPT_DIR}/../flutter_module" ]; then
        cd "${SCRIPT_DIR}/../flutter_module" || exit 1
        flutter clean
        cd "${SCRIPT_DIR}"
    fi
    
    # 清理 CocoaPods 缓存
    if [ -f "${SCRIPT_DIR}/Podfile" ]; then
        cd "${SCRIPT_DIR}" || exit 1
        rm -rf Pods
        rm -f Podfile.lock
        cd "${SCRIPT_DIR}"
    fi
    
    # 清理 Backend 缓存
    if [ -d "${SCRIPT_DIR}/../backend_module" ] && [ -d "${SCRIPT_DIR}/../backend_module/node_modules" ]; then
        rm -rf "${SCRIPT_DIR}/../backend_module/node_modules"
    fi
    
    # 清理 Riverpod Generator 生成的文件
    if [ -d "${SCRIPT_DIR}/../flutter_module" ]; then
        find "${SCRIPT_DIR}/../flutter_module/lib" -name "*.g.dart" -delete 2>/dev/null
    fi
    
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
        return
    fi
    
    # 检查必要工具
    check_requirements
    
    # 设置 Flutter 模块
    setup_flutter
    
    # 设置 iOS 项目
    setup_ios
    
    # 设置 Backend 服务
    setup_backend
    
    echo ""
    info "所有依赖安装完成! 🎉"
    echo ""
    echo "你可以使用以下命令打开 Xcode 项目:"
    echo "  open SwiftFlutter.xcworkspace"
    echo ""
    echo "如需重新构建 Riverpod Generator 代码，可运行:"
    echo "  cd ../flutter_module && ./build.sh"
    echo ""
}

# 执行主函数
main "$@"