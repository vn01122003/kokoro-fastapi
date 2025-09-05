#!/bin/bash

# Kokoro FastAPI Production Deployment Script
# Usage: ./deploy.sh [start|stop|restart|logs|status|update]

set -e

# Configuration
COMPOSE_FILE="docker-compose.production.yml"
PROJECT_NAME="kokoro-fastapi"
BACKUP_DIR="./backups"
LOG_DIR="./logs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if Docker and Docker Compose are installed
check_dependencies() {
    log "Checking dependencies..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    log "Dependencies check passed ✓"
}

# Create necessary directories
setup_directories() {
    log "Setting up directories..."
    mkdir -p "$BACKUP_DIR" "$LOG_DIR"
    log "Directories created ✓"
}

# Backup existing data
backup_data() {
    log "Creating backup..."
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_file="$BACKUP_DIR/kokoro_backup_$timestamp.tar.gz"
    
    if [ -d "volumes" ]; then
        tar -czf "$backup_file" volumes/
        log "Backup created: $backup_file"
    else
        warning "No volumes directory found, skipping backup"
    fi
}

# Build and start services
start_services() {
    log "Starting Kokoro FastAPI services..."
    
    # Use docker-compose or docker compose based on availability
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        COMPOSE_CMD="docker compose"
    fi
    
    $COMPOSE_CMD -f "$COMPOSE_FILE" -p "$PROJECT_NAME" up -d --build
    
    log "Services started ✓"
    info "API available at: http://localhost:8880"
    info "Web UI available at: http://localhost/web/"
    info "API docs available at: http://localhost/docs"
}

# Stop services
stop_services() {
    log "Stopping services..."
    
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        COMPOSE_CMD="docker compose"
    fi
    
    $COMPOSE_CMD -f "$COMPOSE_FILE" -p "$PROJECT_NAME" down
    
    log "Services stopped ✓"
}

# Restart services
restart_services() {
    log "Restarting services..."
    stop_services
    sleep 5
    start_services
}

# Show logs
show_logs() {
    log "Showing logs (press Ctrl+C to exit)..."
    
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        COMPOSE_CMD="docker compose"
    fi
    
    $COMPOSE_CMD -f "$COMPOSE_FILE" -p "$PROJECT_NAME" logs -f
}

# Show status
show_status() {
    log "Service status:"
    
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        COMPOSE_CMD="docker compose"
    fi
    
    $COMPOSE_CMD -f "$COMPOSE_FILE" -p "$PROJECT_NAME" ps
    
    echo ""
    info "Health check:"
    if curl -f http://localhost:8880/health &> /dev/null; then
        log "✓ API is healthy"
    else
        error "✗ API is not responding"
    fi
}

# Update services
update_services() {
    log "Updating services..."
    backup_data
    stop_services
    start_services
    log "Update completed ✓"
}

# Clean up old containers and images
cleanup() {
    log "Cleaning up old containers and images..."
    
    # Remove stopped containers
    docker container prune -f
    
    # Remove unused images
    docker image prune -f
    
    # Remove unused volumes (be careful with this)
    read -p "Remove unused volumes? This will delete all unused data. (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker volume prune -f
        log "Cleanup completed ✓"
    else
        log "Skipped volume cleanup"
    fi
}

# Main script logic
main() {
    case "${1:-start}" in
        start)
            check_dependencies
            setup_directories
            start_services
            show_status
            ;;
        stop)
            stop_services
            ;;
        restart)
            restart_services
            show_status
            ;;
        logs)
            show_logs
            ;;
        status)
            show_status
            ;;
        update)
            check_dependencies
            update_services
            show_status
            ;;
        cleanup)
            cleanup
            ;;
        *)
            echo "Usage: $0 {start|stop|restart|logs|status|update|cleanup}"
            echo ""
            echo "Commands:"
            echo "  start    - Start all services (default)"
            echo "  stop     - Stop all services"
            echo "  restart  - Restart all services"
            echo "  logs     - Show logs from all services"
            echo "  status   - Show service status and health"
            echo "  update   - Update and restart services"
            echo "  cleanup  - Clean up old containers and images"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
