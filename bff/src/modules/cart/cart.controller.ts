import { Body, Controller, Delete, Get, Param, Patch, Post, Put, Req, UseGuards } from '@nestjs/common';

import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AccessTokenPayload } from '../auth/strategies/access-token.strategy';
import { AddCartItemRequestDto } from './dto/add-cart-item.request';
import { UpdateCartItemQuantityRequestDto } from './dto/update-cart-item-quantity.request';
import { AssignCartAddressesRequestDto } from './dto/assign-cart-addresses.request';
import { SelectShippingMethodRequestDto } from './dto/select-shipping-method.request';
import { SelectPaymentMethodRequestDto } from './dto/select-payment-method.request';
import { CartService } from './cart.service';

@Controller('cart')
@UseGuards(JwtAuthGuard)
export class CartController {
  constructor(private readonly cartService: CartService) {}

  @Get()
  getCart(@Req() request: { user: AccessTokenPayload }) {
    return this.cartService.getCart(request.user.sub, request.user.sid);
  }

  @Post('items')
  addItem(@Req() request: { user: AccessTokenPayload }, @Body() body: AddCartItemRequestDto) {
    return this.cartService.addItem(request.user.sub, request.user.sid, body);
  }

  @Patch('items/:itemId')
  updateItemQuantity(
    @Req() request: { user: AccessTokenPayload },
    @Param('itemId') itemId: string,
    @Body() body: UpdateCartItemQuantityRequestDto
  ) {
    return this.cartService.updateItemQuantity(request.user.sub, request.user.sid, itemId, body);
  }

  @Delete('items/:itemId')
  removeItem(@Req() request: { user: AccessTokenPayload }, @Param('itemId') itemId: string) {
    return this.cartService.removeItem(request.user.sub, request.user.sid, itemId);
  }

  @Put('addresses')
  assignAddresses(@Req() request: { user: AccessTokenPayload }, @Body() body: AssignCartAddressesRequestDto) {
    return this.cartService.assignAddresses(request.user.sub, request.user.sid, body);
  }

  @Get('shipping-methods')
  listShippingMethods(@Req() request: { user: AccessTokenPayload }) {
    return this.cartService.listShippingMethods(request.user.sub, request.user.sid);
  }

  @Put('shipping-method')
  selectShippingMethod(@Req() request: { user: AccessTokenPayload }, @Body() body: SelectShippingMethodRequestDto) {
    return this.cartService.selectShippingMethod(request.user.sub, request.user.sid, body);
  }

  @Get('payment-methods')
  listPaymentMethods(@Req() request: { user: AccessTokenPayload }) {
    return this.cartService.listPaymentMethods(request.user.sub, request.user.sid);
  }

  @Put('payment-method')
  selectPaymentMethod(@Req() request: { user: AccessTokenPayload }, @Body() body: SelectPaymentMethodRequestDto) {
    return this.cartService.selectPaymentMethod(request.user.sub, request.user.sid, body);
  }
}
