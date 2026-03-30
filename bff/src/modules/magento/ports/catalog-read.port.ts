export abstract class CatalogReadPort {
  abstract healthcheck(): Promise<boolean>;
}
