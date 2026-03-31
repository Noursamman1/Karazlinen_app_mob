import { IsString } from 'class-validator';

export class SelectShippingMethodRequestDto {
  @IsString()
  carrierCode!: string;

  @IsString()
  methodCode!: string;
}
