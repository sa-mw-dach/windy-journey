import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { SocketAuthenticationAdapter } from './socket/authentication.adapter';
import { json } from 'express';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  /**
   * Makes sense to use when serving from the same domain as
   * the client (and even in general)
   */
  // app.setGlobalPrefix('/api/v1')

  app.useWebSocketAdapter(new SocketAuthenticationAdapter(app));

  /**
   * Explicitly state the allowed size for JSON data
   */
  app.use(json({ limit: '50mb' }));

  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  await app.listen(process.env.PORT || 8888, () => console.log(`Listening on: ${process.env.PORT || 8888}`));
}
bootstrap();
