-- 1
CREATE OR REPLACE FUNCTION f_addEmp(empno INTEGER, ename VARCHAR, deptno INTEGER)
RETURNS VOID AS $$
	BEGIN
		INSERT INTO EMP(EMPNO, ENAME, DEPTNO) VALUES (empno, ename, deptno);
	EXCEPTION
		WHEN unique_violation THEN
			RAISE EXCEPTION 'ERROR, CÓDIGO DE EMPLEADO REPETIDO.';
	END
$$ LANGUAGE plpgsql;
--2
CREATE OR REPLACE FUNCTION f_addEmp1(empno INTEGER, ename VARCHAR, deptno INTEGER)
RETURNS VOID AS $$
	DECLARE
		count INTEGER;
	BEGIN
		SELECT INTO count COUNT(EMPNO) FROM EMP WHERE DEPTNO = deptno;
		IF (COUNT > 8) THEN
			RAISE EXCEPTION 'ERROR, NÚMERO DE EMPLEADOS SUPERA A 8.';
		END IF;
		INSERT INTO EMP(EMPNO, ENAME, DEPTNO) VALUES (empno, ename, deptno);
	EXCEPTION
		WHEN unique_violation THEN
			RAISE EXCEPTION 'ERROR, CÓDIGO DE EMPLEADO REPETIDO.';
		WHEN SQLSTATE '23503' THEN
			RAISE EXCEPTION 'ERROR, DEPARTAMENTO INEXISTENTE';
	END
$$ LANGUAGE plpgsql;
-- 3
CREATE OR REPLACE FUNCTION f_checkStockException(codepro INTEGER, stock INTEGER)
RETURNS VOID AS $$
	DECLARE
		count INTEGER := 0;
		oldStock INTEGER := 0;
	BEGIN
		SELECT INTO count COUNT(CODART)
		FROM ARTICULOS
		WHERE CODART = codepro;
		IF (count = 0) THEN
			RAISE EXCEPTION 'ERROR, ARTICULO NO ENCONTRADO.';
		END IF;	
		SELECT INTO oldStock STKART
		FROM ARTICULOS
		WHERE CODART = codepro;
		IF (oldStock < stock) THEN
			RAISE EXCEPTION 'ERROR, STOCK INSUFICIENTE.';
		END IF;
		UPDATE ARTICULOS
		SET STKART = STKART - stock
		WHERE CODART = codepro;
	END
$$ LANGUAGE plpgsql;
-- 4
CREATE OR REPLACE FUNCTION f_t_updateEmp()
RETURNS TRIGGER AS $$
	DECLARE

	BEGIN
		IF (NEW.ENAME = NULL) THEN
			RAISE EXCEPTION 'ERROR, NOMBRE NULO.';
		END IF;
		IF (NEW.SAL = NULL) THEN
			RAISE EXCEPTION 'ERROR, SALARIO NULO.';
		END IF;
		IF (NEW.SAL < 0) THEN
			RAISE EXCEPTION 'ERROR, SALARIO NEGATIVO.';
		END IF;
	END
$$ LANGUAGE plpgsql;
CREATE TRIGGER t_updateEmp AFTER UPDATE OR INSERT ON EMP 
	FOR EACH ROW EXECUTE PROCEDURE f_t_updateEmp();
-- ##################################################################################################
-- 1
BEGIN;
SAVEPOINT backUp;
UPDATE EMP
SET SAL = SAL + ((SAL * 10) / 100);
SAVEPOINT backUp1;
SELECT COUNT(EMPNO) FROM EMP WHERE SAL > 3800;
ROOLBACK TO SAVEPOINT backUp;
COMMIT;
-- 2
BEGIN;
SAVEPOINT backUp;
UPDATE EMP
SET SAL = SAL + ((SAL * 5) / 100);
WHERE ENAME = 'JONES';
SAVEPOINT backUp1;
UPDATE EMP
SET SAL = SAL + ((SAL * 50) / 100);
WHERE ENAME = 'MILLER';
ROOLBACK TO SAVEPOINT backUp1;
COMMIT;
-- 3
BEGIN;
SAVEPOINT backUp;
DELETE FROM LINEAS
WHERE NUMPEDLIN = 612;
SAVEPOINT backUp1;
DELETE FROM PEDIDOS
WHERE NUMPED = 612;
ROOLBACK TO SAVEPOINT backUp;
COMMIT;
