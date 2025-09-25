import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:mcstatus/core/server.dart';

/// Shows a blurred dialog with optional custom background and blur settings.
Future<T?> showBlurredDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double blurSigma = 4.0,
  bool barrierDismissible = true,
  Color barrierColor = Colors.transparent,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Center(child: builder(context)),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

void showCentralDialog(BuildContext context) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  showBlurredDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Minecraft Server",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("Name", style: TextStyle(fontSize: 16)),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "My Minecraft",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {},
              ),
              const SizedBox(height: 10),
              const Text("Address", style: TextStyle(fontSize: 16)),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: "e.g., mc.example.com:25565",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // 自定义按钮行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("取消"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final name = nameController.text;
                      final address = addressController.text;
                      if (!check(context, name, address)) {
                        return;
                      }
                      await Server().save(name, address);
                      Navigator.pop(context); // 关闭弹窗
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("提交成功: $name / $address")),
                      );
                    },
                    child: const Text("提交"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

check(context, name, address) {
  if (name == null || name.isEmpty) {
    name = "Minncraft Server";
  }
  if (address == null || address.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("请填写服务器地址")));
    return false;
  }
  return true;
}
