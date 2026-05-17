# E-commerce Microservices Platform 🚀

A production-ready e-commerce backend built with Spring Boot microservices architecture, featuring event-driven communication with Apache Kafka, service discovery with Netflix Eureka, and API gateway for unified client access.

## 🌟 Features

- **Microservices Architecture**: 7 independently deployable services
- **Event-Driven Communication**: Apache Kafka for asynchronous messaging
- **Service Discovery**: Netflix Eureka for dynamic service registration
- **API Gateway**: Spring Cloud Gateway with authentication & rate limiting
- **Multi-Database**: Separate MySQL databases per service
- **Caching**: Redis for session management and data caching
- **Payment Integration**: PayPal SDK integration
- **Email Notifications**: Asynchronous email service

---

## 🏗️ Architecture

```
                    ┌─────────────────────────────────────┐
                    │           API Gateway               │
                    │          (Port 9191)                │
                    └──────────────┬──────────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
              ▼                    ▼                    ▼
    ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
    │ Identity Service│  │  Product Service│  │   Order Service │
    │   (Port 9898)   │  │   (Port 8084)   │  │   (Port 8080)   │
    └─────────────────┘  └─────────────────┘  └────────┬────────┘
                                                       │
                                    ┌──────────────────┼──────────────────┐
                                    ▼                  ▼                  ▼
                          ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
                          │ Payment Service │ │  Email Service  │ │     Kafka       │
                          │   (Port 8085)   │ │   (Port 8086)   │ │   (Port 9092)   │
                          └─────────────────┘ └─────────────────┘ └─────────────────┘
                                   
              ┌────────────────────────────────────────────────────────────┐
                                    │ Eureka Server (Port 8761) │
                                    └────────────────────────────────────┘
```

---

## 🛠️ Services

| Service | Port | Description |
|---------|------|-------------|
| **API Gateway** | 9191 | Entry point, routing, auth |
| **Service Registry** | 8761 | Eureka server, service discovery |
| **Identity Service** | 9898 | Authentication & authorization |
| **Product Service** | 8084 | Product catalog & inventory |
| **Order Service** | 8080 | Order processing & management |
| **Payment Service** | 8085 | Payment processing |
| **Email Service** | 8086 | Email notifications |

---

## 🚀 Quick Start

### Option 1: Docker Compose (Recommended for Production)

```bash
git clone https://github.com/your-username/springboot-kafka-microservices.git
cd springboot-kafka-microservices
docker-compose up -d
```

### Option 2: Local Development

```bash
# Start infrastructure and all services
./start-services.sh
```

### Option 3: Manual Start

```bash
# Build all services
mvn clean install -DskipTests -Dgpg.skip=true

# Start each service
java -jar service-registry/target/service-registry.jar
java -jar identity-service/target/identity-service.jar
# ... and so on
```

---

## 📚 Documentation

- [API Documentation](API_DOCUMENTATION.md) - Complete API reference with examples
- [Architecture Guide](ARCHITECTURE.md) - System architecture and design patterns
- [Development Guide](DEVELOPMENT.md) - Setup and development instructions

---

## 🔧 Technologies

| Category | Technologies |
|----------|--------------|
| **Framework** | Spring Boot 3.3, Spring Cloud 2023 |
| **Messaging** | Apache Kafka 3.6 |
| **Databases** | MySQL 8.0, Redis 7.0 |
| **Service Discovery** | Netflix Eureka |
| **API Gateway** | Spring Cloud Gateway |
| **Inter-Service** | OpenFeign |
| **Security** | Spring Security, JWT |
| **Payment** | PayPal SDK |

---

## 🔗 Endpoints

| Service | URL |
|---------|-----|
| API Gateway | http://localhost:9191 |
| Eureka Dashboard | http://localhost:8761 |
| Identity Service | http://localhost:9898 |
| Product Service | http://localhost:8084 |
| Order Service | http://localhost:8080 |
| Payment Service | http://localhost:8085 |
| Email Service | http://localhost:8086 |

---

## 📝 Example API Usage

### Register a User
```bash
curl -X POST http://localhost:9191/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
        "name": "johndoe",
        "password": "securepassword",
        "email": "john.doe@example.com",
        "roles": ["CUSTOMER"]
      }'
```

### Login
```bash
curl -X POST http://localhost:9191/api/v1/auth/token \
  -H "Content-Type: application/json" \
  -d '{
        "username": "johndoe",
        "password": "securepassword"
      }'
```

### Get Products
```bash
curl http://localhost:9191/api/v1/products
```

### Place Order (authenticated)
```bash
curl -X POST http://localhost:9191/api/v1/order \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {token}" \
  -d '{
        "orderItems": [
          {"productId": "uuid", "variantId": 1, "quantity": 2}
        ],
        "paymentMethod": "COD"
      }'
```

---

## 📦 Project Structure

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
├── kafka/                   # Apache Kafka (bundled)
├── docker-compose.yml       # Docker deployment
├── start-services.sh        # Local startup script
└── docs/                    # Documentation
    ├── API_DOCUMENTATION.md
    ├── ARCHITECTURE.md
    └── DEVELOPMENT.md
```

---

## 🔐 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SPRING_DATASOURCE_PASSWORD` | MySQL password | root |
| `SPRING_KAFKA_BOOTSTRAP_SERVERS` | Kafka address | localhost:9092 |
| `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE` | Eureka URL | http://localhost:8761/eureka/ |
| `SPRING_REDIS_HOST` | Redis host | localhost |
| `SPRING_REDIS_PORT` | Redis port | 6379 |

---

## 🧪 Health Checks

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

---

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

**Built with ❤️ using Spring Boot & Apache Kafka**