CREATE DATABASE IF NOT EXISTS projetonetflix;

USE projetonetflix;

/*
IMPORTAÇÃO DAS BASE
Etapa 1 - Importação dos Dados tratados e limpos feito pelo Python(Pandas)

2- CRIAR BANCO DE DADOS: ok
CREATE DATABASE projetonetflix;

INPORTAR OS DADOS:
	-User_ID PRIMARY KEY
    -Name
    -AGE
    -Country (Localização)
    -Subscription_Type (Plano)
    -Watch_Time_Hours
    -Favorite_Genre
    -Last_Login
*/
/*
ETAPA 2 - VALIDAÇÂO DOS DADOS 
	Antes de fazermos as análises, conferir se a importação ocorreu corretamente 
*/

-- Quantidade de registros resultado esperado = 25.000 resultado: ok

SELECT COUNT(*)
FROM customer;

-- Verificar valores nulos - resultado: ok


SELECT 
	SUM(Name IS NULL) as names_nulos,
    SUM(Age IS NULL) as Age_nulos,
    SUM(Country IS NULL) as Country_nulos,
    SUM(Subscription_Type IS NULL) as Planos_nulos,
    SUM(Watch_Time_Hours IS NULL) as Tempo_nulo,
    SUM(Favorite_Genre IS NULL) as Genero_nulo,
    SUM(Last_Login IS NULL) as UltimoLogin_nulos
FROM customer;


SELECT * FROM Customer LIMIT 10;

/*
ETAPA 3 - NOVA COLUNA VALOR 
Criação de uma nova coluna chamada Subscription_Value,
Para poder análisar valor financeiro de cada plano de assinatura

Importante mencionar que os valores inseridos são reais da netflix.
*/


ALTER TABLE Customer
ADD COLUMN Subscription_Value DECIMAL (10,2);

-- INSERINDO VALORES PRA CADA PLANO. Resultado: ok

UPDATE customer
SET Subscription_Value =
	CASE 
		WHEN Subscription_Type = "Premium" THEN 71.90
		WHEN Subscription_Type = "Standard" THEN 51.90
        WHEN Subscription_Type = "Basic" THEN 25.90
        ELSE NULL
	END;
    
SELECT
	Subscription_Type as Plano,
    Subscription_Value as Valor
FROM customer

GROUP BY 1,2
ORDER BY Subscription_Value;


/*
ETAPA 4 - ANÁLISE DESCRITIVA 
	Fase em que respondemos às perguntas de negócio.
    
*/

-- Query - Quantidade de usuários por paísa
-- quais países possuem a maior quantidade de usuários? 
-- Resposta: UK, Germany e india

SELECT
	Country as Pais,
    COUNT(*) as Quantidade_de_usuarios
FROM Customer

GROUP BY 1
ORDER BY 2 DESC;

-- Query - Distribuição por plano de assinatura 
-- qual plano possui maior participação entre os usuários?
-- Resposta: Premium
    
SELECT
    Subscription_Type,
    COUNT(*) AS total_usuarios,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM Customer),
        2
    ) AS percentual
FROM Customer
GROUP BY Subscription_Type
ORDER BY total_usuarios DESC;

-- Query - Gênero favorito
-- quais gêneros possuem maior preferência entre os usuários?
-- Resposta: Horros, Documentary e Action 

SELECT
	Favorite_Genre as Genero,
    COUNT(*) as Total_usuarios
FROM customer

GROUP BY 1 
ORDER BY 2 DESC;

-- Query 07 — Distribuição por faixa etária
-- qual faixa etária concentra mais usuários?
-- Resposta: 60 anos ou mais.

SELECT 
	CASE 
		WHEN Age < 20 THEN "Até 19 anos"
        WHEN Age BETWEEN 20 AND 29 THEN "20 a 29 anos"
		WHEN Age BETWEEN 30 AND 39 THEN "30 a 39 anos"
		WHEN Age BETWEEN 30 AND 39 THEN "30 a 39 anos"
		WHEN Age BETWEEN 40 AND 49 THEN "40 a 49 anos"
		WHEN Age BETWEEN 50 AND 59 THEN "50 a 59 anos"
	ELSE "60 anos ou mais"
		END as faixa_etaria,
        COUNT(*) as Total_de_usuarios
FROM customer

GROUP BY 1
ORDER BY 2 DESC;

/*
ETAPA 4.1 - ANÁLISE DE COMPORTAMENTO DO DOS USUÁRIOS
	Aqui aprofundamos nossas consultas, para emtender um padrão dos usuarios e seus comportamento
    
*/

