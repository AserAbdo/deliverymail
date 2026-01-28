import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/settings_service.dart';

/// Orders Screen
/// شاشة الطلبات
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;
  bool _hasPhone = false;
  List<Order> _orders = [];
  String _currencySymbol = 'ل.س';
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final savedPhone = await OrderService.getSavedPhoneNumber();
    final currency = await SettingsService.getCurrencySymbol();

    setState(() {
      _currencySymbol = currency;
      if (savedPhone != null && savedPhone.isNotEmpty) {
        _phoneController.text = savedPhone;
        _hasPhone = true;
      }
    });

    if (savedPhone != null && savedPhone.isNotEmpty) {
      await _searchOrders(savedPhone);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchOrders(String phone) async {
    if (phone.isEmpty) return;

    setState(() => _isLoading = true);

    final orders = await OrderService.getOrdersByPhone(phone);
    await OrderService.savePhoneNumber(phone);

    setState(() {
      _orders = orders;
      _hasPhone = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            'طلباتي',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (_hasPhone)
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _showSearchDialog,
              ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryGreen,
                  ),
                ),
              )
            : !_hasPhone
            ? _buildPhonePrompt()
            : _orders.isEmpty
            ? _buildEmptyState()
            : _buildOrdersList(),
      ),
    );
  }

  Widget _buildPhonePrompt() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تتبع طلباتك',
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أدخل رقم هاتفك لعرض طلباتك',
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: '09XXXXXXXX',
                      hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: AppColors.primaryGreen,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _searchOrders(_phoneController.text.trim()),
                      icon: const Icon(Icons.search),
                      label: Text(
                        'عرض الطلبات',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
              Icons.shopping_bag_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد طلبات',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على طلبات لهذا الرقم',
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
            label: Text('بحث برقم آخر', style: GoogleFonts.cairo()),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return RefreshIndicator(
      onRefresh: () => _searchOrders(_phoneController.text),
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
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
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طلب #${order.id}',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(order.statusColor, order.statusLabel),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(order.createdAt),
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.governorate?.name ?? order.address,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Products Preview
              if (order.items.isNotEmpty) ...[
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: order.items.length > 4 ? 4 : order.items.length,
                    itemBuilder: (context, index) {
                      if (index == 3 && order.items.length > 4) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '+${order.items.length - 3}',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        );
                      }
                      final item = order.items[index];
                      return Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: item.productImage,
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) =>
                                Icon(Icons.image, color: Colors.grey[400]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} منتجات',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${order.total.toStringAsFixed(0)} $_currencySymbol',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String statusColor, String statusLabel) {
    Color color;
    Color bgColor;

    switch (statusColor.toLowerCase()) {
      case 'yellow':
        color = Colors.orange;
        bgColor = Colors.orange.shade50;
        break;
      case 'blue':
        color = Colors.blue;
        bgColor = Colors.blue.shade50;
        break;
      case 'purple':
        color = Colors.purple;
        bgColor = Colors.purple.shade50;
        break;
      case 'green':
        color = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case 'red':
        color = Colors.red;
        bgColor = Colors.red.shade50;
        break;
      default:
        color = Colors.grey;
        bgColor = Colors.grey.shade100;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusLabel,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تفاصيل الطلب #${order.id}',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusChip(order.statusColor, order.statusLabel),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildDetailRow('التاريخ', _formatDate(order.createdAt)),
                    _buildDetailRow('الاسم', order.customerName),
                    _buildDetailRow('الهاتف', order.customerPhone),
                    _buildDetailRow('المحافظة', order.governorate?.name ?? '-'),
                    _buildDetailRow('العنوان', order.address),
                    if (order.notes != null && order.notes!.isNotEmpty)
                      _buildDetailRow('ملاحظات', order.notes!),
                    const SizedBox(height: 16),
                    Text(
                      'المنتجات',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map((item) => _buildOrderItem(item)),
                    const Divider(height: 32),
                    _buildPriceRow('المجموع الفرعي', order.subtotal),
                    if (order.discountAmount > 0)
                      _buildPriceRow(
                        'الخصم',
                        -order.discountAmount,
                        isDiscount: true,
                      ),
                    _buildPriceRow('رسوم التوصيل', order.deliveryFee),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الإجمالي',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${order.total.toStringAsFixed(0)} $_currencySymbol',
                          style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.cairo(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItemDetails item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: item.productImage,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) =>
                    Icon(Icons.image, color: Colors.grey[400]),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${item.quantity} × ${item.unitPrice.toStringAsFixed(0)} $_currencySymbol',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.subtotal.toStringAsFixed(0)} $_currencySymbol',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(color: Colors.grey[600])),
          Text(
            '${isDiscount ? '-' : ''}${amount.abs().toStringAsFixed(0)} $_currencySymbol',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w500,
              color: isDiscount ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'بحث عن طلبات',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أدخل رقم الهاتف للبحث عن طلباتك',
                style: GoogleFonts.cairo(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '09XXXXXXXX',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
            ],
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
              onPressed: () {
                Navigator.pop(context);
                _searchOrders(_phoneController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: Text('بحث', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }
}
