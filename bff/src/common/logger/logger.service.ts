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

  errorEvent(message: string, metadata: Record<string, unknown> = {}): void {
    this.write('error', message, metadata);
  }

  private write(level: string, message: string, metadata: Record<string, unknown>): void {
    const redactedMetadata = this.redactRecord(metadata);

    // Console JSON keeps the foundation dependency-light while remaining structured.
    // eslint-disable-next-line no-console
    console.log(
      JSON.stringify({
        level,
        message,
        ...redactedMetadata,
        timestamp: new Date().toISOString()
      })
    );
  }

  private redactRecord(value: Record<string, unknown>): Record<string, unknown> {
    return Object.fromEntries(
      Object.entries(value).map(([key, entryValue]) => [
        key,
        this.isSensitiveKey(key) ? '[REDACTED]' : this.redact(entryValue)
      ])
    );
  }

  private redact(value: unknown): unknown {
    if (Array.isArray(value)) {
      return value.map((item) => this.redact(item));
    }

    if (value != null && typeof value === 'object') {
      return this.redactRecord(value as Record<string, unknown>);
    }

    return value;
  }

  private isSensitiveKey(key: string): boolean {
    return /(authorization|password|refreshtoken|accesstoken|secret|cookie|token)/i.test(key);
  }
}
