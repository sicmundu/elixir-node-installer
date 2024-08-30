#!/bin/bash

# Define color codes
RESET="\e[0m"
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
MAGENTA="\e[35m"
BLACK="\e[30m"
BG_RED="\e[41m"
BG_GREEN="\e[42m"

# Hacking-style ASCII banner
banner() {
    echo -e "${MAGENTA}"
    echo -e "
><<<<<<<< ><<                      
><<       ><< ><          ><       
><<       ><<   ><<   ><<   >< ><<<
><<<<<<   ><<><<  >< ><< ><< ><<   
><<       ><<><<   ><    ><< ><<   
><<       ><<><< ><  ><< ><< ><<   
><<<<<<<<><<<><<><<   ><<><<><<<    
    "
    echo -e "${RESET}"
}

# Log messages with colors
log() {
    echo -e "${CYAN}[+] $1${RESET}"
}

# Handle errors
handle_error() {
    echo -e "${BG_RED}${BLACK}[-] Error: $1${RESET}"
    exit 1
}

# Check and install package if missing
install_package() {
    if ! dpkg -l | grep -qw "$1"; then
        log "Installing $1..."
        sudo apt-get install -y "$1" || handle_error "Failed to install $1."
    else
        log "$1 is already installed."
    fi
}

# Check and install Docker
install_docker() {
    if ! command -v docker &> /dev/null; then
        log "Docker not found. Initiating stealth installation..."
        sudo install -m 0755 -d /etc/apt/keyrings || handle_error "Keyrings directory creation failed."
        wget -q -O- https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null || handle_error "GPG key download failed."
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || handle_error "Failed to add Docker repo."
        sudo apt-get update -q || handle_error "Failed to update package list."
        install_package "docker-ce"
    else
        log "Docker is already in the system. No further actions required."
    fi
}

# Prompt user for input
gather_input() {
    read -p "$(echo -e ${MAGENTA}Node name:${RESET}) " NODE_NAME
    read -p "$(echo -e ${MAGENTA}Metamask address:${RESET}) " METAMASK_ADDRESS
    read -p "$(echo -e ${MAGENTA}Private key:${RESET}) " PRIVATE_KEY
    PRIVATE_KEY=$(echo "$PRIVATE_KEY" | sed 's/^0x//')
}

# Get external IP address
fetch_external_ip() {
    log "Locating external IP address..."
    EXTERNAL_IP=$(curl -4 -s ifconfig.me)
    if [ -z "$EXTERNAL_IP" ]; then
        handle_error "External IP could not be retrieved. Are you behind a firewall?"
    fi
    log "External IP: $EXTERNAL_IP"
}

# Create .env file for node configuration
create_env() {
    ENV_DIR="$HOME/.elixir"
    ENV_FILE="$ENV_DIR/.env"

    if [ ! -d "$ENV_DIR" ]; then
        log "Creating directory at $ENV_DIR... Shh, no one should know."
        mkdir -p "$ENV_DIR" || handle_error "Directory creation failed."
    fi

    log "Writing secrets to .env..."
    cat <<EOF > "$ENV_FILE"
ENV=testnet-3

STRATEGY_EXECUTOR_DISPLAY_NAME=$NODE_NAME
STRATEGY_EXECUTOR_BENEFICIARY=$METAMASK_ADDRESS
SIGNER_PRIVATE_KEY=$PRIVATE_KEY
STRATEGY_EXECUTOR_IP_ADDRESS=$EXTERNAL_IP
EOF

    [ -f "$ENV_FILE" ] && log ".env file is in place. All systems go." || handle_error ".env file creation failed."
}

# Run the Elixir node
start_node() {
    log "Downloading Elixir node image... Patience, hacker."
    docker pull elixirprotocol/validator:3.1.0 || handle_error "Failed to pull Docker image."

    log "Launching Elixir node... Engaging engines."
    docker run -d \
        --env-file "$ENV_FILE" \
        --name elixir \
        --restart unless-stopped \
        elixirprotocol/validator:3.1.0 || handle_error "Failed to launch Elixir node."

    log "Node is live. Let the magic begin."
}

# Stop the Elixir node
stop_node() {
    log "Terminating Elixir node... Goodbye."
    docker stop elixir || handle_error "Failed to stop Elixir node."
    log "Node terminated."
}

# Remove the Elixir node
remove_node() {
    log "Erasing all traces of the Elixir node..."
    docker rm elixir || handle_error "Failed to remove Elixir node."
    log "Node completely wiped from existence."
}

# Restart the Elixir node
restart_node() {
    log "Rebooting the system... Fasten your seatbelts."
    stop_node
    remove_node
    start_node
    log "System reboot complete. Back in action."
}

# Display logs for the node
show_logs() {
    log "Tailing node logs... Stay sharp."
    docker logs -f elixir
}

# View .env configuration
view_env() {
    log "Decrypting .env configuration..."
    [ -f "$HOME/.elixir/.env" ] && cat "$HOME/.elixir/.env" || handle_error ".env file not found."
}

# Display help menu
show_help() {
    echo -e "${MAGENTA}Elixir Node Control Center${RESET}"
    echo "1) Install Elixir Node"
    echo "2) Remove Elixir Node"
    echo "3) View Node Logs"
    echo "4) View Configuration"
    echo "5) Manage Node (Start/Stop/Restart)"
    echo "6) Help"
    echo "7) Exit"
    echo -n "Choose your destiny: "
    read -r choice

    case $choice in
        1) install_node ;;
        2) remove_node ;;
        3) show_logs ;;
        4) view_env ;;
        5) manage_node ;;
        6) show_help ;;
        7) exit 0 ;;
        *) echo "Invalid option. The system knows..." ;;
    esac
}

# Installation process
install_node() {
    log "=== Elixir Node Installation Sequence Initiated ==="
    gather_input
    fetch_external_ip
    create_env
    install_docker
    start_node
    show_logs
}

# Node management menu
manage_node() {
    echo -e "${MAGENTA}Node Operations Menu${RESET}"
    echo "1) Start Node"
    echo "2) Stop Node"
    echo "3) Restart Node"
    echo "4) Back to Main Menu"
    echo -n "Select an operation: "
    read -r choice

    case $choice in
        1) start_node ;;
        2) stop_node ;;
        3) restart_node ;;
        4) show_help ;;
        *) echo "Invalid option. The matrix rejects your input..." ;;
    esac
}

# Main script execution
banner
show_help
