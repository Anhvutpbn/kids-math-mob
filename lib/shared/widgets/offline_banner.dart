import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/connectivity_provider.dart';

/// Drop this anywhere above a Scaffold body to show a sticky offline banner.
class OfflineBanner extends ConsumerWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isOnline ? 0 : 36,
          color: Colors.red.shade600,
          child: isOnline
              ? const SizedBox()
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Đang offline — dùng dữ liệu đã lưu',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
