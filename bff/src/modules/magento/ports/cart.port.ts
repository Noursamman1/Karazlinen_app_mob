export type MagentoCartSessionContext = {
  customerId: string;
  customerEmail?: string;
  magentoCustomerToken: string;
  magentoCartId?: string;
};

export type MagentoSelectedOption = {
  code: string;
  label: string;
  value: string;
};

export type MagentoMoney = {
  amount: number;
  currencyCode: string;
  formatted: string;
};

export type MagentoCartItem = {
  itemId: string;
  productId: string;
  sku: string;
  name: string;
  quantity: number;
  unitPrice: MagentoMoney;
  lineTotal: MagentoMoney;
  thumbnail?: {
    url: string;
    alt?: string;
  };
  selectedOptions?: MagentoSelectedOption[];
};

export type MagentoShippingMethod = {
  carrierCode: string;
  methodCode: string;
  label: string;
  detail?: string;
  amount: MagentoMoney;
  selected: boolean;
};

export type MagentoPaymentMethod = {
  code: string;
  label: string;
  detail?: string;
  selected: boolean;
};

export type MagentoCartTotals = {
  subtotal: MagentoMoney;
  grandTotal: MagentoMoney;
  shipping?: MagentoMoney;
  tax?: MagentoMoney;
  discount?: MagentoMoney;
};

export type MagentoCartAddress = {
  id: string;
  firstName: string;
  lastName: string;
  phone: string;
  country: string;
  city: string;
  region?: string;
  streetLines: string[];
  postcode: string;
  isDefaultBilling: boolean;
  isDefaultShipping: boolean;
};

export type MagentoCheckoutBlocker =
  | 'cart_empty'
  | 'shipping_address_missing'
  | 'billing_address_missing'
  | 'shipping_method_missing'
  | 'payment_method_missing';

export type MagentoCart = {
  id: string;
  currencyCode: string;
  itemCount: number;
  items: MagentoCartItem[];
  totals: MagentoCartTotals;
  checkout: {
    ready: boolean;
    blockers: MagentoCheckoutBlocker[];
  };
  shippingAddress?: MagentoCartAddress;
  billingAddress?: MagentoCartAddress;
  selectedShippingMethod?: MagentoShippingMethod;
  selectedPaymentMethod?: MagentoPaymentMethod;
};

export type AddCartItemCommand = {
  sku: string;
  quantity: number;
  selectedOptions?: Record<string, string>;
};

export type UpdateCartItemQuantityCommand = {
  quantity: number;
};

export type CartAddressInput = {
  firstName: string;
  lastName: string;
  phone: string;
  country: string;
  city: string;
  region?: string;
  streetLines: string[];
  postcode: string;
  isDefaultBilling?: boolean;
  isDefaultShipping?: boolean;
};

export type AssignCartAddressesCommand = {
  shippingAddressId?: string;
  shippingAddress?: CartAddressInput;
  billingAddressId?: string;
  billingAddress?: CartAddressInput;
  sameAsShipping: boolean;
};

export type SelectShippingMethodCommand = {
  carrierCode: string;
  methodCode: string;
};

export type SelectPaymentMethodCommand = {
  code: string;
};

export abstract class CartPort {
  abstract getOrCreateCart(context: MagentoCartSessionContext): Promise<MagentoCart>;
  abstract addItem(context: MagentoCartSessionContext, command: AddCartItemCommand): Promise<MagentoCart>;
  abstract updateItemQuantity(
    context: MagentoCartSessionContext,
    itemId: string,
    command: UpdateCartItemQuantityCommand
  ): Promise<MagentoCart>;
  abstract removeItem(context: MagentoCartSessionContext, itemId: string): Promise<MagentoCart>;
  abstract assignAddresses(context: MagentoCartSessionContext, command: AssignCartAddressesCommand): Promise<MagentoCart>;
  abstract listShippingMethods(context: MagentoCartSessionContext): Promise<MagentoShippingMethod[]>;
  abstract selectShippingMethod(
    context: MagentoCartSessionContext,
    command: SelectShippingMethodCommand
  ): Promise<MagentoCart>;
  abstract listPaymentMethods(context: MagentoCartSessionContext): Promise<MagentoPaymentMethod[]>;
  abstract selectPaymentMethod(
    context: MagentoCartSessionContext,
    command: SelectPaymentMethodCommand
  ): Promise<MagentoCart>;
}
