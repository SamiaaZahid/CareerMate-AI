import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Reusable avatar widget supporting Base64 Data URLs, Network URLs, local Files, and raw Bytes.
class UserAvatarWidget extends StatelessWidget {
  const UserAvatarWidget({
    super.key,
    this.photoPath,
    this.photoBytes,
    this.size = 106,
    this.iconSize = 36,
    this.primaryColor = const Color(0xFF54309C),
    this.iconBgColor = const Color(0xFFF2EDFC),
  });

  final String? photoPath;
  final Uint8List? photoBytes;
  final double size;
  final double iconSize;
  final Color primaryColor;
  final Color iconBgColor;

  @override
  Widget build(BuildContext context) {
    if (photoBytes != null && photoBytes!.isNotEmpty) {
      return ClipOval(
        child: Image.memory(
          photoBytes!,
          key: ValueKey('bytes-${photoBytes.hashCode}'),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
        ),
      );
    }

    if (photoPath != null && photoPath!.isNotEmpty) {
      final isNetwork = photoPath!.startsWith('http://') || photoPath!.startsWith('https://');
      final isDataUrl = photoPath!.startsWith('data:image/');
      final imageKey = ValueKey(photoPath);

      if (isDataUrl) {
        try {
          final commaIndex = photoPath!.indexOf(',');
          final base64Data = commaIndex != -1 ? photoPath!.substring(commaIndex + 1) : photoPath!;
          final decodedBytes = base64Decode(base64Data);
          return ClipOval(
            child: Image.memory(
              decodedBytes,
              key: imageKey,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
            ),
          );
        } catch (e) {
          debugPrint('[UserAvatarWidget] Error decoding base64 avatar: $e');
          return _buildDefaultIcon();
        }
      } else if (isNetwork) {
        return ClipOval(
          child: Image.network(
            photoPath!,
            key: imageKey,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
          ),
        );
      } else if (!kIsWeb && File(photoPath!).existsSync()) {
        return ClipOval(
          child: Image.file(
            File(photoPath!),
            key: imageKey,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
          ),
        );
      }
    }

    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: iconBgColor,
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: iconSize,
          color: primaryColor,
        ),
      ),
    );
  }
}
