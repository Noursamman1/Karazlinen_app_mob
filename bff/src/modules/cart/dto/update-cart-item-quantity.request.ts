import { IsInt, Min } from 'class-validator';

export class UpdateCartItemQuantityRequestDto {
  @IsInt()
  @Min(1)
  quantity!: number;
}
