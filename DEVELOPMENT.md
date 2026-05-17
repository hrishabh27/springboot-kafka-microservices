# Development Guide

## Prerequisites

Before you begin, ensure you have the following installed:

- **Java 17+** (JDK 21 recommended)
- **Apache Maven 3.9+**
- **MySQL 8.0** or **MariaDB 10.6+**
- **Redis 7.0+**
- **Apache Kafka 3.6+** (includes Zookeeper)

---

## Quick Start

### 1. Clone and Build

```bash
git clone https://github.com/your-username/springboot-kafka-microservices.git
cd springboot-kafka-microservices

# Build all services
mvn clean install -DskipTests
```

### 2. Start Infrastructure

```bash
# Start MySQL (adjust paths as needed)
mariadbd --user=mysql --datadir=/path/to/data --port=3306 &

# Set MySQL root password
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';"

# Create databases
mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS order_db; 
CREATE DATABASE IF NOT EXISTS user_db; 
CREATE DATABASE IF NOT EXISTS payment_db; 
CREATE DATABASE IF NOT EXISTS product_db;"

# Start Redis
redis-server --daemonize yes

# Start Zookeeper
./kafka/bin/zookeeper-server-start.sh ./kafka/config/zookeeper.properties &

# Start Kafka
./kafka/bin/kafka-server-start.sh ./kafka/config/server.properties &

# Create Kafka topics
./kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic order_topics --partitions 1 --replication-factor 1
./kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic create_order_topic --partitions 1 --replication-factor 1
./kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic product_topics --partitions 1 --replication-factor 1
```

### 3. Start Services

Use the automated startup script:

```bash
./start-services.sh
```

Or start manually:

```bash
# Export common environment variables
export SPRING_DATASOURCE_PASSWORD=root
export SPRING_KAFKA_BOOTSTRAP_SERVERS=localhost:9092
export EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://localhost:8761/eureka/

# Start services in order
java -jar service-registry/target/service-registry.jar
java -jar identity-service/target/identity-service.jar
java -jar product-service/target/product-service.jar
java -jar order-service/target/order-service.jar
java -jar payment-service/target/payment-service.jar
java -jar email-service/target/email-service.jar
java -jar api-gateway/target/api-gateway.jar
```

---

## Project Structure

```
springboot-kafka-microservices/
├── common-lib/              # Shared DTOs and utilities
├── service-registry/        # Netflix Eureka Server
├── api-gateway/             # Spring Cloud Gateway
├── identity-service/        # Authentication & Authorization
├── product-service/         # Product Catalog Management
├── order-service/           # Order Processing
├── payment-service/         # Payment Handling
├── email-service/           # Email Notifications
├── kafka/                   # Apache Kafka (downloaded separately)
├── docker-compose.yml       # Docker deployment configuration
├── start-services.sh        # Local startup script
├── API_DOCUMENTATION.md     # API reference
├── ARCHITECTURE.md          # System architecture
└── README.md                # Project overview
```

---

## Service Dependencies

```
Service Registry (Eureka)
    │
    ├── Identity Service
    ├── Product Service
    ├── Order Service
    ├── Payment Service
    ├── Email Service
    └── API Gateway
           │
           └── (depends on all above)
```

---

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| SPRING_DATASOURCE_URL | JDBC connection URL | jdbc:mysql://localhost:3306/{db} |
| SPRING_DATASOURCE_USERNAME | Database username | root |
| SPRING_DATASOURCE_PASSWORD | Database password | root |
| SPRING_KAFKA_BOOTSTRAP_SERVERS | Kafka broker address | localhost:9092 |
| EUREKA_CLIENT_SERVICEURL_DEFAULTZONE | Eureka server URL | http://localhost:8761/eureka/ |
| SPRING_REDIS_HOST | Redis host | localhost |
| SPRING_REDIS_PORT | Redis port | 6379 |
| CLOUDINARY_CLOUD_NAME | Cloudinary cloud name | demo |
| CLOUDINARY_API_KEY | Cloudinary API key | demo |
| CLOUDINARY_API_SECRET | Cloudinary API secret | demo |
| MAIL_HOST | SMTP server host | smtp.gmail.com |
| MAIL_USERNAME | SMTP username | noreply@example.com |
| MAIL_PASSWORD | SMTP password | password |

