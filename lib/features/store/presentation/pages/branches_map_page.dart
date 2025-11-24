import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class BranchesMapPage extends StatelessWidget {
  const BranchesMapPage({super.key});

  final List<Map<String, dynamic>> _branches = const [
    {
      'name': 'الفرع الرئيسي',
      'address': 'مسقط، شارع السلطان قابوس',
      'phone': '+968 1234 5678',
      'hours': '6:00 ص - 11:00 م',
      'lat': 23.6145,
      'lng': 58.5453,
    },
    {
      'name': 'فرع السيب',
      'address': 'السيب، مجمع السيب التجاري',
      'phone': '+968 2345 6789',
      'hours': '7:00 ص - 10:00 م',
      'lat': 23.6700,
      'lng': 58.1890,
    },
    {
      'name': 'فرع صحار',
      'address': 'صحار، طريق الباطنة',
      'phone': '+968 3456 7890',
      'hours': '6:30 ص - 11:00 م',
      'lat': 24.3640,
      'lng': 56.7430,
    },
  ];

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
          'فروعنا',
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
            // خريطة بسيطة (يمكن استبدالها بخريطة حقيقية)
            Container(
              height: 250,
              margin: EdgeInsets.all(Responsive.spacing(context, 20)),
              decoration: BoxDecoration(
                color: AppColors.subtleText.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 64,
                          color: AppColors.primaryColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'خريطة الفروع',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Responsive.fontSize(context, 16),
                            color: AppColors.subtleText,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'يمكنك استخدام Google Maps',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Responsive.fontSize(context, 12),
                            color: AppColors.subtleText.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // نقاط الفروع على الخريطة
                  ..._branches.asMap().entries.map((entry) {
                    final index = entry.key;
                    final branch = entry.value;
                    return Positioned(
                      left: (index * 80.0) + 50,
                      top: 100 + (index * 30.0),
                      child: GestureDetector(
                        onTap: () => _openMap(branch['lat'], branch['lng']),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            // قائمة الفروع
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.spacing(context, 20),
                ),
                itemCount: _branches.length,
                itemBuilder: (context, index) {
                  return _buildBranchCard(context, _branches[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCard(BuildContext context, Map<String, dynamic> branch) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, 15)),
      padding: EdgeInsets.all(Responsive.spacing(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                branch['name'],
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: Responsive.fontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.location_on, color: AppColors.primaryColor),
                onPressed: () => _openMap(branch['lat'], branch['lng']),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_city, size: 18, color: AppColors.subtleText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  branch['address'],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Responsive.fontSize(context, 14),
                    color: AppColors.subtleText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 18, color: AppColors.subtleText),
              const SizedBox(width: 8),
              Text(
                branch['phone'],
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Responsive.fontSize(context, 14),
                  color: AppColors.subtleText,
                ),
              ),
              const SizedBox(width: 15),
              IconButton(
                icon: const Icon(Icons.phone_outlined, color: AppColors.primaryColor),
                onPressed: () => _makeCall(branch['phone']),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: AppColors.subtleText),
              const SizedBox(width: 8),
              Text(
                branch['hours'],
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Responsive.fontSize(context, 14),
                  color: AppColors.subtleText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openMap(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makeCall(String phone) async {
    final url = 'tel:$phone';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

