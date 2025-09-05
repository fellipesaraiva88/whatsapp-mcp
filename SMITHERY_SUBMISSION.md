# WhatsApp MCP Server - Smithery Submission

## Overview

This is a submission for the **WhatsApp MCP Server** to be listed on [Smithery.ai](https://smithery.ai/docs).

## Server Details

- **Name**: WhatsApp MCP Server
- **Repository**: https://github.com/lharries/whatsapp-mcp
- **Author**: Luke Harries
- **License**: MIT
- **Version**: 1.0.0

## Description

A Model Context Protocol (MCP) server that connects Claude to your personal WhatsApp account. Enables searching messages, managing contacts, and sending messages/media directly from Claude through the WhatsApp Web API.

## Key Features

- 🔍 **Message Search**: Search through your WhatsApp message history
- 👥 **Contact Management**: Find and manage WhatsApp contacts
- 💬 **Send Messages**: Send text messages to individuals and groups
- 📎 **Media Support**: Send/receive images, videos, documents, and audio
- 🎵 **Voice Messages**: Send audio files as playable WhatsApp voice messages
- 💾 **Local Storage**: All data stored locally in SQLite database
- 🔒 **Privacy First**: Direct WhatsApp Web API connection, no third parties
- 🌐 **Dual Mode**: Supports both HTTP and STDIO transport modes

## Installation Methods

### Quick Setup (Recommended)
```bash
git clone https://github.com/lharries/whatsapp-mcp.git
cd whatsapp-mcp
./setup_http.sh
./start_whatsapp_mcp.sh
```

### Manual Setup
1. Clone repository
2. Run WhatsApp bridge: `cd whatsapp-bridge && go run main.go`
3. Configure MCP server: `cd whatsapp-mcp-server && uv sync`
4. Add to Claude Desktop configuration

## Configuration Examples

### HTTP Mode (Recommended)
```json
{
  "mcpServers": {
    "whatsapp": {
      "command": "python3",
      "args": [
        "/path/to/whatsapp-mcp/whatsapp-mcp-server/main.py",
        "--transport", "http",
        "--host", "localhost",
        "--port", "8000"
      ]
    }
  }
}
```

### STDIO Mode
```json
{
  "mcpServers": {
    "whatsapp": {
      "command": "uv",
      "args": [
        "--directory", "/path/to/whatsapp-mcp/whatsapp-mcp-server",
        "run", "main.py"
      ]
    }
  }
}
```

## Available Tools

1. **search_contacts** - Search contacts by name or phone
2. **list_messages** - Retrieve messages with filters
3. **list_chats** - List available chats
4. **get_chat** - Get specific chat information
5. **send_message** - Send text messages
6. **send_file** - Send media files
7. **send_audio_message** - Send voice messages
8. **download_media** - Download message media
9. **get_message_context** - Get message context
10. **get_last_interaction** - Get recent interactions

## Requirements

- **Python**: 3.11+
- **Go**: 1.18+
- **UV**: Python package manager
- **FFmpeg**: Optional, for audio conversion
- **WhatsApp Account**: Personal account for authentication

## Security & Privacy

- ✅ All data stored locally in SQLite
- ✅ Direct WhatsApp Web API connection
- ✅ QR code authentication (like WhatsApp Web)
- ✅ No third-party services involved
- ✅ Data only accessed when explicitly requested

## Platform Support

- ✅ macOS
- ✅ Linux  
- ✅ Windows (with CGO enabled)

## Documentation

- **Main README**: [README.md](https://github.com/lharries/whatsapp-mcp/blob/main/README.md)
- **HTTP Setup Guide**: [HTTP_SETUP.md](https://github.com/lharries/whatsapp-mcp/blob/main/HTTP_SETUP.md)
- **Example Configuration**: [claude_desktop_config.example.json](https://github.com/lharries/whatsapp-mcp/blob/main/claude_desktop_config.example.json)

## Example Usage

```
User: "List my recent WhatsApp conversations"
Claude: *uses list_chats tool* Here are your recent conversations...

User: "Send a message to John saying I'll be late"
Claude: *uses search_contacts and send_message tools* Message sent to John!

User: "Show me messages from yesterday with Sarah"
Claude: *uses list_messages tool with filters* Here are your messages with Sarah from yesterday...
```

## Submission Files

- `smithery.json` - Smithery metadata file
- `SMITHERY_SUBMISSION.md` - This submission document
- Complete project with documentation and examples

## Contact

- **Author**: Luke Harries
- **GitHub**: https://github.com/lharries
- **Repository**: https://github.com/lharries/whatsapp-mcp

---

This MCP server provides a powerful bridge between Claude and WhatsApp, enabling seamless messaging automation while maintaining privacy and security through local data storage.
