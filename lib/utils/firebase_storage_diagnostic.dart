import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Utility class to diagnose Firebase Storage configuration issues
class FirebaseStorageDiagnostic {
  static Future<Map<String, dynamic>> runDiagnostics() async {
    final results = <String, dynamic>{};

    try {
      // Check 1: Authentication
      final user = FirebaseAuth.instance.currentUser;
      results['authenticated'] = user != null;
      results['userId'] = user?.uid ?? 'Not authenticated';

      if (user != null) {
        // Check if the user has a valid token
        final token = await user.getIdToken();
        results['hasValidToken'] = token != null && token.isNotEmpty;
      }

      // Check 2: Storage instance
      final storage = FirebaseStorage.instance;
      results['storageInitialized'] = true;
      results['storageBucket'] = storage.bucket;

      // Check 3: Try to get a reference
      if (user != null) {
        final testRef = storage.ref().child('users/${user.uid}/test.txt');
        results['canCreateReference'] = true;

        // Check 4: Try to check permissions (this will fail if rules block it)
        try {
          // Try to get metadata of a non-existent file
          // This will tell us if we have read access
          await testRef.getMetadata();
          results['hasReadAccess'] = true;
        } on FirebaseException catch (e) {
          if (e.code == 'object-not-found') {
            // This is actually good - means we have read access
            results['hasReadAccess'] = true;
          } else if (e.code == 'unauthorized' || e.code == 'permission-denied') {
            results['hasReadAccess'] = false;
            results['readAccessError'] = e.message;
          } else {
            results['hasReadAccess'] = 'unknown';
            results['readAccessError'] = e.message;
          }
        }
      }

      return results;
    } catch (e) {
      results['error'] = e.toString();
      return results;
    }
  }

  static String formatDiagnosticResults(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    buffer.writeln('🔍 Firebase Storage Diagnostic Results:');
    buffer.writeln('═' * 50);

    results.forEach((key, value) {
      final icon = _getStatusIcon(key, value);
      buffer.writeln('$icon $key: $value');
    });

    buffer.writeln('═' * 50);

    // Provide recommendations
    if (results['authenticated'] == false) {
      buffer.writeln('\n⚠️  ACTION REQUIRED:');
      buffer.writeln('   User is not authenticated. Please sign in first.');
    }

    if (results['hasReadAccess'] == false) {
      buffer.writeln('\n⚠️  ACTION REQUIRED:');
      buffer.writeln('   Storage rules are blocking access.');
      buffer.writeln('   Please update your Firebase Storage rules to:');
      buffer.writeln('''

   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /users/{userId}/{allPaths=**} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ''');
    }

    return buffer.toString();
  }

  static String _getStatusIcon(String key, dynamic value) {
    if (key.contains('error') || value == false) {
      return '❌';
    } else if (value == true || value == 'true') {
      return '✅';
    } else if (value == 'unknown') {
      return '❓';
    }
    return '📋';
  }

  /// Run diagnostics and show in a dialog
  static Future<void> showDiagnosticsDialog(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final results = await runDiagnostics();

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Storage Diagnostics'),
          content: SingleChildScrollView(
            child: Text(
              formatDiagnosticResults(results),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
