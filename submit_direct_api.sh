#!/bin/bash

# Script para submeter WhatsApp MCP ao Smithery via API REST direta
# Este script usa curl para fazer a submissão diretamente

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo -e "${BLUE}🚀 Submetendo WhatsApp MCP ao Smithery via API${NC}"
echo "=============================================="

# Verificar se estamos no diretório correto
if [ ! -f "whatsapp-mcp-server/main.py" ]; then
    print_error "Execute este script do diretório whatsapp-mcp/"
    exit 1
fi

# Verificar se curl está disponível
if ! command -v curl &> /dev/null; then
    print_error "curl não encontrado. Instale curl primeiro."
    exit 1
fi

# Criar diretório temporário
mkdir -p .smithery

print_info "Preparando dados para submissão..."

# Criar arquivo JSON com metadados completos
cat > .smithery/submission.json << 'EOF'
{
  "name": "whatsapp-mcp",
  "displayName": "WhatsApp MCP Server",
  "description": "Connect Claude to your personal WhatsApp account. Search messages, contacts, send messages and media files directly from Claude.",
  "longDescription": "This MCP server enables Claude to interact with your personal WhatsApp account through the WhatsApp Web API. Features include searching through message history, finding contacts, sending text messages and media files (images, videos, documents, audio), and managing both individual and group conversations. All data is stored locally in SQLite and only accessed when you explicitly use the tools.",
  "version": "1.0.0",
  "author": {
    "name": "Luke Harries",
    "email": "luke@lharries.com",
    "url": "https://github.com/lharries"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/lharries/whatsapp-mcp.git"
  },
  "license": "MIT",
  "keywords": [
    "whatsapp",
    "messaging", 
    "communication",
    "social",
    "chat",
    "contacts",
    "media",
    "automation"
  ],
  "categories": [
    "communication",
    "social", 
    "productivity"
  ],
  "homepage": "https://github.com/lharries/whatsapp-mcp",
  "documentation": "https://github.com/lharries/whatsapp-mcp/blob/main/README.md",
  "requirements": {
    "python": ">=3.11",
    "go": ">=1.18",
    "os": ["macos", "linux", "windows"]
  },
  "installation": {
    "methods": [
      {
        "type": "git",
        "url": "https://github.com/lharries/whatsapp-mcp.git",
        "instructions": [
          "Clone the repository",
          "Run ./setup_http.sh for HTTP mode (recommended)",
          "Or follow manual installation in README.md"
        ]
      }
    ]
  },
  "configuration": {
    "stdio": {
      "command": "uv",
      "args": [
        "--directory",
        "{{PATH_TO_REPO}}/whatsapp-mcp-server",
        "run",
        "main.py"
      ]
    },
    "http": {
      "command": "python3",
      "args": [
        "{{PATH_TO_REPO}}/whatsapp-mcp-server/main.py",
        "--transport",
        "http",
        "--host",
        "localhost",
        "--port",
        "8000"
      ]
    }
  },
  "tools": [
    {
      "name": "search_contacts",
      "description": "Search WhatsApp contacts by name or phone number"
    },
    {
      "name": "list_messages",
      "description": "Get WhatsApp messages with filtering and context options"
    },
    {
      "name": "list_chats",
      "description": "List available WhatsApp chats with metadata"
    },
    {
      "name": "get_chat",
      "description": "Get information about a specific chat"
    },
    {
      "name": "send_message",
      "description": "Send a WhatsApp message to a person or group"
    },
    {
      "name": "send_file",
      "description": "Send media files (images, videos, documents) via WhatsApp"
    },
    {
      "name": "send_audio_message",
      "description": "Send audio files as WhatsApp voice messages"
    },
    {
      "name": "download_media",
      "description": "Download media from WhatsApp messages"
    },
    {
      "name": "get_message_context",
      "description": "Get context around a specific message"
    },
    {
      "name": "get_last_interaction",
      "description": "Get most recent message with a contact"
    }
  ],
  "features": [
    "Personal WhatsApp account integration",
    "Message search and retrieval",
    "Contact management",
    "Send text messages and media files",
    "Group chat support",
    "Local SQLite storage",
    "Media download and upload",
    "Voice message support",
    "HTTP and STDIO transport modes",
    "Cross-platform compatibility"
  ],
  "security": {
    "dataHandling": "All WhatsApp data is stored locally in SQLite database. No data is sent to external services except when explicitly requested through MCP tools.",
    "authentication": "Uses WhatsApp Web QR code authentication. Session data stored locally.",
    "privacy": "Direct connection to WhatsApp Web API. No third-party services involved."
  },
  "screenshots": [
    {
      "url": "https://raw.githubusercontent.com/lharries/whatsapp-mcp/main/example-use.png",
      "caption": "Example of WhatsApp MCP integration with Claude Desktop"
    }
  ],
  "tags": ["messaging", "whatsapp", "communication", "social", "automation", "productivity"],
  "maturity": "stable",
  "maintenance": "active"
}
EOF

print_status "Arquivo de submissão criado"

