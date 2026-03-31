import { IsInt, IsObject, IsOptional, IsString, Min } from 'class-validator';

export class AddCartItemRequestDto {
  @IsString()
  sku!: string;

  @IsInt()
  @Min(1)
  quantity!: number;

  @IsOptional()
  @IsObject()
  selectedOptions?: Record<string, string>;
}
