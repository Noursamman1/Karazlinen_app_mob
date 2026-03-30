import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

export interface AccessTokenPayload {
  sub: string;
  sid: string;
  scope: string[];
  device_id?: string;
}

@Injectable()
export class AccessTokenStrategy extends PassportStrategy(Strategy) {
  constructor(configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: configService.getOrThrow<string>('ACCESS_TOKEN_PUBLIC_KEY'),
      algorithms: ['HS256']
    });
  }

  validate(payload: AccessTokenPayload): AccessTokenPayload {
    return payload;
  }
}
