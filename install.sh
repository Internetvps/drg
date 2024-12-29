#!/bin/bash

# Constants
PYTHON_SCRIPT_URL="https://github.com/internetvps/drg/raw/main/drg_websocket.py"
DRG_MANAGER_SCRIPT_URL="https://github.com/internetvps/drg/raw/main/drg_manager.sh"
INSTALL_DIR="/opt/drg_websocket"
SYSTEMD_SERVICE_FILE="/etc/systemd/system/drg_websocket.service"
PYTHON_BIN=$(command -v python3)  # Ensure python3 is available
DRG_MANAGER_SCRIPT="drg_manager.sh"
DRG_MANAGER_PATH="$INSTALL_DIR/$DRG_MANAGER_SCRIPT"
DRG_MANAGER_LINK="/usr/local/bin/websocket"

# Function to install required packages
install_required_packages() {
    echo "Installing required packages..."
    apt-get update
    apt-get install -y python3-pip dos2unix wget
    pip3 install --upgrade pip
    pip3 install websocket-client  # Adjust with other required packages as needed
}

# Function to download Python proxy script using wget
download_drg_websocket() {
    echo "Downloading Python proxy script from $PYTHON_SCRIPT_URL..."
    wget -O "$INSTALL_DIR/drg_websocket.py" "$PYTHON_SCRIPT_URL"
}

# Function to download drg_manager.sh script using wget
download_drg_manager() {
    echo "Downloading $DRG_MANAGER_SCRIPT from $DRG_MANAGER_SCRIPT_URL..."
    wget -O "$DRG_MANAGER_PATH" "$DRG_MANAGER_SCRIPT_URL"
    chmod +x "$DRG_MANAGER_PATH"
    ln -sf "$DRG_MANAGER_PATH" "$DRG_MANAGER_LINK"
    convert_to_unix_line_endings "$DRG_MANAGER_PATH"
}

# Function to convert script to Unix line endings
convert_to_unix_line_endings() {
    local file="$1"
    echo "Converting $file to Unix line endings..."
    dos2unix "$file"
}

# Function to start systemd service
start_systemd_service() {
    echo "Starting drg_websocket service..."
    systemctl start drg_websocket
    systemctl status drg_websocket --no-pager  # Optionally, show status after starting
}

# Function to install systemd service
install_systemd_service() {
    echo "Creating systemd service file..."
    cat > "$SYSTEMD_SERVICE_FILE" <<EOF
[Unit]
Description=Python Proxy Service
After=network.target

[Service]
ExecStart=$PYTHON_BIN $INSTALL_DIR/drg_websocket.py 8098
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF
    echo "Reloading systemd daemon..."
    systemctl daemon-reload
    echo "Enabling drg_websocket service..."
    systemctl enable drg_websocket
}

# Function to display banner
display_banner() {
    cat << "EOF"
**********************************************
*                                            *
*                 DRG VPN                 *
*      Visit me on Telegram: @DRG_VPN      *
*                                            *
**********************************************
EOF
    echo
}

# Function to display installation summary
display_installation_summary() {
    echo "Installation completed successfully!"
    echo
    echo "Installed DRG_websocket.py in: $INSTALL_DIR"
    echo "Installed $DRG_MANAGER_SCRIPT in: $DRG_MANAGER_PATH"
    echo "You can now manage the WebSocket service using 'websocket menu' command."
}

# Main function
main() {
    display_banner

    # Install required packages
    install_required_packages

    # Check if python3 is available
    if [ -z "$PYTHON_BIN" ]; then
        echo "Error: Python 3 is not installed or not found in PATH. Please install Python 3."
        exit 1
    fi

    # Create installation directory
    echo "Creating installation directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"

    # Download Python proxy script
    download_drg_websocket

    # Download DRG_manager.sh script
    download_drg_manager

    # Install systemd service
    install_systemd_service
    
    # Start systemd service
    start_systemd_service

    # Display installation summary
    display_installation_summary
}

# Run main function
main
