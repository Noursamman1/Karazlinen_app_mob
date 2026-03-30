export abstract class OrderReadPort {
  abstract healthcheck(): Promise<boolean>;
}
