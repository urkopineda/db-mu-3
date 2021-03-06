-- 1.1 SIN CURSOR CON FOR
CREATE OR REPLACE FUNCTION p_subirSalario1()
RETURNS VOID AS $$
	DECLARE
		x RECORD;
	BEGIN
		FOR x IN SELECT EMPNO, SAL, COMM FROM EMP
		LOOP
			IF (x.COMM == NULL) THEN
				IF ((200 + x.SAL) > 3000) THEN
					UPDATE EMP
					SET COMM = ((SAL * 10) / 100)
					WHERE EMPNO = x.EMPNO;
				ELSE
					UPDATE EMP
					SET COMM = 200
					WHERE EMPNO = x.EMPNO;
				END IF;
			END IF;
		END LOOP;
	END
$$ LANGUAGE plpgsql;
-- 1.2 CON CURSOR Y WHILE
CREATE OR REPLACE FUNCTION p_subirSalario2()
RETURNS VOID AS $$
	DECLARE
		rs CURSOR FOR 
			SELECT EMPNO, SAL, COMM
			FROM EMP;
		x RECORD;
	BEGIN
		OPEN rs;
		WHILE (x != NULL)
		LOOP
			FETCH rs INTO x;
			IF (x.COMM == NULL) THEN
				IF ((200 + x.SAL) > 3000) THEN
					UPDATE EMP
					SET COMM = ((SAL * 10) / 100)
					WHERE EMPNO = x.EMPNO;
				ELSE
					UPDATE EMP
					SET COMM = 200
					WHERE EMPNO = x.EMPNO;
				END IF;
			END IF;
		END LOOP;
		CLOSE rs;
	END
$$ LANGUAGE plpgsql;
-- 1.3 CON CURSOR CON FOR
CREATE OR REPLACE FUNCTION p_subirSalario3()
RETURNS VOID AS $$
	DECLARE
		rs CURSOR FOR 
			SELECT EMPNO, SAL, COMM
			FROM EMP;
		x RECORD;
	BEGIN
		OPEN rs;
		LOOP
			FETCH rs INTO x;
			EXIT WHEN NOT FOUND;
			IF (x.COMM == NULL) THEN
				IF ((200 + x.SAL) > 3000) THEN
					UPDATE EMP
					SET COMM = ((SAL * 10) / 100)
					WHERE EMPNO = x.EMPNO;
				ELSE
					UPDATE EMP
					SET COMM = 200
					WHERE EMPNO = x.EMPNO;
				END IF;
			END IF;
		END LOOP;
		CLOSE rs;
	END
$$ LANGUAGE plpgsql;
-- 2
CREATE OR REPLACE FUNCTION p_updateStock()
RETURNS VOID AS $$
	DECLARE
		rs CURSOR FOR 
			SELECT CODPROLIN, SUM(CANTLIN) AS TOTAL
			FROM PEDIDOS JOIN LINEAS ON LINEAS.NUMPEDLIN = PEDIDOS.NUMPED
			WHERE FECHPED = CURRENT_DATE
			GROUP BY CODPROLIN;
		x RECORD;
		cantidad RECORD;
	BEGIN
		OPEN rs;
		LOOP
			FETCH rs INTO x;
			EXIT WHEN NOT FOUND;
			UPDATE ARTICULOS
			SET STKART = (STKART - x.TOTAL)
			WHERE ARTICULOS.CODART = x.CODPROLIN;
		END LOOP;
		CLOSE rs;
	END
$$ LANGUAGE plpgsql;
-- 3
CREATE OR REPLACE FUNCTION p_subirSalario4()
RETURNS VOID AS $$
	DECLARE
		rs CURSOR FOR 
			SELECT EMPNO, SAL, JOB
			FROM EMP
			ORDER BY SAL DESC;
		x RECORD;
		count INTEGER := 0;
	BEGIN
		OPEN rs;
		LOOP
			FETCH rs INTO x;
			EXIT WHEN NOT FOUND;
			count = count + 1;
			IF (count => 5) THEN
				UPDATE EMP
				SET SAL = ((SAL * 10) / 100)
				WHERE EMPNO = x.EMPNO;
			ELSE
				UPDATE EMP
				SET SAL = ((SAL * 5) / 100)
				WHERE EMPNO = x.EMPNO;
			END IF;
			IF (JOB == 'MANAGER') THEN
				UPDATE EMP
				SET SAL = ((SAL * 5) / 100)
				WHERE EMPNO = x.EMPNO;
			END IF;
		END LOOP;
		CLOSE rs;
	END
$$ LANGUAGE plpgsql;
-- 4
CREATE DATABASE "BANCO"
	WITH ENCODING='UTF8'
       OWNER=postgres
       CONNECTION LIMIT=-1;
COMMENT ON DATABASE "BANCO"
	IS 'Base de datos de pruebas para los ejercicios de PLPGSQL.';
