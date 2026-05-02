import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:stockflow_flutter_pro/models/app_state_bundle.dart';
import 'package:stockflow_flutter_pro/models/inventory_item.dart';
import 'package:stockflow_flutter_pro/models/store_submission.dart';
import 'package:stockflow_flutter_pro/models/user_account.dart';
import 'package:stockflow_flutter_pro/services/app_storage_service.dart';

class ReorderRow {
  ReorderRow({
    required this.item,
    required this.totalDemand,
    required this.suggestedOrder,
  });

  final InventoryItem item;
  final int totalDemand;
  final int suggestedOrder;
}

class AppController extends ChangeNotifier {
  AppController(this._storage);

  final AppStorageService _storage;

  AppStateBundle? _bundle;
  UserAccount? _currentUser;
  bool _isReady = false;
  bool _isBusy = false;
  String? _error;

  bool get isReady => _isReady;
  bool get isBusy => _isBusy;
  String? get error => _error;
  UserAccount? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isStore => _currentUser?.isStore ?? false;
  List<UserAccount> get accounts => List.unmodifiable(_bundle?.accounts ?? []);
  List<UserAccount> get storeAccounts =>
      accounts.where((account) => account.isStore).toList(growable: false);
  List<InventoryItem> get items => List.unmodifiable(_bundle?.items ?? []);
  List<StoreSubmission> get submissions =>
      [...?_bundle?.submissions]
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

  Future<void> initialize() async {
    try {
      _isBusy = true;
      notifyListeners();
      _bundle = await _storage.loadBundle() ?? await _loadSeedBundle();
      await _storage.saveBundle(_bundle!);
      final persistedUser = await _storage.loadCurrentUser();
      if (persistedUser != null) {
        _currentUser = _bundle!.accounts
            .where((user) => user.username == persistedUser.username)
            .firstOrNull;
      }
      _error = null;
    } catch (e) {
      _error = '初始化失敗：$e';
    } finally {
      _isBusy = false;
      _isReady = true;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    final matched = accounts
        .where(
          (account) =>
              account.username == username && account.password == password,
        )
        .firstOrNull;
    if (matched == null) {
      _error = '帳號或密碼錯誤';
      notifyListeners();
      return false;
    }
    _currentUser = matched;
    _error = null;
    await _storage.saveCurrentUser(matched);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.clearCurrentUser();
    notifyListeners();
  }

  Future<void> addStoreAccount({
    required String displayName,
    required String username,
    required String password,
    required String storeCode,
  }) async {
    final exists = accounts.any((account) => account.username == username);
    if (exists) {
      throw Exception('帳號已存在，請換一個使用者名稱');
    }
    final next = [
      ...accounts,
      UserAccount(
        id: _newId('acc'),
        username: username,
        password: password,
        role: 'store',
        displayName: displayName,
        storeCode: storeCode,
      ),
    ];
    await _saveBundle(_bundle!.copyWith(accounts: next));
  }

  Future<void> upsertItem(InventoryItem item) async {
    final existingIndex = items.indexWhere((element) => element.id == item.id);
    final nextItems = [...items];
    if (existingIndex == -1) {
      nextItems.add(item);
    } else {
      nextItems[existingIndex] = item;
    }
    await _saveBundle(_bundle!.copyWith(items: nextItems));
  }

  Future<void> deleteItem(String id) async {
    final nextItems = items.where((item) => item.id != id).toList();
    final nextSubmissions = submissions
        .map(
          (submission) => StoreSubmission(
            id: submission.id,
            storeUsername: submission.storeUsername,
            note: submission.note,
            submittedAt: submission.submittedAt,
            entries: submission.entries
                .where((entry) => entry.itemId != id)
                .toList(),
          ),
        )
        .toList();
    await _saveBundle(
      _bundle!.copyWith(items: nextItems, submissions: nextSubmissions),
    );
  }

  Future<void> submitStoreRequest({
    required Map<String, int> quantities,
    required String note,
  }) async {
    if (_currentUser == null) {
      throw Exception('尚未登入');
    }
    final submission = StoreSubmission(
      id: _newId('sub'),
      storeUsername: _currentUser!.username,
      note: note,
      submittedAt: DateTime.now(),
      entries: quantities.entries
          .map(
            (entry) =>
                SubmissionEntry(itemId: entry.key, quantity: entry.value),
          )
          .toList(),
    );
    await _saveBundle(
      _bundle!.copyWith(submissions: [...submissions, submission]),
    );
  }

  Future<void> resetToSeed() async {
    final seed = await _loadSeedBundle();
    await _saveBundle(seed);
  }

  List<ReorderRow> get reorderRows {
    return items.map((item) {
      final demand = submissions.fold<int>(0, (sum, submission) {
        final matched = submission.entries
            .where((entry) => entry.itemId == item.id)
            .firstOrNull;
        return sum + (matched?.quantity ?? 0);
      });
      return ReorderRow(
        item: item,
        totalDemand: demand,
        suggestedOrder: (demand + item.safetyStock - item.currentStock)
            .clamp(0, 999999)
            .toInt(),
      );
    }).toList();
  }

  int get suggestionItemCount =>
      reorderRows.where((row) => row.suggestedOrder > 0).length;

  StoreSubmission? latestSubmissionForCurrentStore() {
    if (_currentUser == null) {
      return null;
    }
    return submissions
        .where(
          (submission) => submission.storeUsername == _currentUser!.username,
        )
        .firstOrNull;
  }

  List<StoreSubmission> submissionsForStore(String username) {
    return submissions
        .where((submission) => submission.storeUsername == username)
        .toList();
  }

  int latestQuantityFor(String itemId) {
    final latest = latestSubmissionForCurrentStore();
    if (latest == null) {
      return 0;
    }
    return latest.entries
            .where((entry) => entry.itemId == itemId)
            .firstOrNull
            ?.quantity ??
        0;
  }

  String storeName(String username) {
    return accounts
            .where((account) => account.username == username)
            .firstOrNull
            ?.displayName ??
        username;
  }

  String exportCurrentStatePretty() {
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(_bundle?.toJson() ?? {});
  }

  Future<void> _saveBundle(AppStateBundle bundle) async {
    _bundle = bundle;
    await _storage.saveBundle(bundle);
    if (_currentUser != null) {
      _currentUser =
          bundle.accounts
              .where((user) => user.username == _currentUser!.username)
              .firstOrNull ??
          _currentUser;
      await _storage.saveCurrentUser(_currentUser);
    }
    notifyListeners();
  }

  Future<AppStateBundle> _loadSeedBundle() async {
    final raw = await rootBundle.loadString('assets/seed/seed_data.json');
    return AppStateBundle.fromRawJson(raw);
  }

  String _newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}

extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
