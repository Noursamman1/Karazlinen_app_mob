import { IsOptional, IsUUID } from 'class-validator';

export class LogoutRequestDto {
  @IsOptional()
  @IsUUID()
  sessionId?: string;
}
