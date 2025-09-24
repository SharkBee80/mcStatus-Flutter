import 'package:flutter/material.dart';

class XCard extends StatefulWidget {
  const XCard({super.key});

  @override
  State<XCard> createState() => _XCardState();
}

class _XCardState extends State<XCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380 + 20 + 12 + 12 + 2,
      height: 128 + 20,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [_buildImage(), _buildInfo(), _buildStatus()],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Center(child: Image.asset('assets/img/img.png')),
    );
  }

  Widget _buildInfo() {
    return SizedBox(
      width: 200,
      height: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hypixel Network',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'mc.hypixel.net',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'A Minecraft Server',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus() {
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // color: Colors.greenAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset('assets/img/singal/0.png', width: 40, height: 24),
          const SizedBox(height: 8),
          Text(
            '00 / 00',
            style: TextStyle(
              color: Colors.yellowAccent[200],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
