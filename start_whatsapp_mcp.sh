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
