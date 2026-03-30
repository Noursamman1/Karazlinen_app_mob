import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class ProblemDetailsFilter implements ExceptionFilter {
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
        ? String(exceptionBody.message)
        : exception instanceof Error
          ? exception.message
          : 'Unexpected error';

    const code =
      typeof exceptionBody === 'object' && exceptionBody !== null && 'code' in exceptionBody
        ? String(exceptionBody.code)
        : status === HttpStatus.TOO_MANY_REQUESTS
          ? 'RATE_LIMITED'
          : status === HttpStatus.UNAUTHORIZED
            ? 'AUTH_SESSION_EXPIRED'
            : 'INTERNAL_ERROR';

    response.status(status).json({
      type: 'about:blank',
      title: HttpStatus[status] ?? 'Error',
      status,
      detail,
      instance: request.originalUrl,
      code,
      request_id: request.requestId ?? 'unknown'
    });
  }
}
