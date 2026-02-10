import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/screen/dashboard_screen/dashboard_screen.dart';
import 'package:stakBread/utilities/asset_res.dart';

class InterestItem {
  final String id;
  final String label;
  final String? imagePath;
  final IconData? icon;

  InterestItem({
    required this.id,
    required this.label,
    this.imagePath,
    this.icon,
  });
}

class InterestScreenController extends BaseController {
  final User? myUser;

  InterestScreenController({this.myUser});

  /// Current step in the flow (1-based). Step 3 = Interest screen.
  static const int currentStep = 3;
  static const int totalSteps = 4;

  final List<String> selectedIds = [];

  List<InterestItem> get interestItems => [
        InterestItem(id: 'music', label: 'Music', imagePath: AssetRes.categoryChipMusic),
        InterestItem(id: 'fashion', label: 'Fashion', imagePath: AssetRes.categoryChipFashion),
        InterestItem(id: 'games', label: 'Games', imagePath: AssetRes.categoryChipGames),
        InterestItem(id: 'pet', label: 'Pet', icon: Icons.pets),
        InterestItem(id: 'travelling', label: 'Travelling', icon: Icons.flight_takeoff),
        InterestItem(id: 'technology', label: 'Technology', icon: Icons.laptop_mac),
        InterestItem(id: 'beauty', label: 'Beauty', icon: Icons.auto_awesome),
        InterestItem(id: 'food', label: 'Food', imagePath: AssetRes.categoryChipFood),
        InterestItem(id: 'comedy', label: 'Comedy', imagePath: AssetRes.categoryChipComedy),
        InterestItem(id: 'skincare', label: 'Skincare', icon: Icons.spa),
        InterestItem(id: 'wellness', label: 'Wellness', icon: Icons.self_improvement),
        InterestItem(id: 'bag', label: 'Bag', icon: Icons.backpack),
        InterestItem(id: 'accessories', label: 'Accessories', icon: Icons.watch),
        InterestItem(id: 'architecture', label: 'Architecture', icon: Icons.apartment),
        InterestItem(id: 'art', label: 'Art', icon: Icons.palette),
        InterestItem(id: 'sport', label: 'Sport', icon: Icons.sports_soccer),
        InterestItem(id: 'film', label: 'Film', icon: Icons.movie),
        InterestItem(id: 'drama', label: 'Drama', icon: Icons.theater_comedy),
      ];

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    update();
  }

  bool isSelected(String id) => selectedIds.contains(id);

  void onContinue() {
    // TODO: Save selected interests to backend if needed
    _markInterestCompletedAndGoToDashboard();
  }

  void onMaybeLater() {
    _markInterestCompletedAndGoToDashboard();
  }

  void _markInterestCompletedAndGoToDashboard() {
    final userId = myUser?.id?.toInt();
    if (userId != null) {
      SessionManager.instance.setInterestScreenCompleted(userId);
    }
    _goToDashboard();
  }

  void _goToDashboard() {
    final user = myUser ?? SessionManager.instance.getUser();
    Get.offAll(() => DashboardScreen(myUser: user));
  }
}
