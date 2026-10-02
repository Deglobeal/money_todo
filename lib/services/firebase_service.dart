import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_todo/models/category.dart';
import 'package:money_todo/models/task.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? get currentUser => _auth.currentUser;
  String get userId => currentUser?.uid ?? 'anonymous';

  Future<void> initialize() async {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    if (currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  CollectionReference<Map<String, dynamic>> get _tasksCollection => 
      _firestore.collection('users').doc(userId).collection('tasks');

  CollectionReference<Map<String, dynamic>> get _categoriesCollection => 
      _firestore.collection('users').doc(userId).collection('categories');

  // Tasks
  Stream<List<Task>> get tasksStream => 
      _tasksCollection
          .orderBy('updatedAt', descending: true)
          .snapshots(includeMetadataChanges: true)
          .map((snapshot) => 
              snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList());

  Future<void> addTask(Task task) async {
    await _tasksCollection.doc(task.id).set(task.toJson());
  }

  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  Future<void> toggleComplete(String taskId, bool completed) async {
    await _tasksCollection.doc(taskId).update({
      'completed': completed,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Categories
  Stream<List<TaskCategory>> get categoriesStream =>
      _categoriesCollection
          .orderBy('name')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => TaskCategory.fromJson(doc.data())).toList());

  Future<void> addCategory(TaskCategory category) async {
    await _categoriesCollection.doc(category.id).set(category.toJson());
  }

  Future<void> updateCategory(TaskCategory category) async {
    await _categoriesCollection.doc(category.id).update(category.toJson());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoriesCollection.doc(categoryId).delete();
    // Optionally: remove categoryId from all tasks
    final tasks = await _tasksCollection.where('categoryId', isEqualTo: categoryId).get();
    final batch = _firestore.batch();
    for (var doc in tasks.docs) {
      batch.update(doc.reference, {'categoryId': null, 'updatedAt': DateTime.now().toIso8601String()});
    }
    await batch.commit();
  }
}