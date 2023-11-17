import { Module } from '@nestjs/common';
import { YOLOImageController } from './yolo-image.controller';
import { YOLOImageService } from './yolo-image.service';
import { SocketModule } from 'src/socket/module';

@Module({
  imports: [SocketModule],
  controllers: [YOLOImageController],
  providers: [YOLOImageService],
})
export class YOLOImageModule {}
