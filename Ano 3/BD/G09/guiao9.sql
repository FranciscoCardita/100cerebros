-- b)
-- Crie um stored procedure que retorne um record-set com os
-- funcion�rios gestores de departamentos, assim como o ssn e
-- n�mero de anos (como gestor) do funcion�rio mais antigo dessa lista.

-- DROP PROCEDURE company.p_ManagersRecordSet;
GO
CREATE PROCEDURE company.p_ManagersRecordSet 
	@OldestManagerSSN DECIMAL(9,0) OUTPUT,
	@OldestManagerYears INT OUTPUT
AS
BEGIN
	SELECT CONCAT(Fname, ' ', Minit, '. ', Lname) AS ManagerName, Ssn
	FROM company.employee;

	SELECT TOP 1 @OldestManagerSSN = Mgr_ssn, 
				 @OldestManagerYears = DATEDIFF(yy, Mgr_start_date, CAST(GETDATE() AS DATE))
	FROM company.department
	WHERE Mgr_start_date IS NOT NULL
	ORDER BY Mgr_start_date;
END
GO
/*
-- test
DECLARE @MgrSSN DECIMAL(9,0), @MgrYears INT;
EXEC company.p_ManagersRecordSet @MgrSSN OUTPUT, @MgrYears OUTPUT;
PRINT CONCAT('Oldest manager SSN: ', @MgrSSN);
PRINT CONCAT('Oldest manager years as manager: ', @MgrYears);
*/



-- d)
-- Crie um trigger que n�o permita que determinado funcion�rio
-- tenha um vencimento superior ao vencimento do gestor do seu
-- departamento. Nestes casos, o trigger deve ajustar o sal�rio
-- do funcion�rio para um valor igual ao sal�rio do gestor menos
-- uma unidade. 

CREATE TRIGGER WageLimiter ON company.employee
AFTER INSERT, UPDATE
AS
BEGIN
	UPDATE company.employee
	SET Salary = outlier_employees.Salary - 1
	FROM
		(SELECT i.Ssn, e.Salary
		FROM inserted AS i JOIN employee AS e ON i.Super_ssn = e.Ssn
		WHERE i.Salary >= e.Salary) AS outlier_employees
	WHERE company.employee.Ssn = outlier_employees.Ssn;
END
GO
/*
-- test
DELETE FROM company.employee WHERE Ssn = 123682247;
DELETE FROM company.employee WHERE Ssn = 123682246;
DELETE FROM company.employee WHERE Ssn = 123682245;

INSERT INTO company.employee (Fname, Lname, Ssn, Salary, Super_ssn, Dno) 
VALUES 
('Teste', 'Trigger', 123682245, 2000.0, NULL, 3),
('Teste', 'Trigger', 123682246, 1450.0, 123682245, 3),
('Teste', 'Trigger', 123682247, 2100, 123682245, 3);

UPDATE company.employee SET Salary = 5000 WHERE Ssn = 123682246;
SELECT * FROM company.employee;
*/


-- f
-- Crie uma UDF que, para determinado departamento (dno), retorne os
-- funcion�rios com um vencimento superior � m�dia dos vencimentos 
-- desse departamento;

-- DROP FUNCTION company.AboveAVGSalaries;
GO
CREATE FUNCTION company.AboveAVGSalaries(@dnum INT)
RETURNS @EmployeeInfo TABLE (
	employee_name		VARCHAR(40),
	employee_ssn		DECIMAL(9,0),
	employee_salary		DECIMAL(11,2))
AS
BEGIN
	INSERT @EmployeeInfo (employee_name, employee_ssn, employee_salary)
	
		SELECT CONCAT(Fname, ' ', Minit, '. ', Lname) AS [name], Ssn, Salary
		FROM employee
		WHERE Dno = @dnum
			AND Salary > (SELECT AVG(Salary) FROM employee WHERE Dno = @dnum);

	RETURN;
END
GO
/*
-- test
SELECT * FROM company.AboveAVGSalaries(3);
*/

-- g
-- Crie uma UDF que, para determinado departamento, retorne um
-- record-set com os projetos desse departamento. Para cada projeto
-- devemos ter um atributo com seu o or�amento mensal de m�o de obra
-- e outra coluna com o valor acumulado do or�amento.

-- DROP FUNCTION company.ProjectInfo;
GO
CREATE FUNCTION company.ProjectInfo(@dnum INT)
RETURNS @ProjectInfo TABLE (
	pname		VARCHAR(20),
	pnumber		INT,
	plocation 	VARCHAR(60),
	dnum 		INT,
	budget		DECIMAL(8,2),
	totalbudget	DECIMAL(8,2))
