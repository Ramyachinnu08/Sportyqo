import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/sportyqo_api.dart';
import '../../services/api_client.dart';

/// Opens the camera or gallery, uploads the chosen photo to POST /me/avatar
/// and returns the new avatar URL — or null if the user cancelled or the
/// upload failed (an explanatory snackbar is shown in that case).
Future<String?> pickAndUploadAvatar(
  BuildContext context,
  ImageSource source, {
  Color accent = const Color(0xFF7B2FFF),
}) async {
  final messenger = ScaffoldMessenger.of(context);

  XFile? picked;
  try {
    picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  } on PlatformException catch (e) {
    final denied = e.code.contains('access_denied');
    messenger.showSnackBar(SnackBar(
      content: Text(denied
          ? 'Permission denied. Allow ${source == ImageSource.camera ? 'camera' : 'photos'} access for SportyQo in your device Settings.'
          : 'Could not open the ${source == ImageSource.camera ? 'camera' : 'gallery'} on this device.'),
      backgroundColor: Colors.redAccent,
    ));
    return null;
  } catch (_) {
    messenger.showSnackBar(const SnackBar(
      content: Text('Could not pick an image on this device.'),
      backgroundColor: Colors.redAccent,
    ));
    return null;
  }
  if (picked == null) return null; // user cancelled

  messenger.showSnackBar(SnackBar(
    content: Row(children: const [
      SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white)),
      SizedBox(width: 12),
      Text('Uploading photo…'),
    ]),
    backgroundColor: accent,
    duration: const Duration(seconds: 30),
  ));

  try {
    final url = await SportyQoApi.uploadAvatar(picked.path);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: const Text('Profile photo updated'),
      backgroundColor: accent,
      duration: const Duration(seconds: 2),
    ));
    return url;
  } on ApiException catch (e) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(e.code == 'NETWORK'
          ? 'Upload failed — could not reach the server.'
          : e.message),
      backgroundColor: Colors.redAccent,
    ));
    return null;
  } catch (_) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(const SnackBar(
      content: Text('Upload failed. Please try again.'),
      backgroundColor: Colors.redAccent,
    ));
    return null;
  }
}

/// A circular avatar that shows the network photo when available and falls
/// back to initials (or an emoji) when not. Used across profile and home.
class AvatarCircle extends StatelessWidget {
  final String? avatarUrl; // may be relative ("/uploads/...") or absolute
  final String name;
  final double size;
  final Color borderColor;
  final double borderWidth;
  final double? fontSize;

  const AvatarCircle({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.size = 80,
    this.borderColor = const Color(0xFF7B2FFF),
    this.borderWidth = 2,
    this.fontSize,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final resolved = ApiClient.resolveMediaUrl(avatarUrl);
    final fallback = Center(
      child: Text(_initials,
          style: TextStyle(
              color: Colors.white,
              fontSize: fontSize ?? size * 0.32,
              fontWeight: FontWeight.w800)),
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        color: const Color(0xFF1A1A3A),
      ),
      child: ClipOval(
        child: resolved == null
            ? fallback
            : Image.network(
                resolved,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}
