import { IsNotEmpty } from "class-validator";

export class YOLOImage {
    @IsNotEmpty()
    public id: number;

    public text: string;
    
    public status: number;

    @IsNotEmpty()
    public image: string;
}