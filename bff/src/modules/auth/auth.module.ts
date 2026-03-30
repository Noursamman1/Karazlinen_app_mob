import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';

import { LoggerModule } from '../../common/logger/logger.module';
import { SessionModule } from '../sessions/session.module';
import { MagentoModule } from '../magento/magento.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { AccessTokenStrategy } from './strategies/access-token.strategy';

@Module({
  imports: [
    ConfigModule,
    LoggerModule,
    SessionModule,
    MagentoModule,
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>('ACCESS_TOKEN_PRIVATE_KEY') ?? 'test-secret',
        signOptions: {
          algorithm: 'HS256',
          expiresIn: configService.get<number>('ACCESS_TOKEN_TTL_SECONDS', 300)
        }
      })
    })
  ],
  controllers: [AuthController],
  providers: [AuthService, AccessTokenStrategy]
})
export class AuthModule {}
