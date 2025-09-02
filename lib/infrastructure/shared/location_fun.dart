import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;

Future getUserLocation() async {
 try{
   loc.Location location = loc.Location();
   var position = await location.getLocation();
   var address = await getUserAddress(position.latitude,position.longitude);
   return {'location' : position,'address' : address};
 }
 catch(e){
   return null;
 }
}

Future getAddressLatLng(address) async {
  try{
    List<Location> locationData = await locationFromAddress(address);
    return {'lat' : locationData[0].latitude,'lng' : locationData[0].longitude};
  }
  catch(e){
    return null;
  }
}


getUserAddress(lat,lng) async {
  try{
    List<Placemark> placemarks = await placemarkFromCoordinates(lat,lng);
    print(placemarks[0].toJson());
    return '${placemarks[0].name}  ${placemarks[0].street}  ${placemarks[0].subLocality}  ${placemarks[0].locality}  ${placemarks[0].country}';
  }catch(e){
    return 'unnamed';
  }
}


