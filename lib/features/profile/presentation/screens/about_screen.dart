import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/settings_service.dart';

/// About App Screen
/// شاشة عن التطبيق
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  AppSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.getSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'عن التطبيق',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Logo & Name
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.primaryGreenLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_basket,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _settings?.companyName ?? 'ديليفري مول',
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الإصدار 1.0.0',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        _settings?.footerText ??
                            'متجرك المفضل للخضروات والفواكه الطازجة. توصيل سريع ومضمون لجميع المحافظات.',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Features
                    _buildFeatureCard(
                      Icons.eco,
                      'منتجات صحية وطبيعية',
                      'نوفر لك أفضل المنتجات الطازجة من المزارع مباشرة',
                      Colors.green,
                    ),
                    _buildFeatureCard(
                      Icons.local_shipping,
                      'توصيل سريع',
                      'توصيل لباب منزلك في أسرع وقت ممكن',
                      Colors.blue,
                    ),
                    _buildFeatureCard(
                      Icons.verified,
                      'جودة مضمونة',
                      'نضمن لك جودة جميع منتجاتنا',
                      Colors.orange,
                    ),
                    _buildFeatureCard(
                      Icons.support_agent,
                      'دعم العملاء',
                      'فريق دعم متاح لمساعدتك في أي وقت',
                      Colors.purple,
                    ),

                    const SizedBox(height: 24),

                    // Contact Info
                    if (_settings?.phone != null || _settings?.whatsapp != null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'تواصل معنا',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_settings?.phone != null)
                              _buildContactRow(Icons.phone, _settings!.phone!),
                            if (_settings?.whatsapp != null)
                              _buildContactRow(
                                Icons.message,
                                _settings!.whatsapp!,
                              ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Language Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.language, color: AppColors.primaryGreen),
                          const SizedBox(width: 8),
                          Text(
                            'اللغة: العربية',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Copyright
                    Text(
                      '© 2024 جميع الحقوق محفوظة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
