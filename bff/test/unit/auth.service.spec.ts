import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';

import { AuthService } from '../../src/modules/auth/auth.service';
import { AppLoggerService } from '../../src/common/logger/logger.service';
import { CustomerAuthPort } from '../../src/modules/magento/ports/customer-auth.port';
import { SessionService } from '../../src/modules/sessions/session.service';
import { JwtService } from '@nestjs/jwt';

describe('AuthService', () => {
  it('returns BFF tokens on login', async () => {
    const authenticateCustomer = jest.fn().mockResolvedValue({
      customerId: 'cust-1',
      customerEmail: 'customer@example.com',
      magentoCustomerToken: 'magento-token'
    });
    const createSession = jest.fn().mockResolvedValue({
      sessionId: 'sid-1',
      refreshToken: 'refresh-token'
    });
    const signAsync = jest.fn().mockResolvedValue('access-token');

    const moduleRef = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: CustomerAuthPort,
          useValue: {
            authenticateCustomer,
            fetchCustomerSummary: jest.fn()
          }
        },
        {
          provide: SessionService,
          useValue: {
            createSession,
            findActiveSession: jest.fn()
          }
        },
        {
          provide: JwtService,
          useValue: {
            signAsync
          }
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string, defaultValue: number) => defaultValue),
            getOrThrow: jest.fn(() => 'test-secret')
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

    const service = moduleRef.get(AuthService);
    const result = await service.login('customer@example.com', 'password123', 'device-12345');
    expect(result.refreshToken).toBe('refresh-token');
    expect(result.accessToken).toBe('access-token');
    expect(createSession).toHaveBeenCalledWith('cust-1', 30, {
      deviceId: 'device-12345',
      customerEmail: 'customer@example.com',
      magentoCustomerToken: 'magento-token'
    });
  });

  it('loads profile from Magento using active session context', async () => {
    const fetchCustomerSummary = jest.fn().mockResolvedValue({
      customerId: 'cust-1',
      firstName: 'Noura',
      lastName: 'Al Tamimi',
      email: 'noura@example.com'
    });
    const findActiveSession = jest.fn().mockResolvedValue({
      sessionId: 'sid-1',
      customerId: 'cust-1',
      magentoCustomerToken: 'magento-token',
      refreshTokenHash: 'hash',
      refreshExpiresAt: new Date(Date.now() + 60_000).toISOString(),
      createdAt: new Date().toISOString()
    });

    const moduleRef = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: CustomerAuthPort,
          useValue: {
            authenticateCustomer: jest.fn(),
            fetchCustomerSummary
          }
        },
        {
          provide: SessionService,
          useValue: {
            createSession: jest.fn(),
            findActiveSession
          }
        },
        {
          provide: JwtService,
          useValue: {
            signAsync: jest.fn()
          }
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string, defaultValue: number) => defaultValue),
            getOrThrow: jest.fn(() => 'test-secret')
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

    const service = moduleRef.get(AuthService);
    const result = await service.me('cust-1', 'sid-1');

    expect(result.authenticated).toBe(true);
    expect(fetchCustomerSummary).toHaveBeenCalledWith({
      customerId: 'cust-1',
      magentoCustomerToken: 'magento-token'
    });
  });

  it('rotates refresh tokens with device binding', async () => {
    const rotateRefreshToken = jest.fn().mockResolvedValue({
      session: { customerId: 'cust-1', sessionId: 'sid-2', deviceId: 'device-12345' },
      refreshToken: 'refresh-token-2'
    });

    const moduleRef = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: CustomerAuthPort,
          useValue: {
            authenticateCustomer: jest.fn(),
            fetchCustomerSummary: jest.fn()
          }
        },
        {
          provide: SessionService,
          useValue: {
            createSession: jest.fn(),
            findActiveSession: jest.fn(),
            rotateRefreshToken
          }
        },
        {
          provide: JwtService,
          useValue: {
            signAsync: jest.fn().mockResolvedValue('access-token-2')
          }
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string, defaultValue: number) => defaultValue),
            getOrThrow: jest.fn(() => 'test-secret')
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

    const service = moduleRef.get(AuthService);
    await service.refresh('a'.repeat(96), 'device-12345');

    expect(rotateRefreshToken).toHaveBeenCalledWith('a'.repeat(96), 30, 'device-12345');
  });

  it('revokes only owned sessions on logout', async () => {
    const revokeOwnedSession = jest.fn().mockResolvedValue(undefined);

    const moduleRef = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: CustomerAuthPort,
          useValue: {
            authenticateCustomer: jest.fn(),
            fetchCustomerSummary: jest.fn()
          }
        },
        {
          provide: SessionService,
          useValue: {
            createSession: jest.fn(),
            findActiveSession: jest.fn(),
            revokeOwnedSession
          }
        },
        {
          provide: JwtService,
          useValue: {
            signAsync: jest.fn()
          }
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string, defaultValue: number) => defaultValue),
            getOrThrow: jest.fn(() => 'test-secret')
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

    const service = moduleRef.get(AuthService);
    await service.logout('cust-1', 'sid-1');

    expect(revokeOwnedSession).toHaveBeenCalledWith('cust-1', 'sid-1');
  });
});
