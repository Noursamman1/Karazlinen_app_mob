import { Injectable, ServiceUnavailableException, UnauthorizedException } from '@nestjs/common';

import { AppLoggerService } from '../../common/logger/logger.service';
import {
  CustomerAuthPort,
  MagentoAuthenticationResult,
  MagentoCustomerSessionContext,
  MagentoCustomerSummary
} from './ports/customer-auth.port';
import { CatalogReadPort } from './ports/catalog-read.port';
import { OrderReadPort } from './ports/order-read.port';
import { SearchPort } from '../search/search.port';
import { MagentoConfig } from './magento.config';
import {
  AddCartItemCommand,
  AssignCartAddressesCommand,
  CartPort,
  MagentoCart,
  MagentoCartSessionContext,
  MagentoPaymentMethod,
  MagentoShippingMethod,
  SelectPaymentMethodCommand,
  SelectShippingMethodCommand,
  UpdateCartItemQuantityCommand
} from './ports/cart.port';
import { CheckoutPort, PlaceOrderCommand, PlaceOrderResult } from './ports/checkout.port';

type MagentoGraphQlError = {
  message?: string;
};

type MagentoGraphQlResponse<T> = {
  data?: T;
  errors?: MagentoGraphQlError[];
};

type MagentoCustomerResponse = {
  customer?: {
    id: number | string;
    firstname: string;
    lastname: string;
    email: string;
    addresses?: Array<{ telephone?: string | null }>;
  } | null;
};

@Injectable()
export class MagentoClient implements CustomerAuthPort, CatalogReadPort, CartPort, CheckoutPort, OrderReadPort, SearchPort {
  private consecutiveFailures = 0;
  private circuitOpenedAt?: number;

  constructor(
    private readonly magentoConfig: MagentoConfig,
    private readonly logger: AppLoggerService
  ) {}

  async authenticateCustomer(email: string, password: string): Promise<MagentoAuthenticationResult> {
    const magentoCustomerToken = await this.fetchCustomerToken(email, password);
    const profile = await this.fetchCustomerSummaryByToken(magentoCustomerToken);

    return {
      customerId: profile.customerId,
      customerEmail: profile.email,
      magentoCustomerToken
    };
  }

  async fetchCustomerSummary(context: MagentoCustomerSessionContext): Promise<MagentoCustomerSummary> {
    const profile = await this.fetchCustomerSummaryByToken(context.magentoCustomerToken);
    if (profile.customerId !== context.customerId) {
      throw new UnauthorizedException({
        message: 'Session customer context is invalid',
        code: 'AUTH_SESSION_EXPIRED'
      });
    }
    return profile;
  }

  async healthcheck(): Promise<boolean> {
    try {
      const response = await this.executeGraphQl<{ storeConfig?: { id?: number | string } | null }>({
        query: 'query MobileHealthcheck { storeConfig { id } }'
      });
      return Boolean(response.data?.storeConfig) && !response.errors?.length;
    } catch {
      return false;
    }
  }

  providerName(): string {
    return 'magento';
  }

  async getOrCreateCart(_: MagentoCartSessionContext): Promise<MagentoCart> {
    throw this.upstreamUnavailable('Magento cart orchestration is defined but not wired in this phase');
  }

  async addItem(_: MagentoCartSessionContext, __: AddCartItemCommand): Promise<MagentoCart> {
    throw this.upstreamUnavailable('Magento cart orchestration is defined but not wired in this phase');
  }

  async updateItemQuantity(
    _: MagentoCartSessionContext,
    __: string,
    ___: UpdateCartItemQuantityCommand
  ): Promise<MagentoCart> {
    throw this.upstreamUnavailable('Magento cart orchestration is defined but not wired in this phase');
  }

  async removeItem(_: MagentoCartSessionContext, __: string): Promise<MagentoCart> {
    throw this.upstreamUnavailable('Magento cart orchestration is defined but not wired in this phase');
  }

  async assignAddresses(_: MagentoCartSessionContext, __: AssignCartAddressesCommand): Promise<MagentoCart> {
    throw this.upstreamUnavailable('Magento cart orchestration is defined but not wired in this phase');
  }

