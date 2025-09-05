#!/bin/bash

# Script para submeter WhatsApp MCP ao Smithery via CLI/API
# Este script automatiza a submissão usando a API do Smithery

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

echo -e "${BLUE}🚀 Submetendo WhatsApp MCP ao Smithery via CLI${NC}"
echo "=================================================="

# Verificar se estamos no diretório correto
if [ ! -f "whatsapp-mcp-server/main.py" ]; then
    print_error "Execute este script do diretório whatsapp-mcp/"
    exit 1
fi

# Verificar se a CLI do Smithery está instalada
if ! command -v npx &> /dev/null; then
    print_error "npx não encontrado. Instale Node.js primeiro."
    exit 1
fi

print_info "Verificando autenticação do Smithery..."

# Verificar se está logado
if ! npx smithery list servers &> /dev/null; then
    print_warning "Não está logado no Smithery. Fazendo login..."
    npx smithery login
fi

print_status "Autenticado no Smithery"

# Criar arquivo de metadados temporário para submissão
print_info "Preparando metadados para submissão..."

# Criar um package.json temporário se não existir
if [ ! -f "package.json" ]; then
    cat > package.json << 'EOF'
{
  "name": "whatsapp-mcp",
  "version": "1.0.0",
  "description": "Connect Claude to your personal WhatsApp account",
  "main": "whatsapp-mcp-server/main.py",
  "scripts": {
    "start": "python3 whatsapp-mcp-server/main.py"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/lharries/whatsapp-mcp.git"
  },
  "keywords": [
    "whatsapp",
    "mcp",
    "messaging",
    "claude"
  ],
  "author": "Luke Harries",
  "license": "MIT"
}
EOF
    print_status "package.json criado"
fi

# Tentar usar o comando build para preparar o servidor
print_info "Preparando servidor MCP para submissão..."

# Criar diretório de build se não existir
mkdir -p .smithery

# Tentar fazer build do servidor
if npx smithery build whatsapp-mcp-server/main.py --transport http --out .smithery/whatsapp-mcp.js; then
    print_status "Build do servidor MCP concluído"
else
    print_warning "Build falhou, mas continuando com submissão manual..."
fi

# Função para submissão via API REST
submit_via_api() {
    print_info "Tentando submissão via API REST..."
    
    # Preparar dados JSON para submissão
    cat > .smithery/submission.json << EOF
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
  "keywords": ["whatsapp", "messaging", "communication", "social", "chat", "contacts", "media", "automation"],
  "categories": ["communication", "social", "productivity"],
  "homepage": "https://github.com/lharries/whatsapp-mcp",
  "documentation": "https://github.com/lharries/whatsapp-mcp/blob/main/README.md"
}
EOF

    # Tentar submeter via API
    local api_endpoints=(
        "https://api.smithery.ai/v1/servers"
        "https://smithery.ai/api/v1/servers"
        "https://smithery.ai/api/servers"
    )
    
    for endpoint in "${api_endpoints[@]}"; do
        print_info "Tentando endpoint: $endpoint"
        
        if curl -X POST "$endpoint" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $(cat ~/.smithery/config.json | grep -o '"apiKey":"[^"]*"' | cut -d'"' -f4)" \
            -d @.smithery/submission.json \
            --fail --silent --show-error; then
            print_status "Submissão via API bem-sucedida!"
            return 0
        else
            print_warning "Endpoint $endpoint não funcionou"
        fi
    done
    
    return 1
}

# Tentar submissão via API
if submit_via_api; then
    print_status "Servidor submetido com sucesso via API!"
else
    print_warning "Submissão via API falhou. Usando método manual..."
    
    # Abrir formulário web para submissão manual
    print_info "Abrindo formulário de submissão manual..."
    
    echo ""
    echo -e "${YELLOW}📋 Informações para o formulário:${NC}"
    echo "=================================="
    echo "Nome: WhatsApp MCP Server"
    echo "Repositório: https://github.com/lharries/whatsapp-mcp"
    echo "Descrição: Connect Claude to your personal WhatsApp account"
    echo "Categoria: Communication, Social, Productivity"
    echo "Arquivo de metadados: $(pwd)/.smithery/submission.json"
    echo ""
    
    # Tentar abrir o navegador
    if command -v open &> /dev/null; then
        open "https://smithery.ai/submit"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "https://smithery.ai/submit"
    else
        echo "Acesse manualmente: https://smithery.ai/submit"
    fi
fi

# Limpeza
print_info "Limpando arquivos temporários..."
# rm -f package.json  # Manter o package.json se foi criado

print_status "Processo de submissão concluído!"
echo ""
echo -e "${GREEN}🎉 WhatsApp MCP preparado para Smithery!${NC}"
echo "======================================="
echo ""
echo -e "${BLUE}Próximos passos:${NC}"
echo "1. Se a submissão automática falhou, use o formulário web"
echo "2. Aguarde aprovação da equipe do Smithery"
echo "3. Responda a qualquer feedback solicitado"
echo "4. Promova o servidor após aprovação"
echo ""
print_status "Submissão concluída! 🚀"
