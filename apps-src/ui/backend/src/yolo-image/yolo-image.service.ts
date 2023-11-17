import { Injectable } from '@nestjs/common';
import { WebSocketServer } from '@nestjs/websockets';
import { Server } from 'socket.io';
import { YOLOImage } from './dtos/yolo-image.dto';
import { SocketGateway } from 'src/socket/gateway';


@Injectable()
export class YOLOImageService {

    constructor(private socketGateway: SocketGateway) {}

     emitYOLOImage(yoloImage: YOLOImage): void {
        this.socketGateway.server.emit('server2ui2', yoloImage);
    }
}
