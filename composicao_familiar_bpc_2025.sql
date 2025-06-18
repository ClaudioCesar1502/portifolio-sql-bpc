

CREATE MULTISET TABLE DL_DBAP.COMPOSICAO_FAMILIAR_BPC_2025_DATAPREV_UF_MUNIC, NO BEFORE JOURNAL,NO AFTER JOURNAL, CHECKSUM = DEFAULT,DEFAULT MERGEBLOCKRATIO,
BLOCKCOMPRESSION=ALWAYS, BLOCKCOMPRESSIONLEVEL=9 AS (
WITH FAMILIA AS (
  -- Seleciona todos os membros da família da tabela VW_MACICA_202504_CADUN_202505
  SELECT
    A.CO_FAMILIAR_FAM,
    A.CO_NB,
    A.COD_PARENTESCO_RF_PESSOA,
    A.NU_CPF_PESSOA,
    A.QTD_FAMILIAS_DOMIC_FAM,
    A.SG_UF_APP,
    A.NO_MUNICIPIO_APP,
    A.VAL_REMUNER_EMPREGO_MEMB,
    A.VAL_RENDA_BRUTA_12_MESES_MEMB,
    A.QTD_MESES_12_MESES_MEMB, 
    CASE
             WHEN A.COD_PARENTESCO_RF_PESSOA = 1 THEN 'Representante Familiar'
             WHEN A.COD_PARENTESCO_RF_PESSOA = 2 THEN 'Cônjuge/Companheiro(a)'
             WHEN A.COD_PARENTESCO_RF_PESSOA = 3 THEN 'Filho(a)'
             WHEN A.COD_PARENTESCO_RF_PESSOA = 4 THEN 'Enteado(a)'
             WHEN A.COD_PARENTESCO_RF_PESSOA = 5 THEN 'Neto(a)/Bisneto(a)'
             WHEN A.COD_PARENTESCO_RF_PESSOA = 6 THEN 'Pai/Mãe'
             WHEN A.COD_PARENTESCO_RF_PESSOA = 7 THEN 'Sogro(a)'
             WHEN A.COD_PARENTESCO_RF_PESSOA = 8 THEN 'Irmão/Irmã'
             WHEN A.COD_PARENTESCO_RF_PESSOA = 9 THEN 'Genro/Nora'
             WHEN A.COD_PARENTESCO_RF_PESSOA = 10 THEN 'Outro parente'
             WHEN A.COD_PARENTESCO_RF_PESSOA = 11 THEN 'Não parente' 
             ELSE 'Desconhecido'
    END SITUACAO_FAMILIAR_ANTIGA,
    B.CS_ESPECIE,
       ROW_NUMBER() OVER (PARTITION BY A.CO_FAMILIAR_FAM ORDER BY CASE WHEN A.CO_NB IS NOT NULL THEN 0 ELSE 1 END, A.CO_NB) AS RN
  FROM P_DBAP_ACC.VW_MACICA_202504_CADUN_202505 A
  LEFT JOIN P_CORP_MACICA.TB_MACICA B
    ON A.CO_NB = B.NU_NB
    AND A.NU_MES_REF_MACICA = B.NU_MES_REF
    AND A.IN_MARC_BPC = 1
    AND B.NU_MES_REF = 202504
    AND B.CS_SIT_BENEF = 0
    AND B.CS_ESPECIE IN (87, 88)
    AND B.CS_PA <> 3
),
NB_REFERENCIA AS (
  -- Define o primeiro NB como referência dentro da família
  SELECT
    CO_FAMILIAR_FAM,
    CO_NB AS NB_REF,
    CS_ESPECIE,
    COD_PARENTESCO_RF_PESSOA AS PARENTESCO_REF,
    SG_UF_APP,
    NO_MUNICIPIO_APP,
    VAL_REMUNER_EMPREGO_MEMB,
    VAL_RENDA_BRUTA_12_MESES_MEMB,
    QTD_MESES_12_MESES_MEMB 
  FROM FAMILIA
  WHERE CO_NB IS NOT NULL -- Seleciona apenas membros com NB preenchido
  AND RN = 1 -- Seleciona o primeiro NB como referência
)
SELECT
  F.CO_FAMILIAR_FAM,
  F.CO_NB,
  F.CS_ESPECIE,
  F.NU_CPF_PESSOA,
  CASE
    -- O próprio NB referência recebe o rótulo de beneficiário
    WHEN F.CO_NB = P.NB_REF THEN 'Beneficiário'
 
    -- Ajusta a relação dos demais membros com base no NB referência
    WHEN P.PARENTESCO_REF = 1 THEN ------ RF_CAD
        CASE
             WHEN F.COD_PARENTESCO_RF_PESSOA = 2 THEN 'Cônjuge/Companheiro(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 3 THEN 'Filho(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 4 THEN 'Enteado(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 5 THEN 'Neto(a)/Bisneto(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 6 THEN 'Pai/Mãe'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 7 THEN 'Sogro(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 8 THEN 'Irmão/Irmã'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 9 THEN 'Genro/Nora'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 10 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 11 THEN 'Não parente'
        END
WHEN P.PARENTESCO_REF = 2 THEN
        CASE
             WHEN F.COD_PARENTESCO_RF_PESSOA = 1 THEN 'Cônjuge/Companheiro(a)'   ------- RF_CAD
             WHEN F.COD_PARENTESCO_RF_PESSOA = 3 THEN 'Filho(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 4 THEN 'Filho(a)/Enteado(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 5 THEN 'Neto(a)/Bisneto(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 6 THEN 'Sogro(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 7 THEN 'Pai/Mãe'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 8 THEN 'Cunhado(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 9 THEN 'Genro/Nora/Outro Parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 10 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 11 THEN 'Não parente'
        END
 
    WHEN P.PARENTESCO_REF = 3 THEN
        CASE
             WHEN F.COD_PARENTESCO_RF_PESSOA = 1 THEN 'Pai/Mãe' ------- RF_CAD
             WHEN F.COD_PARENTESCO_RF_PESSOA = 2 THEN 'Pai/Mãe/Padastro/Madastra'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 3 THEN 'Irmão/Irmã' 		
             WHEN F.COD_PARENTESCO_RF_PESSOA = 4 THEN 'Meio-Irmão/Meia-Irmã'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 5 THEN 'Sobrinho(a)/filho(a)/outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 6 THEN 'Avô/Avó'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 7 THEN 'Avô/Avó(dastro)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 8 THEN 'Tio/Tia'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 9 THEN 'Cunhado(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 10 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 11 THEN 'Não parente'
        END
 
    WHEN P.PARENTESCO_REF = 4 THEN
        CASE
             WHEN F.COD_PARENTESCO_RF_PESSOA = 1 THEN 'Padastro/Madastra)' ------- RF_CAD
             WHEN F.COD_PARENTESCO_RF_PESSOA = 2 THEN 'Mãe/pai'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 3 THEN 'Meio-Irmão/Meia-Irmã'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 4 then 'Irmão(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 5 THEN 'Sobrinho(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 6 THEN 'Avô/Avó'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 7 THEN 'Avô/Avó(dastro)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 8 THEN 'Tio/Tia'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 9 THEN 'Cunhado(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 10 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 11 THEN 'Não parente'
        END
 
    WHEN P.PARENTESCO_REF = 5 THEN
        CASE
             WHEN F.COD_PARENTESCO_RF_PESSOA = 1 THEN 'Vô/Vó?Bisavó/Bisavõ' ------- RF_CAD
             WHEN F.COD_PARENTESCO_RF_PESSOA = 2 THEN 'Vô/Vó?Bisavó/Bisavõ'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 3 THEN 'Pai/Mãe/Tio/Tia(avos tb)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 4 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 5 THEN 'Irmão(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 6 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 7 THEN 'Bisa/Tataravó(ô) dastro'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 8 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 9 THEN 'Pai/mãe/Padastro/Madastra/outro p'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 10 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 11 THEN 'Não parente'
        END
 
    WHEN P.PARENTESCO_REF = 6 THEN
        CASE
             WHEN F.COD_PARENTESCO_RF_PESSOA = 1 THEN 'Filho(a)' ------- RF_CAD
             WHEN F.COD_PARENTESCO_RF_PESSOA = 2 THEN 'Nora/Genro'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 3 THEN 'Neto/Neta'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 4 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 5 THEN 'Bisavo/Tataravo'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 6 THEN 'Conjugue/companheiro'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 7 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 8 THEN 'Filho(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 9 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 10 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 11 THEN 'Não parente'
        END
 
    WHEN P.PARENTESCO_REF = 7 THEN
        CASE
             WHEN F.COD_PARENTESCO_RF_PESSOA = 1 THEN 'Nora/Genro' ------ RF_CAD
             WHEN F.COD_PARENTESCO_RF_PESSOA = 2 THEN 'Filha(o)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 3 THEN 'NEto/Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 4 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 5 THEN 'Bisneto(a)/Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 6 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 7 THEN 'Conjuge'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 8 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 9 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 10 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 11 THEN 'Não parente'
        END
 
    WHEN P.PARENTESCO_REF = 8 THEN
        CASE
             WHEN F.COD_PARENTESCO_RF_PESSOA = 1 THEN 'Irmão/Irmã' ------ RF_CAD
             WHEN F.COD_PARENTESCO_RF_PESSOA = 2 THEN 'Cunhado/Cunhada'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 3 THEN 'Sobrinho(a)'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 4 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 5 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 6 THEN 'Pai/Mãe'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 7 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 8 THEN 'Irmão/Irmã'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 9 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 10 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 11 THEN 'Não parente'
        END
 
    WHEN P.PARENTESCO_REF = 9 THEN
        CASE
             WHEN F.COD_PARENTESCO_RF_PESSOA = 1 THEN 'Sogro/sogra' ------ RF_CAD
             WHEN F.COD_PARENTESCO_RF_PESSOA = 2 THEN 'Sogro/sogra'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 3 THEN 'Conjugue/Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 4 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 5 THEN 'Filho/Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 6 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 7 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 8 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 9 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 10 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 11 THEN 'Não parente'
        END
 
    WHEN P.PARENTESCO_REF = 10 THEN
        CASE
             WHEN F.COD_PARENTESCO_RF_PESSOA = 1 THEN 'Outro parente' ------ RF_CAD
             WHEN F.COD_PARENTESCO_RF_PESSOA = 2 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 3 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 4 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 5 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 6 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 7 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 8 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 9 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 10 THEN 'Outro parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 11 THEN 'Não parente'
        END
 
    WHEN P.PARENTESCO_REF = 11 THEN
        CASE
         	 WHEN F.COD_PARENTESCO_RF_PESSOA = 1 THEN 'Não parente' ------ RF_CAD
             WHEN F.COD_PARENTESCO_RF_PESSOA = 2 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 3 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 4 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 5 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 6 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 7 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 8 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 9 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 10 THEN 'Não parente'
             WHEN F.COD_PARENTESCO_RF_PESSOA = 11 THEN 'Não parente'
        END
    ELSE 'Desconhecido'
  END AS NOVA_RELACAO_FAMILIAR,
  SITUACAO_FAMILIAR_ANTIGA,
  F.QTD_FAMILIAS_DOMIC_FAM,
  F.SG_UF_APP,
  F.NO_MUNICIPIO_APP,
  F.VAL_REMUNER_EMPREGO_MEMB,
  F.VAL_RENDA_BRUTA_12_MESES_MEMB,
  F.QTD_MESES_12_MESES_MEMB
FROM FAMILIA F
LEFT JOIN NB_REFERENCIA P ON F.CO_FAMILIAR_FAM = P.CO_FAMILIAR_FAM
)WITH DATA PRIMARY INDEX (CO_FAMILIAR_FAM)
