import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/design_system/theme/app_colors.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final ProductSummaryView product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap ?? () => context.push('/product/${product.id}'),
      child: SectionCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.05,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.mist,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: product.thumbnail == null
                        ? const Icon(Icons.photo_outlined, size: 36, color: AppColors.accent)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              product.thumbnail!.url,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                PositionedDirectional(
                  top: AppSpacing.sm,
                  end: AppSpacing.sm,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: product.stockStatus == 'out_of_stock'
                          ? AppColors.surface.withValues(alpha: 0.94)
                          : AppColors.accentSoft.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        product.stockStatus == 'out_of_stock' ? 'نفد حاليًا' : 'جاهز للشحن',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontSize: 12,
                              color: product.stockStatus == 'out_of_stock'
                                  ? AppColors.danger
                                  : AppColors.success,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (product.subtitle != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                product.subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Spacer(),
            const SizedBox(height: AppSpacing.md),
            Text(
              product.price.formatted,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (product.compareAtPrice != null)
              Text(
                product.compareAtPrice!.formatted,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
