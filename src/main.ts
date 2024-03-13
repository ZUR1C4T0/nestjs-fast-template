import { ValidationPipe } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import { FastifyAdapter, NestFastifyApplication } from "@nestjs/platform-fastify";
import { AppModule } from "./app.module";

async function bootstrap() {
	const app = await NestFactory.create<NestFastifyApplication>(
		AppModule,
		new FastifyAdapter(),
	);

	// enable cors
	app.enableCors();

	// use pipes
	app.useGlobalPipes(new ValidationPipe({
		whitelist: true,
		transform: true,
	}));

	// start the server
	const port = +process.env.PORT || 3000;
	const address = "0.0.0.0";
	await app.listen(port, address);
}
bootstrap();
