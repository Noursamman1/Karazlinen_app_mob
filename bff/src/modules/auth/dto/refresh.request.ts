import { IsString, MinLength } from 'class-validator';

export class RefreshRequestDto {
  @IsString()
  @MinLength(32)
  refreshToken!: string;
}
