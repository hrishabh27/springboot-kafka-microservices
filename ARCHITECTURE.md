# E-commerce Microservices Architecture

## System Overview

This document describes the architecture of the E-commerce Microservices platform, a distributed system built using Spring Boot, Spring Cloud, and Apache Kafka.

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENTS                                         │
│                    (Web, Mobile, API Consumers)                              │
└─────────────────────────────────────┬───────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           API GATEWAY                                        │
│                    (Spring Cloud Gateway)                                    │
│                         Port: 9191                                           │
│                                                                              │
│  • Authentication & Authorization                                            │
│  • Rate Limiting                                                             │
│  • Request Routing                                                           │
│  • CORS Handling                                                             │
└─────────────────────────────────────┬───────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        SERVICE REGISTRY                                      │
│                      (Netflix Eureka Server)                                 │
│                         Port: 8761                                           │
│                                                                              │
│  • Service Registration                                                      │
│  • Service Discovery                                                         │
│  • Health Monitoring                                                         │
└─────────────────────────────────────┬───────────────────────────────────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
                    ▼                 ▼                 ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Identity    │ │   Product    │ │    Order     │ │   Payment    │
│  Service     │ │   Service    │ │   Service    │ │   Service    │
│  Port: 9898  │ │   Port: 8084 │ │   Port: 8080 │ │   Port: 8085 │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
       │                │                │                │
       └────────────────┴────────────────┴────────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
      ┌────────────┐  ┌────────────┐  ┌────────────┐
      │    MySQL   │  │   Redis    │  │    Kafka   │
      │  (4 DBs)   │  │   Cache    │  │  Messaging │
      │  Port:3306 │  │  Port:6379 │  │  Port:9092 │
      └────────────┘  └────────────┘  └────────────┘
```

---

## Services Description

### 1. API Gateway (Port 9191)

The API Gateway serves as the single entry point for all client requests. It handles:

- **Authentication**: JWT token validation and user session management
- **Authorization**: Role-based access control (RBAC)
- **Rate Limiting**: Protects services from excessive requests
- **Load Balancing**: Distributes traffic across service instances
- **CORS**: Handles cross-origin requests from web applications

**Technology Stack:**
- Spring Cloud Gateway
- Spring Security
- Redis (for rate limiting)

---

### 2. Service Registry (Port 8761)

Netflix Eureka Server provides service registration and discovery:

- Services register themselves on startup
- Clients discover service locations dynamically
- Built-in health monitoring and failover

**Technology Stack:**
- Spring Cloud Netflix Eureka

---

### 3. Identity Service (Port 9898)

Handles user authentication and authorization:

- **User Registration**: Create new user accounts
- **Login**: Authenticate users and issue JWT tokens
- **Role Management**: Assign and verify user roles (CUSTOMER, EMPLOYEE, ADMIN)
- **Session Storage**: Redis-backed session management

**Technology Stack:**
- Spring Security
- Spring Data JPA
- Redis (session cache)
- MySQL (user data)

**Database Schema:**
```
users
├── id (UUID)
├── username
├── password (BCrypt hashed)
├── email
├── created_at
└── updated_at

roles
├── id
└── name (CUSTOMER, EMPLOYEE, ADMIN)

user_roles (JOIN TABLE)
├── user_id
└── role_id
```

---

### 4. Product Service (Port 8084)

Manages the product catalog:

- **CRUD Operations**: Create, read, update, delete products
- **Inventory Management**: Track stock quantities
- **Image Upload**: Integration with Cloudinary for image storage
- **Caching**: Redis for frequently accessed product data
- **Event Publishing**: Kafka events for inventory changes

**Technology Stack:**
- Spring Web
- Spring Data JPA
- Redis (caching)
- Apache Kafka (event publishing)
- Cloudinary (image CDN)

**Database Schema:**
```
products
├── id (UUID)
├── name
├── description
├── price
├── stock_quantity
├── image_url
├── created_at
└── updated_at

product_variants
├── id
├── product_id (FK)
├── sku
├── stock_quantity
└── attributes (JSON)
```

---

### 5. Order Service (Port 8080)

Manages order processing:

- **Order Creation**: Create orders from cart items
- **Order Tracking**: Track order status through lifecycle
- **History Management**: Maintain complete order history
- **Payment Integration**: Integration with payment services
- **Event-driven Processing**: Kafka-based order processing

**Technology Stack:**
- Spring Web
- Spring Data JPA
- Spring Kafka (producer)
- Redis (session cache)
- OpenFeign (service-to-service calls)

**Database Schema:**
```
orders
├── id (UUID)
├── user_id (FK)
├── status (PENDING, CONFIRMED, SHIPPED, DELIVERED, CANCELLED)
├── total_amount
├── payment_method
├── shipping_address
├── created_at
└── updated_at

order_items
├── id
├── order_id (FK)
├── product_id
├── variant_id
├── quantity
├── price
└── subtotal
```

---

### 6. Payment Service (Port 8085)

Handles payment processing:

- **Payment Methods**: COD, PayPal, Credit Card
- **Transaction Management**: Record all payment transactions
- **Invoice Generation**: Create and manage invoices
- **Kafka Consumers**: Listen for payment events from order service

**Technology Stack:**
- Spring Web
- Spring Data JPA
- Spring Kafka (consumer)
- PayPal SDK

**Database Schema:**
```
payments
├── id (UUID)
├── order_id (FK)
├── amount
├── currency
├── payment_method
├── status (PENDING, COMPLETED, FAILED, REFUNDED)
├── transaction_id
├── created_at
└── updated_at

