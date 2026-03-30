import { Injectable } from '@nestjs/common';

import { SearchPort } from '../search.port';

@Injectable()
export class MagentoSearchProvider implements SearchPort {
  providerName(): string {
    return 'magento';
  }
}
