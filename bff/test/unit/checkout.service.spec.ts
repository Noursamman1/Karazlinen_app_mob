import { BadRequestException } from '@nestjs/common';
import { Test } from '@nestjs/testing';

import { AppLoggerService } from '../../src/common/logger/logger.service';
import { CheckoutService } from '../../src/modules/checkout/checkout.service';
import { CheckoutPort } from '../../src/modules/magento/ports/checkout.port';
import { SessionService } from '../../src/modules/sessions/session.service';

describe('CheckoutService', () => {
  it('requires an idempotency key for place-order requests', async () => {
    const moduleRef = await Test.createTestingModule({
      providers: [
        CheckoutService,
        {
          provide: SessionService,
          useValue: {
            getMagentoSessionContext: jest.fn(),
            updateMagentoCartId: jest.fn()
          }
        },
        {
          provide: CheckoutPort,
          useValue: {
            placeOrder: jest.fn()
          }
        },
        {
          provide: AppLoggerService,
          useValue: {
            info: jest.fn(),
            warn: jest.fn(),
            errorEvent: jest.fn()
          }
        }
      ]
    }).compile();

    const service = moduleRef.get(CheckoutService);

    await expect(
      service.placeOrder('cust-1', 'sid-1', {
        termsAccepted: true
      })
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('delegates place-order to Magento checkout boundary and clears the stored cart id', async () => {
    const getMagentoSessionContext = jest.fn().mockResolvedValue({
      sessionId: 'sid-1',
      customerId: 'cust-1',
      magentoCustomerToken: 'magento-token',
      magentoCartId: 'cart-1'
    });
    const updateMagentoCartId = jest.fn().mockResolvedValue(undefined);
    const placeOrder = jest.fn().mockResolvedValue({
      orderNumber: '100000301',
      status: 'placed'
    });

    const moduleRef = await Test.createTestingModule({
      providers: [
        CheckoutService,
        {
          provide: SessionService,
          useValue: {
            getMagentoSessionContext,
            updateMagentoCartId
          }
        },
        {
          provide: CheckoutPort,
          useValue: {
            placeOrder
          }
        },
        {
          provide: AppLoggerService,
          useValue: {
            info: jest.fn(),
            warn: jest.fn(),
            errorEvent: jest.fn()
          }
        }
      ]
    }).compile();

    const service = moduleRef.get(CheckoutService);
    const result = await service.placeOrder(
      'cust-1',
      'sid-1',
      {
        termsAccepted: true,
        customerNote: 'اترك الطلب عند الباب'
      },
      'checkout-key-1234'
    );

    expect(result.orderNumber).toBe('100000301');
    expect(placeOrder).toHaveBeenCalledWith(
      {
        sessionId: 'sid-1',
        customerId: 'cust-1',
        magentoCustomerToken: 'magento-token',
        magentoCartId: 'cart-1'
      },
      {
        termsAccepted: true,
        customerNote: 'اترك الطلب عند الباب',
        idempotencyKey: 'checkout-key-1234'
      }
    );
    expect(updateMagentoCartId).toHaveBeenCalledWith('cust-1', 'sid-1', undefined);
  });
});
