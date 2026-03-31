import { Module } from '@nestjs/common';

import { LoggerModule } from '../../common/logger/logger.module';
import { MagentoModule } from '../magento/magento.module';
import { SessionModule } from '../sessions/session.module';
import { CartController } from './cart.controller';
import { CartService } from './cart.service';

@Module({
  imports: [LoggerModule, SessionModule, MagentoModule],
  controllers: [CartController],
  providers: [CartService],
  exports: [CartService]
})
export class CartModule {}
