import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:mcstatus/core/server.dart';
import 'package:mcstatus/models/servers.dart';

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

void showCentralDialog(BuildContext context, {Servers? server}) {
  final TextEditingController nameController = TextEditingController(
    text: server?.name ?? '',
  );
  final TextEditingController addressController = TextEditingController(
    text: server?.address ?? '',
  );
  final bool isEditing = server != null;

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
              Text(
                isEditing ? "编辑服务器" : "添加服务器",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      
                      try {
                        if (isEditing) {
                          // 更新现有服务器
                          final success = await Server().update(name, address, server!.uuid.toString());
                          if (success) {
                            Navigator.pop(context); // 关闭弹窗
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("更新成功: $name / $address"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("更新失败: 服务器不存在"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          // 添加新服务器
                          await Server().save(name, address);
                          Navigator.pop(context); // 关闭弹窗
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("添加成功: $name / $address"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEditing ? "更新失败: $e" : "添加失败: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(isEditing ? "更新" : "添加"),
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
