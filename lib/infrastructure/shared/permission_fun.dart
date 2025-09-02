import 'package:permission_handler/permission_handler.dart';

getLocationServicePermissionStatus() async {
  return await Permission.location.serviceStatus.isEnabled;
}

getLocationPermissionStatus() async {

  if (await Permission.location.status.isDenied &&
      await Permission.locationWhenInUse.status.isDenied &&
      await Permission.locationAlways.status.isDenied) {
    return 0;
  } else if (await Permission.location.status.isPermanentlyDenied &&
      await Permission.locationWhenInUse.status.isPermanentlyDenied &&
      await Permission.locationAlways.status.isPermanentlyDenied) {
    return -1;
  } else {
    return 1;
  }
}

requestLocationPermission() async {
  Map<Permission, PermissionStatus> permissionMap = await [Permission.location].request();
  if (permissionMap[Permission.location] == PermissionStatus.denied ||
      permissionMap[Permission.locationWhenInUse] == PermissionStatus.denied ||
      permissionMap[Permission.locationAlways] == PermissionStatus.denied) {
    return 0;
  } else if (permissionMap[Permission.location] == PermissionStatus.permanentlyDenied ||
      permissionMap[Permission.locationWhenInUse] == PermissionStatus.permanentlyDenied ||
      permissionMap[Permission.locationAlways] == PermissionStatus.permanentlyDenied) {
    return -1;
  } else {
    return 1;
  }
}

getNotificationPermissionStatus() async {
  if (await Permission.notification.status.isDenied) {
    return 0;
  } else if (await Permission.notification.status.isPermanentlyDenied) {
    return -1;
  } else {
    return 1;
  }
}

requestNotificationPermission() async {
  PermissionStatus permissionStatus = await Permission.notification.request();
  if(permissionStatus.isDenied){
    return 0;
  }
  else if(permissionStatus.isDenied){
    return -1;
  }
  else{
    return 1;
  }
}

funOpenAppSettings() async {
  return await openAppSettings();
}