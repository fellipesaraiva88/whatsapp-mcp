#!/usr/bin/env python3
"""
WhatsApp MCP HTTP Server Starter
This script starts the WhatsApp MCP server in HTTP mode for easy integration with Claude Desktop.
"""

import subprocess
import sys
import os
import json
from pathlib import Path

def create_claude_config():
    """Create or update Claude Desktop configuration for HTTP MCP server."""
    
    # Determine the Claude config path based on OS
    if sys.platform == "darwin":  # macOS
        config_dir = Path.home() / "Library" / "Application Support" / "Claude"
    elif sys.platform == "win32":  # Windows
        config_dir = Path.home() / "AppData" / "Roaming" / "Claude"
    else:  # Linux
        config_dir = Path.home() / ".config" / "claude"
    
    config_file = config_dir / "claude_desktop_config.json"
    
    # Create config directory if it doesn't exist
    config_dir.mkdir(parents=True, exist_ok=True)
    
    # Load existing config or create new one
    if config_file.exists():
        with open(config_file, 'r') as f:
            config = json.load(f)
    else:
        config = {}
    
    # Ensure mcpServers section exists
    if "mcpServers" not in config:
        config["mcpServers"] = {}
    
    # Add WhatsApp MCP server configuration
    config["mcpServers"]["whatsapp"] = {
        "command": "python",
        "args": [str(Path(__file__).parent / "main.py"), "--transport", "http", "--host", "localhost", "--port", "8000"],
        "env": {}
    }
    
    # Write updated config
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f"✅ Claude Desktop configuration updated at: {config_file}")
    print("📝 Added WhatsApp MCP server configuration")

def start_server(host="localhost", port=8000):
    """Start the WhatsApp MCP server in HTTP mode."""
    
    print(f"🚀 Starting WhatsApp MCP HTTP Server on {host}:{port}")
    print("📱 Make sure the WhatsApp bridge is running first!")
    print("🔗 Server will be available at: http://{}:{}".format(host, port))
    print("⏹️  Press Ctrl+C to stop the server")
    print("-" * 50)
    
    try:
        # Start the server
        subprocess.run([
            sys.executable, 
            str(Path(__file__).parent / "main.py"),
            "--transport", "http",
            "--host", host,
            "--port", str(port)
        ], check=True)
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error starting server: {e}")
        sys.exit(1)

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Start WhatsApp MCP HTTP Server')
    parser.add_argument('--host', default='localhost', help='Host to bind to')
    parser.add_argument('--port', type=int, default=8000, help='Port to bind to')
    parser.add_argument('--config-only', action='store_true', 
                       help='Only update Claude Desktop config, don\'t start server')
    
    args = parser.parse_args()
    
    # Always update Claude config
    create_claude_config()
    
    if not args.config_only:
        start_server(args.host, args.port)
    else:
        print("✅ Configuration updated. You can now restart Claude Desktop.")

if __name__ == "__main__":
    main()
