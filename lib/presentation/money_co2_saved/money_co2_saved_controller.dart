import 'package:get/get.dart';

import '../../infrastructure/constants/app_constants.dart';
import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/models/earning_model.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/pref_manager.dart';
import '../../infrastructure/shared/progress_dialog.dart';

class MoneyCO2SavedController extends GetxController{

  var progressDialog = ProgressDialog();
  var title = '';
  var screenFlag = '';
  var totalValue = (0.0).obs;
  var originalValue = (0.0).obs;
  var youPaidValue = (0.0).obs;
  var magicalBag = 0.obs;
  var unit = '';
  var totalCo2Saved = ''.obs;

  var electricityValue = '0'.obs;
  var smartPhoneChargeValue = '0'.obs;
  var cupValue = '0'.obs;
  var showerValue = '0'.obs;

  @override
  void onInit() {
    title = Get.arguments['title'];
    screenFlag = Get.arguments['screenFlag'];
    // totalValue = Get.arguments['totalValue'];
    unit = Get.arguments['unit'];
    Future.delayed(Duration.zero, () async {
      await getEarning();
    });
    super.onInit();
  }

  getEarning() async {
    progressDialog.show();
    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    print("accessToken $accessToken");
    try {
      ApiResponseModel<EarningModel> earningModel = await DioClient.multipartBase(accessToken: accessToken).funGetEarning();
      if (earningModel.success! && earningModel.data != null) {
        progressDialog.dismiss();
        totalValue.value = double.parse(earningModel.data!.earning!.money!.savedMoney!.toString());
        magicalBag.value =int.parse( earningModel.data!.earning!.money!.bag!.toString());
        originalValue.value = double.parse(earningModel.data!.earning!.money!.orignalValue!.toString());
        youPaidValue.value = double.parse(earningModel.data!.earning!.money!.totalPaid!.toString());
        var totalCo2 = double.parse(earningModel.data!.earning!.co2!.savedCo2!.toString());

        if (totalCo2 < 100) {
          totalCo2Saved.value = "${totalCo2.toStringAsFixed(3)} kg";
        } else if (totalCo2 >= 100 && totalCo2 < 1000) {
          var quental = totalCo2 / 100;
          totalCo2Saved.value = "${quental.toStringAsFixed(3)} Q";
        } else {
          var ton = totalCo2 / 1000;
          totalCo2Saved.value = "${ton.toStringAsFixed(3)} Q";
        }

        electricityValue.value = earningModel.data!.earning!.co2!.electricity.toString();
        smartPhoneChargeValue.value = earningModel.data!.earning!.co2!.phoneCharges.toString();
        cupValue.value = earningModel.data!.earning!.co2!.cupOfCoffee.toString();
        showerValue.value = earningModel.data!.earning!.co2!.hotShower.toString();

      } else {
        progressDialog.dismiss();
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
    } catch (e) {
      progressDialog.dismiss();
    }
  }

  getTime(String showerData){

    try{
      var hourDecimal = double.parse(showerData);
      int hours = hourDecimal.toInt();
      double minutesDecimal = (hourDecimal - hours) * 60;
      int minutes = minutesDecimal.toInt();
      // int seconds = ((minutesDecimal - minutes) * 60).toInt();
      // if(seconds == 0){
      //   return '${hours}h${minutes}m';
      // }
      if(minutes == 0){
        return '$hours h';
      }
      return '${hours}h${minutes}m';
    }catch(e){
      print(e);
      return showerData;
    }
  }

}