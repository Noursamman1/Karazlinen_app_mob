import { Test } from '@nestjs/testing';

import { AppLoggerService } from '../../src/common/logger/logger.service';
import { CartService } from '../../src/modules/cart/cart.service';
import { CartPort, MagentoCart } from '../../src/modules/magento/ports/cart.port';
import { SessionService } from '../../src/modules/sessions/session.service';

describe('CartService', () => {
  it('loads cart via Magento context and persists the upstream cart id in session state', async () => {
    const getMagentoSessionContext = jest.fn().mockResolvedValue({
      sessionId: 'sid-1',
      customerId: 'cust-1',
      magentoCustomerToken: 'magento-token',
      magentoCartId: undefined
    });
    const getOrCreateCart = jest.fn<Promise<MagentoCart>, []>().mockResolvedValue({
      id: 'cart-1',
      currencyCode: 'SAR',
      itemCount: 0,
      items: [],
      totals: {
        subtotal: { amount: 0, currencyCode: 'SAR', formatted: '0 ر.س' },
        grandTotal: { amount: 0, currencyCode: 'SAR', formatted: '0 ر.س' }
      },
      checkout: {
        ready: false,
        blockers: ['cart_empty']
      }
    });
    const updateMagentoCartId = jest.fn().mockResolvedValue(undefined);

    const moduleRef = await Test.createTestingModule({
      providers: [
        CartService,
        {
          provide: SessionService,
          useValue: {
            getMagentoSessionContext,
            updateMagentoCartId
          }
        },
        {
          provide: CartPort,
          useValue: {
            getOrCreateCart,
            addItem: jest.fn(),
            updateItemQuantity: jest.fn(),
            removeItem: jest.fn(),
            assignAddresses: jest.fn(),
            listShippingMethods: jest.fn(),
            selectShippingMethod: jest.fn(),
            listPaymentMethods: jest.fn(),
            selectPaymentMethod: jest.fn()
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

    const service = moduleRef.get(CartService);
    const result = await service.getCart('cust-1', 'sid-1');

    expect(result.id).toBe('cart-1');
    expect(getOrCreateCart).toHaveBeenCalledWith({
      sessionId: 'sid-1',
      customerId: 'cust-1',
      magentoCustomerToken: 'magento-token',
      magentoCartId: undefined
    });
    expect(updateMagentoCartId).toHaveBeenCalledWith('cust-1', 'sid-1', 'cart-1');
  });

  it('adds item and keeps cart id synchronized in session state', async () => {
    const getMagentoSessionContext = jest.fn().mockResolvedValue({
      sessionId: 'sid-1',
      customerId: 'cust-1',
      magentoCustomerToken: 'magento-token',
      magentoCartId: 'cart-1'
    });
    const addItem = jest.fn<Promise<MagentoCart>, []>().mockResolvedValue({
      id: 'cart-1',
      currencyCode: 'SAR',
      itemCount: 1,
      items: [],
      totals: {
        subtotal: { amount: 399, currencyCode: 'SAR', formatted: '399 ر.س' },
        grandTotal: { amount: 399, currencyCode: 'SAR', formatted: '399 ر.س' }
      },
      checkout: {
        ready: false,
        blockers: ['shipping_address_missing', 'shipping_method_missing', 'payment_method_missing']
      }
    });
    const updateMagentoCartId = jest.fn().mockResolvedValue(undefined);

    const moduleRef = await Test.createTestingModule({
      providers: [
        CartService,
        {
          provide: SessionService,
          useValue: {
            getMagentoSessionContext,
            updateMagentoCartId
          }
        },
        {
          provide: CartPort,
          useValue: {
            getOrCreateCart: jest.fn(),
            addItem,
            updateItemQuantity: jest.fn(),
            removeItem: jest.fn(),
            assignAddresses: jest.fn(),
            listShippingMethods: jest.fn(),
            selectShippingMethod: jest.fn(),
            listPaymentMethods: jest.fn(),
            selectPaymentMethod: jest.fn()
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

    const service = moduleRef.get(CartService);

    await service.addItem('cust-1', 'sid-1', {
      sku: 'KL-100-Q-SND',
      quantity: 1,
      selectedOptions: {
        size: 'queen',
        color: 'sand'
      }
    });

    expect(addItem).toHaveBeenCalledWith(
      {
        sessionId: 'sid-1',
        customerId: 'cust-1',
        magentoCustomerToken: 'magento-token',
        magentoCartId: 'cart-1'
      },
      {
        sku: 'KL-100-Q-SND',
        quantity: 1,
        selectedOptions: {
          size: 'queen',
          color: 'sand'
        }
      }
    );
    expect(updateMagentoCartId).toHaveBeenCalledWith('cust-1', 'sid-1', 'cart-1');
  });
});
