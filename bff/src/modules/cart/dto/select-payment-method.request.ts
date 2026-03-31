import { IsString } from 'class-validator';

export class SelectPaymentMethodRequestDto {
  @IsString()
  code!: string;
}
