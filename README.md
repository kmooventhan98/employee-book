# KarigarBook — Small Business Labor & Financial OS

A Ruby on Rails 8 application for managing employees, attendance, project expenses, invoices, and payroll for small manufacturing and fabrication businesses.

---

## Running with Docker (Recommended)

### 1. Prerequisites
- Docker Engine 24+ & Docker Compose

### 2. Configure Environment
A `.env` file is prepared with default configurations. To recreate or customize it:
```bash
cp .env.example .env
```
Ensure your `RAILS_MASTER_KEY` in `.env` matches your `config/master.key`.

### 3. Start the Application
To build and start the production container (served with Thruster on port 3000):
```bash
docker-compose up --build
```
The database setup (`db:prepare`) and demo seeds run automatically on first boot.

Open your browser at **[http://localhost:3000](http://localhost:3000)**.

### Demo Credentials:
- **Super Admin**: `superadmin@karigarbook.com` / `password123`
- **Business Owner**: `ramesh@apexengg.com` / `password123`
- **Employee Portal**: `muthu@apexengg.com` / `password123`

---

## Development Mode with Docker

To run the container with live code changes and hot reloading:
```bash
docker-compose --profile dev up dev
```

---

## Useful Docker Commands

- **Stop containers**:
  ```bash
  docker-compose down
  ```
- **Reset database and volumes**:
  ```bash
  docker-compose down -v
  ```
- **Run Rails console inside the container**:
  ```bash
  docker-compose run --rm app ./bin/rails console
  ```
- **Run migrations**:
  ```bash
  docker-compose run --rm app ./bin/rails db:migrate
  ```
