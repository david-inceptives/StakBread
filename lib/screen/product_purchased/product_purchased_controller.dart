import 'package:get/get.dart';
import 'package:stakBread/screen/product_purchased/model/purchased_order_model.dart';
import 'package:stakBread/utilities/asset_res.dart';

class ProductPurchasedController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;

  static const List<PurchasedOrderStatus> _tabStatuses = [
    PurchasedOrderStatus.pending,
    PurchasedOrderStatus.toShip,
    PurchasedOrderStatus.completed,
    PurchasedOrderStatus.cancelled,
    PurchasedOrderStatus.rejected,
  ];

  PurchasedOrderStatus get currentStatus => _tabStatuses[selectedTabIndex.value];

  List<PurchasedOrderModel> ordersForStatus(PurchasedOrderStatus status) {
    return _dummyOrders.where((o) => o.status == status).toList();
  }

  void onTabTapped(int index) {
    selectedTabIndex.value = index;
  }

  void onAccept(PurchasedOrderModel order) {
  }

  void onReject(PurchasedOrderModel order) {
  }

  void onCancelOrder(PurchasedOrderModel order) {
  }

  void onChat(PurchasedOrderModel order) {
  }

  void onReport(PurchasedOrderModel order) {
  }

  void onReview(PurchasedOrderModel order) {
  }

  static final List<PurchasedOrderModel> _dummyOrders = [
    ...List.generate(3, (i) => PurchasedOrderModel(
          id: 'p${i + 1}',
          productImagePath: [AssetRes.product1, AssetRes.product2, AssetRes.product3][i],
          productName: 'Product 01 From',
          storeName: 'Wander Store',
          description:
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
          price: '£ 250.00',
          status: PurchasedOrderStatus.pending,
          placedDate: '24th July, 2022',
        )),
    ...List.generate(3, (i) => PurchasedOrderModel(
          id: 'ts${i + 1}',
          productImagePath: [AssetRes.camera1, AssetRes.camera2, AssetRes.camera3][i],
          productName: 'Product 01 From',
          storeName: 'Wander Store',
          description:
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
          price: '£ 250.00',
          status: PurchasedOrderStatus.toShip,
          placedDate: '24th July, 2022',
        )),
    ...List.generate(3, (i) => PurchasedOrderModel(
          id: 'c${i + 1}',
          productImagePath: [AssetRes.reel1, AssetRes.reel2, AssetRes.reel3][i],
          productName: 'Product 01 From',
          storeName: 'Wander Store',
          description:
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
          price: '£ 250.00',
          status: PurchasedOrderStatus.completed,
          placedDate: '24th July, 2022',
        )),
    ...List.generate(2, (i) => PurchasedOrderModel(
          id: 'cl${i + 1}',
          productImagePath: [AssetRes.product1, AssetRes.camera2][i],
          productName: 'Product 01 From',
          storeName: 'Wander Store',
          description:
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
          price: '£ 250.00',
          status: PurchasedOrderStatus.cancelled,
          placedDate: '24th July, 2022',
          isReimbursed: true,
        )),
    ...List.generate(2, (i) => PurchasedOrderModel(
          id: 'r${i + 1}',
          productImagePath: [AssetRes.reel4, AssetRes.product3][i],
          productName: 'Product 01 From',
          storeName: 'Wander Store',
          description:
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
          price: '£ 250.00',
          status: PurchasedOrderStatus.rejected,
          placedDate: '24th July, 2022',
          isReimbursed: true,
        )),
  ];
}
