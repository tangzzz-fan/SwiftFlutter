import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 检测是否在 iOS 平台上运行
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    // 如果是 iOS 平台，使用 CupertinoTabBar
    if (isIOS) {
      return CupertinoTabBar(
        currentIndex: currentIndex,
        activeColor: CupertinoColors.activeBlue,
        inactiveColor: CupertinoColors.inactiveGray,
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(
          top: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.compass),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: '设置',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: '我的',
          ),
        ],
        onTap: (index) => _handleNavigation(context, index),
      );
    }

    // 否则使用 Material 风格的 BottomNavigationBar
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      iconSize: 24,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: '发现',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '设置',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '我的',
        ),
      ],
      onTap: (index) => _handleNavigation(context, index),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;

    // 使用自定义过渡动画，模拟 iOS 原生效果
    final PageRouteBuilder<void> route = PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        switch (index) {
          case 0:
            return const HomeScreen();
          case 1:
            // 暂时重定向到首页
            return const HomeScreen();
          case 2:
            return const SettingsScreen();
          case 3:
            return const ProfileScreen();
          default:
            return const HomeScreen();
        }
      },
      transitionDuration: Duration.zero, // 无动画
      reverseTransitionDuration: Duration.zero,
    );

    // 根据索引导航到相应页面
    switch (index) {
      case 0:
        AppRouter.navigateToHome(context);
        break;
      case 1:
        // 暂时重定向到首页
        AppRouter.navigateToHome(context);
        break;
      case 2:
        AppRouter.navigateToSettings(context);
        break;
      case 3:
        AppRouter.navigateToProfile(context);
        break;
    }
  }
}