AS
BEGIN
	DECLARE @pnumber		INT;
	DECLARE @pname			VARCHAR(20);
	DECLARE @plocation		VARCHAR(60);
	DECLARE @budget			DECIMAL(8,2);
	DECLARE @totalbudget	DECIMAL(8,2);
	DECLARE @totalhours		DECIMAL(7,1);

	-- iterate over each projetc using cursors
	DECLARE cur CURSOR FORWARD_ONLY READ_ONLY LOCAL
	FOR SELECT Pname, Pnumber, Plocation
		FROM company.project
		WHERE Dnum = @dnum;

	SET @totalbudget = 0;

	OPEN cur;
    FETCH NEXT FROM cur INTO @pname, @pnumber, @plocation;
    WHILE @@FETCH_STATUS = 0 BEGIN

		-- calculate budget ("hourly salary" * hours worked)
		SELECT @budget = SUM(w.Hours / 40 * e.Salary)
		FROM company.works_on AS w JOIN company.employee AS e ON w.Essn = e.Ssn
		WHERE w.Pno = @pnumber;

		-- calculate total budget (sum of budgets)
		SET @totalbudget += @budget;

		-- insert into table
		INSERT @ProjectInfo (pname, pnumber, plocation, dnum, budget, totalbudget) VALUES
			(@pname, @pnumber, @plocation, @dnum, @budget, @totalbudget);

		FETCH NEXT FROM cur INTO @pname, @pnumber, @plocation;
    END

    CLOSE cur;
    DEALLOCATE cur;

	RETURN;
END
GO
/*
-- test
SELECT * FROM company.ProjectInfo(3);
*/


GO
-- i
-- Relativamente aos stored procedure e UDFs, enumere as suas
-- mais valias e as caracter�sticas que as distingue. D� exemplos
-- de situa��es em que se deve utiliza cada uma destas ferramentas;

/*
SPs (Stored Procedures) s�o um conjunto de intru��es T-SQL (uma batch)
	armazenadas sob um dado nome. S�o compilados uma �nica vez ("single
	execution plan"), permitindo uma execua��o mais r�pida (pois, ap�s
	a primeira execu��o, o SP passa a ficar na mem�ria cache). Podem ter
	par�metros de entrada, de sa�da, e devolver record sets (conjunto de
	registos). Podem ser system SP (criados na master DB) ou locais 
	(definidos num BD local).
UDFs (User Defined Functions) s�o semelhantes aos SPs, mas al�m da l�gica
	e consultas complexas, podem ainda ser usadas como fontes de dados 
	(equivalentes a "vistas parametriz�veis"). Podem ser de 3 tipos: 
	escalares, inline table-valued, e multi-statement table-valued. 

SPs devem ser utilizados em situa��es onde � neess�rio utilizar func�es n�o
	deterministas (i.e. GETDATE()) ou blocos TRY/CATCH ou em casos que requerem
	encapsulamento em transa��es. Quando queremos alterar objetos da BD, temos 
	necessariamente que utilizar SPs (UDFs n�o podem modificar valores fora do
	scope da sua fun��o). Um SPs pode ainda invocar uma ou mais UDFs, mas o 
	contr�rio (invocar SPs a partir de uma UDF) n�o � poss�vel.
Por outro lado, as UDFs s�o usadas quando � necess�rio que uma tabela seja 
	devolvida. 

As pricipais vantagens dos SPs s�o que estes s�o extens�veis (pois 
	permitem come�ar a criar abstra��es e come�ar a definir um API, al�m
	de come�ar a haver uma centraliza��o do c�digo SQL (concentrados num
	�nico ponto em vez de espalhados 'ad-hoc' pelo sistema) - o que tamb�m
	minimiza os erros e facilita os testes), melhor performance	(como j�
	referido, devido ao single execution plan, SPs s�o mais eficientes), 
	e finalmente permitem melhor seguran�a com a op��o de limitar o acesso
	� BD atrav�s de apenas SPs.
As principais vantangens das UDFs s�o que, de forma semlhante �s SPs, permitem
	grandes melhorias em termos de performaces (devido a ser compilado uma
	�nica vez), da facilidade de extens�o, centraliza��o e teste. 
	Al�m disso, ao contr�rio dos SPs, as UDFs podem ainda ser utilizadas 
	como fontes de dados. Finalmente, Schema Bindings, garantindo a integridade 
	dos objetos utilizados pelas UDFs representam uma outra vantagem das UDFs.

Alguns exemplos de situa��es s�o:
	- Queremos que uma tabela seja devolvida para integrar numa cl�usula de
		FROM, JOIN, etc. - usar uma UDF
	- Queremos obter um mecanismo parametriz�vel para a gera��o de views - usar
		uma UDF
	- Queremos realizar opera��es de DML (INSERT, UPDATE ou DELETE) em tabelas 
		(n�o locais) da BD - usar um SP
	- Queremos juntar ou at� empilhar as tabelas que resultaram de v�rias 
		fun��es e/ou opera��es - usar uma UDF
	- Queremos tirar partido de transa��es ou de fun��es n�o deterministicas - 
		usar um SP
	- Queremos impedir que um erro interrompa necessariamente a execu��o do 
		todas as intru��es seguintes desse bloco - usar um SP (com TRY/CATCH)
*/