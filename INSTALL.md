# Installation Guide

## Prerequisites

Before installing, ensure you have the following installed on your system:

| Requirement | Version | Check Command |
|-------------|---------|---------------|
| Java JDK | 17+ | `java -version` |
| Apache Maven | 3.9+ | `mvn -version` |
| MySQL | 8.0+ | `mysql --version` |
| Redis | 7.0+ | `redis-server --version` |
| Git | 2.0+ | `git --version` |

### For Docker (Optional - for containerized setup)

| Requirement | Check Command |
|-------------|---------------|
| Docker | `docker --version` |
| Docker Compose | `docker-compose --version` |

---

## Quick Installation (5 Steps)

### Step 1: Clone the Repository

```bash
git clone https://github.com/hrishabh27/springboot-kafka-microservices.git
cd springboot-kafka-microservices
```

### Step 2: Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your settings (text editor or manual edit)
nano .env
```

**Required changes for .env:**
- `DB_PASSWORD` - Set your MySQL root password
- `JWT_SECRET` - Generate a secure random string (min 256 bits)
- `MAIL_*` - Configure SMTP settings for email notifications

### Step 3: Initialize Databases

```bash
# Run database initialization script
./scripts/init-db.sh

# Or manually with MySQL:
mysql -u root -p < scripts/sql/01_user_db.sql
mysql -u root -p < scripts/sql/02_product_db.sql
mysql -u root -p < scripts/sql/03_order_db.sql
```

### Step 4: Build the Project

```bash
# Build all services (skip GPG signing for development)
mvn clean install -DskipTests -Dgpg.skip=true

# Or build services individually:
cd common-lib && mvn clean install -DskipTests -Dgpg.skip=true
cd ../service-registry && mvn clean package -DskipTests -Dgpg.skip=true
# ... continue for other services
```

### Step 5: Start All Services

```bash
# Start infrastructure (MySQL, Redis, Kafka) and all microservices
./start-services.sh

# Or start services individually:
java -jar service-registry/target/service-registry.jar
java -jar identity-service/target/identity-service.jar
# ... continue for other services
```

---

## Verification

After starting all services, verify they're running:

```bash
# Check all services
curl http://localhost:8761/actuator/health   # Eureka
curl http://localhost:9191/actuator/health   # API Gateway
curl http://localhost:9898/actuator/health   # Identity
curl http://localhost:8084/actuator/health   # Product
curl http://localhost:8080/actuator/health   # Order
curl http://localhost:8085/actuator/health   # Payment
curl http://localhost:8086/actuator/health   # Email
```

Expected output: `{"status":"UP"}` for each service.

---

## Access Points

| Service | URL | Description |
|---------|-----|-------------|
| API Gateway | http://localhost:9191 | Main entry point |
| Eureka Dashboard | http://localhost:8761 | Service registry UI |
| Product Service | http://localhost:8084 | Direct product API |
| Order Service | http://localhost:8080 | Direct order API |

---

## Default Credentials

After database initialization, you can use these default accounts:

| Username | Password | Role |
|----------|----------|------|
| admin | admin123 | ROLE_ADMIN |
| (any registered user) | (your choice) | ROLE_CUSTOMER |

---

## Troubleshooting

### Port Already in Use

```bash
# Find process using port
lsof -i :8080

# Kill the process
kill -9 <PID>
```

### Database Connection Failed

```bash
# Verify MySQL is running
systemctl status mysql  # Linux
brew services start mysql  # macOS

# Test connection
mysql -u root -p
```

### Kafka Not Starting

```bash
# Check Zookeeper status
telnet localhost 2181

# View Kafka logs
tail -50 /tmp/kafka.log
```

### Service Registration Failed

```bash
# Check Eureka is accessible
curl http://localhost:8761/eureka/apps

# Verify network settings in .env
EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://localhost:8761/eureka/
```

---

## Docker Installation (Alternative)

If you prefer Docker:

```bash
# Start all services with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

---

## Next Steps

1. **Configure API Access**: See [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
2. **Understand Architecture**: See [ARCHITECTURE.md](ARCHITECTURE.md)
3. **Development Guide**: See [DEVELOPMENT.md](DEVELOPMENT.md)

---

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review logs in `/tmp/{service-name}.log`
3. Check the documentation files in the project root