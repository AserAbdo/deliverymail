import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/orders_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/screens/login_screen.dart';

/// Orders Screen
/// شاشة الطلبات
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  List<Order> _orders = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkLoginAndLoadOrders();
  }

  Future<void> _checkLoginAndLoadOrders() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    setState(() => _isLoggedIn = isLoggedIn);

    if (isLoggedIn) {
      await _loadOrders();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await OrdersService.getMyOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ في تحميل الطلبات';
        _isLoading = false;
      });
    }
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
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                ),
              )
            : !_isLoggedIn
            ? _buildLoginPrompt()
            : _orders.isEmpty
            ? _buildEmptyState()
            : _buildOrdersList(),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              'سجل دخولك لمشاهدة طلباتك',
              style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                _checkLoginAndLoadOrders();
              },
              icon: const Icon(Icons.login),
              label: Text(
                'تسجيل الدخول',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Track order section
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
              child: Column(
                children: [
                  Text(
                    'أو تتبع طلبك برقم الهاتف',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => _showTrackOrderDialog(),
                    icon: const Icon(Icons.search),
                    label: Text('تتبع الطلب', style: GoogleFonts.cairo()),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
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
            'لا توجد طلبات بعد',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ التسوق وأضف منتجات إلى سلتك',
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to home tab
            },
            icon: const Icon(Icons.shopping_cart),
            label: Text(
              'ابدأ التسوق',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
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

  Widget _buildOrdersList() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: const Color(0xFF2E7D32),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طلب #${order.orderNumber}',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(order.status, order.statusAr),
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
                      order.address,
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
                    '${order.total.toStringAsFixed(2)} ج.م',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
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

  Widget _buildStatusChip(String status, String statusAr) {
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        bgColor = Colors.orange.shade50;
        break;
      case 'confirmed':
      case 'processing':
        color = Colors.blue;
        bgColor = Colors.blue.shade50;
        break;
      case 'shipped':
        color = Colors.purple;
        bgColor = Colors.purple.shade50;
        break;
      case 'delivered':
        color = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case 'cancelled':
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
        statusAr,
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
          height: MediaQuery.of(context).size.height * 0.75,
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
                      'تفاصيل الطلب',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusChip(order.status, order.statusAr),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildDetailRow('رقم الطلب', '#${order.orderNumber}'),
                    _buildDetailRow('التاريخ', _formatDate(order.createdAt)),
                    _buildDetailRow('الاسم', order.customerName),
                    _buildDetailRow('الهاتف', order.customerPhone),
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
                          '${order.total.toStringAsFixed(2)} ج.م',
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
            width: 100,
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

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${item.quantity} × ${item.price.toStringAsFixed(2)} ج.م',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.total.toStringAsFixed(2)} ج.م',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(color: Colors.grey[600])),
          Text(
            '${amount.toStringAsFixed(2)} ج.م',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showTrackOrderDialog() {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'تتبع الطلب',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أدخل رقم الهاتف المستخدم في الطلب',
                style: GoogleFonts.cairo(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0912345678',
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
              onPressed: () async {
                Navigator.pop(context);
                final result = await OrdersService.trackOrder(
                  phoneController.text,
                );
                if (result['success'] && mounted) {
                  setState(() {
                    _orders = result['orders'];
                    _isLoggedIn = true; // Show orders list
                  });
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message'],
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
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
