# kali-devsecops-baseline

Baseline operacional (mínimo, repetível e verificável) para manter um host Kali Linux em postura segura de workstation/cliente, com evidência diária versionada e pronta para auditoria e portfolio.

## Objetivo

1) Reduzir superfície de ataque do host (modo cliente).  
2) Garantir rastreabilidade: “executar → registrar → versionar → publicar”.  
3) Produzir evidência externa (GitHub) com material verificável.

## Escopo

Inclui:
- Snapshot diário de sistema/rede/firewall/disco em `evidence/YYYY-MM-DD/`
- Política UFW para modo **cliente/workstation**: `deny incoming`, `allow outgoing`, logging controlado
- Runbooks e scripts para execução padronizada

Não inclui (por enquanto):
- Hardening avançado (CIS completo, AppArmor tuning, auditd ruleset abrangente, SELinux etc.)

## Estrutura do repositório

- `configs/`  arquivos de configuração (UFW, network, templates)
- `scripts/`  scripts executáveis para coleta de evidências e aplicação de baseline
- `runbooks/` procedimentos operacionais (passo a passo auditável)
- `evidence/YYYY-MM-DD/` evidências do dia (saídas de comandos, status, checks)
- `reports/` relatórios resumidos (ex.: weekly/monthly, comparativos)

## Modelo operacional diário (10–15 minutos)

1) Coletar evidências:
   - estado do sistema (kernel, pacotes, usuários)
   - rede (interfaces, rotas, DNS)
   - firewall (UFW status + logs)
   - storage (df, lsblk)

2) Verificar baseline:
   - UFW ativo e coerente com “cliente”
   - serviços expostos minimizados
   - atualizações planejadas (sem “upgrade cego” em horário crítico)

3) Publicar evidência:
   - `git add`
   - `git commit -m "evidence: YYYY-MM-DD baseline snapshot"`
   - `git push`

## UFW (modo cliente/workstation)

Premissa: este host NÃO é servidor. Logo:
- inbound: bloqueado por padrão
- outbound: permitido por padrão (com logging sob controle)

Exemplo de estado esperado:
- `Default: deny (incoming), allow (outgoing)`
- `ufw status verbose` sem portas abertas desnecessárias

Observação: ICMP (ping) não é “proto icmp” no UFW. UFW é front-end para iptables/nftables; ICMP costuma ser tratado em regras “before/after”. Este repositório terá um runbook específico para isso quando necessário.

## Evidência e auditabilidade

Cada execução deve gerar artefatos verificáveis:
- arquivos de saída em `evidence/YYYY-MM-DD/`
- commit assinado opcionalmente (melhoria futura)
- trilha clara de mudança: o que mudou, por que mudou, quando mudou

## Roadmap (módulos futuros)

- AppArmor baseline por perfil
- auditd (regras mínimas + export)
- hardening sysctl (curado)
- scan local (lynis) + relatório
- verificação de serviços/listeners (ss/lsof) com diffs

