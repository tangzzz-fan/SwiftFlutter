import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../router/app_router.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('com.example.swiftflutter/channel');
  String _message = '等待来自 iOS 的消息';
  final List<String> _items = List.generate(20, (index) => '项目 ${index + 1}');

  @override
  void initState() {
    super.initState();
    _setupMethodChannel();
  }

  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'sendMessageToFlutter':
          setState(() {
            _message = call.arguments;
          });
          return '消息已成功接收';
        case 'willCloseFromNative':
          print('收到原生端关闭通知');
          return '已收到关闭通知';
        default:
          throw PlatformException(
            code: 'NOT_IMPLEMENTED',
            message: '方法 ${call.method} 未实现',
          );
      }
    });
  }

  void _sendMessageToNative() async {
    try {
      final result = await platform.invokeMethod(
        'sendMessageToNative',
        '来自 Flutter 的消息: ${DateTime.now()}',
      );
      print('iOS 响应: $result');
    } on PlatformException catch (e) {
      print('发送消息失败: ${e.message}');
    }
  }

  void _returnToNative() async {
    try {
      await platform.invokeMethod('willCloseFlutterView');
      SystemNavigator.pop();
    } catch (e) {
      print('关闭页面时出错: $e');
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _returnToNative,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => AppRouter.navigateToSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  '原生通信',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _sendMessageToNative,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('发送消息到 iOS'),
                    ),
                    ElevatedButton(
                      onPressed: _returnToNative,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('返回 iOS'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  '项目列表',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => AppRouter.navigateToProfile(context),
                  icon: const Icon(Icons.person),
                  label: const Text('个人中心'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(_items[index]),
                  subtitle: Text('这是项目 ${index + 1} 的详细描述'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => AppRouter.navigateToDetail(
                    context,
                    (index + 1).toString(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
