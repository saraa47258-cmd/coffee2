import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class TableBookingPage extends StatefulWidget {
  const TableBookingPage({super.key});

  @override
  State<TableBookingPage> createState() => _TableBookingPageState();
}

class _TableBookingPageState extends State<TableBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _guestsController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? _selectedTableNumber;
  bool _isLoading = false;

  final List<int> _availableTables = List.generate(20, (index) => index + 1);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
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
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null || _selectedTableNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bookingDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection('table_bookings').add({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'guests': int.parse(_guestsController.text),
        'tableNumber': _selectedTableNumber,
        'dateTime': Timestamp.fromDate(bookingDateTime),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حجز الطاولة بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          'حجز طاولة',
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.spacing(context, 20)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Selection
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
                
                // Time Selection
                _buildDateTimeCard(
                  context,
                  'الوقت',
                  _selectedTime == null
                      ? 'اختر الوقت'
                      : _selectedTime!.format(context),
                  Icons.access_time,
                  _selectTime,
                ),
                SizedBox(height: Responsive.spacing(context, 15)),
                
                // Table Selection
                _buildTableSelection(context),
                SizedBox(height: Responsive.spacing(context, 15)),
                
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('الاسم'),
                  validator: (v) => v?.isEmpty ?? true ? 'يرجى إدخال الاسم' : null,
                ),
                SizedBox(height: Responsive.spacing(context, 15)),
                
                // Phone
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration('رقم الهاتف'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.isEmpty ?? true ? 'يرجى إدخال رقم الهاتف' : null,
                ),
                SizedBox(height: Responsive.spacing(context, 15)),
                
                // Guests
                TextFormField(
                  controller: _guestsController,
                  decoration: _inputDecoration('عدد الضيوف'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'يرجى إدخال عدد الضيوف';
                    final guests = int.tryParse(v!);
                    if (guests == null || guests < 1) return 'عدد غير صحيح';
                    return null;
                  },
                ),
                SizedBox(height: Responsive.spacing(context, 30)),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitBooking,
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
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'حجز الطاولة',
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

  Widget _buildTableSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر رقم الطاولة',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: Responsive.fontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableTables.map((tableNum) {
            final isSelected = _selectedTableNumber == tableNum;
            return GestureDetector(
              onTap: () => setState(() => _selectedTableNumber = tableNum),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.whiteBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$tableNum',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Responsive.fontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.whiteText
                          : AppColors.darkText,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
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
    );
  }
}

