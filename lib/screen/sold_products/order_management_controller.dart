import 'package:get/get.dart';
import 'package:stakBread/screen/sold_products/model/order_item_model.dart';
import 'package:stakBread/utilities/asset_res.dart';

class OrderManagementController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;

  static const List<OrderStatus> _tabStatuses = [
    OrderStatus.pending,
    OrderStatus.toShip,
    OrderStatus.completed,
    OrderStatus.rejected,
  ];

  OrderStatus get currentStatus => _tabStatuses[selectedTabIndex.value];

  List<OrderItemModel> ordersForStatus(OrderStatus status) {
    return _dummyOrders.where((o) => o.status == status).toList();
  }

  void onTabTapped(int index) {
    selectedTabIndex.value = index;
  }

  void onCancelOrder(OrderItemModel order) {
    // TODO: API call to cancel order
  }

  void onChat(OrderItemModel order) {
    // TODO: Navigate to chat
  }

  void onReport(OrderItemModel order) {
    // TODO: Open report sheet
  }

  void onReview(OrderItemModel order) {
    // TODO: Open review screen/sheet
  }

  static final List<OrderItemModel> _dummyOrders = [
    OrderItemModel(
      id: '1',
      productImagePath: AssetRes.product1,
      productName: 'Product 01 From',
      storeName: 'Wander Store',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      price: '£ 250.00',
      status: OrderStatus.pending,
      placedDate: '24th July, 2022',
    ),
    OrderItemModel(
      id: '2',
      productImagePath: AssetRes.product2,
      productName: 'Product 01 From',
      storeName: 'Wander Store',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      price: '£ 250.00',
      status: OrderStatus.pending,
      placedDate: '24th July, 2022',
    ),
    OrderItemModel(
      id: '3',
      productImagePath: AssetRes.product3,
      productName: 'Product 01 From',
      storeName: 'Wander Store',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      price: '£ 250.00',
      status: OrderStatus.pending,
      placedDate: '24th July, 2022',
    ),
    OrderItemModel(
      id: '4',
      productImagePath: AssetRes.camera1,
      productName: 'Product 01 From',
      storeName: 'Wander Store',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      price: '£ 250.00',
      status: OrderStatus.toShip,
      placedDate: '24th July, 2022',
    ),
    OrderItemModel(
      id: '5',
      productImagePath: AssetRes.camera2,
      productName: 'Product 01 From',
      storeName: 'Wander Store',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      price: '£ 250.00',
      status: OrderStatus.toShip,
      placedDate: '24th July, 2022',
    ),
    OrderItemModel(
      id: '6',
      productImagePath: AssetRes.camera3,
      productName: 'Product 01 From',
      storeName: 'Wander Store',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      price: '£ 250.00',
      status: OrderStatus.toShip,
      placedDate: '24th July, 2022',
    ),
    OrderItemModel(
      id: '7',
      productImagePath: AssetRes.reel1,
      productName: 'Product 01 From',
      storeName: 'Wander Store',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      price: '£ 250.00',
      status: OrderStatus.completed,
      placedDate: '24th July, 2022',
    ),
    OrderItemModel(
      id: '8',
      productImagePath: AssetRes.reel2,
      productName: 'Product 01 From',
      storeName: 'Wander Store',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      price: '£ 250.00',
      status: OrderStatus.completed,
      placedDate: '24th July, 2022',
    ),
    OrderItemModel(
      id: '9',
      productImagePath: AssetRes.reel3,
      productName: 'Product 01 From',
      storeName: 'Wander Store',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      price: '£ 250.00',
      status: OrderStatus.rejected,
      placedDate: '24th July, 2022',
      isReimbursed: true,
    ),
    OrderItemModel(
      id: '10',
      productImagePath: AssetRes.reel4,
      productName: 'Product 01 From',
      storeName: 'Wander Store',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      price: '£ 250.00',
      status: OrderStatus.rejected,
      placedDate: '24th July, 2022',
      isReimbursed: true,
    ),
  ];
}
