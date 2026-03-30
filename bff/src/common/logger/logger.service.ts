import { Injectable, LoggerService as NestLoggerService } from '@nestjs/common';

@Injectable()
export class AppLoggerService implements NestLoggerService {
  log(message: string, context?: string): void {
    this.write('info', message, { context });
  }

  error(message: string, trace?: string, context?: string): void {
    this.write('error', message, { context, trace });
  }

  warn(message: string, context?: string): void {
    this.write('warn', message, { context });
  }

  debug(message: string, context?: string): void {
    this.write('debug', message, { context });
  }

  verbose(message: string, context?: string): void {
    this.write('verbose', message, { context });
  }

  info(message: string, metadata: Record<string, unknown> = {}): void {
    this.write('info', message, metadata);
  }

  private write(level: string, message: string, metadata: Record<string, unknown>): void {
    // Console JSON keeps the foundation dependency-light while remaining structured.
    // eslint-disable-next-line no-console
    console.log(
      JSON.stringify({
        level,
        message,
        ...metadata,
        timestamp: new Date().toISOString()
      })
    );
  }
}
