-- 1
CREATE OR REPLACE FUNCTION p_valor220()
RETURNS INTEGER AS $$
	BEGIN
		RETURN 220;
	END
$$ LANGUAGE plpgsql;
-- 2
CREATE OR REPLACE FUNCTION p_valorVar()
RETURNS INTEGER AS $$
	DECLARE
		VAR INTEGER := 220;
	BEGIN
		RETURN VAR;
	END
$$ LANGUAGE plpgsql;
-- 3
CREATE OR REPLACE FUNCTION p_cantidadPedidos()
RETURNS INTEGER AS $$
	BEGIN
		RETURN (SELECT COUNT(*) FROM ORD);
	END
$$ LANGUAGE plpgsql;
-- 4
CREATE OR REPLACE FUNCTION p_cadenaValor(valor INTEGER)
RETURNS TEXT AS $$
	BEGIN
		IF VALOR > 10 THEN
			RETURN 'MAYOR QUE 10';
		ELSIF VALOR < 11 THEN
			RETURN 'MENOR QUE 11';
		END IF;
	END
$$ LANGUAGE plpgsql;
-- 5
CREATE OR REPLACE FUNCTION p_sumaA(INTEGER, INTEGER)
RETURNS INTEGER AS $$
	BEGIN
		RETURN ($1 + $2);
	END
$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION p_sumaB(a INTEGER, b INTEGER)
RETURNS INTEGER AS $$
	BEGIN
		RETURN (a + b);
	END
$$ LANGUAGE plpgsql;
-- 6
CREATE OR REPLACE FUNCTION p_edad(fNacimiento DATE)
RETURNS INTEGER AS $$
	DECLARE
		añoNacimiento INTEGER := (EXTRACT(YEAR FROM fNacimiento));
		mesNacimiento INTEGER := (EXTRACT(MONTH FROM fNacimiento));
		diaNacimiento INTEGER := (EXTRACT(DAY FROM fNacimiento));
	BEGIN
		IF ((mesNacimiento - EXTRACT(MONTH FROM CURRENT_DATE)) < 0) THEN
			RETURN (EXTRACT(YEAR FROM CURRENT_DATE) - añoNacimiento) - 1;
		ELSE
			IF ((diaNacimiento - EXTRACT(DAY FROM CURRENT_DATE)) < 0) THEN
				RETURN (EXTRACT(YEAR FROM CURRENT_DATE) - añoNacimiento) - 1;
			ELSE
				RETURN EXTRACT(YEAR FROM CURRENT_DATE) - añoNacimiento;
			END IF;
		END IF;
	END
$$ LANGUAGE plpgsql;
-- 7
CREATE OR REPLACE FUNCTION p_nombreApellidos(nombre TEXT, apellido1 TEXT, apellido2 TEXT)
RETURNS TEXT AS $$ -- MEJOR VARCHAR, YA QUE TEXT ES MUY GRANDE.
	BEGIN
		RETURN apellido1 || ' ' || apellido2 || ', ' || nombre;
	END
$$ LANGUAGE plpgsql;
-- 8
CREATE OR REPLACE FUNCTION p_valorFactorial(numero INTEGER)
RETURNS INTEGER AS $$
	DECLARE
		c INTEGER;
		n INTEGER := numero;
		returnValue INTEGER := 1;
	BEGIN
		IF numero < 0 THEN
			RETURN -1;
		ELSE
			FOR c IN 1..n LOOP
				returnValue = returnValue * c;
				-- c = c + 1; EL '+1' LO HACE SOLO!
			END LOOP;
			RETURN returnValue;
		END IF;
	END
$$ LANGUAGE plpgsql;
-- 9
CREATE OR REPLACE FUNCTION p_diaSemana(fecha DATE)
RETURNS TEXT AS $$
	DECLARE
		value INTEGER;
	BEGIN
		value = DATE_PART('isodow', fecha);
		CASE value
			WHEN 1 THEN
				RETURN 'Lunes';
			WHEN 2 THEN
				RETURN 'Martes';
			WHEN 3 THEN
				RETURN 'Miercoles';
			WHEN 4 THEN
				RETURN 'Jueves';
			WHEN 5 THEN
				RETURN 'Viernes';
			WHEN 6 THEN
				RETURN 'Sabado';
			WHEN 7 THEN
				RETURN 'Domingo';
			ELSE
				RETURN 'ERROR';
		END CASE;
	END
$$ LANGUAGE plpgsql;
-- 10
CREATE OR REPLACE FUNCTION p_valorMes(fecha DATE)
RETURNS TEXT AS $$
	DECLARE
		month INTEGER := EXTRACT(MONTH FROM fecha);
	BEGIN
		IF month = 1 THEN
			RETURN 'Enero';
		ELSIF month = 2 THEN
			RETURN 'Febrero';
		ELSIF month = 3 THEN
			RETURN 'Marzo';
		ELSIF month = 4 THEN
			RETURN 'Abril';
		ELSIF month = 5 THEN
			RETURN 'Mayo';
		ELSIF month = 6 THEN
			RETURN 'Junio';
		ELSIF month = 7 THEN
			RETURN 'Julio';
		ELSIF month = 8 THEN
			RETURN 'Agosto';
		ELSIF month = 9 THEN
			RETURN 'Septiembre';
		ELSIF month = 10 THEN
			RETURN 'Octubre';
		ELSIF month = 11 THEN
			RETURN 'Noviembre';
		ELSIF month = 12 THEN
			RETURN 'Diciembre';
		END IF;
	END
$$ LANGUAGE plpgsql;
