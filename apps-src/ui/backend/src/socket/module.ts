import { Module } from '@nestjs/common';
import { SocketGateway } from './gateway';

@Module({
    providers: [SocketGateway],
    exports: [SocketGateway],
})
export class SocketModule {}