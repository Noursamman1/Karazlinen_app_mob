import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { UnauthorizedException } from '@nestjs/common';

import { SessionService } from '../../src/modules/sessions/session.service';
import { SessionRepository } from '../../src/modules/sessions/session.repository';

describe('SessionService', () => {
  it('revokes existing device-bound session before creating a new one', async () => {
    const repository = {
      hashRefreshToken: jest.fn().mockReturnValue('hash-1'),
      save: jest.fn().mockResolvedValue(undefined),
      findCurrentSessionForCustomerDevice: jest.fn().mockResolvedValue({
        sessionId: 'sid-old',
        customerId: 'cust-1',
        deviceId: 'device-12345',
        refreshTokenHash: 'hash-old',
        refreshExpiresAt: new Date(Date.now() + 60_000).toISOString(),
        createdAt: new Date(Date.now() - 60_000).toISOString()
      }),
      findSessionsByCustomer: jest.fn().mockResolvedValue([]),
      revokeSessionWithReason: jest.fn().mockResolvedValue(undefined)
    };

    const moduleRef = await Test.createTestingModule({
      providers: [
        SessionService,
        { provide: SessionRepository, useValue: repository },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string, defaultValue: number) => defaultValue)
          }
        }
      ]
    }).compile();

    const service = moduleRef.get(SessionService);
    await service.createSession('cust-1', 30, { deviceId: 'device-12345' });

    expect(repository.revokeSessionWithReason).toHaveBeenCalledWith('sid-old', 'device_replaced');
    expect(repository.save).toHaveBeenCalled();
  });

  it('rejects refresh token rotation from a different device', async () => {
    const repository = {
      findByRefreshToken: jest.fn().mockResolvedValue({
        sessionId: 'sid-1',
        customerId: 'cust-1',
        deviceId: 'device-12345',
        refreshTokenHash: 'hash-1',
        refreshExpiresAt: new Date(Date.now() + 60_000).toISOString(),
        createdAt: new Date().toISOString()
      }),
      revokeSessionWithReason: jest.fn().mockResolvedValue(undefined),
      hashRefreshToken: jest.fn(),
      save: jest.fn(),
      findCurrentSessionForCustomerDevice: jest.fn(),
      findSessionsByCustomer: jest.fn().mockResolvedValue([])
    };

    const moduleRef = await Test.createTestingModule({
      providers: [
        SessionService,
        { provide: SessionRepository, useValue: repository },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string, defaultValue: number) => defaultValue)
          }
        }
      ]
    }).compile();

    const service = moduleRef.get(SessionService);

    await expect(service.rotateRefreshToken('a'.repeat(96), 30, 'device-99999')).rejects.toBeInstanceOf(
      UnauthorizedException
    );
    expect(repository.revokeSessionWithReason).toHaveBeenCalledWith('sid-1', 'device_mismatch');
  });
});
