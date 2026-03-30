import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable, catchError, tap, throwError } from 'rxjs';

import { AppLoggerService } from '../logger/logger.service';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  constructor(private readonly logger: AppLoggerService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const request = context.switchToHttp().getRequest();
    const response = context.switchToHttp().getResponse();
    const startedAt = Date.now();

    return next.handle().pipe(
      tap({
        next: () => {
          this.logger.info('request_completed', {
            request_id: request.requestId,
            method: request.method,
            path: request.originalUrl,
            status_code: response.statusCode,
            duration_ms: Date.now() - startedAt
          });
        }
      }),
      catchError((error: unknown) => {
        this.logger.errorEvent('request_failed', {
          request_id: request.requestId,
          method: request.method,
          path: request.originalUrl,
          status_code: response.statusCode,
          duration_ms: Date.now() - startedAt,
          error_name: error instanceof Error ? error.name : 'UnknownError',
          error_message: error instanceof Error ? error.message : 'Unexpected error'
        });
        return throwError(() => error);
      })
    );
  }
}
