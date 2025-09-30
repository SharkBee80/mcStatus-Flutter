import 'dart:async';
import 'package:mcstatus/utils/debug.dart';

/// 并发控制工具
class ConcurrencyController {
  static const int maxConcurrentRequests = 4; // 全局最大并发数
  static const int defaultTimeoutSeconds = 8; // 默认超时时间
  
  static int _activeTasks = 0;
  static final List<Completer<void>> _waitingQueue = [];
  
  /// 执行受控的并发任务
  static Future<T?> execute<T>(
    Future<T> Function() task, {
    int timeoutSeconds = defaultTimeoutSeconds,
    String? taskName,
  }) async {
    // 等待获取执行许可
    await _acquirePermission();
    
    try {
      DebugX.console('开始执行任务: ${taskName ?? "未命名"} (当前活跃任务数: $_activeTasks)');
      
      final result = await task().timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          DebugX.console('任务超时: ${taskName ?? "未命名"}');
          throw TimeoutException('任务执行超时', Duration(seconds: timeoutSeconds));
        },
      );
      
      DebugX.console('任务完成: ${taskName ?? "未命名"}');
      return result;
    } catch (e) {
      DebugX.console('任务失败: ${taskName ?? "未命名"} - $e');
      return null;
    } finally {
      _releasePermission();
    }
  }
  
  /// 批量执行任务，自动控制并发数
  static Future<List<T?>> executeBatch<T>(
    List<Future<T> Function()> tasks, {
    int? maxConcurrency,
    int timeoutSeconds = defaultTimeoutSeconds,
    String? batchName,
  }) async {
    final concurrency = maxConcurrency ?? _calculateOptimalConcurrency(tasks.length);
    DebugX.console('批量执行 ${tasks.length} 个任务，并发数: $concurrency (${batchName ?? "未命名批次"})');
    
    final results = <T?>[];
    
    for (int i = 0; i < tasks.length; i += concurrency) {
      final batch = tasks.skip(i).take(concurrency).toList();
      DebugX.console('执行批次 ${(i ~/ concurrency) + 1}/${(tasks.length / concurrency).ceil()}');
      
      final batchResults = await Future.wait(
        batch.asMap().entries.map((entry) {
          final index = i + entry.key;
          return execute(
            entry.value,
            timeoutSeconds: timeoutSeconds,
            taskName: '${batchName ?? "批次"}任务${index + 1}',
          );
        }),
        eagerError: false,
      );
      
      results.addAll(batchResults);
      
      // 批次间稍作等待，避免网络拥塞
      if (i + concurrency < tasks.length) {
        await Future.delayed(Duration(milliseconds: _calculateBatchDelay(concurrency)));
      }
    }
    
    return results;
  }
  
  /// 获取执行许可
  static Future<void> _acquirePermission() async {
    if (_activeTasks >= maxConcurrentRequests) {
      // 需要等待
      final completer = Completer<void>();
      _waitingQueue.add(completer);
      await completer.future;
    }
    
    _activeTasks++;
  }
  
  /// 释放执行许可
  static void _releasePermission() {
    _activeTasks--;
    
    // 如果有等待的任务，唤醒下一个
    if (_waitingQueue.isNotEmpty) {
      final completer = _waitingQueue.removeAt(0);
      completer.complete();
    }
  }
  
  /// 计算最优并发数
  static int _calculateOptimalConcurrency(int taskCount) {
    if (taskCount <= 2) return taskCount;
    if (taskCount <= 4) return 2;
    if (taskCount <= 8) return 3;
    return 4; // 最大并发数
  }
  
  /// 计算批次间延迟
  static int _calculateBatchDelay(int concurrency) {
    switch (concurrency) {
      case 1:
        return 50;
      case 2:
        return 100;
      case 3:
        return 150;
      default:
        return 200;
    }
  }
  
  /// 重置控制器状态（用于测试或重启）
  static void reset() {
    _activeTasks = 0;
    for (final completer in _waitingQueue) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    _waitingQueue.clear();
  }
  
  /// 获取当前状态信息
  static Map<String, dynamic> getStatus() {
    return {
      'activeTasks': _activeTasks,
      'waitingTasks': _waitingQueue.length,
      'maxConcurrency': maxConcurrentRequests,
    };
  }
}
