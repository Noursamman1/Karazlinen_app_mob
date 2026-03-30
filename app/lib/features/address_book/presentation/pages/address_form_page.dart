import 'package:flutter/material.dart';

import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/design_system/theme/app_colors.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';

class AddressFormPage extends StatelessWidget {
  const AddressFormPage({
    super.key,
    this.initialAddress,
  });

  final AddressView? initialAddress;

  bool get isEditing => initialAddress != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'تعديل العنوان' : 'إضافة عنوان')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isEditing ? 'مراجعة بيانات العنوان الحالي' : 'إعداد عنوان جديد',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'النموذج جاهز للربط مع عقود create/update الحالية، لكن الحفظ الفعلي سيُفعّل عند توصيل write flow بالـBFF.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            initialValue: initialAddress?.firstName,
            decoration: const InputDecoration(labelText: 'الاسم الأول'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: initialAddress?.lastName,
            decoration: const InputDecoration(labelText: 'اسم العائلة'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: initialAddress?.phone,
            decoration: const InputDecoration(labelText: 'رقم الجوال'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: initialAddress?.city,
            decoration: const InputDecoration(labelText: 'المدينة'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: initialAddress?.region,
            decoration: const InputDecoration(labelText: 'المنطقة'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: initialAddress?.streetLines.join('، '),
            decoration: const InputDecoration(labelText: 'الحي / الشارع'),
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: initialAddress?.postcode,
            decoration: const InputDecoration(labelText: 'الرمز البريدي'),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (initialAddress?.isDefaultShipping ?? false)
                  const Text('هذا العنوان مميز حاليًا كعنوان افتراضي للشحن'),
                if (initialAddress?.isDefaultBilling ?? false) ...<Widget>[
                  if (initialAddress?.isDefaultShipping ?? false) const SizedBox(height: AppSpacing.xs),
                  const Text('هذا العنوان مميز حاليًا كعنوان افتراضي للفوترة'),
                ],
                if (!(initialAddress?.isDefaultShipping ?? false) && !(initialAddress?.isDefaultBilling ?? false))
                  const Text('يمكن تخصيص حالات الافتراضي عند تفعيل مسار الحفظ المتصل بالـBFF.'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: null,
            child: Text(isEditing ? 'تحديث العنوان سيتفعّل عند ربط الـBFF' : 'الحفظ سيتفعّل عند ربط الـBFF'),
          ),
        ],
      ),
    );
  }
}
