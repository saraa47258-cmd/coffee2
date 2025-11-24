import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ty_cafe/features/cart/presentation/bloc/cart_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class PreOrderPage extends StatefulWidget {
  const PreOrderPage({super.key});

  @override
  State<PreOrderPage> createState() => _PreOrderPageState();
}

class _PreOrderPageState extends State<PreOrderPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _confirmPreOrder() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار التاريخ والوقت')),
      );
      return;
    }

    final cartState = context.read<CartBloc>().state;
    if (cartState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السلة فارغة')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الطلب المسبق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('التاريخ: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            Text('الوقت: ${_selectedTime!.format(context)}'),
            Text('عدد المنتجات: ${cartState.totalQuantity}'),
            Text('المجموع: ${cartState.totalAmount.toStringAsFixed(1)} ر.ع.'),
            if (_notesController.text.isNotEmpty)
              Text('ملاحظات: ${_notesController.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تأكيد الطلب المسبق بنجاح!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      appBar: AppBar(
        backgroundColor: AppColors.whiteBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'طلب مسبق',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: Responsive.fontSize(context, 22),
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 238, 184, 132).withValues(alpha: 0.03),
              AppColors.whiteBackground,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Responsive.spacing(context, 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Time Selection
                    _buildDateTimeCard(
                      context,
                      'التاريخ',
                      _selectedDate == null
                          ? 'اختر التاريخ'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      Icons.calendar_today,
                      _selectDate,
                    ),
                    SizedBox(height: Responsive.spacing(context, 15)),
                    _buildDateTimeCard(
                      context,
                      'الوقت',
                      _selectedTime == null
                          ? 'اختر الوقت'
                          : _selectedTime!.format(context),
                      Icons.access_time,
                      _selectTime,
                    ),
                    SizedBox(height: Responsive.spacing(context, 20)),
                    
                    // Cart Items
                    Text(
                      'المنتجات المختارة',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: Responsive.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 15)),
                    BlocBuilder<CartBloc, CartState>(
                      builder: (context, state) {
                        if (state.items.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 64,
                                  color: AppColors.subtleText.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'السلة فارغة',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: Responsive.fontSize(context, 16),
                                    color: AppColors.subtleText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Column(
                          children: state.items.map((item) {
                            final product = item.product;
                            return Container(
                              margin: EdgeInsets.only(
                                bottom: Responsive.spacing(context, 10),
                              ),
                              padding: EdgeInsets.all(Responsive.spacing(context, 15)),
                              decoration: BoxDecoration(
                                color: AppColors.whiteBackground,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: AppColors.subtleText.withValues(alpha: 0.1),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        product.image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: Responsive.fontSize(context, 14),
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'الكمية: ${item.quantity} × ${item.unitPrice.toStringAsFixed(1)} ر.ع.',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: Responsive.fontSize(context, 12),
                                            color: AppColors.subtleText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${item.totalPrice.toStringAsFixed(1)} ر.ع.',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Responsive.fontSize(context, 16),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    SizedBox(height: Responsive.spacing(context, 20)),
                    
                    // Notes
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        labelStyle: const TextStyle(fontFamily: 'Poppins'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            
            // Total & Confirm Button
            Container(
              padding: EdgeInsets.all(Responsive.spacing(context, 20)),
              decoration: BoxDecoration(
                color: AppColors.whiteBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, state) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المجموع',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Responsive.fontSize(context, 18),
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          Text(
                            '${state.totalAmount.toStringAsFixed(1)} ر.ع.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Responsive.fontSize(context, 20),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: Responsive.spacing(context, 15)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmPreOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.lerp(
                          AppColors.primaryColor,
                          Colors.orange,
                          0.6,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: Responsive.spacing(context, 16),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'تأكيد الطلب المسبق',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteText,
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

  Widget _buildDateTimeCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Responsive.spacing(context, 20)),
        decoration: BoxDecoration(
          color: AppColors.whiteBackground,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Responsive.fontSize(context, 12),
                      color: AppColors.subtleText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Responsive.fontSize(context, 16),
                      color: AppColors.darkText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.subtleText),
          ],
        ),
      ),
    );
  }
}

