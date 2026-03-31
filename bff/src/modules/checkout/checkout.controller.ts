import { Body, Controller, Headers, Post, Req, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AccessTokenPayload } from '../auth/strategies/access-token.strategy';
import { PlaceOrderRequestDto } from './dto/place-order.request';
import { CheckoutService } from './checkout.service';

@Controller('checkout')
@UseGuards(JwtAuthGuard)
export class CheckoutController {
  constructor(private readonly checkoutService: CheckoutService) {}

  @Post('place-order')
  placeOrder(
    @Req() request: { user: AccessTokenPayload },
    @Body() body: PlaceOrderRequestDto,
    @Headers('x-idempotency-key') idempotencyKey?: string
  ) {
    return this.checkoutService.placeOrder(request.user.sub, request.user.sid, body, idempotencyKey);
  }
}