invoices
├── id (UUID)
├── order_id (FK)
├── invoice_number
├── amount
├── issued_at
└── due_date
```

---

### 7. Email Service (Port 8086)

Manages email communications:

- **Order Notifications**: Email confirmations
- **Password Reset**: Password recovery emails
- **Marketing**: Promotional emails (future)

**Technology Stack:**
- Spring Mail
- Spring Kafka (consumer)

---

## Infrastructure Components

### Apache Kafka (Port 9092)

Message broker for event-driven communication:

**Topics:**
| Topic | Purpose | Producers | Consumers |
|-------|---------|-----------|-----------|
| order_topics | Order lifecycle events | Order Service | Payment, Email |
| create_order_topic | New order creation | Order Service | Product, Payment |
| product_topics | Product updates | Product Service | Order Service |

---

### MySQL (Port 3306)

Each microservice has its own database:

| Service | Database | Purpose |
|---------|----------|---------|
| Identity | user_db | User and role data |
| Product | product_db | Product catalog |
| Order | order_db | Order and fulfillment |
| Payment | payment_db | Payment transactions |

---

### Redis (Port 6379)

In-memory data store for:

- Session management (Identity Service)
- Product caching (Product Service)
- Order session cache (Order Service)
- Rate limiting (API Gateway)

---

## Communication Patterns

### 1. Synchronous (REST)

Used for real-time client requests:

```
Client → API Gateway → Service
```

Technologies:
- Spring Web (REST)
- OpenFeign (service-to-service)
- Spring Cloud LoadBalancer

### 2. Asynchronous (Kafka)

Used for background processing and event-driven workflows:

```
Service A → Kafka Topic → Service B
```

Example: Order creation flow
1. Client submits order via API Gateway
2. Order Service publishes `create_order_topic` event
3. Product Service consumes event and decrements stock
4. Payment Service consumes event and awaits payment
5. Email Service consumes event and sends confirmation

---

## Security Architecture

### Authentication Flow

```
1. User registers → Identity Service → User created
2. User logs in → Identity Service → JWT token issued
3. Client includes JWT in Authorization header
4. API Gateway validates JWT on each request
5. Services receive validated authentication context
```

### Authorization Matrix

| Resource | CUSTOMER | EMPLOYEE | ADMIN |
|----------|----------|----------|-------|
| View Products | ✅ | ✅ | ✅ |
| Create Product | ❌ | ✅ | ✅ |
| Update Product | ❌ | ✅ | ✅ |
| Delete Product | ❌ | ❌ | ✅ |
| Place Order | ✅ | ✅ | ✅ |
| View Own Orders | ✅ | ✅ | ✅ |
| View All Orders | ❌ | ✅ | ✅ |
| Process Payment | ❌ | ✅ | ✅ |

---

## Scalability Considerations

### Horizontal Scaling

Each service can be scaled independently:

1. **Stateless Services**: Services are designed to be stateless, allowing multiple instances
2. **Eureka Integration**: New instances auto-register with Eureka
3. **Load Balancing**: Spring Cloud LoadBalancer distributes traffic
4. **Database Connections**: Connection pooling handles increased load

### Database Scaling

- **Read Replicas**: MySQL can be configured with read replicas
- **Caching**: Redis reduces database load for frequently accessed data

### Kafka Partitioning

- Topics can be partitioned for parallel processing
- Consumer groups allow multiple instances to process messages concurrently

---

## Monitoring & Observability

### Actuator Endpoints

Each service exposes Spring Boot Actuator endpoints:
- `/actuator/health` - Health check
- `/actuator/info` - Application info
- `/actuator/metrics` - Application metrics
- `/actuator/prometheus` - Prometheus-format metrics

### Logging

- Structured JSON logging
- Log aggregation ready (ELK stack compatible)
- Service correlation IDs for request tracing

---

## Development & Deployment

### Local Development

Use the `start-services.sh` script to start all services locally:

```bash
./start-services.sh
```

### Docker Deployment

For production, use Docker Compose:

```bash
docker-compose up -d
```

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| SPRING_DATASOURCE_PASSWORD | MySQL password | root |
| SPRING_KAFKA_BOOTSTRAP_SERVERS | Kafka address | kafka:9092 |
| EUREKA_CLIENT_SERVICEURL_DEFAULTZONE | Eureka URL | http://eureka:8761/eureka/ |
| SPRING_REDIS_HOST | Redis address | redis |
| CLOUDINARY_* | Cloudinary credentials | (from Cloudinary dashboard) |

---

## Error Handling

### Circuit Breaker Pattern

Implemented via Resilience4j:
- Fallback methods for service failures
- Timeout handling for slow services
- Bulkhead isolation for resource protection

### Retry Policy

- Automatic retry for transient failures
- Exponential backoff for retry delays
- Dead letter queue for failed messages

---

## Future Enhancements

- [ ] GraphQL API layer
- [ ] Real-time WebSocket notifications
- [ ] Graph database for recommendations
- [ ] ML-based fraud detection
- [ ] Multi-region deployment support