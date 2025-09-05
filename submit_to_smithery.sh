#!/bin/bash

# Script para submeter o WhatsApp MCP ao Smithery.ai
# Este script prepara e valida os arquivos necessários para submissão

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

echo -e "${BLUE}🚀 Preparando submissão para Smithery.ai${NC}"
echo "========================================"

# Verificar se estamos no diretório correto
if [ ! -f "smithery.json" ]; then
    print_error "Execute este script do diretório raiz do projeto (onde está o smithery.json)"
    exit 1
fi

# Verificar se o repositório está limpo
if [ -d ".git" ]; then
    if ! git diff-index --quiet HEAD --; then
        print_warning "Há mudanças não commitadas no repositório"
        echo "Deseja continuar? (y/n)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    print_status "Repositório Git verificado"
fi

# Validar smithery.json
print_info "Validando smithery.json..."
if command -v jq &> /dev/null; then
    if jq empty smithery.json; then
        print_status "smithery.json é um JSON válido"
    else
        print_error "smithery.json contém JSON inválido"
        exit 1
    fi
else
    print_warning "jq não encontrado, pulando validação JSON"
fi

# Verificar arquivos necessários
required_files=(
    "smithery.json"
    "SMITHERY_SUBMISSION.md"
    "whatsapp-mcp/README.md"
    "whatsapp-mcp/LICENSE"
    "whatsapp-mcp/whatsapp-mcp-server/main.py"
    "whatsapp-mcp/whatsapp-bridge/main.go"
)

print_info "Verificando arquivos necessários..."
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        print_status "$file encontrado"
    else
        print_error "$file não encontrado"
        exit 1
    fi
done

# Verificar se há screenshot
if [ -f "whatsapp-mcp/example-use.png" ]; then
    print_status "Screenshot encontrado"
else
    print_warning "Screenshot não encontrado (recomendado)"
fi

# Criar arquivo de checklist para submissão
print_info "Criando checklist de submissão..."
cat > SMITHERY_CHECKLIST.md << 'EOF'
# Checklist para Submissão ao Smithery.ai

## ✅ Arquivos Preparados

- [x] `smithery.json` - Metadados do servidor MCP
- [x] `SMITHERY_SUBMISSION.md` - Documento de submissão
- [x] `README.md` - Documentação principal
- [x] `LICENSE` - Licença do projeto
- [x] Screenshot/exemplo de uso

## 📋 Próximos Passos

### 1. Verificar Informações
- [ ] Confirmar que todas as informações em `smithery.json` estão corretas
- [ ] Verificar se a descrição está clara e atrativa
- [ ] Confirmar que os links do repositório estão funcionando

### 2. Submissão Manual ao Smithery
Visite: https://smithery.ai/submit

**Informações necessárias:**
- **Nome**: WhatsApp MCP Server
- **Repositório**: https://github.com/lharries/whatsapp-mcp
- **Descrição**: Connect Claude to your personal WhatsApp account
- **Categoria**: Communication, Social, Productivity
- **Arquivo de metadados**: Anexar `smithery.json`

### 3. Submissão via GitHub (Alternativa)
Se o Smithery aceitar PRs:
```bash
# Fork do repositório do Smithery
git clone https://github.com/smithery-ai/smithery-registry.git
cd smithery-registry

# Adicionar entrada para WhatsApp MCP
# Seguir estrutura do repositório

# Criar PR com os metadados
```

### 4. Verificação Pós-Submissão
- [ ] Confirmar que o servidor aparece no diretório
- [ ] Testar instalação através do Smithery
- [ ] Verificar se links e documentação estão funcionando
- [ ] Responder a feedback da comunidade

## 📞 Contato para Suporte

Se houver problemas na submissão:
- **GitHub Issues**: https://github.com/lharries/whatsapp-mcp/issues
- **Smithery Support**: Através do site oficial
- **Documentação**: https://smithery.ai/docs

## 🔍 Validação Final

Antes de submeter, confirme:
- [ ] Servidor MCP funciona corretamente
- [ ] Documentação está completa e clara
- [ ] Exemplos de configuração estão corretos
- [ ] Screenshots são representativos
- [ ] Informações de contato estão atualizadas
EOF

print_status "Checklist criado: SMITHERY_CHECKLIST.md"

# Mostrar resumo
echo ""
echo -e "${GREEN}🎉 Preparação concluída!${NC}"
echo "========================"
echo ""
echo -e "${BLUE}Arquivos preparados para submissão:${NC}"
echo "  📄 smithery.json - Metadados do servidor"
echo "  📋 SMITHERY_SUBMISSION.md - Documento de submissão"
echo "  ✅ SMITHERY_CHECKLIST.md - Checklist de verificação"
echo ""
echo -e "${BLUE}Próximos passos:${NC}"
echo "1. Revisar os arquivos gerados"
echo "2. Visitar https://smithery.ai/submit"
echo "3. Preencher o formulário de submissão"
echo "4. Anexar o arquivo smithery.json"
echo "5. Aguardar aprovação"
echo ""
echo -e "${YELLOW}💡 Dica:${NC} Leia SMITHERY_CHECKLIST.md para instruções detalhadas"
echo ""
print_status "Pronto para submissão ao Smithery.ai! 🚀"
