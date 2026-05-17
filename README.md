# E-Commerce Microservices Platform

A production-ready e-commerce backend built with Spring Boot microservices architecture, featuring event-driven communication with Apache Kafka, service discovery with Netflix Eureka, and API gateway for unified client access.

## 🚀 Quick Start

```bash
# 1. Clone and enter directory
git clone https://github.com/hrishabh27/springboot-kafka-microservices.git
cd springboot-kafka-microservices

# 2. Configure environment
cp .env.example .env

# 3. Initialize databases
./scripts/init-db.sh

# 4. Build project
mvn clean install -DskipTests -Dgpg.skip=true

# 5. Start services
./start-services.sh
```

## 📁 Project Structure

```
├── api-gateway/          # Spring Cloud Gateway
├── common-lib/           # Shared DTOs and utilities
├── service-registry/     # Netflix Eureka Server
├── identity-service/     # Authentication & Authorization
├── product-service/      # Product catalog management
├── order-service/        # Order processing
├── payment-service/      # Payment handling
├── email-service/        # Email notifications
├── scripts/              # Utility scripts
│   ├── sql/             # Database scripts
│   └── init-db.sh       # Database initialization
├── .env.example         # Environment template
├── start-services.sh    # Service startup script
├── docker-compose.yml   # Docker deployment
└── docs/                # Documentation
```

## 🛠️ Services

| Service | Port | Description |
|---------|------|-------------|
| API Gateway | 9191 | Entry point, routing, auth |
| Eureka Server | 8761 | Service discovery |
| Identity Service | 9898 | Authentication |
| Product Service | 8084 | Products & inventory |
| Order Service | 8080 | Order processing |
| Payment Service | 8085 | Payment processing |
| Email Service | 8086 | Notifications |

## 📚 Documentation

- [Installation Guide](INSTALL.md) - Setup instructions
- [API Documentation](API_DOCUMENTATION.md) - API reference
- [Architecture Guide](ARCHITECTURE.md) - System design
- [Development Guide](DEVELOPMENT.md) - Developer setup

## 🔧 Technologies

Java 17 • Spring Boot 3.3 • Spring Cloud 2023 • Apache Kafka • MySQL • Redis • Netflix Eureka • OpenFeign • JWT

## ⚡ API Examples

```bash
# Register
curl -X POST http://localhost:9191/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"user","password":"pass","email":"user@test.com","roles":["CUSTOMER"]}'

# Login
curl -X POST http://localhost:9191/api/v1/auth/token \
  -H "Content-Type: application/json" \
  -d '{"username":"user","password":"pass"}'

# Get products
curl http://localhost:9191/api/v1/products
```

## 📄 License

MIT License
