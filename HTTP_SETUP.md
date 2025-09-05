# WhatsApp MCP HTTP Server Setup

Este guia mostra como configurar o WhatsApp MCP como um servidor HTTP para integração com Claude Desktop.

## Pré-requisitos

1. **WhatsApp Bridge rodando**: Certifique-se de que o bridge Go está executando no servidor
2. **Python 3.11+**: Necessário para o servidor MCP
3. **Claude Desktop**: Para usar o servidor MCP

## Configuração Rápida

### 1. Instalar Dependências

```bash
cd whatsapp-mcp/whatsapp-mcp-server
uv sync
```

### 2. Iniciar o Servidor HTTP

Opção A - Script automático (recomendado):
```bash
python start_http_server.py
```

Opção B - Manual:
```bash
python main.py --transport http --host localhost --port 8000
```

### 3. Configurar Claude Desktop

O script `start_http_server.py` automaticamente atualiza a configuração do Claude Desktop.

Alternativamente, você pode configurar manualmente editando `claude_desktop_config.json`:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows**: `%APPDATA%/Claude/claude_desktop_config.json`
**Linux**: `~/.config/claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "whatsapp": {
      "command": "python",
      "args": [
        "/caminho/para/whatsapp-mcp/whatsapp-mcp-server/main.py",
        "--transport",
        "http",
        "--host",
        "localhost",
        "--port",
        "8000"
      ],
      "env": {}
    }
  }
}
```

## Uso

### Iniciar os Serviços

1. **Primeiro, inicie o WhatsApp Bridge** (no servidor):
```bash
cd whatsapp-bridge
go run main.go
```

2. **Depois, inicie o servidor MCP HTTP**:
```bash
cd whatsapp-mcp-server
python start_http_server.py
```

3. **Reinicie o Claude Desktop** para carregar a nova configuração

### Verificar se Está Funcionando

1. Abra o Claude Desktop
2. Você deve ver o ícone do MCP (🔌) na interface
3. Teste enviando uma mensagem como: "Liste meus contatos do WhatsApp"

## Opções de Configuração

### Parâmetros do Servidor

- `--host`: Host para bind (padrão: localhost)
- `--port`: Porta para bind (padrão: 8000)
- `--transport`: Tipo de transporte (stdio ou http)

### Exemplos

```bash
# Servidor na porta 9000
python start_http_server.py --port 9000

# Apenas atualizar configuração do Claude
python start_http_server.py --config-only

# Servidor manual com parâmetros customizados
python main.py --transport http --host 0.0.0.0 --port 8080
```

## Troubleshooting

### Erro: "Connection refused"
- Verifique se o WhatsApp Bridge está rodando
- Confirme se o servidor HTTP está ativo na porta correta

### Erro: "Module not found"
- Execute `uv sync` para instalar dependências
- Verifique se está usando Python 3.11+

### Claude não reconhece o servidor
- Reinicie o Claude Desktop após alterar a configuração
- Verifique se o caminho no `claude_desktop_config.json` está correto
- Confirme se o servidor está rodando na porta especificada

### Logs do Servidor
O servidor HTTP mostra logs detalhados no terminal, incluindo:
- Requisições recebidas
- Erros de conexão com o bridge
- Status das operações

## Vantagens do HTTP vs STDIO

### HTTP (Recomendado)
- ✅ Mais fácil de debugar
- ✅ Logs visíveis no terminal
- ✅ Pode ser acessado remotamente
- ✅ Melhor para desenvolvimento

### STDIO
- ✅ Mais leve
- ✅ Integração direta com Claude
- ❌ Difícil de debugar
- ❌ Sem logs visíveis

## Segurança

- O servidor HTTP roda apenas em localhost por padrão
- Para acesso remoto, use `--host 0.0.0.0` com cuidado
- Considere usar HTTPS em produção
- O WhatsApp Bridge deve estar protegido adequadamente
