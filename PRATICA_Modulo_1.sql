SELECT id_cargo,cargo,salario_minimo FROM CARGOS

Select * from Paises

SELECT id_funcionario, ultimo_nome,Salario* 12 as "Salario Anual" FROM funcionarios

Desc localizacoes

Select Estado,Cidade,cep from Localizacoes

Select distinct id_cargo from funcionarios

Select primeiro_nome  ||  ' ' || ultimo_nome || ' Ultimo Salario: ' || salario || ' Data De Admissao: ' || dt_admissao as "Dados Funcionario"  from funcionarios