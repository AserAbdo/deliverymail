import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/screens/login_screen.dart';

/// Profile Screen
/// شاشة الحساب الشخصي
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      final user = await AuthService.getSavedUser();
      setState(() {
        _isLoggedIn = true;
        _user = user;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'تسجيل الخروج',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من تسجيل الخروج؟',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await AuthService.logout();
                setState(() {
                  _isLoggedIn = false;
                  _user = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('تسجيل الخروج', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                ),
              )
            : _isLoggedIn
            ? _buildLoggedInView()
            : _buildGuestView(),
      ),
    );
  }

  Widget _buildGuestView() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: const Color(0xFF2E7D32),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'مرحباً بك',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'سجل دخولك للاستمتاع بالمزايا',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                      _checkLoginStatus();
                    },
                    icon: const Icon(Icons.login),
                    label: Text(
                      'تسجيل الدخول',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Features
                _buildFeatureItem(
                  Icons.shopping_bag_outlined,
                  'تتبع طلباتك بسهولة',
                ),
                _buildFeatureItem(
                  Icons.favorite_outline,
                  'احفظ منتجاتك المفضلة',
                ),
                _buildFeatureItem(
                  Icons.local_offer_outlined,
                  'احصل على عروض حصرية',
                ),
                _buildFeatureItem(
                  Icons.notifications_outlined,
                  'تنبيهات للعروض الجديدة',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInView() {
    final userName = _user?['name'] ?? 'المستخدم';
    final userEmail = _user?['email'] ?? '';
    final userPhone = _user?['phone'] ?? '';

    return CustomScrollView(
      slivers: [
        // App Bar with user info
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: const Color(0xFF2E7D32),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: const Color(
                            0xFF2E7D32,
                          ).withOpacity(0.1),
                          child: Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'U',
                            style: GoogleFonts.cairo(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userName,
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (userEmail.isNotEmpty)
                        Text(
                          userEmail,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Section
                _buildSectionTitle('الحساب'),
                _buildMenuItem(Icons.person_outline, 'معلومات الحساب', () {}),
                _buildMenuItem(Icons.location_on_outlined, 'عناويني', () {}),
                _buildMenuItem(Icons.payment_outlined, 'طرق الدفع', () {}),

                const SizedBox(height: 24),

                // Orders Section
                _buildSectionTitle('الطلبات'),
                _buildMenuItem(Icons.shopping_bag_outlined, 'طلباتي', () {}),
                _buildMenuItem(Icons.favorite_outline, 'المفضلة', () {}),

                const SizedBox(height: 24),

                // Settings Section
                _buildSectionTitle('الإعدادات'),
                _buildMenuItem(
                  Icons.notifications_outlined,
                  'الإشعارات',
                  () {},
                ),
                _buildMenuItem(Icons.language_outlined, 'اللغة', () {}),
                _buildMenuItem(Icons.help_outline, 'المساعدة والدعم', () {}),
                _buildMenuItem(Icons.info_outline, 'عن التطبيق', () {}),

                const SizedBox(height: 24),

                // Logout Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: Text(
                      'تسجيل الخروج',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
        ),
        title: Text(title, style: GoogleFonts.cairo(fontSize: 15)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
