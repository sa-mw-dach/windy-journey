import { Module } from '@nestjs/common';
import { YOLOImageModule } from './yolo-image/yolo-image.module';
import { SocketModule } from './socket/module';

@Module({
  imports: [SocketModule, YOLOImageModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
