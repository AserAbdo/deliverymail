import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/governorates_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/services/coupon_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/checkout_data_service.dart';
import '../../../../core/services/order_history_service.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../../core/services/notifications_storage_service.dart';

/// Checkout Screen
/// شاشة إتمام الطلب
class CheckoutScreen extends StatefulWidget {
  final Coupon? appliedCoupon;

  const CheckoutScreen({super.key, this.appliedCoupon});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartService _cartService = CartService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  // State
  List<Governorate> _governorates = [];
  Governorate? _selectedGovernorate;
  bool _isLoadingGovernorates = true;
  bool _isSubmitting = false;
  String _currencySymbol = 'ل.س';

  // Coupon
  Coupon? _appliedCoupon;

  @override
  void initState() {
    super.initState();
    _appliedCoupon = widget.appliedCoupon;
    _loadData();
    _loadSavedCheckoutData();
  }

  /// Load saved checkout data from SharedPreferences
  Future<void> _loadSavedCheckoutData() async {
    final savedName = await CheckoutDataService.getName();
    final savedPhone = await CheckoutDataService.getPhone();
    final savedEmail = await CheckoutDataService.getEmail();
    final savedAddress = await CheckoutDataService.getAddress();
    final savedGovernorateId = await CheckoutDataService.getGovernorateId();

    if (mounted) {
      setState(() {
        if (savedName != null) _nameController.text = savedName;
        if (savedPhone != null) _phoneController.text = savedPhone;
        if (savedEmail != null) {
          // Note: The original code doesn't show email field, adjust as needed
        }
        if (savedAddress != null) _addressController.text = savedAddress;

        // Set saved governorate
        if (savedGovernorateId != null && _governorates.isNotEmpty) {
          try {
            _selectedGovernorate = _governorates.firstWhere(
              (gov) => gov.id == savedGovernorateId,
            );
          } catch (e) {
            // Not found
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Load governorates
    final governorates = await GovernoratesService.getGovernorates();
    final savedGovernorate = await GovernoratesService.getSelectedGovernorate();

    // Load currency
    final currencySymbol = await SettingsService.getCurrencySymbol();

    // Find matching governorate from list by ID
    Governorate? matchingGovernorate;
    if (savedGovernorate != null && governorates.isNotEmpty) {
      try {
        matchingGovernorate = governorates.firstWhere(
          (gov) => gov.id == savedGovernorate.id,
        );
      } catch (e) {
        // Not found, keep null
        matchingGovernorate = null;
      }
    }

    setState(() {
      _governorates = governorates;
      _selectedGovernorate = matchingGovernorate;
      _currencySymbol = currencySymbol;
      _isLoadingGovernorates = false;
    });
  }

  double get _subtotal => _cartService.totalPrice;

  double get _discount => _appliedCoupon?.discountAmount ?? 0;

  double get _deliveryFee => _selectedGovernorate?.deliveryFee ?? 0;

  double get _total => _subtotal - _discount + _deliveryFee;

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGovernorate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار المحافظة', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Save checkout data to SharedPreferences (excluding coupon code & notes)
    await CheckoutDataService.saveName(_nameController.text.trim());
    await CheckoutDataService.savePhone(_phoneController.text.trim());
    await CheckoutDataService.saveAddress(_addressController.text.trim());
    if (_selectedGovernorate != null) {
      await CheckoutDataService.saveGovernorate(
        _selectedGovernorate!.name,
        _selectedGovernorate!.id.toString(),
      );
    }

    // Submit order to API
    final response = await OrderService.createOrderFromCart(
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      governorateId: _selectedGovernorate!.id,
      address: _addressController.text.trim(),
      couponCode: _appliedCoupon?.code,
      notes: _notesController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (response.success) {
      // Save governorate for future orders
      await GovernoratesService.saveSelectedGovernorate(_selectedGovernorate!);

      // Save order items to history
      for (final item in _cartService.items) {
        await OrderHistoryService.addOrder(
          productId: item.product.id.toString(),
          productName: item.product.nameAr,
          productImage: item.product.imageUrl,
          price: item.product.price,
          quantity: item.quantity,
        );
      }

      // Save notification to storage
      await NotificationsStorageService.saveNotification(
        title: 'تم إرسال طلبك بنجاح! 🎉',
        message: response.orderId != null
            ? 'رقم الطلب: ${response.orderId} - ${response.message}'
            : response.message,
        orderId: response.orderId?.toString(),
        type: 'order_success',
      );

      // Show local notification
      await LocalNotificationService.showOrderSuccessNotification(
        orderId: response.orderId?.toString() ?? 'N/A',
        message: response.message,
      );

      // Clear cart and show success
      _cartService.clearCart();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.primaryGreen,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  'تم تقديم الطلب بنجاح!',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  response.message,
                  style: GoogleFonts.cairo(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                if (response.orderId != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'رقم الطلب: ${response.orderId}',
                    style: GoogleFonts.cairo(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close checkout
                  Navigator.pop(context); // Close cart
                },
                child: Text(
                  'حسناً',
                  style: GoogleFonts.cairo(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message, style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            'إتمام الطلب',
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
        body: _isLoadingGovernorates
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCustomerInfoSection(),
                      const SizedBox(height: 24),
                      _buildOrderSummary(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات التوصيل',
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Full Name
          _buildTextField(
            controller: _nameController,
            label: 'الاسم الكامل *',
            hint: 'أدخل اسمك الكامل',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال الاسم';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone
          _buildTextField(
            controller: _phoneController,
            label: 'رقم الهاتف *',
            hint: 'مثال: 0991234567',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال رقم الهاتف';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Governorate Dropdown
          Text(
            'المحافظة *',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Governorate>(
                isExpanded: true,
                value: _selectedGovernorate,
                hint: Text(
                  'اختر المحافظة',
                  style: GoogleFonts.cairo(color: Colors.grey[400]),
                ),
                items: _governorates.map((gov) {
                  return DropdownMenuItem(
                    value: gov,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(gov.name, style: GoogleFonts.cairo()),
                        if (gov.deliveryFee > 0)
                          Text(
                            '${gov.deliveryFee.toStringAsFixed(0)} $_currencySymbol',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (gov) {
                  setState(() => _selectedGovernorate = gov);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Address
          _buildTextField(
            controller: _addressController,
            label: 'العنوان بالتفصيل *',
            hint: 'المدينة، الحي، والشارع...',
            icon: Icons.location_on_outlined,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال العنوان';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Notes
          _buildTextField(
            controller: _notesController,
            label: 'ملاحظات / اقتراحاتكم (اختياري)',
            hint: 'أي ملاحظات أو اقتراحات تود إضافتها...',
            icon: Icons.note_outlined,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.cairo(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الطلب',
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Cart Items
          ..._cartService.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.product.nameAr} × ${item.quantity} ${item.product.unit}',
                    style: GoogleFonts.cairo(color: Colors.grey[700]),
                  ),
                  Text(
                    '${item.totalPrice.toStringAsFixed(0)} $_currencySymbol',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 24),

          // Subtotal
          _buildSummaryRow('المجموع الفرعي:', '$_subtotal $_currencySymbol'),

          // Discount
          if (_appliedCoupon != null)
            _buildSummaryRow(
              'الخصم:',
              '- $_discount $_currencySymbol',
              valueColor: Colors.green,
            ),

          // Delivery Fee
          _buildSummaryRow(
            'رسوم التوصيل:',
            _selectedGovernorate != null
                ? '${_deliveryFee.toStringAsFixed(0)} $_currencySymbol'
                : 'اختر المحافظة',
          ),

          const Divider(height: 24),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع:',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_total.toStringAsFixed(0)} $_currencySymbol',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(color: Colors.grey[600])),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'تأكيد الطلب',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
