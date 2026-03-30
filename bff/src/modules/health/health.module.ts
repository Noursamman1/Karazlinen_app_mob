import { Module } from '@nestjs/common';

import { MagentoModule } from '../magento/magento.module';
import { SessionModule } from '../sessions/session.module';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';

@Module({
  imports: [SessionModule, MagentoModule],
  controllers: [HealthController],
  providers: [HealthService]
})
export class HealthModule {}
