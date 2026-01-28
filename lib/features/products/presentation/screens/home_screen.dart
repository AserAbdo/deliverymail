import 'dart:async';
import 'package:flutter/material.dart' hide Banner;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/categories_service.dart';
import '../../../../core/services/governorates_service.dart';
import '../../../../core/services/banners_service.dart';
import '../../../../core/services/notifications_storage_service.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/services/cart_service.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_card.dart';
import '../widgets/quantity_selector_dialog.dart';
import 'product_details_screen.dart';
import 'category_products_screen.dart';

/// Home Screen - Redesigned UI matching the provided design
/// الشاشة الرئيسية - التصميم الجديد
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  // Cart
  final CartService _cartService = CartService();

  // Dynamic data from API
  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  // Banners
  List<Banner> _banners = [];
  bool _isLoadingBanners = true;
  final PageController _bannerPageController = PageController();
  Timer? _bannerAutoScrollTimer;
  int _currentBannerPage = 0;

  // Governorate
  List<Governorate> _governorates = [];
  Governorate? _selectedGovernorate;

  // Notifications
  int _unreadNotificationsCount = 0;

  // Cubit instance
  ProductsCubit? _productsCubit;
  ProductsCubit? _searchCubit; // Separate cubit for search suggestions

  // Search suggestions
  bool _showSearchSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadUnreadNotificationsCount();
    _searchController.addListener(_onSearchChanged);
    _cartService.addListener(_onCartChanged);
    _startBannerAutoScroll();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadCategories(), _loadGovernorates(), _loadBanners()]);
  }

  Future<void> _loadGovernorates() async {
    try {
      final governorates = await GovernoratesService.getGovernorates();
      final savedGovernorate =
          await GovernoratesService.getSelectedGovernorate();

      Governorate? selected;
      if (savedGovernorate != null && governorates.isNotEmpty) {
        try {
          selected = governorates.firstWhere(
            (gov) => gov.id == savedGovernorate.id,
          );
        } catch (e) {
          selected = null;
        }
      }

      if (mounted) {
        setState(() {
          _governorates = governorates;
          _selectedGovernorate = selected;
        });
      }
    } catch (e) {
      // Error loading governorates
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoriesService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _loadBanners() async {
    try {
      final banners = await BannersService.getBanners();
      if (mounted) {
        setState(() {
          _banners = banners;
          _isLoadingBanners = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBanners = false;
        });
      }
    }
  }

  Future<void> _loadUnreadNotificationsCount() async {
    final count = await NotificationsStorageService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadNotificationsCount = count;
      });
    }
  }

  void _startBannerAutoScroll() {
    _bannerAutoScrollTimer = Timer.periodic(const Duration(seconds: 4), (
      timer,
    ) {
      if (_banners.isEmpty || !mounted) return;

      _currentBannerPage = (_currentBannerPage + 1) % _banners.length;

      if (_bannerPageController.hasClients) {
        _bannerPageController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query != _searchQuery) {
        _searchQuery = query;
        _performSearch();
      }
    });
  }

  void _performSearch() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _showSearchSuggestions = false;
      });
      // Don't reload products, keep them as is
    } else {
      // Create search cubit if not exists
      _searchCubit ??= di.sl<ProductsCubit>();

      // Show suggestions overlay and load search results
      setState(() {
        _showSearchSuggestions = true;
      });
      _searchCubit!.searchProducts(_searchQuery);
    }
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    _searchQuery = '';
    setState(() {
      _showSearchSuggestions = false;
    });
    // Don't call _performSearch, just hide suggestions
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _bannerAutoScrollTimer?.cancel();
    _bannerPageController.dispose();
    _cartService.removeListener(_onCartChanged);
    _productsCubit = null;
    _searchCubit?.close(); // Close search cubit if exists
    _searchCubit = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return BlocProvider(
      create: (_) {
        _productsCubit = di.sl<ProductsCubit>()..loadProducts();
        return _productsCubit!;
      },
      child: Builder(
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      // Pinned App Bar
                      _buildSliverAppBar(),
                      // Pinned Search Bar
                      _buildSliverSearchBar(),
                      // Special Offers Section
                      SliverToBoxAdapter(child: _buildSpecialOffersSection()),
                      // Categories Section
                      SliverToBoxAdapter(child: _buildCategoriesSection()),
                      // Featured Products Section Title
                      SliverToBoxAdapter(child: _buildFeaturedTitle()),
                      // Products Grid
                      _buildProductsGrid(),
                      // Bottom padding
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    ],
                  ),
                  // Backdrop overlay when search is active
                  if (_showSearchSuggestions)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showSearchSuggestions = false;
                          });
                        },
                        child: Container(color: Colors.black.withOpacity(0.3)),
                      ),
                    ),
                  // Search suggestions overlay
                  if (_showSearchSuggestions) _buildSearchSuggestionsOverlay(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final cartCount = _cartService.itemCount;

    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // Cart Icon with Badge (left/start)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        if (cartCount > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Notifications Icon
                GestureDetector(
                  onTap: () {
                    _showNotifications();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Icon(
                            Icons.notifications_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        if (_unreadNotificationsCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                _unreadNotificationsCount > 9
                                    ? '9+'
                                    : _unreadNotificationsCount.toString(),
                                style: GoogleFonts.cairo(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Governorate Selector
                GestureDetector(
                  onTap: _showGovernorateDropdown,
                  child: Container(
                    height: 44, // Fixed height for consistency
                    constraints: const BoxConstraints(
                      minWidth: 120,
                      maxWidth: 180,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedGovernorate != null
                          ? Colors.white
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedGovernorate != null
                            ? AppColors.primaryGreen.withOpacity(0.3)
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: _selectedGovernorate != null
                              ? AppColors.primaryGreen
                              : Colors.grey[400],
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _selectedGovernorate != null &&
                                    _selectedGovernorate!.name.isNotEmpty
                                ? _selectedGovernorate!.name
                                : 'اختر محافظة',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: _selectedGovernorate != null
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: _selectedGovernorate != null
                                  ? Colors.grey[900]
                                  : Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: _selectedGovernorate != null
                              ? AppColors.primaryGreen
                              : Colors.grey[600],
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Logo with Two Colors
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'دليفري',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF003366), // Dark blue
                      ),
                    ),
                    Text(
                      ' مول',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen, // Green
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                // Menu Icon (opens drawer) - right/end
                GestureDetector(
                  onTap: () => _showMenuDrawer(),
                  child: Icon(Icons.menu, color: Colors.grey[700], size: 26),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMenuDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                margin: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'دليفري مول',
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'دليفري مول هو رفيقك الأول للتسوق في سوريا.\nنوفر لك أجود أنواع الخضار، الفواكه، والمنظفات\nبأسعار منافسة وتوصيل سريع إلى باب منزلك.',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Contact Section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طرق التواصل معنا',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Phone
                      _buildContactItem(
                        icon: Icons.phone,
                        title: 'خدمة العملاء',
                        value: '0991234567',
                      ),
                      const SizedBox(height: 16),
                      // Email
                      _buildContactItem(
                        icon: Icons.email_outlined,
                        title: 'البريد الإلكتروني',
                        value: 'support@deliverymall.sy',
                      ),
                      const SizedBox(height: 16),
                      // Address
                      _buildContactItem(
                        icon: Icons.location_on_outlined,
                        title: 'المقر الرئيسي',
                        value: 'اللاذقية - شارع الجمهورية',
                      ),
                      const Spacer(),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.login),
                          label: Text(
                            'تسجيل الدخول',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Back to Shopping Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: AppColors.primaryGreen),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'العودة للتسوق',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 22),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[500]),
            ),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build Sliver Search Bar (Pinned)
  Widget _buildSliverSearchBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SearchBarDelegate(
        searchController: _searchController,
        searchQuery: _searchQuery,
        onClear: _clearSearch,
      ),
    );
  }

  /// Show notifications
  void _showNotifications() async {
    // Load notifications
    final notifications = await NotificationsStorageService.getNotifications();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'الإشعارات',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    if (notifications.isNotEmpty)
                      TextButton(
                        onPressed: () async {
                          await NotificationsStorageService.markAllAsRead();
                          await _loadUnreadNotificationsCount();
                          Navigator.pop(context);
                          _showNotifications();
                        },
                        child: Text(
                          'وضع علامة مقروء للكل',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Notifications List
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد إشعارات حالياً',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          final isUnread = !notification.isRead;

                          return Dismissible(
                            key: Key(notification.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) async {
                              await NotificationsStorageService.deleteNotification(
                                notification.id,
                              );
                              await _loadUnreadNotificationsCount();
                            },
                            child: ListTile(
                              tileColor: isUnread
                                  ? AppColors.primaryGreen.withOpacity(0.05)
                                  : null,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: notification.type == 'order_success'
                                      ? AppColors.primaryGreen.withOpacity(0.1)
                                      : Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  notification.type == 'order_success'
                                      ? Icons.check_circle
                                      : Icons.notifications,
                                  color: notification.type == 'order_success'
                                      ? AppColors.primaryGreen
                                      : Colors.grey[600],
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                notification.title,
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.message,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatNotificationTime(
                                      notification.timestamp,
                                    ),
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: isUnread
                                  ? Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null,
                              onTap: () async {
                                if (isUnread) {
                                  await NotificationsStorageService.markAsRead(
                                    notification.id,
                                  );
                                  await _loadUnreadNotificationsCount();
                                  Navigator.pop(context);
                                  _showNotifications();
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      // Refresh count when bottom sheet closes
      _loadUnreadNotificationsCount();
    });
  }

  String _formatNotificationTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Show governorate dropdown
  void _showGovernorateDropdown() {
    if (_governorates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('جاري التحميل...', style: GoogleFonts.cairo()),
          backgroundColor: Colors.grey[600],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'اختر المحافظة',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  // List
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _governorates.length,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemBuilder: (context, index) {
                        final gov = _governorates[index];
                        final isSelected = _selectedGovernorate?.id == gov.id;
                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: AppColors.primaryGreen.withOpacity(
                            0.1,
                          ),
                          onTap: () async {
                            // Save to SharedPreferences
                            await GovernoratesService.saveSelectedGovernorate(
                              gov,
                            );

                            setState(() {
                              _selectedGovernorate = gov;
                            });

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم اختيار ${gov.name}',
                                    style: GoogleFonts.cairo(),
                                  ),
                                  backgroundColor: AppColors.primaryGreen,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          title: Text(
                            gov.name,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : Colors.grey[800],
                            ),
                          ),
                          subtitle: Text(
                            'رسوم التوصيل: ${gov.deliveryFee.toStringAsFixed(0)} ل.س',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryGreen,
                                  size: 24,
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpecialOffersSection() {
    if (_isLoadingBanners) {
      return Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        children: [
          // Banner PageView
          PageView.builder(
            controller: _bannerPageController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildBannerCard(_banners[index]);
            },
          ),
          // Dots Indicator
          if (_banners.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _banners.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentBannerPage == index
                          ? AppColors.primaryGreen
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(Banner banner) {
    return GestureDetector(
      onTap: () {
        if (banner.link != null && banner.link!.isNotEmpty) {
          // Handle banner link navigation
          print('Banner clicked: ${banner.link}');
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Banner Image
              CachedNetworkImage(
                imageUrl: banner.image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        banner.title,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // Gradient Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        banner.title,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (banner.description.isNotEmpty)
                        Text(
                          banner.description,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Text(
              'التصنيفات',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          // Categories Scrollable Grid
          _isLoadingCategories
              ? SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _categories.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'لا توجد تصنيفات',
                      style: GoogleFonts.cairo(color: Colors.grey),
                    ),
                  ),
                )
              : SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(_categories[index]);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    // Icon and colors based on category name
    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    // Map categories to icons and colors
    if (category.nameAr.contains('خضروات') ||
        category.nameAr.contains('خضار')) {
      iconData = Icons.eco; // Eco/leaf icon
      iconColor = const Color(0xFF4CAF50); // Green
      backgroundColor = const Color(0xFFE8F5E9); // Light green
    } else if (category.nameAr.contains('فواكه') ||
        category.nameAr.contains('فاكهة')) {
      iconData = Icons.apple; // Apple icon
      iconColor = const Color(0xFFFF9800); // Orange
      backgroundColor = const Color(0xFFFFE0B2); // Light orange
    } else if (category.nameAr.contains('تسالي') ||
        category.nameAr.contains('مكسرات')) {
      iconData = Icons.cookie; // Cookie/snack icon
      iconColor = const Color(0xFFFF5722); // Deep orange
      backgroundColor = const Color(0xFFFFE0B2); // Light orange
    } else if (category.nameAr.contains('مشروبات') ||
        category.nameAr.contains('مرطبات')) {
      iconData = Icons.local_drink; // Drink icon
      iconColor = const Color(0xFF00BCD4); // Cyan
      backgroundColor = const Color(0xFFE0F7FA); // Light cyan
    } else if (category.nameAr.contains('منظفات') ||
        category.nameAr.contains('نظافة')) {
      iconData = Icons.cleaning_services; // Cleaning icon
      iconColor = const Color(0xFF2196F3); // Blue
      backgroundColor = const Color(0xFFE3F2FD); // Light blue
    } else if (category.nameAr.contains('غذائية') ||
        category.nameAr.contains('طعام')) {
      iconData = Icons.restaurant; // Restaurant icon
      iconColor = const Color(0xFFFF9800); // Orange
      backgroundColor = const Color(0xFFFFE0B2); // Light orange
    } else if (category.nameAr.contains('لحوم') ||
        category.nameAr.contains('دجاج')) {
      iconData = Icons.set_meal; // Meat icon
      iconColor = const Color(0xFFE91E63); // Pink
      backgroundColor = const Color(0xFFFCE4EC); // Light pink
    } else {
      // Default icon
      iconData = Icons.category;
      iconColor = const Color(0xFF9C27B0); // Purple
      backgroundColor = const Color(0xFFF3E5F5); // Light purple
    }

    return GestureDetector(
      onTap: () {
        // Navigate to category products screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsScreen(
              categoryId: category.id,
              categoryName: category.nameAr,
              subcategories: category.children,
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with colored background
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(iconData, color: iconColor, size: 26)),
            ),
            const SizedBox(height: 8),
            // Category name
            Text(
              category.nameAr,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Center(
        child: Text(
          'المنتجات المميزة',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.cairo()),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ProductsLoading) {
          return ShimmerLoading.productsGrid();
        }

        if (state is ProductsEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(context, state.message),
          );
        }

        if (state is ProductsLoaded) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildProductCard(state.products[index]);
              }, childCount: state.products.length),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox());
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return ProductCard(
      product: product,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      onAddToCart: () {
        QuantitySelectorDialog.show(
          context: context,
          product: product,
          cartService: _cartService,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ProductsCubit>().loadProducts();
            },
            icon: const Icon(Icons.refresh),
            label: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestionsOverlay() {
    // Calculate approximate height of header + search bar
    const headerHeight = 60.0; // Approximate header height
    const searchBarHeight = 60.0; // Approximate search bar height
    const topOffset = headerHeight + searchBarHeight + 10; // 10 for margins

    if (_searchCubit == null) return const SizedBox.shrink();

    return Positioned(
      top: topOffset,
      left: 8,
      right: 8,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showSearchSuggestions = false;
          });
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: BlocProvider<ProductsCubit>.value(
              value: _searchCubit!,
              child: BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoading) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is ProductsLoaded && state.products.isNotEmpty) {
                    // Show up to 5 suggestions
                    final suggestions = state.products.take(5).toList();

                    return Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // AI Search Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7ED),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 18,
                                  color: const Color(0xFF457C3B),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'بحث ذكي بالذكاء الاصطناعي',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: const Color(0xFF457C3B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Results List
                          Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: suggestions.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.grey[200],
                                indent: 70,
                              ),
                              itemBuilder: (context, index) {
                                final product = suggestions[index];
                                return ListTile(
                                  onTap: () {
                                    setState(() {
                                      _showSearchSuggestions = false;
                                    });
                                    // Show quantity dialog
                                    QuantitySelectorDialog.show(
                                      context: context,
                                      product: product,
                                      cartService: _cartService,
                                    );
                                  },
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: product.imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                    ),
                                  ),
                                  title: Text(
                                    product.nameAr,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${product.price} ل.س',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 16,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ProductsEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'لا توجد نتائج',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Search Bar Delegate for Pinned Header
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final String searchQuery;
  final VoidCallback onClear;

  _SearchBarDelegate({
    required this.searchController,
    required this.searchQuery,
    required this.onClear,
  });

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[500], size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: searchController,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث بأي طريقة... (بحث ذكي)',
                  hintStyle: GoogleFonts.cairo(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style: GoogleFonts.cairo(fontSize: 14),
              ),
            ),
            if (searchQuery.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.clear, color: Colors.grey[600], size: 20),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) {
    return searchQuery != oldDelegate.searchQuery;
  }
}
