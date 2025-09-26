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
  });

  @override
  State<XCard> createState() => _XCardState();
}

class _XCardState extends State<XCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onRefresh,
      onLongPress: widget.onLongPress,
      child: AspectRatio(
        aspectRatio: 8 / 3, // 规定卡片比例
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
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
            border: Border.all(
              color: Colors.blueAccent.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
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
        ),
      ),
    );
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
                  widget.signal == '0' ? Icons.signal_wifi_off : Icons.signal_wifi_4_bar,
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
