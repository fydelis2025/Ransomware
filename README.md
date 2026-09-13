# 🛡️ Simulador Educacional de Criptografia — Estilo Ransomware

> ⚠️ **PROJETO EXCLUSIVAMENTE EDUCACIONAL — NÃO É MALWARE REAL**
>
> Este código demonstra, de forma simplificada e segura, o mecanismo básico de criptografia usado em ransomware. **Nada é destruído e toda operação é totalmente reversível** com a ferramenta de descriptografia inclusa.

---

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Aviso de Segurança](#aviso-de-segurança)
- [Arquivos Incluídos](#arquivos-incluídos)
- [Funcionamento Técnico](#funcionamento-técnico)
- [Pré-requisitos](#pré-requisitos)
- [Compilação](#compilação)
- [Como Usar](#como-usar)
- [Por que é Reversível?](#por-que-é-reversível)
- [Limitações Didáticas](#limitações-didáticas)
- [Licença](#licença)

---

## 📖 Sobre o Projeto

Este repositório contém dois programas escritos em **Assembly x86_64 para Linux** que simulam o comportamento de um criptolocker de forma segura e educacional. O objetivo é demonstrar como a cifra XOR funciona e como ameaças do tipo ransomware operam em nível básico, sem qualquer risco aos seus dados.

Desenvolvido pela **FydelisTech** para fins de estudo e conscientização em cibersegurança.

---

## ⚠️ Aviso de Segurança

- ✅ **Totalmente Seguro:** Usa apenas a cifra XOR com chave conhecida e fixa. Nenhum dado é perdido permanentemente.
- ✅ **Totalmente Reversível:** Basta executar o descriptografador para restaurar os arquivos ao estado original.
- 🚫 **NÃO USE** em sistemas de produção, redes públicas ou em arquivos de terceiros sem autorização explícita.
- 📚 **Destinado a:** Ambientes acadêmicos, laboratórios autorizados e fins educacionais.
- ⚖️ O uso indevido deste código para fins maliciosos constitui crime e será responsabilizado legalmente conforme a legislação vigente.

---

## 📁 Arquivos Incluídos

| Arquivo | Descrição |
|---|---|
| `ransom_demo.asm` | Simulador: cifra o arquivo com XOR, renomeia para `.locked` e exibe mensagem |
| `decrypt_demo.asm` | Descriptografador: aplica XOR novamente e restaura o nome original |

---

## 🔧 Funcionamento Técnico

- **Cifra Utilizada:** XOR com chave de 4 bytes → `0x42, 0x13, 0x37, 0x99`
- **Tamanho Máximo:** Processa até **64KB** por arquivo (limite didático)
- **Fluxo de Operação:**
  1. Abre o arquivo em modo leitura/escrita
  2. Lê o conteúdo para memória
  3. Aplica XOR byte a byte com a chave
  4. Reescreve o conteúdo "cifrado" no arquivo
  5. Renomeia adicionando a extensão `.locked`
  6. Exibe mensagem informativa

---

## 💻 Pré-requisitos

- Sistema Operacional **Linux** (arquitetura x86_64)
- Montador NASM e ligador LD:

```bash
sudo apt update
sudo apt install nasm binutils