  async listShippingMethods(_: MagentoCartSessionContext): Promise<MagentoShippingMethod[]> {
    throw this.upstreamUnavailable('Magento shipping method orchestration is defined but not wired in this phase');
  }

  async selectShippingMethod(_: MagentoCartSessionContext, __: SelectShippingMethodCommand): Promise<MagentoCart> {
    throw this.upstreamUnavailable('Magento shipping method orchestration is defined but not wired in this phase');
  }

  async listPaymentMethods(_: MagentoCartSessionContext): Promise<MagentoPaymentMethod[]> {
    throw this.upstreamUnavailable('Magento payment method orchestration is defined but not wired in this phase');
  }

  async selectPaymentMethod(_: MagentoCartSessionContext, __: SelectPaymentMethodCommand): Promise<MagentoCart> {
    throw this.upstreamUnavailable('Magento payment method orchestration is defined but not wired in this phase');
  }

  async placeOrder(_: MagentoCartSessionContext, __: PlaceOrderCommand): Promise<PlaceOrderResult> {
    throw this.upstreamUnavailable('Magento place-order orchestration is defined but not wired in this phase');
  }

  private async fetchCustomerToken(email: string, password: string): Promise<string> {
    const response = await this.requestJson({
      path: this.magentoConfig.customerTokenPath,
      method: 'POST',
      body: { username: email, password }
    });

    if (response.status === 400 || response.status === 401) {
      throw new UnauthorizedException({
        message: 'Email or password is incorrect',
        code: 'AUTH_INVALID_CREDENTIALS'
      });
    }

    if (!response.ok) {
      throw this.upstreamUnavailable('Magento authentication endpoint is unavailable');
    }

    const token = this.parseTokenResponse(response.body);
    if (!token) {
      throw this.upstreamUnavailable('Magento authentication response was invalid');
    }

    return token;
  }

  private async fetchCustomerSummaryByToken(magentoCustomerToken: string): Promise<MagentoCustomerSummary> {
    const response = await this.executeGraphQl<MagentoCustomerResponse>(
      {
        query: `
          query MobileCustomerSummary {
            customer {
              id
              firstname
              lastname
              email
              addresses {
                telephone
              }
            }
          }
        `
      },
      magentoCustomerToken
    );

    const unauthorizedFromMagento =
      response.errors?.some((error) => (error.message ?? '').toLowerCase().includes('authorized')) ?? false;
    if (unauthorizedFromMagento || !response.data?.customer) {
      throw new UnauthorizedException({
        message: 'Session is invalid or expired',
        code: 'AUTH_SESSION_EXPIRED'
      });
    }

    const customer = response.data.customer;
    const firstPhone = customer.addresses?.find((address) => Boolean(address.telephone))?.telephone ?? undefined;
    return {
      customerId: String(customer.id),
      firstName: customer.firstname,
      lastName: customer.lastname,
      email: customer.email,
      phone: firstPhone ?? undefined
    };
  }

  private async executeGraphQl<TData>(
    body: { query: string; variables?: Record<string, unknown> },
    magentoCustomerToken?: string
  ): Promise<MagentoGraphQlResponse<TData>> {
    const response = await this.requestJson({
      path: this.magentoConfig.graphQlPath,
      method: 'POST',
      body,
      magentoCustomerToken
    });

    if (!response.ok) {
      if (response.status === 401) {
        throw new UnauthorizedException({
          message: 'Session is invalid or expired',
          code: 'AUTH_SESSION_EXPIRED'
        });
      }
      throw this.upstreamUnavailable('Magento GraphQL endpoint is unavailable');
    }

    if (!response.body || typeof response.body !== 'object') {
      throw this.upstreamUnavailable('Magento GraphQL response was invalid');
    }

    return response.body as MagentoGraphQlResponse<TData>;
  }

  private parseTokenResponse(responseBody: unknown): string | null {
    if (typeof responseBody === 'string') {
      return responseBody;
    }

    if (
      typeof responseBody === 'object' &&
      responseBody !== null &&
      'token' in responseBody &&
      typeof (responseBody as { token?: unknown }).token === 'string'
    ) {
      return (responseBody as { token: string }).token;
    }

    return null;
  }

