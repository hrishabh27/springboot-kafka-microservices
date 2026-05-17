# E-commerce Microservices API Documentation

## Overview

This document provides comprehensive API documentation for the E-commerce Microservices platform. All requests should be made through the API Gateway at `http://localhost:9191`.

---

## Base URL

```
http://localhost:9191
```

---

## Authentication Endpoints

All authentication endpoints are available at the API Gateway under `/api/v1/auth`.

### Register User

**POST** `/api/v1/auth/register`

Register a new user in the system.

**Request Body:**
```json
{
    "name": "johndoe",
    "password": "securepassword",
    "email": "john.doe@example.com",
    "roles": ["CUSTOMER"]
}
```

**Roles Available:** `CUSTOMER`, `EMPLOYEE`, `ADMIN`

**Response:**
```json
{
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "johndoe",
    "email": "john.doe@example.com",
    "roles": ["CUSTOMER"],
    "createdAt": "2026-05-17T13:00:00Z"
}
```

---

### Login

**POST** `/api/v1/auth/token`

Authenticate a user and obtain a session token.

**Request Body:**
```json
{
    "username": "johndoe",
    "password": "securepassword"
}
```

**Response:**
```json
{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "type": "Bearer",
    "expiresIn": 86400
}
```

**Note:** The token should be included in the `Authorization` header as `Bearer {token}` for subsequent requests.

---

## Product Endpoints

All product endpoints are available at `/api/v1/products`.

### Get All Products

**GET** `/api/v1/products`

Retrieve all products.

**Response:**
```json
{
    "content": [
        {
            "id": "550e8400-e29b-41d4-a716-446655440001",
            "name": "Sample Product",
            "imageUrl": "https://example.com/image.png",
            "description": "Product description",
            "price": 99.99,
            "stockQuantity": 100
        }
    ],
    "page": 0,
    "size": 20,
    "totalElements": 1,
    "totalPages": 1
}
```

---

### Get Product by ID

**GET** `/api/v1/products/{id}`

Retrieve a specific product by its ID.

---

### Create Product (EMPLOYEE/ADMIN only)

**POST** `/api/v1/products`

Create a new product.

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
    "name": "New Product",
    "imageUrl": "https://example.com/new-product.png",
    "description": "Product description",
    "price": 149.99,
    "stockQuantity": 50
}
```

---

### Update Product (EMPLOYEE/ADMIN only)

**PUT** `/api/v1/products/{id}`

Update an existing product.

---

### Delete Product (ADMIN only)

**DELETE** `/api/v1/products/{id}`

Delete a product.

---

## Order Endpoints

### Place Order (CUSTOMER only)

**POST** `/api/v1/order`

Create a new order.

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
    "orderItems": [
        {
            "productId": "550e8400-e29b-41d4-a716-446655440001",
            "variantId": 1,
            "quantity": 2
        }
    ],
    "paymentMethod": "COD"
}
```

**Payment Methods:** `COD`, `PAYPAL`, `CREDIT_CARD`

**Response:**
```json
{
    "orderId": "ORD-2026-001",
    "status": "PENDING",
    "orderItems": [...],
    "totalAmount": 299.98,
    "createdAt": "2026-05-17T14:00:00Z"
}
```

---

### Get Order by ID (CUSTOMER/EMPLOYEE/ADMIN)

**GET** `/api/v1/order/{id}`

Retrieve order details.

---

### Get All Orders (EMPLOYEE/ADMIN only)

**GET** `/api/v1/orders`

Retrieve all orders with pagination.

---

## Payment Endpoints

### Process Payment

**POST** `/api/v1/payment/process`

Process a payment for an order.

**Request Body:**
```json
{
    "orderId": "ORD-2026-001",
    "paymentMethod": "PAYPAL",
    "amount": 299.98
}
```

---

## Health Check Endpoints

Each service exposes actuator endpoints for monitoring:

| Service | URL | Description |
|---------|-----|-------------|
| Service Registry | http://localhost:8761/actuator/health | Eureka Server health |
| API Gateway | http://localhost:9191/actuator/health | Gateway health |
| Identity Service | http://localhost:9898/actuator/health | Auth service health |
| Product Service | http://localhost:8084/actuator/health | Product service health |
| Order Service | http://localhost:8080/actuator/health | Order service health |
| Payment Service | http://localhost:8085/actuator/health | Payment service health |
| Email Service | http://localhost:8086/actuator/health | Email service health |

---

## Example cURL Commands

### Register a new user:
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

### Login:
```bash
curl -X POST http://localhost:9191/api/v1/auth/token \
  -H "Content-Type: application/json" \
  -d '{
        "username": "johndoe",
        "password": "securepassword"
      }'
```

### Get Products (public):
```bash
curl http://localhost:9191/api/v1/products
```

### Create Product (authenticated):
```bash
curl -X POST http://localhost:9191/api/v1/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {your_token}" \
  -d '{
        "name": "New Product",
        "imageUrl": "https://example.com/image.png",
        "description": "Product description",
        "price": 99.99,
        "stockQuantity": 100
      }'
```

### Place Order (authenticated):
```bash
curl -X POST http://localhost:9191/api/v1/order \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {your_token}" \
  -d '{
        "orderItems": [
          {
            "productId": "550e8400-e29b-41d4-a716-446655440001",
            "variantId": 1,
            "quantity": 1
          }
        ],
        "paymentMethod": "COD"
      }'
```

---

## Error Responses

All endpoints may return error responses in the following format:

```json
{
    "timestamp": "2026-05-17T13:00:00Z",
    "status": 400,
    "error": "Bad Request",
    "message": "Validation failed",
    "path": "/api/v1/products"
}
```

### Common HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 500 | Internal Server Error |

---

## Rate Limiting

The API Gateway implements rate limiting to protect services from excessive requests.

- **Authenticated users:** 1000 requests per minute
- **Unauthenticated users:** 100 requests per minute

---

## Service Architecture

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

## Database Configuration

Each microservice has its own database:

| Service | Database | Port |
|---------|----------|------|
| Identity Service | user_db | 3306 |
| Product Service | product_db | 3306 |
| Order Service | order_db | 3306 |
| Payment Service | payment_db | 3306 |

---

## Environment Variables

Key environment variables for configuration:

| Variable | Description | Default |
|----------|-------------|---------|
| SPRING_DATASOURCE_PASSWORD | MySQL password | root |
| SPRING_KAFKA_BOOTSTRAP_SERVERS | Kafka broker address | localhost:9092 |
| EUREKA_CLIENT_SERVICEURL_DEFAULTZONE | Eureka server URL | http://localhost:8761/eureka/ |
| SPRING_REDIS_HOST | Redis host | localhost |
| SPRING_REDIS_PORT | Redis port | 6379 |