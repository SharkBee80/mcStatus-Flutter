import 'package:flutter/material.dart';
import 'package:mcstatus/pages/gate.dart';
import 'package:mcstatus/utils/activator.dart';

class ActivationPage extends StatefulWidget {
  const ActivationPage({super.key});

  @override
  State<ActivationPage> createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  final TextEditingController _activationKeyController =
      TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  /// 处理激活请求
  Future<void> _activateApp() async {
    final String activationKey = _activationKeyController.text.trim();

    if (activationKey.isEmpty) {
      setState(() {
        _errorMessage = '请输入激活码';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 验证激活码
      final bool isValid = await Activator.validateActivationKey(
        activationKey,
      );

      if (isValid) {
        // 保存激活码
        await Activator.saveActivationKey(activationKey);

        // 导航到网关页面
        if (mounted) {
          // Navigator.pushReplacementNamed(context, '/gate');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GatePage()),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = '激活码无效';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '激活过程中出现错误';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('应用激活')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '请输入激活码以继续使用本应用',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _activationKeyController,
              decoration: InputDecoration(
                labelText: '激活码',
                hintText: '请输入您的激活码',
                errorText: _errorMessage.isEmpty ? null : _errorMessage,
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _activateApp,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('激活'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '如果您没有激活码，请联系客服获取。',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _activationKeyController.dispose();
    super.dispose();
  }
}
