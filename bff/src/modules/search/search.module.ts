import { Module } from '@nestjs/common';

import { TOKENS } from 'src/common/constants/tokens';

import { MagentoSearchProvider } from './providers/magento-search.provider';

@Module({
  providers: [
    MagentoSearchProvider,
    {
      provide: TOKENS.SEARCH_PORT,
      useExisting: MagentoSearchProvider,
    },
  ],
  exports: [TOKENS.SEARCH_PORT],
})
export class SearchModule {}
