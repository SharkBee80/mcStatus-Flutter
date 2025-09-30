import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcstatus/utils/debug.dart';

/// 全局错误处理器
class GlobalErrorHandler {
  static void setup() {
    // 捕获Flutter框架错误
    FlutterError.onError = (FlutterErrorDetails details) {
      DebugX.console('Flutter错误: ${details.exception}');
      DebugX.console('堆栈跟踪: ${details.stack}');
      
      if (kDebugMode) {
        // Debug模式下显示原生错误界面
        FlutterError.presentError(details);
      } else {
        // Release模式下记录错误但不显示红屏
        DebugX.console('Release模式下捕获到Flutter错误，已记录但不显示');
      }
    };

    // 捕获异步错误
    PlatformDispatcher.instance.onError = (error, stack) {
      DebugX.console('平台错误: $error');
      DebugX.console('堆栈跟踪: $stack');
      return true; // 返回true表示错误已被处理
    };
  }
}

/// 错误边界Widget，用于包装可能出错的组件
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;
  final String? errorMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.errorMessage,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  String? _errorDetails;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.fallback ?? _buildDefaultErrorWidget();
    }

    return widget.child;
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            widget.errorMessage ?? '页面加载出错',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '请尝试刷新页面',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (_errorDetails != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorDetails = null;
                });
              },
              child: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 监听错误
    try {
      // 这里可以添加特定的错误监听逻辑
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(dynamic error) {
    DebugX.console('ErrorBoundary捕获错误: $error');
    
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorDetails = error.toString();
      });
    }
  }
}

/// 安全的异步操作包装器
class SafeAsyncOperation {
  /// 安全执行异步操作，自动处理错误
  static Future<T?> execute<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    bool showToast = false,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      DebugX.console('异步操作错误: $e');
      DebugX.console('堆栈跟踪: $stackTrace');
      
      if (showToast && errorMessage != null) {
        // 这里可以添加toast显示逻辑
        DebugX.console('显示错误提示: $errorMessage');
      }
      
      return null;
    }
  }
}