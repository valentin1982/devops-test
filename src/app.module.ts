import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { RedisService } from './redis/redis.service';
import { MetricsModule } from './metrics/metrics.module'; // Ensure this path is correct based on your project structure

@Module({
	imports: [
		ConfigModule.forRoot({
			isGlobal: true,
		}),
		MetricsModule, // Import the MetricsModule here
	],
	controllers: [AppController],
	providers: [AppService, RedisService],
})
export class AppModule {}
