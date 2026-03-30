import 'package:flutter/material.dart';

import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';

class AddressFormPage extends StatelessWidget {
  const AddressFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عنوان')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          const TextField(decoration: InputDecoration(labelText: 'الاسم الأول')),
          const SizedBox(height: AppSpacing.md),
          const TextField(decoration: InputDecoration(labelText: 'اسم العائلة')),
          const SizedBox(height: AppSpacing.md),
          const TextField(decoration: InputDecoration(labelText: 'رقم الجوال')),
          const SizedBox(height: AppSpacing.md),
          const TextField(decoration: InputDecoration(labelText: 'المدينة')),
          const SizedBox(height: AppSpacing.md),
          const TextField(decoration: InputDecoration(labelText: 'الحي / الشارع')),
          const SizedBox(height: AppSpacing.lg),
          const FilledButton(
            onPressed: null,
            child: Text('الحفظ متاح عند ربط الـ BFF'),
          ),
        ],
      ),
    );
  }
}
