import { IsBoolean, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class PlaceOrderRequestDto {
  @IsBoolean()
  termsAccepted!: boolean;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(500)
  customerNote?: string;
}
