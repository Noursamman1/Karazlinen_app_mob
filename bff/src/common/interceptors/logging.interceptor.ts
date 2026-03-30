import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable, tap } from 'rxjs';

import { AppLoggerService } from '../logger/logger.service';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  constructor(private readonly logger: AppLoggerService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const request = context.switchToHttp().getRequest();
    const startedAt = Date.now();

    return next.handle().pipe(
      tap({
        next: () => {
          this.logger.info('request_completed', {
            request_id: request.requestId,
            method: request.method,
            path: request.originalUrl,
            duration_ms: Date.now() - startedAt
          });
        }
      })
    );
  }
}
