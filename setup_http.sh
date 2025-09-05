#!/bin/bash

# WhatsApp MCP HTTP Setup Script
# Este script automatiza a configuração do WhatsApp MCP como servidor HTTP

set -e

echo "🚀 WhatsApp MCP HTTP Setup"
echo "=========================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
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

# Verificar se estamos no diretório correto
if [ ! -f "whatsapp-mcp-server/main.py" ]; then
    print_error "Execute este script do diretório whatsapp-mcp/"
    exit 1
fi

print_info "Verificando pré-requisitos..."

# Verificar Python
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 não encontrado. Instale Python 3.11+ primeiro."
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
print_status "Python $PYTHON_VERSION encontrado"

# Verificar uv
if ! command -v uv &> /dev/null; then
    print_warning "uv não encontrado. Instalando..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source $HOME/.local/bin/env
fi

print_status "uv encontrado"

# Instalar dependências do servidor MCP
print_info "Instalando dependências do servidor MCP..."
cd whatsapp-mcp-server
uv sync
print_status "Dependências instaladas"

# Tornar o script de inicialização executável
chmod +x start_http_server.py

print_status "Script de inicialização configurado"

# Verificar se Go está instalado (para o bridge)
cd ..
if ! command -v go &> /dev/null; then
    print_warning "Go não encontrado. Você precisará instalar Go para executar o WhatsApp Bridge."
    print_info "Visite: https://golang.org/doc/install"
else
    print_status "Go encontrado"
    
    # Verificar dependências do bridge
    if [ -f "whatsapp-bridge/go.mod" ]; then
        print_info "Verificando dependências do WhatsApp Bridge..."
        cd whatsapp-bridge
        go mod tidy
        print_status "Dependências do bridge verificadas"
        cd ..
    fi
fi

# Criar script de inicialização completa
print_info "Criando script de inicialização completa..."

cat > start_whatsapp_mcp.sh << 'EOF'
#!/bin/bash

# Script para iniciar WhatsApp MCP completo (Bridge + HTTP Server)

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Iniciando WhatsApp MCP${NC}"
echo "=========================="

# Função para cleanup
cleanup() {
    echo -e "\n${YELLOW}🛑 Parando serviços...${NC}"
    kill $BRIDGE_PID 2>/dev/null || true
    kill $SERVER_PID 2>/dev/null || true
    exit 0
}

trap cleanup SIGINT SIGTERM

# Verificar se o bridge existe
if [ ! -f "whatsapp-bridge/main.go" ]; then
    echo -e "${RED}❌ WhatsApp Bridge não encontrado${NC}"
    exit 1
fi

# Verificar se o servidor existe
if [ ! -f "whatsapp-mcp-server/main.py" ]; then
    echo -e "${RED}❌ Servidor MCP não encontrado${NC}"
    exit 1
fi

echo -e "${GREEN}📱 Iniciando WhatsApp Bridge...${NC}"
cd whatsapp-bridge
go run main.go &
BRIDGE_PID=$!
cd ..

# Aguardar o bridge inicializar
sleep 3

echo -e "${GREEN}🌐 Iniciando servidor MCP HTTP...${NC}"
cd whatsapp-mcp-server
python3 start_http_server.py &
SERVER_PID=$!
cd ..

echo -e "${GREEN}✅ Serviços iniciados!${NC}"
echo "📱 WhatsApp Bridge PID: $BRIDGE_PID"
echo "🌐 HTTP Server PID: $SERVER_PID"
echo "🔗 Servidor disponível em: http://localhost:8000"
echo ""
echo -e "${YELLOW}📝 Próximos passos:${NC}"
echo "1. Escaneie o QR code no WhatsApp Bridge (se necessário)"
echo "2. Reinicie o Claude Desktop"
echo "3. Teste enviando: 'Liste meus contatos do WhatsApp'"
echo ""
echo -e "${BLUE}⏹️  Pressione Ctrl+C para parar os serviços${NC}"

# Aguardar
wait
EOF

chmod +x start_whatsapp_mcp.sh
print_status "Script de inicialização completa criado"

# Resumo final
echo ""
echo -e "${GREEN}🎉 Configuração concluída!${NC}"
echo "========================"
echo ""
echo -e "${BLUE}Para iniciar o WhatsApp MCP:${NC}"
echo "  ./start_whatsapp_mcp.sh"
echo ""
echo -e "${BLUE}Para iniciar apenas o servidor HTTP:${NC}"
echo "  cd whatsapp-mcp-server"
echo "  python3 start_http_server.py"
echo ""
echo -e "${BLUE}Para configuração manual:${NC}"
echo "  Leia: HTTP_SETUP.md"
echo ""
echo -e "${YELLOW}⚠️  Lembre-se:${NC}"
echo "1. O WhatsApp Bridge precisa estar rodando primeiro"
echo "2. Reinicie o Claude Desktop após a primeira configuração"
echo "3. Verifique os logs se houver problemas"
echo ""
print_status "Setup completo! 🚀"
