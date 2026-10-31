# computer-club-app

Для запуску бази даних має бути встановлено:
1. [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. [Git](https://git-scm.com/)

Як запустити проєкт
1. Клонуйте репозиторій
```bash
git clone [https://github.com/steve-irl/computer-club-app.git](https://github.com/steve-irl/computer-club-app.git)
cd computer-club-app
```
2. Виконайте команду
```bash
docker compose up -d
```

Як працювати з БД

Якщо хтось  оновив структуру БД
1. Завантажте останні зміни
```bash
git pull origin main
```
2. Перезапустіть Docker із видаленням старого кешу даних, щоб MariaDB перечитала оновлені .sql файли
```bash
docker compose down -v
docker compose up -d
```

Якщо створено нову таблицю або змінено структуру
1. Скопіюйте SQL-код CREATE TABLE або ALTER TABLE у файл 01-schema.sql

Зупинити проект: docker compose down
