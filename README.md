# Elixir Node Control Center

## Features

- Automated Docker Setup
- Real-Time Feedback
- Node Management (Start/Stop/Restart)
- Configuration Handling (.env)
- Log Monitoring

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/sicmundu/elixir-node-installer.git
    cd elixir-node-control-center
    ```

2. Make the script executable:
    ```bash
    chmod +x elixir-installer.sh
    ```

3. Run the script:
    ```bash
    ./elixir-installer.sh
    ```

## Usage

Menu options:

1) Install Elixir Node
2) Remove Elixir Node
3) View Node Logs
4) View Configuration
5) Manage Node (Start/Stop/Restart)
6) Help
7) Exit

## Configuration

`.env` file created in `~/.elixir/`:

```plaintext
ENV=testnet-3
STRATEGY_EXECUTOR_DISPLAY_NAME=your_node_name
STRATEGY_EXECUTOR_BENEFICIARY=your_metamask_address
SIGNER_PRIVATE_KEY=your_private_key
STRATEGY_EXECUTOR_IP_ADDRESS=your_external_ip
```

If you found this tool useful, please don’t forget to ⭐ the repository!