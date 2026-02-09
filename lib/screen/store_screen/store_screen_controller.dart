import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';

class StoreCategory {
  final String id;
  final String name;
  final String imagePath; // asset path for category icon image

  StoreCategory({required this.id, required this.name, required this.imagePath});
}

class StoreProduct {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? imagePath; // asset path for product image
  final double rating;
  final String? price; // e.g. "\$299"
  final String? detailDescription; // long description for detail screen
  final List<String>? thumbnailPaths; // optional list of asset paths for thumbnails

  StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.imagePath,
    this.rating = 4.9,
    this.price,
    this.detailDescription,
    this.thumbnailPaths,
  });
}

class StoreScreenController extends BaseController {
  RxInt notificationCount = 15.obs;
  RxInt cartCount = 2.obs;

  final List<StoreCategory> categories = [
    StoreCategory(id: '1', name: 'Cosmetics', imagePath: AssetRes.categoryCosmetics),
    StoreCategory(id: '2', name: 'Toys', imagePath: AssetRes.categoryToys),
    StoreCategory(id: '3', name: 'Clothing', imagePath: AssetRes.categoryClothing),
    StoreCategory(id: '4', name: 'Tech', imagePath: AssetRes.categoryTech),
    StoreCategory(id: '5', name: 'Skincare', imagePath: AssetRes.categorySkincare),
    StoreCategory(id: '6', name: 'Photography', imagePath: AssetRes.categoryPhotography),
  ];

  final List<StoreProduct> productsForYou = [
    StoreProduct(
      id: '1',
      title: 'Classic Retro Film Camera',
      description: 'Capture timeless moments with vintage charm and modern quality.',
      imagePath: AssetRes.camera4,
      rating: 4.5,
      price: '\$299',
      detailDescription: null, // use LKey.productDetailDescription for camera
      thumbnailPaths: [AssetRes.camera4, AssetRes.camera2, AssetRes.camera3, AssetRes.camera1],
    ),
    StoreProduct(
      id: '2',
      title: 'Floral Midi Dress',
      description: 'Vibrant mustard yellow with delicate floral pattern, puff sleeves and tie waist.',
      imagePath: AssetRes.product2,
      rating: 4.8,
      price: '\$89',
      thumbnailPaths: [AssetRes.product2, AssetRes.product2, AssetRes.product2, AssetRes.product2],
    ),
    StoreProduct(
      id: '3',
      title: 'Skincare Essentials Set',
      description: 'Clean, natural formulas in minimalist packaging for your daily routine.',
      imagePath: AssetRes.product3,
      rating: 4.7,
      price: '\$45',
      thumbnailPaths: [AssetRes.product3, AssetRes.product3, AssetRes.product3, AssetRes.product3],
    ),
  ];

  final List<StoreProduct> topSelling = [
    StoreProduct(
      id: 't1',
      title: 'Next-Gen Earbuds',
      description: 'High-Quality Audio, Long Battery....',
      imagePath: AssetRes.product1,
      rating: 4.8,
      price: '\$129',
    ),
    StoreProduct(
      id: 't2',
      title: 'Retro Film Camera',
      description: 'This Old Retro Camera Brings Ti....',
      imagePath: AssetRes.camera4,
      rating: 4.8,
      price: '\$299',
    ),
    StoreProduct(
      id: 't3',
      title: 'Skin Care',
      description: 'A Powerful Serum....',
      imagePath: AssetRes.product3,
      rating: 4.8,
      price: '\$45',
    ),
  ];
}
