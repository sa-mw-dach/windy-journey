import { Body, Controller, Header, Post } from '@nestjs/common';
import { YOLOImage } from './dtos/yolo-image.dto';
import { YOLOImageService } from './yolo-image.service';

@Controller()
export class YOLOImageController {

    constructor(private aiImageService: YOLOImageService) { }

    @Post('/')
    @Header('Cache-Control', 'none')
    @Header('Ce-Id', 'UUID')
    @Header('Ce-specversion', '1.0')
    @Header('Ce-Source', 'manuela/eventing/image-processor')
    @Header('Ce-Type', 'manuela.image-processor.response')
    public receiveAIImage(@Body() yoloImage: YOLOImage) {
        console.log(`Received Image: ${yoloImage.id}`);

        this.aiImageService.emitYOLOImage(yoloImage);

        return {msg: 'Image sent to dashoard'};
    }
}
