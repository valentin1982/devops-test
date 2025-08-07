###########################
#  STAGE 1: Build Stage #
###########################
FROM node:20-alpine AS builder

# Встановлюємо робочу директорію
WORKDIR /app

# Копіюємо package.json та package-lock.json окремо — це дозволяє кешувати шар з залежностями
COPY package*.json ./

# Встановлюємо лише production-залежності для побудови
RUN npm ci

# Копіюємо весь вихідний код у контейнер
COPY . .

# Збираємо NestJS застосунок (результат буде в /app/dist)
RUN npm run build


#####################################
#  STAGE 2: Production Image      #
#####################################
FROM node:20-alpine

# Встановлюємо змінну середовища для продакшену
ENV NODE_ENV=production

# Робоча директорія у фінальному образі
WORKDIR /app

# Створюємо unprivileged (непривілейованого) користувача для безпеки
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Копіюємо лише зібраний код та потрібні файли package*.json з попереднього шару
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

# Встановлюємо лише production-залежності
RUN npm ci --omit=dev

# Змінюємо власника файлів на непривілейованого користувача
RUN chown -R appuser:appgroup /app

# Переходимо на користувача з обмеженими правами
USER appuser

# Вказуємо команду запуску NestJS застосунку
CMD ["node", "dist/main"]
