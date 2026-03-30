import { Body, Controller, Get, Headers, Post, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

import { LoginRequestDto } from './dto/login.request';
import { RefreshRequestDto } from './dto/refresh.request';
import { LogoutRequestDto } from './dto/logout.request';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  login(@Body() body: LoginRequestDto, @Headers('x-device-id') deviceId?: string) {
    return this.authService.login(body.email, body.password, deviceId);
  }

  @Post('refresh')
  refresh(@Body() body: RefreshRequestDto, @Headers('x-device-id') deviceId?: string) {
    return this.authService.refresh(body.refreshToken, deviceId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('logout')
  async logout(@Req() request: { user: { sid: string; sub: string } }, @Body() body: LogoutRequestDto): Promise<void> {
    await this.authService.logout(request.user.sub, body.sessionId ?? request.user.sid);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('me')
  me(@Req() request: { user: { sub: string; sid: string } }) {
    return this.authService.me(request.user.sub, request.user.sid);
  }
}
