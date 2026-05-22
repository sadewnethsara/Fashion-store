import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> saveUserProfile(UserModel user) {
    return _db.collection(AppConstants.usersCollection).doc(user.id).set(
          user.toJson(),
          SetOptions(merge: true),
        );
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromJson({...doc.data()!, 'id': uid});
  }

  // ── Cart (persisted on user document) ───────────────────────────────────

  Future<List<CartItemModel>> loadCart(String userId) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(userId).get();
    if (!doc.exists || doc.data() == null) return [];
    final raw = doc.data()![AppConstants.userCartField];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e)))
        .where((item) => item.productId.isNotEmpty)
        .toList();
  }

  Future<void> saveCart(String userId, List<CartItemModel> items) {
    return _db.collection(AppConstants.usersCollection).doc(userId).set(
          {AppConstants.userCartField: items.map((e) => e.toJson()).toList()},
          SetOptions(merge: true),
        );
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<void> saveOrder(OrderModel order) async {
    await _db
        .collection(AppConstants.ordersCollection)
        .doc(order.orderId)
        .set(order.toJson());
  }

  Future<List<OrderModel>> fetchOrdersForUser(String userId) async {
    final snapshot = await _db
        .collection(AppConstants.ordersCollection)
        .where('userId', isEqualTo: userId)
        .get();
    final orders = snapshot.docs
        .map((doc) => OrderModel.fromJson({...doc.data(), 'orderId': doc.id}))
        .toList();
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  // ── Categories ──────────────────────────────────────────────────────────

  Future<List<CategoryModel>> fetchCategories() async {
    final snapshot =
        await _db.collection(AppConstants.categoriesCollection).get();
    final list = snapshot.docs.map((doc) {
      final data = doc.data();
      return CategoryModel.fromJson({
        ...data,
        'id': data['id'] ?? doc.id,
      });
    }).toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<void> seedCategories(List<CategoryModel> categories) async {
    final batch = _db.batch();
    for (final cat in categories) {
      final ref =
          _db.collection(AppConstants.categoriesCollection).doc(cat.id);
      batch.set(ref, cat.toJson());
    }
    await batch.commit();
  }

  Future<void> addCategory(String name) async {
    final docRef = _db.collection(AppConstants.categoriesCollection).doc();
    final cat = CategoryModel(id: docRef.id, name: name.trim());
    await docRef.set(cat.toJson());
  }

  Future<void> updateCategory(CategoryModel category, String newName) async {
    final trimmed = newName.trim();
    await _db
        .collection(AppConstants.categoriesCollection)
        .doc(category.id)
        .update({'name': trimmed, 'id': category.id});

    final products = await _db
        .collection(AppConstants.productsCollection)
        .where('category', isEqualTo: category.name)
        .get();
    final batch = _db.batch();
    for (final doc in products.docs) {
      batch.update(doc.reference, {'category': trimmed});
    }
    await batch.commit();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db
        .collection(AppConstants.categoriesCollection)
        .doc(categoryId)
        .delete();
  }

  Future<int> countProductsInCategory(String categoryName) async {
    final snapshot = await _db
        .collection(AppConstants.productsCollection)
        .where('category', isEqualTo: categoryName)
        .get();
    return snapshot.docs.length;
  }

  // ── Products ──────────────────────────────────────────────────────────────

  Future<List<ProductModel>> fetchProducts() async {
    final snapshot =
        await _db.collection(AppConstants.productsCollection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ProductModel.fromJson({
        ...data,
        'id': data['id'] ?? doc.id,
      });
    }).toList();
  }

  Future<void> addProduct(ProductModel product) async {
    final docRef = _db.collection(AppConstants.productsCollection).doc();
    final productWithId = ProductModel(
      id: docRef.id,
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.category,
      imageUrl: product.imageUrl,
    );
    await docRef.set(productWithId.toJson());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db
        .collection(AppConstants.productsCollection)
        .doc(product.id)
        .set(product.toJson());
  }

  Future<void> deleteProduct(String productId) async {
    await _db
        .collection(AppConstants.productsCollection)
        .doc(productId)
        .delete();
  }

  Future<void> seedProducts(List<ProductModel> products) async {
    final batch = _db.batch();
    for (final product in products) {
      final ref =
          _db.collection(AppConstants.productsCollection).doc(product.id);
      batch.set(ref, product.toJson());
    }
    await batch.commit();
  }
}
