import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product/product.dart';
import '../models/product/product_category.dart';
import '../services/product_service.dart';

// 创建ProductService的provider
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// 商品列表状态管理
final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  () => ProductsNotifier(),
);

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  late final ProductService _productService;

  @override
  Future<List<Product>> build() async {
    _productService = ref.read(productServiceProvider);
    return await _productService.getProducts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _productService.getProducts();
    });
  }

  Future<void> fetchProducts({Map<String, dynamic>? params}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _productService.getProducts(params: params);
    });
  }

  Future<void> searchProducts(String keyword, {Map<String, dynamic>? params}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _productService.searchProducts(keyword, params: params);
    });
  }

  Future<void> createProduct(Map<String, dynamic> productData) async {
    state = await AsyncValue.guard(() async {
      final newProduct = await _productService.createProduct(productData);
      final currentProducts = state.value ?? [];
      return [...currentProducts, newProduct];
    });
  }

  Future<void> addProduct(Product product) async {
    state = await AsyncValue.guard(() async {
      final currentProducts = state.value ?? [];
      return [...currentProducts, product];
    });
  }

  Future<void> updateProduct(int id, Map<String, dynamic> productData) async {
    state = await AsyncValue.guard(() async {
      final updatedProduct = await _productService.updateProduct(id, productData);
      final currentProducts = state.value ?? [];
      return currentProducts
          .map((product) => product.id == id ? updatedProduct : product)
          .toList();
    });
  }

  Future<void> updateProductDirect(Product product) async {
    state = await AsyncValue.guard(() async {
      final currentProducts = state.value ?? [];
      return currentProducts
          .map((p) => p.id == product.id ? product : p)
          .toList();
    });
  }

  Future<void> withdrawProduct(int id) async {
    state = await AsyncValue.guard(() async {
      final currentProducts = state.value ?? [];
      return currentProducts
          .map((product) => product.id == id 
              ? Product(
                  id: product.id,
                  name: product.name,
                  code: product.code,
                  specification: product.specification,
                  model: product.model,
                  unit: product.unit,
                  price: product.price,
                  costPrice: product.costPrice,
                  originalPrice: product.originalPrice,
                  stock: product.stock,
                  safetyStock: product.safetyStock,
                  categoryId: product.categoryId,
                  brand: product.brand,
                  manufacturer: product.manufacturer,
                  supplierId: product.supplierId,
                  barcode: product.barcode,
                  imageUrl: product.imageUrl,
                  description: product.description,
                  status: 'WITHDRAWN',
                  createdAt: product.createdAt,
                  updatedAt: DateTime.now(),
                  salespersonId: product.salespersonId,
                  salespersonName: product.salespersonName,
                  companyName: product.companyName,
                  categoryName: product.categoryName,
                  weight: product.weight,
                  dimensions: product.dimensions,
                  railwayBureau: product.railwayBureau,
                  station: product.station,
                  customer: product.customer,
                  actualName: product.actualName,
                  actualModel: product.actualModel,
                  purchasePrice: product.purchasePrice,
                  supplierName: product.supplierName,
                  imageUrls: product.imageUrls,
                  note: product.note,
                  mainImageUrls: product.mainImageUrls,
                  detailImageUrl: product.detailImageUrl,
                  barcode69: product.barcode69,
                  externalLink: product.externalLink,
                  approvalUserId: product.approvalUserId,
                  approvalUserName: product.approvalUserName,
                  approvalTime: product.approvalTime,
                  approvalComment: product.approvalComment,
                  isSynced: product.isSynced,
                )
              : product)
          .toList();
    });
  }

  Future<void> deleteProduct(int id) async {
    state = await AsyncValue.guard(() async {
      await _productService.deleteProduct(id);
      final currentProducts = state.value ?? [];
      return currentProducts
          .where((product) => product.id != id)
          .toList();
    });
  }

  Future<void> batchDeleteProducts(List<int> ids) async {
    state = await AsyncValue.guard(() async {
      await _productService.batchDeleteProducts(ids);
      final currentProducts = state.value ?? [];
      return currentProducts
          .where((product) => !ids.contains(product.id))
          .toList();
    });
  }
}

// 商品分类状态管理
final productCategoriesProvider = AsyncNotifierProvider<ProductCategoriesNotifier, List<ProductCategory>>(
  () => ProductCategoriesNotifier(),
);

class ProductCategoriesNotifier extends AsyncNotifier<List<ProductCategory>> {
  late final ProductService _productService;

  @override
  Future<List<ProductCategory>> build() async {
    _productService = ref.read(productServiceProvider);
    return await _productService.getProductCategories();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _productService.getProductCategories();
    });
  }

  Future<List<ProductCategory>> fetchCategoryTree() async {
    try {
      return await _productService.getProductCategoryTree();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> createCategory(Map<String, dynamic> categoryData) async {
    state = await AsyncValue.guard(() async {
      final newCategory = await _productService.createProductCategory(categoryData);
      final currentCategories = state.value ?? [];
      return [...currentCategories, newCategory];
    });
  }

  Future<void> updateCategory(int id, Map<String, dynamic> categoryData) async {
    state = await AsyncValue.guard(() async {
      final updatedCategory = await _productService.updateProductCategory(id, categoryData);
      final currentCategories = state.value ?? [];
      return currentCategories
          .map((category) => category.id == id ? updatedCategory : category)
          .toList();
    });
  }

  Future<void> deleteCategory(int id) async {
    state = await AsyncValue.guard(() async {
      await _productService.deleteProductCategory(id);
      final currentCategories = state.value ?? [];
      return currentCategories
          .where((category) => category.id != id)
          .toList();
    });
  }
}

// 单个商品状态管理
final productProvider = AsyncNotifierProviderFamily<ProductNotifier, Product, int>(
  () => ProductNotifier(),
);

class ProductNotifier extends FamilyAsyncNotifier<Product, int> {
  late final ProductService _productService;

  @override
  Future<Product> build(int productId) async {
    _productService = ref.read(productServiceProvider);
    return await _productService.getProductById(productId);
  }

  Future<void> fetchProduct() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _productService.getProductById(arg);
    });
  }

  Future<void> updateProduct(Map<String, dynamic> productData) async {
    state = await AsyncValue.guard(() async {
      return await _productService.updateProduct(arg, productData);
    });
  }
}