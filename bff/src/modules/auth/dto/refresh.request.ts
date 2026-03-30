import { Transform } from 'class-transformer';
import { IsHexadecimal, IsString, MaxLength, MinLength } from 'class-validator';

export class RefreshRequestDto {
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  @IsHexadecimal()
  @MinLength(32)
  @MaxLength(256)
  refreshToken!: string;
}
