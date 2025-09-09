#!/bin/bash

# ============================================================================
# CyberBlue SOC - Complete Cleanup Script for Fresh Installation
# ============================================================================
# This script completely removes all CyberBlue components and prepares
# the system for a fresh installation.
# 
# Usage: ./cleanup-fresh-install.sh [OPTIONS]
# Options:
#   --keep-docker    Keep Docker installed (only remove containers/images)
#   --keep-data      Keep persistent data volumes
#   --force          Skip confirmation prompts
#   --help           Show this help message
# ============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KEEP_DOCKER=false
KEEP_DATA=false
FORCE=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --keep-docker)
                KEEP_DOCKER=true
                shift
                ;;
            --keep-data)
                KEEP_DATA=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    echo -e "${BLUE}🧹 CyberBlue SOC - Complete Cleanup Script${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --keep-docker    Keep Docker installed (only remove containers/images)"
    echo "  --keep-data      Keep persistent data volumes"
    echo "  --force          Skip confirmation prompts"
    echo "  --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # Complete cleanup with confirmation"
    echo "  $0 --force                   # Complete cleanup without confirmation"
    echo "  $0 --keep-docker --force     # Keep Docker, remove everything else"
    echo "  $0 --keep-data --force       # Keep data volumes, remove containers"
}

# Confirmation prompt
confirm_cleanup() {
    if [[ "$FORCE" == "true" ]]; then
        return 0
    fi

    echo -e "${YELLOW}⚠️  WARNING: This will completely remove CyberBlue SOC components!${NC}"
    echo ""
    echo "This script will:"
    echo "  🗑️  Stop and remove all Docker containers"
    echo "  🖼️  Remove all Docker images"
    if [[ "$KEEP_DATA" == "false" ]]; then
        echo "  💾 Remove all Docker volumes (data will be lost!)"
    fi
    echo "  🌐 Remove Docker networks"
    echo "  🔧 Remove build cache"
    if [[ "$KEEP_DOCKER" == "false" ]]; then
        echo "  🐳 Uninstall Docker completely"
    fi
    echo "  📁 Clean up CyberBlue directories"
    echo "  🔥 Remove iptables rules"
    echo "  🚫 Remove systemd services"
    echo ""
    
    read -p "Are you sure you want to continue? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo -e "${GREEN}✅ Cleanup cancelled.${NC}"
        exit 0
    fi
}

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ❌ $1${NC}"
}

# Check if running as root
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Do not run this script as root. It will use sudo when needed."
        exit 1
    fi
}

# Stop all running containers
stop_containers() {
    log "🛑 Stopping all running containers..."
    
    if docker ps -q | wc -l | grep -q "0"; then
        log "ℹ️  No running containers found"
    else
        sudo docker stop $(sudo docker ps -aq) 2>/dev/null || log_warn "Some containers couldn't be stopped"
        log "✅ All containers stopped"
    fi
}

# Remove all containers
remove_containers() {
    log "🗑️  Removing all containers..."
    
    if sudo docker ps -aq | wc -l | grep -q "0"; then
        log "ℹ️  No containers found"
    else
        sudo docker rm -f $(sudo docker ps -aq) 2>/dev/null || log_warn "Some containers couldn't be removed"
        log "✅ All containers removed"
    fi
}

# Remove Docker images
remove_images() {
    log "🖼️  Removing all Docker images..."
    
    if sudo docker images -q | wc -l | grep -q "0"; then
        log "ℹ️  No images found"
    else
        sudo docker rmi -f $(sudo docker images -q) 2>/dev/null || log_warn "Some images couldn't be removed"
        log "✅ All images removed"
    fi
}

# Remove Docker volumes
remove_volumes() {
    if [[ "$KEEP_DATA" == "true" ]]; then
        log_warn "Skipping volume removal (--keep-data specified)"
        return
    fi

    log "💾 Removing all Docker volumes..."
    
    if sudo docker volume ls -q | wc -l | grep -q "0"; then
        log "ℹ️  No volumes found"
    else
        sudo docker volume rm $(sudo docker volume ls -q) 2>/dev/null || log_warn "Some volumes couldn't be removed"
        log "✅ All volumes removed"
    fi
}

# Remove Docker networks
remove_networks() {
    log "🌐 Removing Docker networks..."
    
    # Remove custom networks (keep default ones)
    sudo docker network ls --format "{{.Name}}" | grep -v -E "^(bridge|host|none)$" | xargs -r sudo docker network rm 2>/dev/null || log_warn "Some networks couldn't be removed"
    log "✅ Custom networks removed"
}

# Clean Docker system
clean_docker_system() {
    log "🔧 Cleaning Docker system (build cache, unused objects)..."
    
    sudo docker system prune -a -f --volumes 2>/dev/null || log_warn "Docker system prune had issues"
    log "✅ Docker system cleaned"
}

