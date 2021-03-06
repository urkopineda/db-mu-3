-- 1 y 2
CREATE TABLE USUARIO (
	USERID INTEGER PRIMARY KEY NOT NULL,
	USERNAME VARCHAR(20) NOT NULL,
	PASSWORD VARCHAR(20) NOT NULL,
	SESSION BOOLEAN 
);
CREATE TABLE ACCESO (
	USERID INTEGER NOT NULL,
	INITDATE TIMESTAMP,
	FINIDATE TIMESTAMP,
	CONSTRAINT PK_ACCESO
	PRIMARY KEY (USERID, INITDATE),
	CONSTRAINT FK_USUARIO
	FOREIGN KEY (USERID)
	REFERENCES USUARIO(USERID)
);
INSERT INTO USUARIO VALUES (1, 'URKO', 'PINEDA', FALSE);
INSERT INTO USUARIO VALUES (2, 'GORKA', 'OLALDE', FALSE);
INSERT INTO USUARIO VALUES (3, 'JON', 'AYERDI', FALSE);
CREATE OR REPLACE FUNCTION f_t_session()
RETURNS TRIGGER AS $$
	BEGIN
		IF ((OLD.SESSION = FALSE) AND (NEW.SESSION = TRUE)) THEN
			INSERT INTO ACCESO
			VALUES (OLD.USERID, current_timestamp, NULL);
		ELSIF ((OLD.SESSION = TRUE) AND (NEW.SESSION = FALSE)) THEN
			UPDATE ACCESO
			SET FINIDATE = current_timestamp
			WHERE USERID = OLD.USERID;
		END IF;
		RETURN NULL;
	END
$$ LANGUAGE plpgsql;
CREATE TRIGGER t_session AFTER UPDATE OF SESSION ON USUARIO 
	FOR EACH ROW EXECUTE PROCEDURE f_t_session();
-- 3 (USANDO SCOTT)
CREATE TABLE CONTROL (
	EMPNO INTEGER NOT NULL,
	FUPDATE DATE,
	NSAL NUMERIC,
	NCOMM NUMERIC,
	OSAL NUMERIC,
	OCOMM NUMERIC
);
CREATE OR REPLACE FUNCTION f_t_control()
RETURNS TRIGGER AS $$
	BEGIN
		INSERT INTO CONTROL VALUES(NEW.EMPNO, current_date, NEW.SAL, NEW.COMM, OLD.SAL, OLD.COMM);
		RETURN NULL;
	END
$$ LANGUAGE plpgsql;
CREATE TRIGGER t_session AFTER UPDATE OF SAL, COMM ON EMP 
	FOR EACH ROW EXECUTE PROCEDURE f_t_control();
-- 4 (USANDO SCOTT)
ALTER TABLE DEPT
ADD PRESUPUESTO NUMERIC;
CREATE OR REPLACE FUNCTION f_t_newUser()
RETURNS TRIGGER AS $$
	BEGIN
		UPDATE DEPT
		SET PRESUPUESTO = (PRESUPUESTO + NEW.SAL)
		WHERE DEPTNO = NEW.DEPTNO;
		RETURN NULL;
	END
$$ LANGUAGE plpgsql;
CREATE TRIGGER t_newUser AFTER INSERT ON EMP 
	FOR EACH ROW EXECUTE PROCEDURE f_t_newUser();
-- 5 (USANDO FAGOR)
CREATE TABLE CONTROL_PRECIOS (
	NUMPED INTEGER NOT NULL,
	CODART INTEGER NOT NULL,
	PREPED NUMERIC,
	PREART NUMERIC,
	CANT INTEGER
);
CREATE OR REPLACE FUNCTION f_t_controlPrecios()
RETURNS TRIGGER AS $$
	DECLARE
		i NUMERIC;
	BEGIN
		SELECT INTO i PREART FROM ARTICULOS WHERE CODART = NEW.CODPROLIN;
		IF (i > NEW.PRECIOLIN) THEN
			INSERT INTO CONTROL_PRECIOS
			VALUES (NEW.NUMPEDLIN, NEW.CODPROLIN, i, NEW.PRECIOLIN, NEW.CANTLIN);
		END IF;
		RETURN NULL;
	END
$$ LANGUAGE plpgsql;
CREATE TRIGGER t_controlPrecios AFTER INSERT ON LINEAS 
	FOR EACH ROW EXECUTE PROCEDURE f_t_controlPrecios();
-- 6 (USANDO FAGOR)
ALTER TABLE ARTICULOS
ADD STKMIN INTEGER;
ALTER TABLE ARTICULOS
ADD STKMED INTEGER;
CREATE TABLE REAPRO (
	CODPRO INTEGER PRIMARY KEY NOT NULL,
	FECHA DATE,
	CANT INTEGER
);	
CREATE OR REPLACE FUNCTION f_t_controlStk()
RETURNS TRIGGER AS $$
	DECLARE
		stk NUMERIC;
		stk_med NUMERIC;
		stk_min NUMERIC;
		i INTEGER := -1;
	BEGIN
		SELECT INTO stk STKART FROM ARTICULOS WHERE CODART = NEW.CODPROLIN;
		SELECT INTO stk_med STKMED FROM ARTICULOS WHERE CODART = NEW.CODPROLIN;
		SELECT INTO stk_min STKMIN FROM ARTICULOS WHERE CODART = NEW.CODPROLIN;
		IF (stk < stk_min) THEN
			SELECT INTO i COUNT(CODPRO) FROM REAPRO WHERE CODPRO = NEW.CODPROLIN;
			IF (i = 0) THEN
				INSERT INTO REAPRO VALUES(NEW.CODPROLIN, current_date, (stk_med - stk));
			ELSE
				UPDATE REAPRO SET CANT = (stk_med - stk) WHERE CODPRO = NEW.CODPROLIN;
			END IF;
		END IF;
		RETURN NULL;
	END
$$ LANGUAGE plpgsql;
CREATE TRIGGER t_controlStk AFTER INSERT ON LINEAS 
	FOR EACH ROW EXECUTE PROCEDURE f_t_controlStk();
