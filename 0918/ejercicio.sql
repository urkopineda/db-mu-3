CREATE OR REPLACE FUNCTION f_checkDigitos(cuenta VARCHAR)
RETURNS BOOLEAN AS $$
	DECLARE
		digitos VARCHAR;
		suma INTEGER = 0;
		checkRes INTEGER;
		temp INTEGER;
		changeNumber INTEGER := 0;
	BEGIN
		digitos = SUBSTRING(cuenta, 11, 9);
		FOR i IN 1..9
		LOOP
			temp = TO_NUMBER(SUBSTRING(digitos, i, 1), '9');
			IF changeNumber = 0 THEN
				suma = suma + (temp * 1);
				changeNumber = 1;
			ELSIF changeNumber = 1 THEN
				suma = suma + (temp * 3);
				changeNumber = 2;
			ELSIF changeNumber = 2 THEN
				suma = suma + (temp * 5);
				changeNumber = 0;
			END IF;
		END LOOP;
		checkRes = suma % 10;
		IF TO_NUMBER(SUBSTRING(cuenta, 20, 1), '9') = checkRes THEN
			RETURN TRUE;
		ELSE 
			RETURN FALSE;
		END IF;
	END
$$ LANGUAGE plpgsql;
