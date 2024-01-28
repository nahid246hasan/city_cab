import 'package:get/get.dart';

import '../../../models/option_model.dart';

class OptionListController extends GetxController{
  RxList<OptionModel> option = [
    OptionModel("Share Ride", false),
    OptionModel("Courier", false)
  ].obs;
  RxList selectedOptions = [].obs;

  void addIntoTheList(String element){
    selectedOptions.add(element);
  }

  void removeFromTheList(String element){
    selectedOptions.remove(element);
  }

}