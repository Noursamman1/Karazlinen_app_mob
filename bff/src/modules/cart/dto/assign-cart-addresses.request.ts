import { IsBoolean, IsOptional, IsString, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

import { CartAddressInputDto } from './cart-address.input';

export class AssignCartAddressesRequestDto {
  @IsOptional()
  @IsString()
  shippingAddressId?: string;

  @IsOptional()
  @ValidateNested()
  @Type(() => CartAddressInputDto)
  shippingAddress?: CartAddressInputDto;

  @IsOptional()
  @IsString()
  billingAddressId?: string;

  @IsOptional()
  @ValidateNested()
  @Type(() => CartAddressInputDto)
  billingAddress?: CartAddressInputDto;

  @IsBoolean()
  sameAsShipping!: boolean;
}