---

## Building Individual Services

```bash
# Build common-lib first
cd common-lib
mvn clean install -DskipTests -Dgpg.skip=true

# Build other services
cd ../service-registry && mvn clean package -DskipTests -Dgpg.skip=true
cd ../identity-service && mvn clean package -DskipTests -Dgpg.skip=true
cd ../product-service && mvn clean package -DskipTests -Dgpg.skip=true
cd ../order-service && mvn clean package -DskipTests -Dgpg.skip=true
cd ../payment-service && mvn clean package -DskipTests -Dgpg.skip=true
cd ../email-service && mvn clean package -DskipTests -Dgpg.skip=true
cd ../api-gateway && mvn clean package -DskipTests -Dgpg.skip=true
```

---

## Running Tests

```bash
# Run all tests
mvn test

# Run tests for specific service
cd identity-service && mvn test

# Run with coverage
mvn test jacoco:report
```

---

## Debugging

### View Service Logs

```bash
# Tail logs for specific service
tail -f /tmp/service-registry.log
tail -f /tmp/identity-service.log
tail -f /tmp/product-service.log
tail -f /tmp/order-service.log
tail -f /tmp/payment-service.log
tail -f /tmp/email-service.log
tail -f /tmp/api-gateway.log
```

### Check Service Health

```bash
curl http://localhost:8761/actuator/health   # Eureka
curl http://localhost:9191/actuator/health   # API Gateway
curl http://localhost:9898/actuator/health   # Identity
curl http://localhost:8084/actuator/health   # Product
curl http://localhost:8080/actuator/health   # Order
curl http://localhost:8085/actuator/health   # Payment
curl http://localhost:8086/actuator/health   # Email
```

### Kafka Topics

```bash
# List topics
./kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list

# Describe topic
./kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic order_topics

# View messages (for debugging)
./kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic order_topics --from-beginning
```

---

## Database Access

```bash
# Connect to MySQL
mysql -u root -proot

# Switch to specific database
use order_db;
use user_db;
use product_db;
use payment_db;

# View tables
show tables;

# View data
SELECT * FROM users;
SELECT * FROM products;
SELECT * FROM orders;
```

---

## Redis Commands

```bash
# Connect to Redis CLI
redis-cli

# Check connection
ping

# View all keys
keys *

# View specific key
get <key>

# Delete all keys (for testing)
flushall
```

---

## Code Style

### Java Conventions

- Follow Google Java Style Guide
- Use meaningful variable and method names
- Keep methods small and focused
- Add Javadoc for public APIs

### Commit Messages

Follow Conventional Commits:

```
feat: add new product endpoint
fix: resolve authentication issue
docs: update API documentation
refactor: simplify order processing logic
```

---

## Troubleshooting

### Service Won't Start

1. Check if port is already in use:
   ```bash
   lsof -i :8080
   ```

2. Check logs for specific error:
   ```bash
   tail -50 /tmp/<service-name>.log
   ```

3. Verify database connection:
   ```bash
   mysql -u root -proot -e "SELECT 1"
   ```

### Kafka Issues

1. Verify Zookeeper is running:
   ```bash
   telnet localhost 2181
   ```

2. Check Kafka logs:
   ```bash
   tail -30 /tmp/kafka.log
   ```

3. Recreate topic:
   ```bash
   ./kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic order_topics
   ./kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic order_topics --partitions 1 --replication-factor 1
   ```

### Database Connection Issues

1. Check MySQL is running:
   ```bash
   ps aux | grep mariadb
   ```

2. Verify credentials:
   ```bash
   mysql -u root -proot -e "SELECT 1"
   ```

3. Check database exists:
   ```bash
   mysql -u root -proot -e "SHOW DATABASES"
   ```

---

## IDE Setup

### IntelliJ IDEA

1. Import project as Maven project
2. Set JDK 17+ in Project Structure
3. Enable Annotation Processing for Lombok
4. Configure Run Configurations for each service

### VS Code

1. Install Java Extension Pack
2. Install Lombok Annotations Support
3. Import project folder

---

## Additional Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring Cloud Documentation](https://spring.io/projects/spring-cloud)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Eureka Server Guide](https://spring.io/projects/spring-cloud-netflix)
- [API Gateway Guide](https://spring.io/projects/spring-cloud-gateway)