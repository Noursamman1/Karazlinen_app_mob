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
  });

  final ProductSummaryView product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/product/${product.id}'),
      child: SectionCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.05,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: product.thumbnail == null
                    ? const Icon(Icons.photo_outlined, size: 36, color: AppColors.cedar)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          product.thumbnail!.url,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
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
            ],
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
