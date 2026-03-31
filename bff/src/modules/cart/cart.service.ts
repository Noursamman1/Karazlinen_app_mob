import { Injectable } from '@nestjs/common';

import { AppLoggerService } from '../../common/logger/logger.service';
import {
  AddCartItemCommand,
  AssignCartAddressesCommand,
  CartPort,
  MagentoCart,
  MagentoPaymentMethod,
  MagentoShippingMethod,
  SelectPaymentMethodCommand,
  SelectShippingMethodCommand,
  UpdateCartItemQuantityCommand
} from '../magento/ports/cart.port';
import { SessionService } from '../sessions/session.service';

@Injectable()
export class CartService {
  constructor(
    private readonly sessionService: SessionService,
    private readonly cartPort: CartPort,
    private readonly logger: AppLoggerService
  ) {}

  async getCart(customerId: string, sessionId: string): Promise<MagentoCart> {
    const context = await this.sessionService.getMagentoSessionContext(customerId, sessionId);
    const cart = await this.cartPort.getOrCreateCart(context);
    await this.syncCartContext(customerId, sessionId, cart.id);
    return cart;
  }

  async addItem(customerId: string, sessionId: string, command: AddCartItemCommand): Promise<MagentoCart> {
    const context = await this.sessionService.getMagentoSessionContext(customerId, sessionId);
    const cart = await this.cartPort.addItem(context, command);
    await this.syncCartContext(customerId, sessionId, cart.id);
    this.logger.info('cart_item_added', {
      customer_id: customerId,
      session_id: sessionId,
      cart_id: cart.id,
      sku: command.sku,
      quantity: command.quantity
    });
    return cart;
  }

  async updateItemQuantity(
    customerId: string,
    sessionId: string,
    itemId: string,
    command: UpdateCartItemQuantityCommand
  ): Promise<MagentoCart> {
    const context = await this.sessionService.getMagentoSessionContext(customerId, sessionId);
    const cart = await this.cartPort.updateItemQuantity(context, itemId, command);
    await this.syncCartContext(customerId, sessionId, cart.id);
    this.logger.info('cart_item_quantity_updated', {
      customer_id: customerId,
      session_id: sessionId,
      cart_id: cart.id,
      item_id: itemId,
      quantity: command.quantity
    });
    return cart;
  }

  async removeItem(customerId: string, sessionId: string, itemId: string): Promise<MagentoCart> {
    const context = await this.sessionService.getMagentoSessionContext(customerId, sessionId);
    const cart = await this.cartPort.removeItem(context, itemId);
    await this.syncCartContext(customerId, sessionId, cart.id);
    this.logger.info('cart_item_removed', {
      customer_id: customerId,
      session_id: sessionId,
      cart_id: cart.id,
      item_id: itemId
    });
    return cart;
  }

  async assignAddresses(
    customerId: string,
    sessionId: string,
    command: AssignCartAddressesCommand
  ): Promise<MagentoCart> {
    const context = await this.sessionService.getMagentoSessionContext(customerId, sessionId);
    const cart = await this.cartPort.assignAddresses(context, command);
    await this.syncCartContext(customerId, sessionId, cart.id);
    this.logger.info('cart_addresses_assigned', {
      customer_id: customerId,
      session_id: sessionId,
      cart_id: cart.id,
      same_as_shipping: command.sameAsShipping
    });
    return cart;
  }

  async listShippingMethods(customerId: string, sessionId: string): Promise<{ items: MagentoShippingMethod[] }> {
    const context = await this.sessionService.getMagentoSessionContext(customerId, sessionId);
    return {
      items: await this.cartPort.listShippingMethods(context)
    };
  }

  async selectShippingMethod(
    customerId: string,
    sessionId: string,
    command: SelectShippingMethodCommand
  ): Promise<MagentoCart> {
    const context = await this.sessionService.getMagentoSessionContext(customerId, sessionId);
    const cart = await this.cartPort.selectShippingMethod(context, command);
    await this.syncCartContext(customerId, sessionId, cart.id);
    this.logger.info('cart_shipping_method_selected', {
      customer_id: customerId,
      session_id: sessionId,
      cart_id: cart.id,
      carrier_code: command.carrierCode,
      method_code: command.methodCode
    });
    return cart;
  }

  async listPaymentMethods(customerId: string, sessionId: string): Promise<{ items: MagentoPaymentMethod[] }> {
    const context = await this.sessionService.getMagentoSessionContext(customerId, sessionId);
    return {
      items: await this.cartPort.listPaymentMethods(context)
    };
  }

  async selectPaymentMethod(
    customerId: string,
    sessionId: string,
    command: SelectPaymentMethodCommand
  ): Promise<MagentoCart> {
    const context = await this.sessionService.getMagentoSessionContext(customerId, sessionId);
    const cart = await this.cartPort.selectPaymentMethod(context, command);
    await this.syncCartContext(customerId, sessionId, cart.id);
    this.logger.info('cart_payment_method_selected', {
      customer_id: customerId,
      session_id: sessionId,
      cart_id: cart.id,
      payment_method_code: command.code
    });
    return cart;
  }

  private async syncCartContext(customerId: string, sessionId: string, cartId: string): Promise<void> {
    await this.sessionService.updateMagentoCartId(customerId, sessionId, cartId);
  }
}
