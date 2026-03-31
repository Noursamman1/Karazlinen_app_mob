import { MagentoCartSessionContext } from './cart.port';

export type PlaceOrderCommand = {
  termsAccepted: boolean;
  customerNote?: string;
  idempotencyKey: string;
};

export type PlaceOrderResult = {
  orderNumber: string;
  status: 'placed';
};

export abstract class CheckoutPort {
  abstract placeOrder(context: MagentoCartSessionContext, command: PlaceOrderCommand): Promise<PlaceOrderResult>;
}
