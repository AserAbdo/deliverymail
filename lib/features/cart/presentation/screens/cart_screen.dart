import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/services/order_history_service.dart';
import '../../../../features/products/domain/entities/product.dart';
import 'checkout_screen.dart';

/// Cart Screen
/// شاشة السلة
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  String _currencySymbol = 'ل.س';

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final symbol = await SettingsService.getCurrencySymbol();
    if (mounted) {
      setState(() => _currencySymbol = symbol);
    }
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'سلة التسوق',
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
          actions: [
            if (_cartService.items.isEmpty)
              IconButton(
                icon: const Icon(Icons.history, color: Colors.grey),
                onPressed: _showOrderHistory,
              ),
          ],
        ),
        body: _cartService.isEmpty
            ? _buildEmptyCart()
            : Column(
                children: [
                  Expanded(child: _buildCartItems()),
                  _buildBottomBar(),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'السلة فارغة',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'أضف منتجات للسلة للبدء بالتسوق',
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'تصفح المنتجات',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cartService.items.length,
      itemBuilder: (context, index) {
        final item = _cartService.items[index];
        return Dismissible(
          key: Key('cart_item_${item.product.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24),
            child: const Icon(
              Icons.delete_forever,
              color: Colors.white,
              size: 28,
            ),
          ),
          onDismissed: (direction) {
            _cartService.removeFromCart(item.product);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Product Image with background
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: item.product.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name & Delete
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.product.nameAr,
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  _cartService.removeFromCart(item.product),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red[400],
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Unit Price
                        Text(
                          '${item.product.price.toStringAsFixed(0)} $_currencySymbol / ${item.product.unit}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Quantity Controls & Total Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Quantity Selector
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildQuantityButton(
                                    icon: Icons.remove,
                                    onTap: () => _cartService.decrementQuantity(
                                      item.product,
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${item.quantity}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  _buildQuantityButton(
                                    icon: Icons.add,
                                    onTap: () => _cartService.incrementQuantity(
                                      item.product,
                                    ),
                                    isAdd: true,
                                  ),
                                ],
                              ),
                            ),
                            // Total Price for this item
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryGreen.withOpacity(0.1),
                                    AppColors.primaryGreenLight.withOpacity(
                                      0.1,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${item.totalPrice.toStringAsFixed(0)} $_currencySymbol',
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isAdd = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isAdd ? AppColors.primaryGreen : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isAdd ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${_cartService.totalPrice.toStringAsFixed(0)} $_currencySymbol',
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'إتمام الطلب (${_cartService.itemCount} منتج)',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show order history dialog
  void _showOrderHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => OrderHistoryModal(
        cartService: _cartService,
        onOrderSelected: _onHistoryOrderSelected,
      ),
    );
  }

  /// Handle history order selection
  void _onHistoryOrderSelected(HistoryOrder order) {
    // Create a Product object to add to cart
    final mockProduct = Product(
      id: order.productId,
      nameAr: order.productName,
      descriptionAr: '',
      price: order.price,
      unit: '',
      imageUrl: order.productImage,
      category: '',
    );

    // Add to cart
    _cartService.addToCart(mockProduct, quantity: order.quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${order.productName} تمت إضافته للسلة',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Close dialog
    Navigator.pop(context);
  }
}

/// Order History Modal
class OrderHistoryModal extends StatefulWidget {
  final CartService cartService;
  final Function(HistoryOrder) onOrderSelected;

  const OrderHistoryModal({
    super.key,
    required this.cartService,
    required this.onOrderSelected,
  });

  @override
  State<OrderHistoryModal> createState() => _OrderHistoryModalState();
}

class _OrderHistoryModalState extends State<OrderHistoryModal> {
  late Future<List<HistoryOrder>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = OrderHistoryService.getUniqueHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الطلبات السابقة',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // History list
              Expanded(
                child: FutureBuilder<List<HistoryOrder>>(
                  future: _historyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد طلبات سابقة',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final order = snapshot.data![index];
                        return _buildHistoryItem(order);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(HistoryOrder order) {
    return InkWell(
      onTap: () => widget.onOrderSelected(order),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: order.productImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${order.price} ل.س',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      Text(
                        '${order.quantity} قطعة',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
