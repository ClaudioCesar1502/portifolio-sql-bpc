# portifolio-sql-bpc
Scripts de análise e composição familiar para o BPC

# Composição Familiar BPC 2025

Este repositório contém o script SQL responsável por gerar a **recomposição familiar** dos beneficiários do BPC (Benefício de Prestação Continuada) para o ano de 2025, com base nos dados do CadÚnico, onde a composição familiar encontrada é vinculada de acordo com o representante familiar.

## 🎯 Objetivo

Criar uma tabela estruturada contendo os membros das famílias vinculadas ao BPC, classificando o tipo de vínculo de cada pessoa (referência ou familiar) conforme o grau de parentesco em relação ao beneficiário e ordenação dos registros.

## 🧩 Lógica do Script

- Utiliza a função `ROW_NUMBER()` particionada por família para identificar o membro de referência (geralmente o primeiro da composição).
- Classifica os vínculos como:
  - `REFERENCIA`: primeiro membro da família (NB principal)
  - `FAMILIAR`: demais membros vinculados
- A tabela final é criada no Teradata, com configurações otimizadas de compressão e sem journaling, visando eficiência de armazenamento e performance.

## 🗂 Base de Dados Utilizada

- View: `P_DBAP_ACC.VW_MACICA_202503_CADUN_202503`
- Ambiente: Teradata

## ▶️ Como usar

1. Acesse o ambiente Teradata com permissão de escrita na base desejada.
2. Execute o script localizado em `sql/composicao_familiar_bpc_2025.sql`.
3. A tabela será criada com os vínculos familiares definidos e prontos para análise.


---

## 📄 Documentação Técnica

Para detalhes completos sobre a lógica SQL, estrutura de dados e finalidade do processo:

👉 [Acesse a Documentação Técnica Detalhada](docs/documentacao_tecnica.md)
