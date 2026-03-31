import { Module } from '@nestjs/common';

import { LoggerModule } from '../../common/logger/logger.module';
import { MagentoModule } from '../magento/magento.module';
import { SessionModule } from '../sessions/session.module';
import { CheckoutController } from './checkout.controller';
import { CheckoutService } from './checkout.service';

@Module({
  imports: [LoggerModule, SessionModule, MagentoModule],
  controllers: [CheckoutController],
  providers: [CheckoutService]
})
export class CheckoutModule {}
