#!/bin/bash
# E-commerce Microservices Startup Script

echo "=========================================="
echo "  E-commerce Microservices Startup Script"
echo "=========================================="
echo ""

# Check if services are already running
check_service() {
    curl -s -o /dev/null -w "%{http_code}" http://localhost:$1/actuator/health 2>/dev/null
}

# Function to start infrastructure
start_infrastructure() {
    echo "Starting infrastructure services..."
    
    # Start MariaDB
    if ! pgrep -x "mariadbd" > /dev/null; then
        echo "  -> Starting MariaDB..."
        nohup mariadbd --user=root --datadir=/workspace/springboot-kafka-microservices/data/mysql --port=3306 --bind-address=0.0.0.0 > /tmp/mysql.log 2>&1 &
        sleep 5
    else
        echo "  -> MariaDB already running"
    fi
    
    # Set MySQL password
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root'; FLUSH PRIVILEGES;" 2>/dev/null || true
    mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS order_db; CREATE DATABASE IF NOT EXISTS user_db; CREATE DATABASE IF NOT EXISTS payment_db; CREATE DATABASE IF NOT EXISTS product_db;" 2>/dev/null || true
    
    # Start Redis
    if ! pgrep -x "redis-server" > /dev/null; then
        echo "  -> Starting Redis..."
        redis-server --daemonize yes --dir /workspace/springboot-kafka-microservices/data/redis 2>/dev/null
    else
        echo "  -> Redis already running"
    fi
    
    # Start Zookeeper
    if ! pgrep -f "org.apache.zookeeper.server.quorum.QuorumPeerMain" > /dev/null; then
        echo "  -> Starting Zookeeper..."
        nohup /workspace/springboot-kafka-microservices/kafka/bin/zookeeper-server-start.sh /workspace/springboot-kafka-microservices/kafka/config/zookeeper.properties > /tmp/zookeeper.log 2>&1 &
        sleep 5
    else
        echo "  -> Zookeeper already running"
    fi
    
    # Start Kafka
    if ! pgrep -f "kafka.Kafka" > /dev/null; then
        echo "  -> Starting Kafka..."
        nohup /workspace/springboot-kafka-microservices/kafka/bin/kafka-server-start.sh /workspace/springboot-kafka-microservices/kafka/config/server.properties > /tmp/kafka.log 2>&1 &
        sleep 10
    else
        echo "  -> Kafka already running"
    fi
    
    # Create Kafka topics
    echo "  -> Creating Kafka topics..."
    /workspace/springboot-kafka-microservices/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic order_topics --partitions 1 --replication-factor 1 2>/dev/null || true
    /workspace/springboot-kafka-microservices/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic create_order_topic --partitions 1 --replication-factor 1 2>/dev/null || true
    /workspace/springboot-kafka-microservices/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic product_topics --partitions 1 --replication-factor 1 2>/dev/null || true
    
    echo "Infrastructure started!"
}

# Function to start microservices
start_services() {
    echo ""
    echo "Starting microservices..."
    
    # Common environment variables
    export SPRING_DATASOURCE_PASSWORD=root
    export SPRING_KAFKA_BOOTSTRAP_SERVERS=localhost:9092
    export EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://localhost:8761/eureka/
    
    # Start Service Registry (Eureka)
    if [ "$(check_service 8761)" != "200" ]; then
        echo "  -> Starting Service Registry (Eureka)..."
        nohup java -jar /workspace/springboot-kafka-microservices/service-registry/target/service-registry.jar > /tmp/service-registry.log 2>&1 &
        sleep 10
    else
        echo "  -> Service Registry already running"
    fi
    
    # Start Identity Service
    if [ "$(check_service 9898)" != "200" ]; then
        echo "  -> Starting Identity Service..."
        nohup java -jar /workspace/springboot-kafka-microservices/identity-service/target/identity-service.jar > /tmp/identity-service.log 2>&1 &
        sleep 12
    else
        echo "  -> Identity Service already running"
    fi
    
    # Start Product Service
    if [ "$(check_service 8084)" != "200" ]; then
        echo "  -> Starting Product Service..."
        nohup java -jar /workspace/springboot-kafka-microservices/product-service/target/product-service.jar > /tmp/product-service.log 2>&1 &
        sleep 12
    else
        echo "  -> Product Service already running"
    fi
    
    # Start Order Service
    if [ "$(check_service 8080)" != "200" ]; then
        echo "  -> Starting Order Service..."
        nohup java -jar /workspace/springboot-kafka-microservices/order-service/target/order-service.jar > /tmp/order-service.log 2>&1 &
        sleep 12
    else
        echo "  -> Order Service already running"
    fi
    
    # Start Payment Service
    if [ "$(check_service 8085)" != "200" ]; then
        echo "  -> Starting Payment Service..."
        nohup java -jar /workspace/springboot-kafka-microservices/payment-service/target/payment-service.jar > /tmp/payment-service.log 2>&1 &
        sleep 12
    else
        echo "  -> Payment Service already running"
    fi
    
    # Start Email Service
    if [ "$(check_service 8086)" != "200" ]; then
        echo "  -> Starting Email Service..."
        nohup java -jar /workspace/springboot-kafka-microservices/email-service/target/email-service.jar > /tmp/email-service.log 2>&1 &
        sleep 12
    else
        echo "  -> Email Service already running"
    fi
    
    # Start API Gateway
    if [ "$(check_service 9191)" != "200" ]; then
        echo "  -> Starting API Gateway..."
        nohup java -jar /workspace/springboot-kafka-microservices/api-gateway/target/api-gateway.jar > /tmp/api-gateway.log 2>&1 &
        sleep 12
    else
        echo "  -> API Gateway already running"
    fi
}

# Function to display service status
show_status() {
    echo ""
    echo "=========================================="
    echo "           Service Status"
    echo "=========================================="
    echo ""
    
    printf "%-20s %-10s %s\n" "Service" "Port" "Status"
    printf "%-20s %-10s %s\n" "-------" "----" "------"
    
    check_and_display() {
        local name=$1
        local port=$2
        local status=$(curl -s http://localhost:$port/actuator/health 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        if [ "$status" = "UP" ]; then
            printf "%-20s %-10s %s\n" "$name" "$port" "✅ Running"
        else
            printf "%-20s %-10s %s\n" "$name" "$port" "❌ Stopped"
        fi
    }
    
    check_and_display "Service Registry" "8761"
    check_and_display "API Gateway" "9191"
    check_and_display "Identity Service" "9898"
    check_and_display "Product Service" "8084"
    check_and_display "Order Service" "8080"
    check_and_display "Payment Service" "8085"
    check_and_display "Email Service" "8086"
    
    echo ""
    echo "Access points:"
    echo "  - Eureka Dashboard: http://localhost:8761"
    echo "  - API Gateway:      http://localhost:9191"
    echo "  - Product Service:  http://localhost:8084"
    echo "  - Order Service:    http://localhost:8080"
    echo ""
}

# Main execution
start_infrastructure
start_services
show_status

echo "Startup complete!"