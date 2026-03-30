import { CallHandler, ExecutionContext, Injectable, NestInterceptor, RequestTimeoutException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Observable, TimeoutError, catchError, timeout } from 'rxjs';

@Injectable()
export class TimeoutInterceptor implements NestInterceptor {
  constructor(private readonly configService: ConfigService) {}

  intercept(_context: ExecutionContext, next: CallHandler): Observable<unknown> {
    return next.handle().pipe(
      timeout(this.configService.get<number>('REQUEST_TIMEOUT_MS', 15000)),
      catchError((error: unknown) => {
        if (error instanceof TimeoutError) {
          throw new RequestTimeoutException({
            message: 'Request timed out',
            code: 'REQUEST_TIMEOUT'
          });
        }
        throw error;
      })
    );
  }
}
