# Documentação Técnica – Composição Familiar BPC 2025

## Objetivo

Este processo visa gerar a recomposição familiar dos beneficiários do BPC com base no CadÚnico e registros da TB_MACICA, classificando vínculos familiares com lógica baseada no grau de parentesco do NB de referência da família.

## Fonte de Dados

- **Base Principal:** `P_DBAP_ACC.VW_MACICA_202504_CADUN_202505`
- **Validação NB BPC:** `P_CORP_MACICA.TB_MACICA`
- **Referência:** Abril/2025 (202504)

## Etapas do Processo

### 1. CTE `FAMILIA`
Seleciona todos os membros da família e inclui:

- Grau de parentesco (`COD_PARENTESCO_RF_PESSOA`)
- Dados de renda
- Dados geográficos (UF e município)
- Identificação do beneficiário (NB) com validação pela TB_MACICA
- `ROW_NUMBER()` para determinar ordem na família

### 2. CTE `NB_REFERENCIA`
Seleciona o **primeiro NB válido** por família como referência, considerando:

- `CS_ESPECIE` entre 87 e 88 (BPC-Idoso e BPC-PCD)
- `CS_SIT_BENEF = 0` (ativo)
- `CS_PA <> 3` (não cancelado)
- Apenas NB com `IN_MARC_BPC = 1`

### 3. Seleção Final

- Junta `FAMILIA` com `NB_REFERENCIA` por `CO_FAMILIAR_FAM`
- Atribui o rótulo de **Beneficiário** ao NB de referência
- Aplica lógica condicional (via `CASE`) para determinar o novo vínculo dos demais membros
- Inclui campo comparativo com o vínculo antigo (`SITUACAO_FAMILIAR_ANTIGA`)
- Define como índice primário: `CO_FAMILIAR_FAM`

## Observações Técnicas

- A tabela criada é `MULTISET`, sem journaling e com compressão total (`BLOCKCOMPRESSION = ALWAYS`)
- Cada `CASE` dentro da lógica de parentesco respeita a posição do NB na família (`PARENTESCO_REF`)
- A lógica é extensível para novas regras ou cruzamentos com outros benefícios

## Finalidade

Essa recomposição é útil para:

- Análises de dependência socioeconômica
- Validações de elegibilidade
- Políticas de focalização social
- Auditorias de vínculo e conformidade

## Autor

Claudio Cesar Alves da Silva – Analista de Dados
