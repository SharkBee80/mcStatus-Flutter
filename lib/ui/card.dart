import 'package:flutter/material.dart';
import 'package:mcstatus/pkg/auto_size_text/auto_size_builder/auto_size_text.dart';

class XCard extends StatefulWidget {
  final String? serverId;
  final String title;
  final String address;
  final String description;
  final String imagePath;
  final String signal;
  final String players;
  final VoidCallback? onRefresh;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap; // 点击事件
  final bool isMovingMode; // 是否处于移动模式
  final bool isMovingTarget; // 是否为当前移动的目标
  final VoidCallback? onMoveToPosition; // 移动到此位置的回调

  const XCard({
    super.key,
    this.serverId,
    this.title = "Hypixel Network",
    this.address = "mc.hypixel.net",
    this.description = "A Minecraft Server",
    this.imagePath = "assets/img/img.png",
    this.signal = "0",
    this.players = "00 / 00",
    this.onRefresh,
    this.onLongPress,
    this.onTap,
    this.isMovingMode = false,
    this.isMovingTarget = false,
    this.onMoveToPosition,
  });

  @override
  State<XCard> createState() => _XCardState();
}

class _XCardState extends State<XCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isMovingMode
          ? widget.onMoveToPosition
          : widget.onTap, // 移动模式下使用移动回调，否则使用点击回调
      onLongPress: widget.onLongPress,
      child: AspectRatio(
        aspectRatio: 8 / 3, // 规定卡片比例
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.all(10),
          decoration: _buildCardDecoration(),
          child: Stack(
            children: [
              // 主要内容
              Row(
                children: [
                  _buildImage(), // 固定为正方形，跟随高度
                  const SizedBox(width: 6),
                  Expanded(
                    // 占据剩余空间
                    child: Row(
                      children: [
                        Expanded(child: _buildInfo()), // 自适应填充
                        const SizedBox(width: 6),
                        _buildStatus(), // 按内容宽度
                      ],
                    ),
                  ),
                ],
              ),

              // 移动模式覆盖层
              if (widget.isMovingMode) _buildMoveOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建卡片装饰
  BoxDecoration _buildCardDecoration() {
    if (widget.isMovingMode) {
      if (widget.isMovingTarget) {
        // 当前移动的目标：金色边框 + 半透明
        return BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.amber, width: 2),
        );
      } else {
        // 可放置目标：蓝色边框
        return BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.blue.withOpacity(0.7), width: 2),
        );
      }
    } else {
      // 正常模式
      return BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 1),
      );
    }
  }

  /// 构建移动模式覆盖层
  Widget _buildMoveOverlay() {
    if (widget.isMovingTarget) {
      // 当前移动的目标：显示移动中的提示
      return Container(
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.open_with, color: Colors.amber, size: 24),
              SizedBox(height: 4),
              Text(
                '移动中...',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // 可放置目标：显示放置提示
      return Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.place, color: Colors.blue, size: 24),
              SizedBox(height: 4),
              Text(
                '点击放置这里',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildImage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight, // 跟随卡片高度
          child: AspectRatio(
            aspectRatio: 1, // 保持图片是正方形
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.cover, // 铺满方形区域
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        AutoSizeText(
          widget.address,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
          maxLines: 1,
        ),
        const SizedBox(height: 4),
        AutoSizeText(
          widget.description,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 2,
          wrapWords: false,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatus() {
    // 根据signal值确定颜色
    Color signalColor;
    switch (widget.signal) {
      case '4':
        signalColor = Colors.green;
        break;
      case '3':
        signalColor = Colors.lightGreen;
        break;
      case '2':
        signalColor = Colors.yellow;
        break;
      case '1':
        signalColor = Colors.orange;
        break;
      default:
        signalColor = Colors.red;
    }

    return IntrinsicWidth(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 30,
              height: 21,
              decoration: BoxDecoration(
                color: signalColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Icon(
                  widget.signal == '0'
                      ? Icons.signal_wifi_off
                      : Icons.signal_wifi_4_bar,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: 6),
            AutoSizeText(
              widget.players,
              style: TextStyle(
                color: Colors.yellowAccent[200],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