CREATE TABLE CUENTA (
	CUENTAID INTEGER PRIMARY KEY NOT NULL,
	NUMERO NUMERIC NOT NULL,
	TIPO INTEGER NOT NULL,
	IMPORTE	BIGINT
);
CREATE TABLE CLIENTE (
	COD	VARCHAR(10) PRIMARY KEY NOT NULL,
	CUENTAID INTEGER REFERENCES CUENTA(CUENTAID),
	NOMBRE VARCHAR(40) NOT NULL
);
CREATE TABLE REGISTRO (
	COD	VARCHAR(10) REFERENCES CLIENTE(COD),
	CUENTAID INTEGER REFERENCES CUENTA(CUENTAID),
	IMPORTE BIGINT NOT NULL,
	CONCEPTO TEXT
);
INSERT INTO CUENTA VALUES(1000, 12345678901234567890, 0, 1500);
INSERT INTO CLIENTE VALUES(0, 1000, 'URKO');
INSERT INTO CUENTA VALUES(1001, 12345678901234567891, 0, 200);
INSERT INTO CLIENTE VALUES(1, 1001, 'GORKA');
INSERT INTO CUENTA VALUES(1002, 12345678901234567891, 2, 4000);
INSERT INTO CLIENTE VALUES(2, 1002, 'XABI');
INSERT INTO CUENTA VALUES(1003, 12345678901234567891, 1, 50000);
INSERT INTO CLIENTE VALUES(3, 1003, 'JON');
INSERT INTO CUENTA VALUES(1004, 12345678901234567891, 2, 14000);
INSERT INTO CLIENTE VALUES(4, 1004, 'ASIER');
CREATE OR REPLACE FUNCTION p_cobrarComision()
RETURNS VOID AS $$
	DECLARE
		rs CURSOR FOR 
			SELECT CL.COD, CU.CUENTAID, CU.TIPO, CU.IMPORTE
			FROM CLIENTE CL JOIN CUENTA CU ON CL.CUENTAID = CU.CUENTAID;
		x RECORD;
		comision INTEGER := -25;
	BEGIN
		OPEN rs;
		LOOP
			FETCH rs INTO x;
			EXIT WHEN NOT FOUND;
			IF (x.TIPO == 0) THEN -- Teniendo en cuenta que 0 es de tipo ahorro.
				INSERT INTO REGISTRO
				VALUES(CL.COD, CU.CUENTAID, comision, 'COMISION DE LA CUENTA DE AHORRO');
				UPDATE CUENTA CU
				SET IMPORTE = IMPORTE + comision
				WHERE x.CUENTAID = CU.CUENTAID;
			END IF;
		END LOOP;
		CLOSE rs;
	END
$$ LANGUAGE plpgsql;
-- 5
CREATE OR REPLACE FUNCTION p_devolverComision()
RETURNS VOID AS $$
	DECLARE
		rs CURSOR FOR 
			SELECT CL.COD, CU.CUENTAID, CU.TIPO, CU.IMPORTE
			FROM CLIENTE CL JOIN CUENTA CU ON CL.CUENTAID = CU.CUENTAID;
		x RECORD;
		comision INTEGER := 25;
	BEGIN
		OPEN rs;
		LOOP
			FETCH rs INTO x;
			EXIT WHEN NOT FOUND;
			IF (x.TIPO == 0) THEN -- Teniendo en cuenta que 0 es de tipo ahorro.
				IF (x.IMPORTE >= 1000 + comision) THEN
					INSERT INTO REGISTRO
					VALUES(CL.COD, CU.CUENTAID, comision, 'DEVOLUCION DE COMISION DE LA CUENTA DE AHORRO');
					UPDATE CUENTA CU
					SET IMPORTE = IMPORTE + comision
					WHERE x.CUENTAID = CU.CUENTAID;
				END IF;
			END IF;
		END LOOP;
		CLOSE rs;
	END
$$ LANGUAGE plpgsql;
-- 6
CREATE OR REPLACE FUNCTION p_tiempoMedio()
RETURNS INTEGER AS $$
	DECLARE
		rs CURSOR FOR 
			SELECT MF_GFH AS HORAFINALIZACION
			FROM TRAZAS
			ORDER BY HORAFINALIZACION;
		x RECORD;
		temp INTEGER := 0;
		count INTEGER := 0;
	BEGIN
		OPEN rs;
		FETCH rs INTO x;
		temp = AGE(HORAFINALIZACION);
		WHILE (temp != NULL)
		LOOP
			FETCH rs INTO x;
			EXIT WHEN NOT FOUND;
			temp = temp + AGE(HORAFINALIZACION);
			count = count + 1;
		END LOOP;
		CLOSE rs;
		RETURN temp / count;
	END
$$ LANGUAGE plpgsql;
