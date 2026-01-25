import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../network/api_client.dart';
import 'auth_service.dart';

/// Google Sign-In Service
/// خدمة تسجيل الدخول بواسطة جوجل
class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final ApiClient _apiClient = ApiClient();

  /// Sign in with Google
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('🔵 بدء عملية تسجيل الدخول بـ Google...');

      // Check if Firebase is initialized
      try {
        FirebaseAuth.instance;
        print('✅ Firebase initialized successfully');
      } catch (e) {
        print('❌ Firebase Error: $e');
        return {
          'success': false,
          'message':
              'Firebase غير مُعد. الرجاء إعداد Firebase أولاً.\nSee FIREBASE_QUICK_START.md',
        };
      }

      // Trigger the authentication flow
      print('🔵 فتح نافذة Google Sign In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('⚠️ تم إلغاء تسجيل الدخول من قبل المستخدم');
        return {'success': false, 'message': 'تم إلغاء تسجيل الدخول'};
      }

      print('✅ تم اختيار حساب Google: ${googleUser.email}');

      // Obtain the auth details from the request
      print('🔵 الحصول على بيانات المصادقة...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('✅ تم الحصول على accessToken و idToken');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔵 تسجيل الدخول إلى Firebase...');
      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      print('✅ تم تسجيل الدخول إلى Firebase: ${userCredential.user?.email}');

      // Get the Firebase ID token (force refresh to avoid revoked token)
      print('🔵 الحصول على Firebase ID Token جديد...');
      final String? idToken = await userCredential.user?.getIdToken(
        true,
      ); // true = force refresh

      if (idToken == null) {
        print('❌ فشل الحصول على ID Token');
        return {'success': false, 'message': 'فشل الحصول على رمز المصادقة'};
      }

      print('✅ تم الحصول على ID Token (الطول: ${idToken.length})');
      print('🔵 ID Token: ${idToken.substring(0, 50)}...');

      // Send the ID token to your Laravel backend
      print('🔵 إرسال البيانات إلى Backend...');
      print('🔵 Endpoint: /auth/google');
      print('🔵 Body: {');
      print('  id_token: ${idToken.substring(0, 30)}...,');
      print('  email: ${userCredential.user?.email},');
      print('  name: ${userCredential.user?.displayName},');
      print('  photo_url: ${userCredential.user?.photoURL}');
      print('}');

      final response = await _apiClient.post(
        '/auth/google',
        body: {
          'id_token': idToken,
          'email': userCredential.user?.email,
          'name': userCredential.user?.displayName,
          'photo_url': userCredential.user?.photoURL,
        },
      );

      print('✅ تم استلام الرد من Backend');
      print('🔵 Response: $response');

      if (response['success'] == true) {
        print('✅ تسجيل الدخول ناجح!');
        // Save the token and user data from your backend
        final token = response['data']['token'];
        final user = response['data']['user'];

        await AuthService.saveToken(token);
        await AuthService.saveUser(user);

        return {
          'success': true,
          'message': 'تم تسجيل الدخول بنجاح',
          'data': response['data'],
        };
      }

      print('❌ فشل تسجيل الدخول: ${response['message']}');
      return {
        'success': false,
        'message': response['message'] ?? 'فشل تسجيل الدخول',
      };
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Full Error: $e');
      return {'success': false, 'message': _getFirebaseErrorMessage(e.code)};
    } catch (e, stackTrace) {
      print('❌ خطأ غير متوقع:');
      print('   Error: $e');
      print('   Type: ${e.runtimeType}');
      print('   StackTrace: $stackTrace');
      return {
        'success': false,
        'message': 'حدث خطأ أثناء تسجيل الدخول: ${e.toString()}',
      };
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      // Ignore sign out errors
    }
  }

  /// Get Firebase error message in Arabic
  static String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'يوجد حساب بالفعل بنفس البريد الإلكتروني';
      case 'invalid-credential':
        return 'بيانات الاعتماد غير صالحة';
      case 'operation-not-allowed':
        return 'العملية غير مسموح بها';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صالح';
      case 'invalid-verification-id':
        return 'معرف التحقق غير صالح';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
