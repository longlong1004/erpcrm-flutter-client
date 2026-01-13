import '../models/product/product.dart';
import '../models/product/product_category.dart';
import '../utils/http_client.dart';
import './network_service.dart';
import './local_storage_service.dart';
import './sync_service.dart';
import '../models/sync/sync_operation.dart';

class ProductService {
  final NetworkService _networkService;
  final LocalStorageService _localStorageService;
  final SyncService _syncService;

  ProductService() : 
    _networkService = NetworkService(),
    _localStorageService = LocalStorageService(),
    _syncService = SyncService();

  ProductService.withDependencies({
    required NetworkService networkService,
    required LocalStorageService localStorageService,
    SyncService? syncService,
  }) : 
    _networkService = networkService,
    _localStorageService = localStorageService,
    _syncService = syncService ?? SyncService();

  // 商品相关API - 离线优先策略
  Future<List<Product>> getProducts({Map<String, dynamic>? params}) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，合并本地存储，更新本地存储，返回数据
        try {
          final response = await HttpClient.get('/products', queryParameters: params);
          final productsJson = response.data['data'] as List;
          final apiProducts = productsJson.map((json) => Product.fromJson(json)).toList();
          
          // 获取本地存储的所有商品
          final localProducts = await _localStorageService.getProducts();
          
          // 合并商品：保留API返回的商品，同时添加本地新增但API中没有的商品
          final mergedProducts = <Product>[];
          final apiProductIds = apiProducts.map((product) => product.id).toSet();
          
          // 添加API返回的所有商品
          mergedProducts.addAll(apiProducts);
          
          // 添加本地新增但API中没有的商品（通常是离线创建的商品）
          for (final localProduct in localProducts) {
            if (!apiProductIds.contains(localProduct.id)) {
              mergedProducts.add(localProduct);
            }
          }
          
          // 更新本地存储
          await _localStorageService.saveProducts(mergedProducts);
          return mergedProducts;
        } catch (apiError) {
          // API请求失败，使用示例数据
          print('API请求失败，使用示例数据: $apiError');
          final sampleProducts = _generateSampleProducts();
          await _localStorageService.saveProducts(sampleProducts);
          return sampleProducts;
        }
      } else {
        // 离线：从本地存储获取数据
        final localProducts = await _localStorageService.getProducts();
        if (localProducts.isEmpty) {
          // 本地存储为空，生成示例数据
          final sampleProducts = _generateSampleProducts();
          await _localStorageService.saveProducts(sampleProducts);
          return sampleProducts;
        }
        return localProducts;
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        final localProducts = await _localStorageService.getProducts();
        if (localProducts.isEmpty) {
          // 本地存储为空，生成示例数据
          final sampleProducts = _generateSampleProducts();
          await _localStorageService.saveProducts(sampleProducts);
          return sampleProducts;
        }
        return localProducts;
      } catch (localError) {
        // 本地存储也失败，直接返回示例数据
        print('本地存储失败，使用示例数据: $localError');
        return _generateSampleProducts();
      }
    }
  }

  // 生成示例商品数据
  List<Product> _generateSampleProducts() {
    final now = DateTime.now();
    return [
      Product(
        id: 1,
        name: '【商品示例1】铁路信号设备',
        code: 'PRODUCT-SAMPLE-001',
        specification: '【商品示例1】型号RX-2024，适用于铁路信号系统，示例数据',
        model: 'RX-2024',
        unit: '套',
        price: 15000.00,
        costPrice: 12000.00,
        originalPrice: 15000.00,
        stock: 25,
        safetyStock: 5,
        categoryId: 1,
        brand: '中国铁路',
        manufacturer: '北京铁路器材厂',
        supplierId: 1,
        barcode: '6901234567890',
        imageUrl: null,
        description: '【商品示例1】铁路信号设备，用于铁路信号系统的控制和监测，示例数据',
        status: 'ACTIVE',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        salespersonId: 1,
        salespersonName: '王五',
        companyName: '北京铁路物资有限公司',
        categoryName: '铁路设备',
        weight: 25.5,
        dimensions: '50cm x 40cm x 30cm',
        railwayBureau: '北京局',
        station: '北京站',
        customer: '北京铁路局',
        actualName: '铁路信号设备',
        actualModel: 'RX-2024',
        purchasePrice: 12000.00,
        supplierName: '北京铁路器材厂',
        imageUrls: [],
        note: '【商品示例1】这是一个示例产品，用于演示商品表单功能，示例数据',
        mainImageUrls: [],
        detailImageUrl: null,
        barcode69: '6901234567890',
        externalLink: 'https://www.example.com/products/product-sample-001',
        isSynced: true,
      ),
      Product(
        id: 2,
        name: '【商品示例2】铁路轨道扣件',
        code: 'PRODUCT-SAMPLE-002',
        specification: '【商品示例2】型号GK-2024，适用于标准铁路轨道，示例数据',
        model: 'GK-2024',
        unit: '套',
        price: 800.00,
        costPrice: 600.00,
        originalPrice: 800.00,
        stock: 150,
        safetyStock: 20,
        categoryId: 2,
        brand: '中国铁路',
        manufacturer: '上海铁路配件厂',
        supplierId: 2,
        barcode: '6901234567891',
        imageUrl: null,
        description: '【商品示例2】铁路轨道扣件，用于固定铁路轨道和钢轨，示例数据',
        status: 'ACTIVE',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now,
        salespersonId: 1,
        salespersonName: '王五',
        companyName: '北京铁路物资有限公司',
        categoryName: '铁路配件',
        weight: 12.0,
        dimensions: '20cm x 15cm x 10cm',
        railwayBureau: '上海局',
        station: '上海站',
        customer: '上海铁路局',
        actualName: '铁路轨道扣件',
        actualModel: 'GK-2024',
        purchasePrice: 600.00,
        supplierName: '上海铁路配件厂',
        imageUrls: [],
        note: '【商品示例2】铁路轨道扣件，用于固定铁路轨道和钢轨，示例数据',
        mainImageUrls: [],
        detailImageUrl: null,
        barcode69: '6901234567891',
        externalLink: 'https://www.example.com/products/product-sample-002',
        isSynced: true,
      ),
      Product(
        id: 3,
        name: '【商品示例3】铁路通信设备',
        code: 'PRODUCT-SAMPLE-003',
        specification: '【商品示例3】型号TX-2024，适用于铁路通信系统，示例数据',
        model: 'TX-2024',
        unit: '套',
        price: 25000.00,
        costPrice: 20000.00,
        originalPrice: 25000.00,
        stock: 0,
        safetyStock: 3,
        categoryId: 1,
        brand: '中国铁路',
        manufacturer: '广州铁路通信设备厂',
        supplierId: 3,
        barcode: '6901234567892',
        imageUrl: null,
        description: '【商品示例3】铁路通信设备，用于铁路通信系统的传输和交换，示例数据',
        status: 'OUT_OF_STOCK',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
        salespersonId: 1,
        salespersonName: '王五',
        companyName: '北京铁路物资有限公司',
        categoryName: '铁路设备',
        weight: 35.0,
        dimensions: '60cm x 50cm x 40cm',
        railwayBureau: '广州局',
        station: '广州站',
        customer: '广州铁路局',
        actualName: '铁路通信设备',
        actualModel: 'TX-2024',
        purchasePrice: 20000.00,
        supplierName: '广州铁路通信设备厂',
        imageUrls: [],
        note: '【商品示例3】铁路通信设备，用于铁路通信系统的传输和交换，示例数据',
        mainImageUrls: [],
        detailImageUrl: null,
        barcode69: '6901234567892',
        externalLink: 'https://www.example.com/products/product-sample-003',
        isSynced: true,
      ),
      Product(
        id: 4,
        name: '【商品示例4】铁路照明设备',
        code: 'PRODUCT-SAMPLE-004',
        specification: '【商品示例4】型号ZM-2024，适用于铁路站台和隧道照明，示例数据',
        model: 'ZM-2024',
        unit: '套',
        price: 5000.00,
        costPrice: 4000.00,
        originalPrice: 5000.00,
        stock: 80,
        safetyStock: 10,
        categoryId: 1,
        brand: '中国铁路',
        manufacturer: '成都铁路照明设备厂',
        supplierId: 4,
        barcode: '6901234567893',
        imageUrl: null,
        description: '【商品示例4】铁路照明设备，用于铁路站台和隧道的照明，示例数据',
        status: 'ACTIVE',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
        salespersonId: 1,
        salespersonName: '王五',
        companyName: '北京铁路物资有限公司',
        categoryName: '铁路设备',
        weight: 18.0,
        dimensions: '30cm x 30cm x 25cm',
        railwayBureau: '成都局',
        station: '成都站',
        customer: '成都铁路局',
        actualName: '铁路照明设备',
        actualModel: 'ZM-2024',
        purchasePrice: 4000.00,
        supplierName: '成都铁路照明设备厂',
        imageUrls: [],
        note: '【商品示例4】铁路照明设备，用于铁路站台和隧道的照明，示例数据',
        mainImageUrls: [],
        detailImageUrl: null,
        barcode69: '6901234567893',
        externalLink: 'https://www.example.com/products/product-sample-004',
        isSynced: true,
      ),
      Product(
        id: 5,
        name: '【商品示例5】铁路电力设备',
        code: 'PRODUCT-SAMPLE-005',
        specification: '【商品示例5】型号DL-2024，适用于铁路电力系统，示例数据',
        model: 'DL-2024',
        unit: '套',
        price: 30000.00,
        costPrice: 24000.00,
        originalPrice: 30000.00,
        stock: 10,
        safetyStock: 2,
        categoryId: 1,
        brand: '中国铁路',
        manufacturer: '武汉铁路电力设备厂',
        supplierId: 5,
        barcode: '6901234567894',
        imageUrl: null,
        description: '【商品示例5】铁路电力设备，用于铁路电力系统的配电和控制，示例数据',
        status: 'INACTIVE',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
        salespersonId: 1,
        salespersonName: '王五',
        companyName: '北京铁路物资有限公司',
        categoryName: '铁路设备',
        weight: 45.0,
        dimensions: '70cm x 60cm x 50cm',
        railwayBureau: '武汉局',
        station: '武汉站',
        customer: '武汉铁路局',
        actualName: '铁路电力设备',
        actualModel: 'DL-2024',
        purchasePrice: 24000.00,
        supplierName: '武汉铁路电力设备厂',
        imageUrls: [],
        note: '【商品示例5】铁路电力设备，用于铁路电力系统的配电和控制，示例数据',
        mainImageUrls: [],
        detailImageUrl: null,
        barcode69: '6901234567894',
        externalLink: 'https://www.example.com/products/product-sample-005',
        isSynced: true,
      ),
    ];
  }

  Future<Product> getProductById(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，更新本地存储，返回数据
        final response = await HttpClient.get('/products/$id');
        final product = Product.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveProducts([product]);
        return product;
      } else {
        // 离线：从本地存储获取数据
        final product = await _localStorageService.getProductById(id);
        if (product == null) {
          throw Exception('商品不存在');
        }
        return product;
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储获取数据
      try {
        final product = await _localStorageService.getProductById(id);
        if (product == null) {
          throw Exception('商品不存在');
        }
        return product;
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.post('/products', data: productData);
        final product = Product.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveProducts([product]);
        return product;
      } else {
        // 离线：保存到本地存储，添加到同步队列，返回创建的产品
        // 注意：离线创建时需要生成临时ID，同步时替换
        final tempId = DateTime.now().millisecondsSinceEpoch;
        final product = Product(
          id: tempId, // 临时ID
          name: productData['name'],
          code: productData['code'],
          specification: productData['specification'],
          model: productData['model'],
          unit: productData['unit'],
          price: productData['price'],
          costPrice: productData['costPrice'],
          originalPrice: productData['originalPrice'],
          stock: productData['stock'],
          safetyStock: productData['safetyStock'],
          categoryId: productData['categoryId'],
          brand: productData['brand'],
          manufacturer: productData['manufacturer'],
          supplierId: productData['supplierId'],
          barcode: productData['barcode'],
          imageUrl: productData['imageUrl'],
          description: productData['description'],
          status: productData['status'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // 保存到本地存储
        await _localStorageService.saveProducts([product]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: tempId,
          operationType: SyncOperationType.create,
          dataType: 'product',
          data: productData,
          timestamp: DateTime.now(),
          tempId: tempId,
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return product;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> productData) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        final response = await HttpClient.put('/products/$id', data: productData);
        final product = Product.fromJson(response.data['data']);
        
        // 更新本地存储
        await _localStorageService.saveProducts([product]);
        return product;
      } else {
        // 离线：从本地存储获取产品，更新后保存，添加到同步队列
        final existingProduct = await _localStorageService.getProductById(id);
        if (existingProduct == null) {
          throw Exception('商品不存在');
        }
        
        final updatedProduct = Product(
          id: existingProduct.id,
          name: productData['name'] ?? existingProduct.name,
          code: productData['code'] ?? existingProduct.code,
          specification: productData['specification'] ?? existingProduct.specification,
          model: productData['model'] ?? existingProduct.model,
          unit: productData['unit'] ?? existingProduct.unit,
          price: productData['price'] ?? existingProduct.price,
          costPrice: productData['costPrice'] ?? existingProduct.costPrice,
          originalPrice: productData['originalPrice'] ?? existingProduct.originalPrice,
          stock: productData['stock'] ?? existingProduct.stock,
          safetyStock: productData['safetyStock'] ?? existingProduct.safetyStock,
          categoryId: productData['categoryId'] ?? existingProduct.categoryId,
          brand: productData['brand'] ?? existingProduct.brand,
          manufacturer: productData['manufacturer'] ?? existingProduct.manufacturer,
          supplierId: productData['supplierId'] ?? existingProduct.supplierId,
          barcode: productData['barcode'] ?? existingProduct.barcode,
          imageUrl: productData['imageUrl'] ?? existingProduct.imageUrl,
          description: productData['description'] ?? existingProduct.description,
          status: productData['status'] ?? existingProduct.status,
          createdAt: existingProduct.createdAt,
          updatedAt: DateTime.now(),
        );
        
        // 保存到本地存储
        await _localStorageService.saveProducts([updatedProduct]);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.update,
          dataType: 'product',
          data: productData,
          timestamp: DateTime.now(),
          tempId: id, // 使用实际ID作为tempId
        );
        await _syncService.addSyncOperation(syncOperation);
        
        return updatedProduct;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/products/$id');
        
        // 更新本地存储
        await _localStorageService.deleteProduct(id);
      } else {
        // 离线：直接从本地存储删除，添加到同步队列
        await _localStorageService.deleteProduct(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'product',
          data: {'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储删除
      try {
        await _localStorageService.deleteProduct(id);
        
        // 添加到同步队列
        final syncOperation = SyncOperation(
          id: DateTime.now().millisecondsSinceEpoch,
          operationType: SyncOperationType.delete,
          dataType: 'product',
          data: {'id': id},
          timestamp: DateTime.now(),
          tempId: id,
        );
        await _syncService.addSyncOperation(syncOperation);
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<void> batchDeleteProducts(List<int> ids) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：先调用API，再更新本地存储
        await HttpClient.delete('/products/batch', data: {'ids': ids});
        
        // 更新本地存储
        for (final id in ids) {
          await _localStorageService.deleteProduct(id);
        }
      } else {
        // 离线：直接从本地存储删除，逐个添加到同步队列
        for (final id in ids) {
          await _localStorageService.deleteProduct(id);
          
          // 添加到同步队列
          final syncOperation = SyncOperation(
            id: DateTime.now().millisecondsSinceEpoch,
            operationType: SyncOperationType.delete,
            dataType: 'product',
            data: {'id': id},
            timestamp: DateTime.now(),
            tempId: id,
          );
          await _syncService.addSyncOperation(syncOperation);
        }
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储删除
      try {
        for (final id in ids) {
          await _localStorageService.deleteProduct(id);
          
          // 添加到同步队列
          final syncOperation = SyncOperation(
            id: DateTime.now().millisecondsSinceEpoch,
            operationType: SyncOperationType.delete,
            dataType: 'product',
            data: {'id': id},
            timestamp: DateTime.now(),
            tempId: id,
          );
          await _syncService.addSyncOperation(syncOperation);
        }
      } catch (localError) {
        rethrow;
      }
    }
  }

  Future<List<Product>> searchProducts(String keyword, {Map<String, dynamic>? params}) async {
    try {
      final isConnected = await _networkService.isConnected();
      
      if (isConnected) {
        // 在线：从API获取数据，返回结果
        final queryParams = {
          'keyword': keyword,
          ...?params,
        };
        final response = await HttpClient.get('/products/search', queryParameters: queryParams);
        final productsJson = response.data['data'] as List;
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        // 离线：从本地存储搜索
        final allProducts = await _localStorageService.getProducts();
        return allProducts.where((product) => 
          product.name.contains(keyword) || 
          product.code.contains(keyword) ||
          product.specification.contains(keyword)
        ).toList();
      }
    } catch (error) {
      // 网络请求失败，尝试从本地存储搜索
      try {
        final allProducts = await _localStorageService.getProducts();
        return allProducts.where((product) => 
          product.name.contains(keyword) || 
          product.code.contains(keyword) ||
          product.specification.contains(keyword)
        ).toList();
      } catch (localError) {
        rethrow;
      }
    }
  }

  // 商品分类相关API
  Future<List<ProductCategory>> getProductCategories() async {
    try {
      final response = await HttpClient.get('/product-categories');
      final categoriesJson = response.data['data'] as List;
      return categoriesJson.map((json) => ProductCategory.fromJson(json)).toList();
    } catch (error) {
      rethrow;
    }
  }

  Future<ProductCategory> getProductCategoryById(int id) async {
    try {
      final response = await HttpClient.get('/product-categories/$id');
      return ProductCategory.fromJson(response.data['data']);
    } catch (error) {
      rethrow;
    }
  }

  Future<ProductCategory> createProductCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await HttpClient.post('/product-categories', data: categoryData);
      return ProductCategory.fromJson(response.data['data']);
    } catch (error) {
      rethrow;
    }
  }

  Future<ProductCategory> updateProductCategory(int id, Map<String, dynamic> categoryData) async {
    try {
      final response = await HttpClient.put('/product-categories/$id', data: categoryData);
      return ProductCategory.fromJson(response.data['data']);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteProductCategory(int id) async {
    try {
      await HttpClient.delete('/product-categories/$id');
    } catch (error) {
      rethrow;
    }
  }

  Future<List<ProductCategory>> getProductCategoryTree() async {
    try {
      final response = await HttpClient.get('/product-categories/tree');
      final categoriesJson = response.data['data'] as List;
      return categoriesJson.map((json) => ProductCategory.fromJson(json)).toList();
    } catch (error) {
      rethrow;
    }
  }
}
