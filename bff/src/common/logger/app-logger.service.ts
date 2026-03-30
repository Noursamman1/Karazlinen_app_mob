import { Injectable, LoggerService } from '@nestjs/common';

type LogContext = Record<string, unknown>;

@Injectable()
export class AppLoggerService implements LoggerService {
  log(message: string, context?: string): void {
    this.info(message, context ? { context } : undefined);
  }

  error(message: string, trace?: string, context?: string): void {
    this.print('error', message, { context, trace });
  }

  warn(message: string, context?: string): void {
    this.print('warn', message, { context });
  }

  debug(message: string, context?: string): void {
    this.print('debug', message, { context });
  }

  verbose(message: string, context?: string): void {
    this.print('verbose', message, { context });
  }

  info(message: string, context?: LogContext): void {
    this.print('info', message, context);
  }

  private print(level: string, message: string, context?: LogContext): void {
    // JSON logs keep the BFF ready for aggregation without coupling to a vendor SDK.
    process.stdout.write(
      `${JSON.stringify({
        level,
        message,
        ...context,
        timestamp: new Date().toISOString(),
      })}\n`,
    );
  }
}
