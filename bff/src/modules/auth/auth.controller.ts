import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

import { LoginRequestDto } from './dto/login.request';
import { RefreshRequestDto } from './dto/refresh.request';
import { LogoutRequestDto } from './dto/logout.request';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  login(@Body() body: LoginRequestDto) {
    return this.authService.login(body.email, body.password);
  }

  @Post('refresh')
  refresh(@Body() body: RefreshRequestDto) {
    return this.authService.refresh(body.refreshToken);
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('logout')
  async logout(@Req() request: { user: { sid: string } }, @Body() body: LogoutRequestDto): Promise<void> {
    await this.authService.logout(body.sessionId ?? request.user.sid);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('me')
  me(@Req() request: { user: { sub: string } }) {
    return this.authService.me(request.user.sub);
  }
}
