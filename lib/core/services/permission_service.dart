import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    } else {
      var result = await Permission.camera.request();
      return result.isGranted;
    }
  }
}