# Remove Caldera systemd service
remove_caldera_service() {
    log "🚫 Removing Caldera systemd service..."
    
    if systemctl is-enabled caldera-autostart >/dev/null 2>&1; then
        sudo systemctl stop caldera-autostart 2>/dev/null || true
        sudo systemctl disable caldera-autostart 2>/dev/null || true
        sudo rm -f /etc/systemd/system/caldera-autostart.service
        sudo systemctl daemon-reload
        log "✅ Caldera service removed"
    else
        log "ℹ️  Caldera service not found"
    fi
}

# Clean iptables rules
clean_iptables() {
    log "🔥 Cleaning iptables rules..."
    
    # Reset iptables to default
    sudo iptables -t nat -F 2>/dev/null || true
    sudo iptables -t mangle -F 2>/dev/null || true
    sudo iptables -F 2>/dev/null || true
    sudo iptables -X 2>/dev/null || true
    
    # Remove persistent rules
    sudo rm -f /etc/iptables/rules.v4 2>/dev/null || true
    sudo rm -f /etc/iptables/rules.v6 2>/dev/null || true
    
    log "✅ iptables rules cleaned"
}

# Clean CyberBlue directories
clean_directories() {
    log "📁 Cleaning CyberBlue directories..."
    
    # Remove generated/downloaded content but keep source files
    local dirs_to_clean=(
        "arkime/pcaps"
        "arkime/logs"
        "logs"
        "wazuh/config/wazuh_indexer_ssl_certs"
        "ssl"
        "attack-navigator"
        "caldera"
        "wireshark/config"
        "suricata/logs"
        "portal/logs"
    )
    
    for dir in "${dirs_to_clean[@]}"; do
        if [[ -d "$dir" ]]; then
            sudo rm -rf "$dir" 2>/dev/null || log_warn "Couldn't remove $dir"
            log "  ✅ Removed $dir"
        fi
    done
    
    # Clean temporary files
    sudo find . -name "*.tmp" -delete 2>/dev/null || true
    sudo find . -name "*.log" -path "*/logs/*" -delete 2>/dev/null || true
    
    log "✅ Directories cleaned"
}

# Uninstall Docker completely
uninstall_docker() {
    if [[ "$KEEP_DOCKER" == "true" ]]; then
        log_warn "Skipping Docker uninstall (--keep-docker specified)"
        return
    fi

    log "🐳 Uninstalling Docker completely..."
    
    # Stop Docker service
    sudo systemctl stop docker 2>/dev/null || true
    sudo systemctl stop containerd 2>/dev/null || true
    
    # Remove Docker packages
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
    sudo apt-get purge -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc 2>/dev/null || true
    
    # Remove Docker directories
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    sudo rm -rf /etc/docker
    sudo rm -rf /usr/local/bin/docker-compose
    
    # Remove Docker group
    sudo groupdel docker 2>/dev/null || true
    
    # Remove repository
    sudo rm -f /etc/apt/sources.list.d/docker.list
    sudo rm -f /etc/apt/keyrings/docker.gpg
    
    # Clean package cache
    sudo apt-get autoremove -y 2>/dev/null || true
    sudo apt-get autoclean 2>/dev/null || true
    
    log "✅ Docker completely uninstalled"
}

# Reset system configuration
reset_system_config() {
    log "⚙️  Resetting system configuration..."
    
    # Remove sysctl changes
    sudo sed -i '/vm.max_map_count=262144/d' /etc/sysctl.conf 2>/dev/null || true
    
    # Remove limits.conf changes
    sudo sed -i '/\* soft nofile 65536/d' /etc/security/limits.conf 2>/dev/null || true
    sudo sed -i '/\* hard nofile 65536/d' /etc/security/limits.conf 2>/dev/null || true
    
    # Remove bashrc exports
    sed -i '/export DOCKER_BUILDKIT=1/d' ~/.bashrc 2>/dev/null || true
    sed -i '/export COMPOSE_DOCKER_CLI_BUILD=1/d' ~/.bashrc 2>/dev/null || true
    
    log "✅ System configuration reset"
}

# Main cleanup function
main_cleanup() {
    log "🧹 Starting CyberBlue SOC complete cleanup..."
    
    # Change to script directory
    cd "$SCRIPT_DIR"
    
    # Docker cleanup
    stop_containers
    remove_containers
    remove_images
    remove_volumes
    remove_networks
    clean_docker_system
    
    # System cleanup
    remove_caldera_service
    clean_iptables
    clean_directories
    reset_system_config
    
    # Optional Docker uninstall
    uninstall_docker
    
    log "🎉 Cleanup completed successfully!"
    
    if [[ "$KEEP_DOCKER" == "false" ]]; then
        echo ""
        echo -e "${BLUE}📋 Next steps for fresh installation:${NC}"
        echo "1. Run the prerequisites script from README.md"
        echo "2. Clone CyberBlue repository"
        echo "3. Run ./cyberblue_init.sh"
    else
        echo ""
        echo -e "${BLUE}📋 Next steps for fresh installation:${NC}"
        echo "1. Clone fresh CyberBlue repository (or git pull)"
        echo "2. Run ./cyberblue_init.sh"
    fi
}

# Main execution
main() {
    parse_args "$@"
    check_permissions
    confirm_cleanup
    main_cleanup
}

# Run main function with all arguments
main "$@"
