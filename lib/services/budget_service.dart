import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import 'notification_service.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<List<Budget>> getActiveBudgets(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => Budget.fromFirestore(doc)).toList();
  }

  Future<double> calculateSpentAmount(
    String userId,
    List<String> spentTypes,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .where('spentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('spentAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    final expenses = snapshot.docs
        .map((doc) => Expense.fromFirestore(doc))
        .toList();

    double totalSpent = 0;
    for (var expense in expenses) {
      for (var item in expense.items) {
        if (spentTypes.contains(item.spentType)) {
          totalSpent += item.value;
        }
      }
    }

    return totalSpent;
  }

  Future<void> checkBudgetAlerts(String userId) async {
    final budgets = await getActiveBudgets(userId);
    final now = DateTime.now();

    for (var budget in budgets) {
      if (budget.endDate.isBefore(now)) continue;

      final spent = await calculateSpentAmount(
        userId,
        budget.spentTypes,
        budget.startDate,
        budget.endDate,
      );

      final percentage = (spent / budget.amount) * 100;

      if (percentage >= budget.notificationThreshold) {
        await _sendBudgetAlert(userId, budget, percentage);
      }
    }
  }

  Future<void> _sendBudgetAlert(
    String userId,
    Budget budget,
    double percentage,
  ) async {
    final title = 'Budget Alert';
    final body =
        'You have reached ${percentage.toStringAsFixed(0)}% of your ${budget.period} budget for ${budget.spentTypes.join(", ")}.';

    await _notificationService.sendBudgetAlert(title, body);
  }
}
