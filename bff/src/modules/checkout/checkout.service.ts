import { BadRequestException, Injectable } from '@nestjs/common';

import { AppLoggerService } from '../../common/logger/logger.service';
import { CheckoutPort, PlaceOrderCommand, PlaceOrderResult } from '../magento/ports/checkout.port';
import { SessionService } from '../sessions/session.service';

@Injectable()
export class CheckoutService {
  constructor(
    private readonly sessionService: SessionService,
    private readonly checkoutPort: CheckoutPort,
    private readonly logger: AppLoggerService
  ) {}

  async placeOrder(
    customerId: string,
    sessionId: string,
    command: Omit<PlaceOrderCommand, 'idempotencyKey'>,
    idempotencyKey?: string
  ): Promise<PlaceOrderResult> {
    const normalizedKey = this.normalizeIdempotencyKey(idempotencyKey);
    const context = await this.sessionService.getMagentoSessionContext(customerId, sessionId);
    const result = await this.checkoutPort.placeOrder(context, {
      ...command,
      idempotencyKey: normalizedKey
    });
    await this.sessionService.updateMagentoCartId(customerId, sessionId, undefined);
    this.logger.info('checkout_place_order_requested', {
      customer_id: customerId,
      session_id: sessionId,
      previous_cart_id: context.magentoCartId ?? 'none',
      order_number: result.orderNumber
    });
    return result;
  }

  private normalizeIdempotencyKey(idempotencyKey?: string): string {
    const normalized = idempotencyKey?.trim();
    if (!normalized) {
      throw new BadRequestException({
        message: 'x-idempotency-key header is required for place-order requests',
        code: 'VALIDATION_ERROR'
      });
    }
    if (!/^[A-Za-z0-9._:-]{8,128}$/.test(normalized)) {
      throw new BadRequestException({
        message: 'x-idempotency-key header is invalid',
        code: 'VALIDATION_ERROR'
      });
    }
    return normalized;
  }
}
