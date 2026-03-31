import { IsArray, IsBoolean, IsOptional, IsString, MinLength } from 'class-validator';

export class CartAddressInputDto {
  @IsString()
  firstName!: string;

  @IsString()
  lastName!: string;

  @IsString()
  phone!: string;

  @IsString()
  country!: string;

  @IsString()
  city!: string;

  @IsOptional()
  @IsString()
  region?: string;

  @IsArray()
  @MinLength(1, { each: true })
  streetLines!: string[];

  @IsString()
  postcode!: string;

  @IsOptional()
  @IsBoolean()
  isDefaultBilling?: boolean;

  @IsOptional()
  @IsBoolean()
  isDefaultShipping?: boolean;
}
