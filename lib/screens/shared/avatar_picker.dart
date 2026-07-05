import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/sportyqo_api.dart';
import '../../services/api_client.dart';
import 'app_toast.dart';

/// Opens the camera or gallery, uploads the chosen photo to POST /me/avatar
/// and returns the new avatar URL — or null if the user cancelled or the
/// upload failed (an explanatory toast is shown in that case).
Future<String?> pickAndUploadAvatar(
  BuildContext context,
  ImageSource source, {
  Color accent = const Color(0xFF7B2FFF),
}) async {
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
    if (context.mounted) {
      AppToast.error(
          context,
          denied
              ? 'Permission denied. Allow ${source == ImageSource.camera ? 'camera' : 'photos'} access for SportyQo in your device Settings.'
              : 'Could not open the ${source == ImageSource.camera ? 'camera' : 'gallery'} on this device.');
    }
    return null;
  } catch (_) {
    if (context.mounted) {
      AppToast.error(context, 'Could not pick an image on this device.');
    }
    return null;
  }
  if (picked == null) return null; // user cancelled

  if (context.mounted) {
    AppToast.info(context, 'Uploading photo…',
        duration: const Duration(seconds: 60));
  }

  try {
    final url = await SportyQoApi.uploadAvatar(picked.path);
    if (context.mounted) {
      AppToast.success(context, 'Profile photo updated');
    } else {
      AppToast.dismiss();
    }
    return url;
  } on ApiException catch (e) {
    if (context.mounted) {
      AppToast.error(
          context,
          e.code == 'NETWORK'
              ? 'Upload failed — could not reach the server.'
              : e.message);
    } else {
      AppToast.dismiss();
    }
    return null;
  } catch (_) {
    if (context.mounted) {
      AppToast.error(context, 'Upload failed. Please try again.');
    } else {
      AppToast.dismiss();
    }
    return null;
  }
}


/// Recovers a photo picked just before Android killed the app.
///
/// On low-RAM devices (e.g. 1 GB Android Go phones) the OS routinely kills
/// the backgrounded Flutter process while the external camera/gallery
/// activity is in the foreground. The picked image is not lost — Android
/// caches it — but the app restarts from scratch. Calling this on startup
/// retrieves that image via image_picker's retrieveLostData() and finishes
/// the avatar upload, so the feature works even after a process death.
///
/// Returns the new avatar URL when a photo was recovered and uploaded.
Future<String?> recoverLostAvatar() async {
  if (kIsWeb || !Platform.isAndroid) return null;
  if (!ApiClient.instance.isLoggedIn) return null;
  try {
    final LostDataResponse resp = await ImagePicker().retrieveLostData();
    if (resp.isEmpty || resp.file == null) return null;
    return await SportyQoApi.uploadAvatar(resp.file!.path);
  } catch (_) {
    // Nothing to recover (or unsupported platform embedding) — not an error.
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