# Função para tentar diferentes endpoints da API
try_api_submission() {
    local endpoints=(
        "https://api.smithery.ai/v1/servers"
        "https://smithery.ai/api/v1/servers" 
        "https://smithery.ai/api/servers"
        "https://smithery.ai/api/submit"
        "https://api.smithery.ai/servers"
    )
    
    # Tentar obter API key do arquivo de configuração do Smithery
    local api_key=""
    if [ -f ~/.smithery/config.json ]; then
        api_key=$(cat ~/.smithery/config.json | grep -o '"apiKey":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
    fi
    
    if [ -z "$api_key" ]; then
        print_warning "API key não encontrada. Tentando submissão sem autenticação..."
    else
        print_info "API key encontrada, usando autenticação"
    fi
    
    for endpoint in "${endpoints[@]}"; do
        print_info "Tentando endpoint: $endpoint"
        
        local curl_cmd="curl -X POST \"$endpoint\" \
            -H \"Content-Type: application/json\" \
            -H \"Accept: application/json\" \
            -H \"User-Agent: WhatsApp-MCP-Submitter/1.0\""
        
        if [ -n "$api_key" ]; then
            curl_cmd="$curl_cmd -H \"Authorization: Bearer $api_key\""
        fi
        
        curl_cmd="$curl_cmd -d @.smithery/submission.json --fail --silent --show-error --write-out \"HTTP %{http_code}\""
        
        local response
        if response=$(eval $curl_cmd 2>&1); then
            print_status "Resposta do servidor: $response"
            if [[ "$response" == *"HTTP 2"* ]] || [[ "$response" == *"HTTP 201"* ]]; then
                print_status "Submissão bem-sucedida via $endpoint!"
                return 0
            fi
        else
            print_warning "Endpoint $endpoint falhou: $response"
        fi
    done
    
    return 1
}

# Tentar submissão via API
print_info "Tentando submissão via API REST..."

if try_api_submission; then
    print_status "Servidor submetido com sucesso via API!"
else
    print_warning "Todas as tentativas de API falharam. Preparando submissão manual..."
    
    # Criar instruções para submissão manual
    cat > .smithery/manual_submission_guide.md << 'EOF'
# Guia de Submissão Manual - WhatsApp MCP

## Dados para o Formulário Web

**URL do Formulário**: https://smithery.ai/submit

### Informações Básicas
- **Nome**: WhatsApp MCP Server
- **Nome de Exibição**: WhatsApp MCP Server
- **Repositório**: https://github.com/lharries/whatsapp-mcp
- **Versão**: 1.0.0
- **Licença**: MIT

### Descrição
**Descrição Curta**:
Connect Claude to your personal WhatsApp account. Search messages, contacts, send messages and media files directly from Claude.

**Descrição Longa**:
This MCP server enables Claude to interact with your personal WhatsApp account through the WhatsApp Web API. Features include searching through message history, finding contacts, sending text messages and media files (images, videos, documents, audio), and managing both individual and group conversations. All data is stored locally in SQLite and only accessed when you explicitly use the tools.

### Categorias
- Communication
- Social  
- Productivity

### Tags/Keywords
whatsapp, messaging, communication, social, chat, contacts, media, automation

### Autor
- **Nome**: Luke Harries
- **Email**: luke@lharries.com
- **URL**: https://github.com/lharries

### Links
- **Homepage**: https://github.com/lharries/whatsapp-mcp
- **Documentação**: https://github.com/lharries/whatsapp-mcp/blob/main/README.md
- **Screenshot**: https://raw.githubusercontent.com/lharries/whatsapp-mcp/main/example-use.png

### Arquivo de Metadados
Anexar o arquivo: .smithery/submission.json
EOF

    print_status "Guia de submissão manual criado"
    
    echo ""
    echo -e "${YELLOW}📋 Submissão Manual Necessária${NC}"
    echo "================================"
    echo ""
    echo -e "${BLUE}1. Acesse:${NC} https://smithery.ai/submit"
    echo -e "${BLUE}2. Use as informações em:${NC} .smithery/manual_submission_guide.md"
    echo -e "${BLUE}3. Anexe o arquivo:${NC} .smithery/submission.json"
    echo ""
    
    # Tentar abrir o navegador automaticamente
    if command -v open &> /dev/null; then
        print_info "Abrindo formulário no navegador..."
        open "https://smithery.ai/submit"
    elif command -v xdg-open &> /dev/null; then
        print_info "Abrindo formulário no navegador..."
        xdg-open "https://smithery.ai/submit"
    else
        print_info "Acesse manualmente: https://smithery.ai/submit"
    fi
fi

print_status "Processo de submissão concluído!"
echo ""
echo -e "${GREEN}🎉 WhatsApp MCP preparado para Smithery!${NC}"
echo "======================================="
echo ""
echo -e "${BLUE}Arquivos criados:${NC}"
echo "  📄 .smithery/submission.json - Metadados completos"
echo "  📋 .smithery/manual_submission_guide.md - Guia manual"
echo ""
echo -e "${BLUE}Próximos passos:${NC}"
echo "1. Se a submissão automática funcionou, aguarde aprovação"
echo "2. Se não, use o formulário web com os dados preparados"
echo "3. Responda a qualquer feedback da equipe do Smithery"
echo "4. Promova o servidor após aprovação"
echo ""
print_status "Submissão via CLI concluída! 🚀"