  private async requestJson(params: {
    path: string;
    method: 'POST' | 'GET';
    body?: unknown;
    magentoCustomerToken?: string;
  }): Promise<{ ok: boolean; status: number; body: unknown }> {
    return this.executeWithResilience(async () => {
      const url = new URL(params.path, this.magentoConfig.baseUrl).toString();
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), this.magentoConfig.timeoutMs);

      try {
        const response = await fetch(url, {
          method: params.method,
          headers: this.buildHeaders(params.magentoCustomerToken),
          body: params.body != null ? JSON.stringify(params.body) : undefined,
          signal: controller.signal
        });

        const rawBody = await response.text();
        const parsedBody = rawBody.length ? this.parseJsonSafely(rawBody) : null;

        if (this.shouldTripOnStatus(response.status)) {
          throw this.upstreamUnavailable(`Magento responded with retryable status ${response.status}`);
        }

        return {
          ok: response.ok,
          status: response.status,
          body: parsedBody
        };
      } catch (error: unknown) {
        if (error instanceof UnauthorizedException) {
          throw error;
        }
        if (error instanceof ServiceUnavailableException) {
          throw error;
        }
        if (error instanceof Error && error.name === 'AbortError') {
          throw this.upstreamUnavailable('Magento request timed out');
        }
        throw this.upstreamUnavailable('Magento request failed');
      } finally {
        clearTimeout(timeoutId);
      }
    });
  }

  private buildHeaders(magentoCustomerToken?: string): Record<string, string> {
    const headers: Record<string, string> = {
      Accept: 'application/json',
      'Content-Type': 'application/json',
      Store: this.magentoConfig.storeCode
    };
    if (magentoCustomerToken) {
      headers.Authorization = `Bearer ${magentoCustomerToken}`;
    }
    return headers;
  }

  private parseJsonSafely(rawBody: string): unknown {
    try {
      return JSON.parse(rawBody);
    } catch {
      return rawBody;
    }
  }

  private upstreamUnavailable(message: string): ServiceUnavailableException {
    return new ServiceUnavailableException({
      message,
      code: 'UPSTREAM_MAGENTO_UNAVAILABLE'
    });
  }

  private async executeWithResilience<T>(operation: () => Promise<T>): Promise<T> {
    this.assertCircuitClosed();

    let lastError: ServiceUnavailableException | undefined;
    const attempts = this.magentoConfig.retryAttempts + 1;

    for (let attempt = 1; attempt <= attempts; attempt += 1) {
      try {
        const result = await operation();
        this.recordSuccess();
        return result;
      } catch (error: unknown) {
        if (!(error instanceof ServiceUnavailableException)) {
          throw error;
        }

        lastError = error;
        this.recordFailure(error.message);

        if (attempt >= attempts) {
          break;
        }

        await this.delay(this.magentoConfig.retryBackoffMs * attempt);
        this.assertCircuitClosed();
      }
    }

    throw lastError ?? this.upstreamUnavailable('Magento request failed');
  }

  private assertCircuitClosed(): void {
    if (this.circuitOpenedAt == null) {
      return;
    }

    const elapsed = Date.now() - this.circuitOpenedAt;
    if (elapsed >= this.magentoConfig.circuitBreakerResetMs) {
      this.circuitOpenedAt = undefined;
      this.consecutiveFailures = 0;
      return;
    }

    throw this.upstreamUnavailable('Magento circuit breaker is open');
  }

  private recordSuccess(): void {
    this.consecutiveFailures = 0;
    this.circuitOpenedAt = undefined;
  }

  private recordFailure(message: string): void {
    this.consecutiveFailures += 1;
    if (this.consecutiveFailures >= this.magentoConfig.circuitBreakerThreshold) {
      this.circuitOpenedAt = Date.now();
      this.logger.warn('magento_circuit_opened', `MagentoClient failures=${this.consecutiveFailures}`);
    } else {
      this.logger.warn('magento_retryable_failure', `MagentoClient ${message}`);
    }
  }

  private shouldTripOnStatus(status: number): boolean {
    return status === 429 || status >= 500;
  }

  private async delay(milliseconds: number): Promise<void> {
    await new Promise((resolve) => setTimeout(resolve, milliseconds));
  }
}
