import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/audio_helper.dart';

class MuteButton extends ConsumerWidget {
  final double size;
  const MuteButton({super.key, this.size = 24});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = ref.watch(muteProvider);
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        icon: Icon(
          muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          size: size,
        ),
        tooltip: muted ? 'Bật âm thanh' : 'Tắt âm thanh',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: () => ref.read(muteProvider.notifier).toggle(),
      ),
    );
  }
}