-- Média de horas assistida por plano 

SELECT
	Subscription_Type as Plano,
    COUNT(*) as total_de_usuarios,
	ROUND(AVG(Watch_Time_Hours), 2 ) as Média_de_horas,
    ROUND(MIN(Watch_Time_Hours), 2 ) as MInino_de_horas,
    ROUND(MAX(Watch_Time_Hours), 2 ) as maxima_de_horas
    
FROM Customer

GROUP BY 1;

-- Query - Consumo médio por pais 
-- em quais países os usuários apresentam maior tempo médio de utilização?
-- Resposta: canada, Australia e France

SELECT 
	Country,
    COUNT(*) as Total_de_usuario,
    ROUND(AVG(Watch_Time_Hours), 2) as Media_tempo
    
FROM Customer
GROUP BY 1
ORDER BY 3 DESC;


-- Relação entre idade e consumo
-- qual faixa etária apresenta maior consumo médio?
-- Resposta: 30 a 39 anos

SELECT
    CASE
        WHEN Age < 20 THEN 'Até 19 anos'
        WHEN Age BETWEEN 20 AND 29 THEN '20 a 29 anos'
        WHEN Age BETWEEN 30 AND 39 THEN '30 a 39 anos'
        WHEN Age BETWEEN 40 AND 49 THEN '40 a 49 anos'
        ELSE '50 anos ou mais'
    END AS faixa_etaria,

    ROUND(AVG(Watch_Time_Hours), 2) AS media_horas

FROM Customer

GROUP BY faixa_etaria

ORDER BY media_horas DESC;

-- Distribuição por último acesso
-- como estão distribuídas as datas do último acesso dos usuários?

SELECT
    DATE_FORMAT(Last_Login, '%Y-%m') AS mes,
    COUNT(*) AS total_acessos

FROM customer

GROUP BY mes

ORDER BY mes;

/*
	SQL INTERMEDIARIO 
	Com a utilização de do CTE (Common Table Expression)
    Criar uma consulta temporária para identificar os planos com maior consumo médio.
    
*/


WITH consumo AS (

    SELECT
        Subscription_Type,
        AVG(Watch_Time_Hours) AS media_horas

    FROM customer

    GROUP BY Subscription_Type

)

SELECT
    Subscription_Type,
    ROUND(media_horas, 2) AS media_horas

FROM consumo

ORDER BY media_horas DESC;

-- Ranking dos países quais países apresentam maior consumo médio.
-- Resposta: Canada, Australia e France

SELECT
	Country,
    ROUND(AVG(Watch_Time_Hours), 2 ) as Media_horas,
    
    RANK() OVER (
    ORDER BY AVG(Watch_Time_Hours) DESC ) as Ranking
FROM Customer
    
GROUP BY 1;


/*
ETAPA 4.2 - Consulta de faturamento e valores
	Podendo desenvolver indicadores financeiros interessantes.
*/

-- Faturamento estimado por plano

SELECT 
	Subscription_Type as Plano,
    SUM(Subscription_Value) as Valor_Total
FROM customer

GROUP BY 1;

-- Receita Total estimada 
	
SELECT SUM(Subscription_Value) as Total_Faturamento FROM Customer ;
	
    
-- Ticket Médio

SELECT 
	ROUND(AVG(Subscription_Value),2) as Ticket_medio
FROM Customer;
	
-- análise de receita por país

SELECT 
	Country,
    COUNT(*) as Quantidade_Assinante,
    SUM(Subscription_Value) as Faturamento
FROM customer
    
GROUP BY 1
ORDER BY Faturamento DESC;

/*
OBJETIVO ALCANÇADO

	A etapa de SQL permitiu desenvolver habilidades de manipulação, organização, agregação e análise de dados utilizando MySQL.
Também possibilitou explorar indicadores de assinaturas e receita estimada, identificando padrões de comportamento e oportunidades de análise.

*/

/*
		ETAPA 5 DESHBOARD NO POWER BI
Objetivo: Criar um painel dinâmico para acompanhar os KPIs estratégicos

Itens obrigatorios no Deshboard:

 -Criar os 6 cartões de KPIs
- Criar gráfico de assinantes por plano
- Criar gráfico de receita por plano
- Criar gráfico de receita por país
- Criar gráfico de usuários por país
- Criar gráfico de usuários por gênero
- Criar gráfico de consumo por plano
- Adicionar filtros interativos
- Padronizar cores, títulos e formatação


*/





