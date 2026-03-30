import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { Request, Response } from 'express';

import { AppLoggerService } from '../logger/logger.service';

@Catch()
@Injectable()
export class ProblemDetailsFilter implements ExceptionFilter {
  constructor(private readonly logger: AppLoggerService) {}

  catch(exception: unknown, host: ArgumentsHost): void {
    const context = host.switchToHttp();
    const response = context.getResponse<Response>();
    const request = context.getRequest<Request & { requestId?: string }>();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const exceptionBody =
      exception instanceof HttpException ? exception.getResponse() : null;

    const detail =
      typeof exceptionBody === 'object' && exceptionBody !== null && 'message' in exceptionBody
        ? this.normalizeDetail(exceptionBody.message, status)
        : exception instanceof Error && status < HttpStatus.INTERNAL_SERVER_ERROR
          ? exception.message
          : 'An unexpected error occurred';

    const code =
      typeof exceptionBody === 'object' && exceptionBody !== null && 'code' in exceptionBody
        ? String(exceptionBody.code)
        : status === HttpStatus.BAD_REQUEST
          ? 'VALIDATION_ERROR'
          : status === HttpStatus.REQUEST_TIMEOUT
            ? 'REQUEST_TIMEOUT'
        : status === HttpStatus.TOO_MANY_REQUESTS
          ? 'RATE_LIMITED'
          : status === HttpStatus.UNAUTHORIZED
            ? 'AUTH_SESSION_EXPIRED'
            : 'INTERNAL_ERROR';

    if (status >= HttpStatus.INTERNAL_SERVER_ERROR) {
      this.logger.errorEvent('request_exception', {
        request_id: request.requestId ?? 'unknown',
        method: request.method,
        path: request.originalUrl,
        status_code: status,
        error_name: exception instanceof Error ? exception.name : 'UnknownError',
        error_message: exception instanceof Error ? exception.message : 'Unexpected error'
      });
    }

    response.status(status).json({
      type: this.problemType(code),
      title: HttpStatus[status] ?? 'Error',
      status,
      detail,
      instance: request.originalUrl,
      code,
      request_id: request.requestId ?? 'unknown'
    });
  }

  private normalizeDetail(message: unknown, status: number): string {
    if (Array.isArray(message)) {
      return message.join('; ');
    }

    if (typeof message === 'string') {
      return status >= HttpStatus.INTERNAL_SERVER_ERROR ? 'An unexpected error occurred' : message;
    }

    return status >= HttpStatus.INTERNAL_SERVER_ERROR ? 'An unexpected error occurred' : 'Request failed';
  }

  private problemType(code: string): string {
    return `https://api.karazlinen.example/errors/${code.toLowerCase().replace(/_/g, '-')}`;
  }
}
