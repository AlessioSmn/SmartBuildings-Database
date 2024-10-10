-- se tutti i sotto-elementi di un edificio (piano, vano, muro)
-- sono stati inseriti, si mette edificio.Completo = 1
-- altrimenti edificio.completo = 0
-- Chiamato quando un sotto elemento cambia il bit inCostr
DROP PROCEDURE IF EXISTS setEdificioCompleto;
DELIMITER $$
CREATE PROCEDURE setEdificioCompleto(IN _Edificio INT)
BEGIN
	DECLARE edificioNonCompletato INT DEFAULT 0;
	DECLARE pianiNonCompletati INT DEFAULT 0;
	DECLARE vaniNonCompletati INT DEFAULT 0;
	DECLARE bitCompleto BIT DEFAULT 0;

	SET edificioNonCompletato = (
		SELECT E.inCostruzione
		FROM Edificio E
		WHERE E.idEdificio = _Edificio
		);
	SET pianiNonCompletati = (
		SELECT count(*)
		FROM Piano P
		WHERE P.Edificio = _Edificio AND P.inCostruzione = 1);
	SET vaniNonCompletati = ( 
		SELECT count(*)
		FROM Vano V
		WHERE V.inCostruzione = 1 AND V.Piano IN 
			(SELECT P.idPiano
			FROM Piano P
			WHERE P.Edificio = _Edificio));
			
	IF (edificioNonCompletato + pianiNonCompletati + vaniNonCompletati = 0) THEN SET bitCompleto = 1;
	END IF;

	
	UPDATE Edificio E
	SET E.completo = bitCompleto
	WHERE E.idEdificio = _Edificio;
END $$
DELIMITER ;


-- se si sta inserendo l'ultimo piano -> si mette edificio.inCostruzione a 0
-- se il bit cambia -> si controlla se l'edificio è completo
DROP PROCEDURE IF EXISTS setEdificioInCostruzione;
DELIMITER $$
CREATE PROCEDURE setEdificioInCostruzione(IN _Edificio INT)
BEGIN
	DECLARE maxPiani INT;
	DECLARE numPianiEdificio INT;
	DECLARE bitInCostruzione BIT DEFAULT 1;
	DECLARE oldBitInCostruzione BIT;

	SET maxPiani = (
		SELECT E.NumeroPiani
		FROM Edificio E
		WHERE E.idEdificio = _Edificio);
	SET numPianiEdificio = (
		SELECT count(*)
		FROM Piano P
		WHERE P.Edificio = _Edificio);

	IF (numPianiEdificio = maxPiani) THEN SET bitInCostruzione = 0;
	END IF;
	SET oldBitInCostruzione = (
		SELECT E.inCostruzione
		FROM Edificio E
		WHERE E.idEdificio = _Edificio);
	IF (oldBitInCostruzione <> bitInCostruzione) THEN
		UPDATE Edificio E
		SET E.inCostruzione = bitInCostruzione
		WHERE E.idEdificio = _Edificio;

		CALL setEdificioCompleto(_Edificio);
	END IF;
END $$
DELIMITER ;


-- se si e' inserito l'ultimo -> si mette piano.inCostruzione a 0
-- altrimenti si mette piano.inCostruzione a 1
-- da chiamare dal trigger con NEW.Piano come parametro
-- se il bit viene cambiato si chiama setEdificioCompleto
DROP PROCEDURE IF EXISTS setPianoInCostruzione;
DELIMITER $$
CREATE PROCEDURE setPianoInCostruzione(IN _Piano INT)
BEGIN
	DECLARE maxVani INT;
	DECLARE numVaniPiano INT;
	DECLARE bitInCostruzione BIT DEFAULT 1;
	DECLARE oldBitInCostruzione BIT;
	DECLARE edificio INT;

	SET maxVani = (
		SELECT P.NumeroVani
		FROM Piano P
		WHERE P.idPiano = _Piano);
	-- after insert -> valori già consistenti secondo le specifiche delle chiavi
	SET numVaniPiano = (
		SELECT count(*)
		FROM Vano V
		WHERE V.Piano = _Piano);

	IF (numVaniPiano = maxVani) THEN SET bitInCostruzione = 0;
	END IF;
	SET oldBitInCostruzione = (
		SELECT P.inCostruzione
		FROM Piano P
		WHERE P.idPiano = _Piano);

	IF (bitInCostruzione <> oldBitInCostruzione) THEN
		UPDATE Piano P
		SET P.inCostruzione = bitInCostruzione
		WHERE P.idPiano = _Piano;
		
		SET edificio = (
			SELECT P.Edificio
			FROM Piano P
			WHERE P.idPiano = _Piano);
		CALL setEdificioCompleto(edificio);
	END IF;
END $$
DELIMITER ;


-- controlla se tutti i muri di un vano sono stati inseriti
-- se si' mette bit inCost a 0, altrimenti a 1
-- se inCost=0 chiama SP per il calcolo delle dim del vano
DROP PROCEDURE IF EXISTS setVanoInCostruzione;
DELIMITER $$
CREATE PROCEDURE setVanoInCostruzione(IN _Vano INT)
BEGIN
	DECLARE maxMuri INT;
	DECLARE numMuriVano INT;
	DECLARE bitInCostruzione BIT DEFAULT 1;
	DECLARE oldBitInCostruzione BIT DEFAULT 1;
	DECLARE edificio INT;

	SET maxMuri = (
		SELECT V.NumeroMuri
		FROM Vano V
		WHERE V.idVano = _Vano);
	SET numMuriVano = (
		SELECT count(*)
		FROM Delimitazione D
		WHERE D.Vano = _Vano);
	
	IF (numMuriVano = maxMuri) THEN SET bitInCostruzione = 0;
	END IF;
	SET oldBitInCostruzione = (
		SELECT V.inCostruzione
		FROM Vano V
		WHERE V.idVano = _Vano);

	IF(oldBitInCostruzione <> bitInCostruzione) THEN
		UPDATE Vano V
		SET V.inCostruzione = bitInCostruzione
		WHERE V.idVano = _Vano;

		SET edificio = (
			SELECT P.Edificio
			FROM Piano P
			WHERE P.idPiano IN (
				SELECT V.Piano
				FROM Vano V
				WHERE V.idVano = _Vano));
		CALL setEdificioCompleto(edificio);

		IF (bitInCostruzione = 0) THEN CALL calculateDimVano(_Vano);
		END IF;
	END IF;
END $$
DELIMITER ;
-- controlla che siano inseriti max piani <= NumeroPiani 
-- per edificio prima di inserire un nuovo piano nell'edificio
DROP PROCEDURE IF EXISTS checkNumeroPiani;
DELIMITER $$
CREATE PROCEDURE checkNumeroPiani(IN _Edificio INT, IN _numPiano INT)
BEGIN
	DECLARE maxPiani INT;
	DECLARE numPianiEdificio INT;

	SET maxPiani = (
		SELECT IF(E.NumeroPiani IS NULL, -1, E.NumeroPiani)
		FROM Edificio E
		WHERE E.idEdificio = _Edificio);
	IF (maxPiani = -1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Edificio non esistente';
	END IF;
	SET numPianiEdificio = (
		SELECT count(*)
		FROM Piano P
		WHERE P.Edificio = _Edificio);

	IF (numPianiEdificio >= maxPiani) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Numero di piani da inserire già raggiunto';
	END IF;

	IF(_numPiano >= maxPiani) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Numero piano non consistente con il numero di piani dell`edificio';
	END IF;
END $$
DELIMITER ;


-- controlla che siano inseriti max vani <= NumeroVani 
-- per piano prima di inserire un nuovo vano 
DROP PROCEDURE IF EXISTS checkNumeroVani;
DELIMITER $$
CREATE PROCEDURE checkNumeroVani(IN _Piano INT)
BEGIN
	DECLARE maxVani INT;
	DECLARE numVaniPiano INT;

	SET maxVani = (
		SELECT IF(P.NumeroVani IS NULL, -1, P.NumeroVani)
		FROM Piano P
		WHERE P.idPiano = _Piano);
	IF (maxVani = -1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Piano non esistente';
	END IF;
	SET numVaniPiano = (
		SELECT count(*)
		FROM Vano V
		WHERE V.Piano = _Piano);

	IF (numVaniPiano >= maxVani) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Numero di vani da inserire già raggiunto';
	END IF;
END $$
DELIMITER ;


-- controlla che siano inseriti max muri <= NumeroMuri 
-- per vano prima di inserire un nuovo muro 
DROP PROCEDURE IF EXISTS checkNumeroMuri;
DELIMITER $$
CREATE PROCEDURE checkNumeroMuri(IN _Vano INT, IN _Muro INT)
BEGIN
DECLARE inserimentiMuro INT;
	DECLARE maxMuri INT;
	DECLARE numMuriVano INT;
	-- DECLARE bitMuroInseribile BIT DEFAULT 0;
	DECLARE vecchioPiano INT;
	DECLARE nuovoPiano INT;
	DECLARE sensoriEsterni INT;
	DECLARE accessiEsterni INT;
	
	-- controllo che ci sia max 1 occorrenza di muro in delimitazione per inserine una nuova
	SET inserimentiMuro = (
		SELECT count(*)
		FROM Delimitazione D
		WHERE D.Muro = _Muro);
	IF (inserimentiMuro >= 2) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Muro già legato a due vani';
	END IF;

	-- controllo che il vano specificato esista e non abbia già tutti i muri
	SET maxMuri = (
		SELECT IF(V.NumeroMuri IS NULL, -1, V.NumeroMuri)
		FROM Vano V
		WHERE V.idVano = _Vano);
	IF (maxMuri = -1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vano non esistente';
	END IF;
	SET numMuriVano = (
		SELECT count(*)
		FROM Delimitazione D
		WHERE D.Vano = _Vano);
	IF (numMuriVano >= maxMuri) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Numero di muri per vano da inserire già raggiunto';
	END IF;
	
	-- controllo da fare solo quando è già presente una occorrenza del muro specificato in delimitazione
	IF (inserimentiMuro = 1) THEN
		-- controllo che i vani confinanti dal muro specificato siano parte dello stesso piano
		SET vecchioPiano = (
			SELECT V.Piano
			FROM Vano V
			WHERE V.idVano IN (
				SELECT D.Vano
				FROM Delimitazione D
				WHERE D.Muro = _Muro));
		SET nuovoPiano = (
			SELECT V.Piano
			FROM Vano V
			WHERE V.idVano = _Vano);
		IF (vecchioPiano <> nuovoPiano) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Muro può fare da confine solo tra vani di uno stesso piano';
		END IF;

		-- controllo che non ci siano sensori da esterno (pluviometro non ha senso che stia dentro la casa)
		SET sensoriEsterni = (
			SELECT count(*)
			FROM Sensore S
			WHERE S.Muro = _Muro AND S.Tipo = 'pluviometro');

		-- controllo che non ci siano finestre/portefinestre su quel muro
		SET accessiEsterni = (
			SELECT count(*)
			FROM AperturaMuro PA
			WHERE PA.Muro = _Muro
				AND (PA.Tipo = 'finestra' OR PA.Tipo = 'portafinestra'));
		IF (accessiEsterni + sensoriEsterni  > 0) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Muro contiene elementi da esterno';
		END IF;
	END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS updateAttributiMuro;
DELIMITER $$
CREATE PROCEDURE updateAttributiMuro(IN _Muro INT)
BEGIN
	-- count = 1/2 -> 
	-- 1 <=> muro Esterno -> Interno = 0
	-- 2 <=> muro Interno -> Interno = 1
	UPDATE Muro M 
	SET 
		M.Interno = (
			SELECT IF(count(*)-1 = 0, 0, 1)
			FROM Delimitazione D 
			WHERE D.Muro = _Muro),
		M.Edificio = (
			SELECT DISTINCT(P.Edificio)
			FROM Piano P
				INNER JOIN Vano V ON P.idPiano = V.Piano
				INNER JOIN Delimitazione D ON V.idVano = D.Vano
			WHERE D.Muro = _Muro)
	WHERE M.idMuro = _Muro;
END $$
DELIMITER ;



DROP FUNCTION IF EXISTS max_;
DELIMITER $$
CREATE FUNCTION max_(a FLOAT, b FLOAT)
RETURNS FLOAT DETERMINISTIC
BEGIN
	DECLARE retValue FLOAT;
	IF (a >= b) THEN SET retValue = a;
	ELSE SET retValue = b;
	END IF;
	RETURN retValue;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS min_;
DELIMITER $$
CREATE FUNCTION min_(a FLOAT, b FLOAT)
RETURNS FLOAT DETERMINISTIC
BEGIN
	DECLARE retValue FLOAT;
	IF (a <= b) THEN SET retValue = a;
	ELSE SET retValue = b;
	END IF;
	RETURN retValue;
END $$
DELIMITER ;

-- dati due insiemi A = (x1a; x2a) e B controlla che non si sovrappongano
-- la sovrapposizione al vertice non viene considerata
-- retBit = 0 -> non c'è sovrapposizione
-- retBit = 1 -> c'è sovrapposizione
DROP FUNCTION IF EXISTS insiemiSovrapposti;
DELIMITER $$
CREATE FUNCTION insiemiSovrapposti(x1A FLOAT, x2A FLOAT, x1B FLOAT, x2B FLOAT)
RETURNS BIT DETERMINISTIC
BEGIN
	DECLARE retBit FLOAT DEFAULT 0;
	IF ((min_(x1A, x2A) < min_(x1B, x2B)) AND (min_(x1B, x2B) < max_(x1A, x2A))) THEN
		SET retBit = 1;
	ELSEIF ((min_(x1B, x2B) < min_(x1A, x2A)) AND (min_(x1A, x2A) < max_(x1B, x2B))) THEN
		SET retBit = 1;
	END IF;
	RETURN retBit;
END $$
DELIMITER ;

-- dati due muri controlla che non si intersechino
-- l'intersezione al vertice non viene considerata
-- retBit = 0 -> non c'è intersezione
-- retBit = 1 -> c'è intersezione
DROP FUNCTION IF EXISTS intersezione;
DELIMITER $$
CREATE FUNCTION intersezione(
	x1A FLOAT, y1A FLOAT, x2A FLOAT, y2A FLOAT, 
	x1B FLOAT, y1B FLOAT, x2B FLOAT, y2B FLOAT)
RETURNS BIT DETERMINISTIC
BEGIN
	DECLARE retBit BIT DEFAULT 0;
	DECLARE mA FLOAT;
	DECLARE mB FLOAT;
	DECLARE qA FLOAT;
	DECLARE qB FLOAT;
	DECLARE xi FLOAT; -- xIntersezione
	DECLARE yi FLOAT; -- yIntersezione
	
	IF (x2A = x1A OR x2B = x1B) THEN
		CASE
			WHEN (x2A = x1A AND x2B = x1B) THEN
				IF (x1A = x1B AND insiemiSovrapposti(y1A, y2A, y1B, y2B) = 1) THEN SET retBit = 1; END IF;
			WHEN (x2A = x1A AND x2B <> x1B) THEN
				SET mB = (y2B - y1B) / (x2B - x1B);
				SET qB = y1B - (x1B * mB);
				SET yi = mB * x1A + qB;
				IF (min_(y1A, y2A) < yi AND yi < max_(y1A, y2A) AND min_(x1B, x2B) < x1A AND x1A < max_(x1B, x2B)) THEN SET retBit = 1; END IF;
			WHEN (x2A <> x1A AND x2B = x1B) THEN
				SET mA = (y2A - y1A) / (x2A - x1A);
				SET qA = y1A - (x1A * mA);
				SET yi = mA * x1B + qA;
				IF (min_(y1B, y2B) < yi AND yi < max_(y1B, y2B) AND min_(x1A, x2A) < x1B AND x1B < max_(x1A, x2A)) THEN SET retBit = 1; END IF;
		END CASE;
	ELSE
		SET mA = (y2A - y1A) / (x2A - x1A);
		SET mB = (y2B - y1B) / (x2B - x1B);
		SET qA = y1A - (x1A * mA);
		SET qB = y1B - (x1B * mB);

		IF (mA = mB) THEN -- rette parallele
			IF (qA = qB AND insiemiSovrapposti(x1A, x2A, x1B, x2B) = 1) THEN 
				SET retBit = 1;
			END IF;
			-- rette parallele non coincidenti non hanno mai intersezioni
		ELSE
			SET xi = (qB - qA) / (mA - mB);
			IF ( (min_(x1A, x2A) < xi AND max_(x1A, x2A) > xi) AND (min_(x1B, x2B) < xi AND max_(x1B, x2B) > xi) )
				THEN SET retBit = 1; END IF;
		END IF;
	END IF;

	RETURN retBit;
END $$
DELIMITER ;

-- ===================================================
-- ====  Controllo intersezione Muri  ================
-- ===================================================
-- controlla che il nuovo muro non intersechi muri sdello stesso piano
-- ovviamente vanno bene intersezioni ai vertici
DROP PROCEDURE IF EXISTS checkIntersezioneMuri;
DELIMITER $$
CREATE PROCEDURE checkIntersezioneMuri( IN _Vano INT, IN _Muro INT)
BEGIN
	DECLARE finito BIT DEFAULT 0;
	DECLARE x1a_ FLOAT;
	DECLARE y1a_ FLOAT;
	DECLARE x2a_ FLOAT;
	DECLARE y2a_ FLOAT;
	DECLARE x1b_ FLOAT;
	DECLARE y1b_ FLOAT;
	DECLARE x2b_ FLOAT;
	DECLARE y2b_ FLOAT;

	DECLARE cursoreMuri CURSOR FOR
	SELECT M.X1, M.Y1, M.X2, M.Y2
	FROM Muro M
		INNER JOIN Delimitazione D ON M.idMuro = D.Muro
		INNER JOIN Vano V ON D.Vano = V.idVano
		INNER JOIN Vano V2 ON V.Piano = V2.Piano
	WHERE V2.idVano = _Vano AND M.idMuro <> _Muro;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
	
	SELECT M.X1, M.Y1, M.X2, M.Y2
	INTO x1a_, y1a_, x2a_, y2a_
	FROM Muro M WHERE M.idMuro = _Muro;

	OPEN cursoreMuri;
	ciclo: LOOP
		FETCH cursoreMuri INTO x1b_, y1b_,x2b_, y2b_;
		IF (finito = 1) THEN LEAVE ciclo; END IF;
		IF (1 = intersezione(x1a_, y1a_, x2a_, y2a_, x1b_, y1b_, x2b_, y2b_)) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Muro si interseca con altri muri dello stesso piano';
			LEAVE ciclo;
		END IF;
	END LOOP;
	CLOSE cursoreMuri;
END $$
DELIMITER ;
-- ===================================================
-- =========  Calcolo dimensioni vano  ===============
-- ===================================================
-- calcola le dimensioni del vano,
-- intese come il parallelepipedo in cui è contenuto
DROP PROCEDURE IF EXISTS calculateDimVano;
DELIMITER $$
CREATE PROCEDURE calculateDimVano(IN _Vano INT)
BEGIN
	DECLARE altezza_, larghezza_, lunghezza_ FLOAT;
	WITH
    minMax1 as (
		SELECT
			max(M.X1) as maxX1,
			max(M.X2) as maxX2,
			max(M.Y1) as maxY1,
			max(M.Y2) as maxY2,
			min(M.X1) as minX1,
			min(M.X2) as minX2,
			min(M.Y1) as minY1,
			min(M.Y2) as minY2,
			max(M.Altezza) as maxAltezza
		FROM Muro M
		WHERE M.idMuro IN (
			SELECT D.Muro
			FROM Delimitazione D
			WHERE D.Vano = _Vano)),
	minMax2 as (
		SELECT
			IF(maxX1 >= maxX2, maxX1, maxX2) AS maxX,
			IF(maxY1 >= maxY2, maxY1, maxY2) AS maxY,
			IF(minX1 <= minX2, minX1, minX2) AS minX,
			IF(minY1 <= minY2, minY1, minY2) AS minY,
			maxAltezza
            FROM minMax1)
	SELECT
		maxX - minX, maxY - minY, maxAltezza
	INTO larghezza_, lunghezza_, altezza_
	FROM minMax2;

	UPDATE Vano V
	SET
		V.Altezza = altezza_,
        V.Larghezza = larghezza_,
        V.Lunghezza = lunghezza_
	WHERE V.idVano = _Vano;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS checkAperturaMuro;
DELIMITER $$
CREATE PROCEDURE checkAperturaMuro(
	IN _AM INT, 
    IN _Muro INT, 
    IN Altezza_ FLOAT, 
    IN AltezzaDaTerra_ FLOAT, 
    IN Larghezza_ FLOAT, 
    IN DistanzaMuro_ FLOAT, 
    IN TipoAccesso_ VARCHAR(50), 
    IN puntoCardinale_ VARCHAR(2))
BEGIN
	DECLARE AltezzaMuro_ INT DEFAULT (SELECT M.Altezza FROM Muro M WHERE M.idMuro = _Muro);
	DECLARE LunghezzaMuro_ INT DEFAULT (SELECT sqrt((M.X2-M.X1)*(M.X2-M.X1) + (M.Y2-M.Y1)*(M.Y2-M.Y1)) FROM Muro M WHERE M.idMuro = _Muro);
	DECLARE MuroInterno_ BIT DEFAULT (SELECT M.Interno FROM Muro M WHERE M.idMuro = _Muro);
	DECLARE deltaX_ FLOAT DEFAULT (SELECT M.X2-M.X1 FROM Muro M WHERE M.idMuro = _Muro);
	DECLARE deltaY_ FLOAT DEFAULT (SELECT M.Y2-M.Y1 FROM Muro M WHERE M.idMuro = _Muro);
	DECLARE m FLOAT;

	-- controllo che le dimensioni non vadano oltre quelle del muro (altezza e lunghezza)
	IF ((Altezza_ + AltezzaDaTerra_ > AltezzaMuro_) OR (Larghezza_ + DistanzaMuro_ > LunghezzaMuro_)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Punto di accesso non compatibile con le dimensioni del muro';
	END IF;
        
    IF(TipoAccesso_ = 'finestra') THEN
		IF(MuroInterno_ = 1) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Punto di accesso non inseribile: non si può inserire una finestra su un muro interno';
		END IF;
    END IF;
    IF(TipoAccesso_ = 'portafinestra') THEN
		IF((SELECT count(*) FROM Balcone B WHERE B.Muro = _Muro) = 0) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Punto di accesso non inseribile: non si può inserire una portafinestra su un muro non legato ad un balcone';
		END IF;
    END IF;

	-- controllo che il punto cardinale puntato dalla finestra/portafinestra sia compatibile con l'orientazione del muro
	IF ( TipoAccesso_ = 'finestra' OR TipoAccesso_ = 'portafinestra') THEN
		
		IF(deltaX_ <> 0) THEN
			SET m = deltaY_ / deltaX_;
			IF ( (m > tan(pi()/8) AND m <= tan(3*pi()/8)) AND puntoCardinale_ <> 'NW' AND puntoCardinale_ <> 'SE') THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Punto cardinale non compatibile con l`orientazione del muro'; END IF;
			IF ( (m > tan(3*pi()/8) AND m <= tan(5*pi()/8)) AND puntoCardinale_ <> 'E' AND puntoCardinale_ <> 'W') THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Punto cardinale non compatibile con l`orientazione del muro'; END IF;
			IF ( (m > tan(5*pi()/8) AND m <= tan(7*pi()/8)) AND puntoCardinale_ <> 'NE' AND puntoCardinale_ <> 'SW') THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Punto cardinale non compatibile con l`orientazione del muro'; END IF;
			IF ( (m > tan(7*pi()/8) AND m <= tan(pi()/8)) AND puntoCardinale_ <> 'N' AND puntoCardinale_ <> 'S') THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Punto cardinale non compatibile con l`orientazione del muro'; END IF;
		ELSE
			-- qui sicuramente il muro è 'verticale' sulla piantina -> è perfettamente sull'asse E-W
			IF(puntoCardinale_ <> 'E' AND puntoCardinale_ <> 'W') THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Punto cardinale non compatibile con l`orientazione del muro';
			END IF;
		END IF;
	END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiorna_Rischio_Area;
DELIMITER $$
CREATE PROCEDURE Aggiorna_Rischio_Area(IN _CAP INT, IN ModifierIdro FLOAT, IN ModifierSisma FLOAT)
BEGIN
	DECLARE current_rischioIdrogeologico FLOAT;
	DECLARE current_rischioSismico FLOAT;
    DECLARE updated_rischioSismico FLOAT;
    DECLARE updated_rischioIdrogeologico FLOAT;

	-- Rischio idrogeologico
	SET current_rischioIdrogeologico = (SELECT RischioIdrogeologico
							FROM Area
							WHERE CAP = _CAP);
	IF current_rischioIdrogeologico + ModifierIdro > 1
	THEN 
		SET updated_rischioIdrogeologico = 1;
	ELSEIF current_rischioIdrogeologico + ModifierIdro < 0
	THEN 
		SET updated_rischioIdrogeologico = 0;
	ELSE
		SET updated_rischioIdrogeologico = current_rischioIdrogeologico + ModifierIdro;
	END IF;
	-- Rischio sismico 
	SET current_rischioSismico = (SELECT RischioSismico
							FROM Area
							WHERE CAP = _CAP);
	IF current_rischioSismico + ModifierSisma > 1
	THEN 
		SET updated_rischioSismico = 1;
	ELSEIF current_rischioSismico + ModifierSisma < 0
	THEN 
		SET updated_rischioSismico = 0;
	ELSE
		SET updated_rischioSismico = current_rischioSismico + ModifierSisma;
		
	END IF;
    UPDATE Area
    SET RischioSismico = updated_rischioSismico,
		RischioIdrogeologico = updated_rischioIdrogeologico
	WHERE CAP = _CAP;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS aggiorna_rischio_aree_confinanti;
DELIMITER $$
CREATE PROCEDURE aggiorna_rischio_aree_confinanti(IN _CAP INT, IN modifierIdro FLOAT, IN modifierSisma FLOAT)
BEGIN
	DECLARE areaConf INT DEFAULT 0;
	DECLARE areaConf1 INT DEFAULT 0;
	DECLARE areaConf2 INT DEFAULT 0;
	DECLARE finito INT DEFAULT 0;
	DECLARE areeConfinanti CURSOR FOR (
										SELECT Area1, Area2
										FROM ConfineAree
										WHERE Area1 = _CAP OR Area2 = _CAP
										);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
	OPEN areeConfinanti;
	aggiornaAree:LOOP
		FETCH areeConfinanti INTO areaConf1, areaConf2;
		IF finito = 1
		THEN LEAVE aggiornaAree;
		END IF;
		IF areaConf1 = _CAP
		THEN SET areaConf = areaConf2;
		ELSE SET areaConf = areaConf1;
		END IF;
		CALL Aggiorna_Rischio_Area(areaConf, modifierIdro, modifierSisma);
        END LOOP;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS ParametriModali;
DELIMITER $$
CREATE PROCEDURE ParametriModali(IN _Edificio INT, OUT parametroModale INT)
BEGIN
	-- scorre tra tutte le calamità (direttamente le date) avvenute nella zona dell'edificio
	DECLARE finito BIT DEFAULT 0;
	DECLARE dataCalamita_ DATE;
	DECLARE gravita_ DATE;
	DECLARE retMedia FLOAT DEFAULT 0;
	DECLARE countCalamita_ INT DEFAULT 0;
	DECLARE reportPrec_, reportSucc_ INT;
	DECLARE statoPrec_ FLOAT DEFAULT 0;
	DECLARE statoSucc_ FLOAT DEFAULT 0;
	DECLARE countMonit INT DEFAULT 0;

	DECLARE cursoreCalamita CURSOR FOR (
		SELECT C.DataEvento, C.Gravita -- , count(*) as calamitaZona
		FROM EventoCalamitoso C NATURAL JOIN Edificio E -- fa il join su Area
		WHERE E.idEdificio = _Edificio AND
			C.Tipo = 'sisma'
		ORDER BY C.DataEvento DESC);

		-- !!!!!!!!{ si fa solo su sisma o anche su altro? }!!!!!!!!

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

	-- controlla la risposta a ogni calamità avventua
		-- si stima la risposta confrontando il peggioramento dello stato con la gravità della calamita
		-- non calcola esattamente lo stato, ma un qualcosa di vagamente simile (stato medio dei muri)
		-- quello che interessa qui è il peggioramento, non il valore in sè
	-- si fa una media dei valori

	OPEN cursoreCalamita;
	cicloCalamita: LOOP
		FETCH cursoreCalamita INTO dataCalamita_, gravita_;
		IF finito = 1 THEN LEAVE cicloCalamita; END IF;
		
		SET reportPrec_ = (SELECT R.idReport FROM Report R
			WHERE R.Edificio = _Edificio AND R.Data_ < dataCalamita
			ORDER BY R.Data_ DESC LIMIT 1);
		SET reportSucc_ = (SELECT R.idReport FROM Report R
			WHERE R.Edificio = _Edificio AND R.Data_ > dataCalamita
			ORDER BY R.Data_ ASC LIMIT 1);

		IF(reportPrec_ IS NULL OR reportSucc_ IS NULL) THEN LEAVE cicloCalamita; END IF;
		SET countCalamita_ = countCalamita_ + 1;

		SELECT IF(count(*) = 0, 2, avg(Stato))
		INTO statoPrec_
		FROM Monitorazione
		WHERE Report = reportPrec_ AND Danno = 'crepa';

		SELECT IF(count(*) = 0, 2, avg(Stato))
		INTO statoSucc_
		FROM Monitorazione
		WHERE Report = reportSucc_ AND Danno = 'crepa';

		SET retMedia = retMedia + RispostaCalamita(_statoSucc - _statoPrec, _Gravita);
	END LOOP;
	CLOSE cursoreCalamita;

	IF(countCalamita_<>0) THEN SET retMedia = retMedia / countCalamita_;
    ELSE SET retMedia = 3;
    END IF;

	-- stimo quindi un parametro modale (resistenza a terremoti)
	 -- 5 ottimo, 4 buono, 3 medio, 2 non buono, 1 pessimo
     CASE
		WHEN retMedia <= 1.5 THEN SET parametroModale = 1;
		WHEN retmedia > 1.5 AND retMedia <= 2.5 THEN SET parametroModale = 2;
		WHEN retmedia > 2.5 AND retMedia <= 3.5 THEN SET parametroModale = 3;
		WHEN retmedia > 3.5 AND retMedia <= 4.5 THEN SET parametroModale = 4;
		WHEN retmedia > 4.5 THEN SET parametroModale = 5;
     END CASE;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS RispostaCalamita;
DELIMITER $$
CREATE FUNCTION RispostaCalamita(_DeltaStato FLOAT, _Gravita INT)
RETURNS INT DETERMINISTIC

BEGIN
	-- confronto peggioramento dello stato con la gravità della calamita
	/*
	gravita va da 1 a 10 compresi (10 valori)
	stato da 0 a 5 (6 valori)
	*/
	-- stimo quindi un parametro modale (resistenza a terremoti)
	 -- 5 ottimo, 4 buono, 3 medio, 2 non buono, 1 pessimo
	DECLARE PM INT;
	DECLARE pm2 INT;
	SET pm2 = _DeltaStato * 2 - _Gravita;
	CASE
		WHEN pm2 > 3 THEN SET PM = 1;
		WHEN pm2 <= 3 AND pm2 > 1 THEN SET PM = 2;
		WHEN pm2 <= 1 AND pm2 >= -1 THEN SET PM = 3;
		WHEN pm2 < -1 AND pm2 >= -3 THEN SET PM = 4;
		WHEN pm2 < -3 THEN SET PM = 5;
	END CASE;
	RETURN PM;
END $$
DELIMITER ;
-- aggiunge un nuovo sensore
-- aggiunge anche y e z se accelerometro

DROP PROCEDURE IF EXISTS Aggiungi_Sensore;
DELIMITER $$
CREATE PROCEDURE Aggiungi_Sensore(
	IN _muro INT,
	IN _tipo VARCHAR(50),
	IN _soglia FLOAT,
	IN _valMinimo FLOAT,
	IN _valMassimo FLOAT,
	IN _distanzaOrigineMuro FLOAT,
	IN _altezzaDaTerra FLOAT
	)
BEGIN
	INSERT INTO Sensore(Muro, Tipo, Soglia, valMinimo, valMassimo, DistanzaOrigineMuro, AltezzaDaTerra)
	VALUES(_muro, _tipo, _soglia, _valMinimo, _valMassimo, _distanzaOrigineMuro, _altezzaDaTerra);
	IF (_tipo = 'accelerometro' OR _tipo = 'giroscopio') THEN
		INSERT INTO Sensore(Muro, Tipo, Soglia, valMinimo, valMassimo, DistanzaOrigineMuro, AltezzaDaTerra, Asse)
		VALUES(_muro, _tipo, _soglia, _valMinimo, _valMassimo, _distanzaOrigineMuro, _altezzaDaTerra, 'y');
		INSERT INTO Sensore(Muro, Tipo, Soglia, valMinimo, valMassimo, DistanzaOrigineMuro, AltezzaDaTerra, Asse)
		VALUES(_muro, _tipo, _soglia, _valMinimo, _valMassimo, _distanzaOrigineMuro, _altezzaDaTerra, 'z');
	END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS InserimentoRegistrazioneCampionamento;
DELIMITER $$
CREATE PROCEDURE InserimentoRegistrazioneCampionamento(IN _Registrazione INT, IN _Edificio INT)
BEGIN
	DECLARE _campionamento INTEGER DEFAULT 0;
	DECLARE _sensore INTEGER DEFAULT 0;
	DECLARE finito INTEGER DEFAULT 0;

	-- prende tutti i campionamenti più recenti dei sensori del'edificio specificato
	DECLARE cursoreCampionamenti CURSOR FOR(
		SELECT C.numCampionamento, C.Sensore
		FROM Campionamento C
			INNER JOIN Sensore S ON S.codSensore = C.Sensore
			INNER JOIN Muro M ON M.idMuro = S.Muro
		WHERE M.Edificio = _Edificio
			AND C.Data_ > ALL(
				SELECT C1.Data_
				FROM Campionamento C1
				WHERE C1.Data_ <> C.Data_
					AND C1.Sensore = C.Sensore));

	DECLARE CONTINUE HANDLER 
	FOR NOT FOUND SET finito = 1;

	OPEN cursoreCampionamenti;

	preleva: LOOP
		FETCH cursoreCampionamenti INTO _campionamento, _sensore;
		IF finito = 1
		THEN LEAVE preleva;
		END IF;
		INSERT INTO RegistrazioneCampionamenti(Campionamento, Sensore, Registrazione, Edificio) VALUES (_campionamento, _sensore, _Registrazione, _Edificio);
	END LOOP;
    
    CLOSE cursoreCampionamenti;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS consigli_di_intervento_edificio_Stato;
DELIMITER $$
CREATE PROCEDURE consigli_di_intervento_edificio_Stato(IN _report INT)
BEGIN
	DECLARE edificio INT DEFAULT ( SELECT Edificio FROM Report WHERE idReport = _report );
	DECLARE stato_ VARCHAR(50) DEFAULT (
					SELECT Stato
					FROM Edificio
					WHERE idEdificio = edificio
					);
	DECLARE idNuovoLavoro INT DEFAULT ( SELECT IF(idLavoro IS NULL, 1, MAX(idLavoro) + 1) FROM Lavoro );
    DECLARE descrizione_ VARCHAR(300) DEFAULT '';
    DECLARE urgenza_ INT DEFAULT 1;
	
	CASE
		WHEN stato_ = 'perfetto' THEN
			SET descrizione_ = '';
		WHEN stato_ = 'ottimo' THEN
			SET descrizione_ = 'Lavori di mautenzione ordinaria (p.e.: pitture, stuccature). ';
		WHEN stato_ = 'buono' THEN
			SET descrizione_ = 'Lavori di estetica non strutturale di manutenzione straordinaria (p.e. rifacimento intonaci)';
		WHEN stato_ = 'non sicuro' THEN
			SET descrizione_ = 'Ristrutturazione: consolidamenti strutturali e piccole opere accessorie. ';
			SET urgenza_ = 2;
		WHEN stato_ = 'rischioso' THEN
			SET descrizione_ = 'Ristrutturazione profonda con aggiunta di elementi consolidanti pesanti. ';
			SET urgenza_ = 3;
		WHEN stato_ = 'pericolante' THEN
			SET descrizione_ = 'Ricostruzione di parti intere dell`edificio. ';
			SET urgenza_ = 3;
	END CASE;
    
	INSERT INTO Lavoro(idLavoro, Descrizione, Costo)
		VALUES (idNuovoLavoro, descrizione_, 0);
	INSERT INTO ConsiglioIntervento(Lavoro, Report, Urgenza)
		VALUES (idNuovoLavoro, _report, urgenza_);

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS consigli_di_intervento_edificio_Salubrita;
DELIMITER $$
CREATE PROCEDURE consigli_di_intervento_edificio_Salubrita(IN _report INT)
BEGIN
	DECLARE edificio INT DEFAULT ( SELECT Edificio FROM Report WHERE idReport = _report );
	DECLARE salubrita_ VARCHAR(50) DEFAULT (
					SELECT Salubrita
					FROM Edificio
					WHERE idEdificio = edificio
					);
	DECLARE idNuovoLavoro INT DEFAULT ( SELECT IF(idLavoro IS NULL, 1, MAX(idLavoro) + 1) FROM Lavoro );
    DECLARE descrizione_ VARCHAR(300) DEFAULT '';
    DECLARE urgenza_ INT DEFAULT 1;
	CASE
		WHEN salubrita_ = 'salubre' THEN 
			SET descrizione_ = '';
		WHEN salubrita_ = 'leggermente insalubre' THEN 
			SET descrizione_ = 'Verifica del tipo di infiltrazione e del punto dell`edificio dove si sono originate.';
		WHEN salubrita_ = 'insalubre' THEN 
			SET descrizione_ = 'Verifica del tipo di infiltrazione e del punto dell`edificio dove si sono originate.';
			SET urgenza_ = 2;
		WHEN salubrita_ = 'totalmente insalubre' THEN 
			SET descrizione_ = 'Radicale risanamento dell`edificio o di intere parti di esso.';
			SET urgenza_ = 3;
	END CASE;
    
	INSERT INTO Lavoro(idLavoro, Descrizione, Costo)
		VALUES (idNuovoLavoro, descrizione_, 0);
	INSERT INTO ConsiglioIntervento(Lavoro, Report, Urgenza)
		VALUES (idNuovoLavoro, _report, urgenza_);

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS generaConsigliInterventoReport;
DELIMITER $$
CREATE PROCEDURE generaConsigliInterventoReport(IN _Report INT)
BEGIN
		-- genero una pk nota valida per il nuovo lavoro
	DECLARE pk_ INT DEFAULT (SELECT IF(count(*)=0, 1, MAX(idLavoro) + 1) FROM Lavoro);
	DECLARE intervento_Fondamenta BIT DEFAULT 0;
	DECLARE intervento_Solai BIT DEFAULT 0;
	DECLARE intervento_InfiltrazioneTerra BIT DEFAULT 0;
	DECLARE intervento_UmiditaPianoTerra_Grave BIT DEFAULT 0;
	DECLARE intervento_UmiditaPianoTerra_Medio_MuroEsterno BIT DEFAULT 0;
	-- infiltrazioni Solai => cerco infiltrazioni all'ultimo piano
	SET intervento_Solai = (
		SELECT IF(count(*) = 0, 0, 1)
		FROM Monitorazione M -- (rep, muro , stato , danno)
			INNER JOIN Muro Mu ON M.Muro = Mu.idMuro 
			INNER JOIN Edificio E ON Mu.Edificio = E.idEdificio 
			INNER JOIN Piano P ON E.idEdificio = P.Edificio
		WHERE M.Report = _Report 
			AND M.Danno = 'infiltrazione'
			AND M.Stato > 2
			AND P.NumeroPiano = E.NumeroPiani - 1);
	IF (intervento_Solai = 1 AND 'Verifica del manto di copertura nei vari livelli' NOT IN (
			SELECT L.descrizione
            FROM Lavoro L
				INNER JOIN consigliointervento CI ON L.idLavoro = CI.Lavoro
                INNER JOIN Report R ON CI.Report = R.idReport
                INNER JOIN Report R2 ON R.Edificio = R2.Edificio
			WHERE R2.idReport = _Report)) THEN
		INSERT INTO Lavoro(idLavoro, Descrizione, Costo) VALUES(pk_, 'Verifica del manto di copertura nei vari livelli', 0);
		INSERT INTO ConsiglioIntervento(Lavoro, Report, Urgenza) VALUES(pk_, _Report, 1);
	END IF;

			
	-- infiltrazione piano terra estrema
	SET intervento_InfiltrazioneTerra = (
		SELECT IF(count(*) = 0, 0, 1)
		FROM Monitorazione M -- (rep, muro , stato , danno)
			INNER JOIN Muro Mu ON M.Muro = Mu.idMuro 
			INNER JOIN Piano P ON Mu.Edificio = P.Edificio
		WHERE M.Report = _Report 
			AND M.Danno = 'infiltrazione'
			AND M.Stato = 5
			AND P.NumeroPiano = 0);
	IF (intervento_InfiltrazioneTerra = 1 AND 'Realizzazione di pozzetto di raccolta in un punto adeguato con pompa e galleggiante automatico per l`eliminazione continua' NOT IN (
			SELECT L.descrizione
            FROM Lavoro L
				INNER JOIN consigliointervento CI ON L.idLavoro = CI.Lavoro
                INNER JOIN Report R ON CI.Report = R.idReport
                INNER JOIN Report R2 ON R.Edificio = R2.Edificio
			WHERE R2.idReport = _Report)) THEN
		SET pk_ = pk_+1;
		INSERT INTO Lavoro(idLavoro, Descrizione, Costo) VALUES(pk_, 'Realizzazione di pozzetto di raccolta in un punto adeguato con pompa e galleggiante automatico per l`eliminazione continua', 0);
		INSERT INTO ConsiglioIntervento(Lavoro, Report, Urgenza) VALUES(pk_, _Report, 3);
	END IF;
		

	SET intervento_UmiditaPianoTerra_Grave = (
		SELECT IF(count(*) = 0, 0, 1)
		FROM Monitorazione M -- (rep, muro , stato , danno)
			INNER JOIN Muro Mu ON M.Muro = Mu.idMuro 
			INNER JOIN Piano P ON Mu.Edificio = P.Edificio
		WHERE M.Report = _Report 
			AND M.Danno = 'umidità capillare'
			AND M.Stato = 5
			AND P.NumeroPiano = 0);
	IF (intervento_UmiditaPianoTerra_Grave = 1 AND 'Eventuale taglio delle murature alla base e/o realizzazione ove possibile di scannafosso, rifacimento intonaco' NOT IN (
			SELECT L.descrizione
            FROM Lavoro L
				INNER JOIN consigliointervento CI ON L.idLavoro = CI.Lavoro
                INNER JOIN Report R ON CI.Report = R.idReport
                INNER JOIN Report R2 ON R.Edificio = R2.Edificio
			WHERE R2.idReport = _Report)) THEN
		SET pk_ = pk_+1;
		INSERT INTO Lavoro(idLavoro, Descrizione, Costo)  VALUES(pk_, 'Eventuale taglio delle murature alla base e/o realizzazione ove possibile di scannafosso, rifacimento intonaco', 0);
		INSERT INTO ConsiglioIntervento(Lavoro, Report, Urgenza) VALUES(pk_, _Report, 3);
	END IF;


	SET intervento_UmiditaPianoTerra_Medio_MuroEsterno = (
		SELECT IF(count(*) = 0, 0, 1)
		FROM Monitorazione M -- (rep, muro , stato , danno)
			INNER JOIN Muro Mu ON M.Muro = Mu.idMuro 
			INNER JOIN Piano P ON Mu.Edificio = P.Edificio
		WHERE M.Report = _Report 
			AND M.Danno = 'umidità capillare'
			AND M.Stato > 2 AND Stato < 5
			AND P.NumeroPiano = 0
			AND Mu.Interno = 0);
	IF (intervento_UmiditaPianoTerra_Medio_MuroEsterno = 1 AND 'Rimuovere intonaco esterno nella fascia bassa e rifacimento dell`intonaco interno con prodotti specifici per una fascia di altezza adeguata' NOT IN (
			SELECT L.descrizione
            FROM Lavoro L
				INNER JOIN consigliointervento CI ON L.idLavoro = CI.Lavoro
                INNER JOIN Report R ON CI.Report = R.idReport
                INNER JOIN Report R2 ON R.Edificio = R2.Edificio
			WHERE R2.idReport = _Report)) THEN
		SET pk_ = pk_+1;
		INSERT INTO Lavoro(idLavoro, Descrizione, Costo)  VALUES(pk_, 'Rimuovere intonaco esterno nella fascia bassa e rifacimento dell`intonaco interno con prodotti specifici per una fascia di altezza adeguata', 0);
		INSERT INTO ConsiglioIntervento(Lavoro, Report, Urgenza) VALUES(pk_, _Report, 2);
	END IF;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS InserimentoMonitorazioneSP;
DELIMITER $$
CREATE PROCEDURE InserimentoMonitorazioneSP(IN _Report INT, IN _Registrazione INT, IN _Edificio INT)
BEGIN
	DECLARE Finito INTEGER DEFAULT 0;
	DECLARE _campionamento INTEGER;
	DECLARE _sensore INTEGER;
	DECLARE _tipo VARCHAR(50);
	DECLARE _currentValoreMisurato FLOAT;
	DECLARE _danno VARCHAR(50);
	DECLARE _soglia FLOAT;
	DECLARE _valMin FLOAT;
	DECLARE _valMax FLOAT;
	DECLARE _stato INT;
	DECLARE _muro INTEGER;
	-- prendi tutti i campionamenti da registrazioneCampionamenti, con registrazione legata all'istanza di report
	DECLARE cursoreCampionamenti CURSOR FOR (
									SELECT RC.Campionamento, RC.Sensore 
									FROM RegistrazioneCampionamenti RC
									WHERE RC.Registrazione = _Registrazione
										AND RC.Edificio = _Edificio);

	DECLARE CONTINUE HANDLER
	FOR NOT FOUND SET Finito = 1;

	OPEN cursoreCampionamenti;

	-- per ogni campionamento inserisci in monitorazione 
	preleva: LOOP
		FETCH cursoreCampionamenti INTO _campionamento, _sensore;
		IF Finito = 1
		THEN LEAVE preleva;
		END IF;
	-- tipo di danno dal sensore 
		SET _tipo = (SELECT Tipo FROM Sensore WHERE codSensore = _sensore);
        IF _tipo = 'fessurimetro' OR _tipo = 'rilevatore di umidità' OR _tipo = 'rilevatore di infiltrazioni' THEN
			SET _currentValoreMisurato = (SELECT valMisurato FROM Campionamento WHERE _campionamento = numCampionamento AND _sensore = Sensore);
			SET _soglia = (SELECT Soglia FROM Sensore WHERE codSensore = _sensore);
			SET _valMin = (SELECT valMinimo FROM Sensore WHERE codSensore = _sensore);
			SET _valMax = (SELECT valMassimo FROM Sensore WHERE codSensore = _sensore);
			SET _muro = (SELECT Muro FROM Sensore WHERE codSensore = _sensore);
			IF _tipo = 'fessurimetro' THEN SET _danno = 'crepa';
			ELSEIF _tipo = 'rilevatore di umidità' THEN SET _danno = 'umidità capillare';
			ELSE SET _danno = 'infiltrazione';
			END IF;

		-- stato del danno valore misurato rispetto a max, min e soglia
			IF _currentValoreMisurato > _valMin AND _currentValoreMisurato <= (_soglia - _valMin) / 3
			THEN 
				SET _stato = 0;
				SET _danno = 'nessuno';

			ELSEIF _currentValoreMisurato > (_soglia - _valMin) / 3 AND _currentValoreMisurato <= (_soglia - _valMin) * 2 / 3
			THEN SET _stato = 1;
			ELSEIF _currentValoreMisurato > (_soglia - _valMin) * 2 / 3 AND _currentValoreMisurato <= _soglia
			THEN SET _stato = 2;
			ELSEIF _currentValoreMisurato > _soglia AND _currentValoreMisurato <= (_valMax - _soglia) / 3 + _soglia
			THEN SET _stato = 3;
			ELSEIF _currentValoreMisurato > (_valMax - _soglia) / 3  + _soglia AND _currentValoreMisurato <= (_valMax - _soglia) * 2 / 3  + _soglia
			THEN SET _stato = 4;
			ELSE SET _stato = 5;
			END IF;
			INSERT INTO Monitorazione VALUES (_Report, _muro, _stato, _danno);
        END IF;
	END LOOP;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS AggiornaStatoEdificioSp;
DELIMITER $$
CREATE PROCEDURE AggiornaStatoEdificioSp(
	IN _muro INT, 
    IN _statoMuro INT, 
    IN _dannoMuro VARCHAR(50), 
    OUT _OLDStato VARCHAR(50), 
    OUT _NEWStato VARCHAR(50), 
    OUT _OLDSalubrita VARCHAR(50), 
    OUT _NEWSalubrita VARCHAR(50)) 
BEGIN
	DECLARE statoEdificio_ VARCHAR(50) DEFAULT '';
	DECLARE salubritaEdificio_ VARCHAR(50) DEFAULT '';
	DECLARE idEdificio_ INT DEFAULT 0;
	SET idEdificio_ = (
					SELECT E.idEdificio 
					FROM Edificio E
					INNER JOIN Muro M
					ON E.idEdificio = M.Edificio
					WHERE M.idMuro = _muro
					);
	SET statoEdificio_ = (
						SELECT Stato FROM Edificio E
						WHERE E.idEdificio = idEdificio_
						);
	SET salubritaEdificio_ = (
							SELECT Salubrita FROM Edificio E
							WHERE E.idEdificio = idEdificio_
							);
	SET _OLDStato = statoEdificio_;
	SET _OLDSalubrita = salubritaEdificio_;
	IF _dannoMuro = 'crepa' 
	THEN
		IF statoEdificio_ = 'perfetto'
		THEN IF _statoMuro = 1 OR _statoMuro = 2
			THEN SET statoEdificio_ = 'ottimo';
			ELSEIF _statoMuro = 4 OR _statoMuro = 3
			THEN SET statoEdificio_ = 'buono';
			ELSEIF _statoMuro = 5
			THEN SET statoEdificio_ = 'non sicuro';
			END IF;
		ELSEIF statoEdificio_ = 'ottimo'
		THEN IF _statoMuro = 2 OR _statoMuro = 3
			THEN SET statoEdificio_ = 'buono';
			ELSEIF _statoMuro = 4
			THEN SET statoEdificio_ = 'non sicuro';
			ELSEIF _statoMuro = 5
			THEN SET statoEdificio_ = 'rischioso';
			END IF;
		ELSEIF statoEdificio_ = 'buono'
		THEN IF _statoMuro = 3 OR _statoMuro = 4
			THEN SET statoEdificio_ = 'non sicuro';
			ELSEIF _statoMuro = 5
			THEN SET statoEdificio_ = 'rischioso';
			END IF;
		ELSEIF statoEdificio_ = 'non sicuro'
		THEN IF _statoMuro = 4
			THEN SET statoEdificio_ = 'rischioso';
			ELSEIF _statoMuro = 5
			THEN SET statoEdificio_ = 'pericolante';
			END IF;
		ELSE IF _statoMuro = 5
			THEN SET statoEdificio_ = 'pericolante';
			END IF;
		END IF;
	ELSE
		IF salubritaEdificio_ = 'salubre'
		THEN IF _statoMuro = 3
			THEN SET salubritaEdificio_ = 'leggermente insalubre';
			ELSEIF _statoMuro = 4 OR _statoMuro = 5
			THEN SET salubritaEdificio_ = 'insalubre';
			END IF;
		ELSEIF salubritaEdificio_ = 'leggermente insalubre'
		THEN IF _statoMuro = 5 OR _statoMuro = 4
			THEN SET salubritaEdificio_ = 'insalubre';
			END IF;
		ELSE IF _statoMuro = 5
			THEN SET salubritaEdificio_ = 'totalmente insalubre';
			END IF;
		END IF;
	END IF;
	SET _NEWStato = statoEdificio_;
	SET _NEWSalubrita = salubritaEdificio_;
	UPDATE Edificio 
	SET Stato = statoEdificio_,
		Salubrita = salubritaEdificio_
	WHERE idEdificio = idEdificio_;

END $$
DELIMITER ;

DROP FUNCTION IF EXISTS statoPeggiorato;
DELIMITER $$
CREATE FUNCTION statoPeggiorato(OLDstato VARCHAR(50), NEWstato VARCHAR(50))
RETURNS BIT DETERMINISTIC
BEGIN
	IF OLDstato <> NEWstato THEN
		CASE OLDstato
			WHEN 'ottimo' THEN IF NEWstato <> 'perfetto'
				THEN RETURN 1; END IF;
			WHEN 'buono' THEN IF (NEWstato <> 'perfetto' AND NEWstato <> 'ottimo')
				THEN RETURN 1; END IF;
			WHEN 'non sicuro' THEN IF (NEWstato = 'rischioso' OR NEWstato = 'pericolante')
				THEN RETURN 1; END IF;
			WHEN 'rischioso' THEN IF NEWstato = 'pericolante'
				THEN RETURN 1; END IF;
			ELSE 
				RETURN 0;
		END CASE;
	ELSE RETURN 0;
    END IF;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS salubritaPeggiorata;
DELIMITER $$
CREATE FUNCTION salubritaPeggiorata(OLDSalubrita VARCHAR(50), NEWSalubrita VARCHAR(50))
RETURNS BIT DETERMINISTIC
BEGIN
	IF NEWSalubrita <> OLDSalubrita THEN
		CASE OLDSalubrita
			WHEN 'leggermente insalubre' THEN IF NEWSalubrita <> 'salubre'
				THEN RETURN 1; END IF;
			WHEN 'insalubre' THEN IF NEWSalubrita = 'totalmente insalubre'
				THEN RETURN 1; END IF;
			ELSE RETURN 0;
		END CASE;
	ELSE RETURN 0;
    END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiungi_Pietra;
DELIMITER $$
CREATE PROCEDURE Aggiungi_Pietra(IN _costo INT, IN _peso INT, IN _tipo VARCHAR(50))
BEGIN
	INSERT INTO Pietra(CostoKG, PesoMedio, Tipo) 
		VALUES(_costo,_peso, _tipo);
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiungi_Parquet;
DELIMITER $$
CREATE PROCEDURE Aggiungi_Parquet(IN _costo INT, IN _tipo VARCHAR(50))
BEGIN
	INSERT INTO Parquet_(CostoM2, TipoLegno) VALUES (_costo, _tipo);
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiungi_Intonaco;
DELIMITER $$
CREATE PROCEDURE Aggiungi_Intonaco(IN _costo INT, IN _tipo VARCHAR(50))
BEGIN
	INSERT INTO Intonaco(CostoM2, Tipo) VALUES (_costo, _tipo);
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiungi_Piastrella;
DELIMITER $$
CREATE PROCEDURE Aggiungi_Piastrella(IN _costo INT, IN _lunghezzaLati INT, IN _numLati INT, IN _materiale VARCHAR(50), IN _disegno VARCHAR(50), IN _fuga BIT)
BEGIN
	INSERT INTO Piastrella(CostoM2, LunghezzaLato, NumLati, Materiale, Disegno, Fuga) 
		VALUES (_costo, _lunghezzaLati, _numLati, _materiale, _disegno, _fuga);
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiungi_Mattone;
DELIMITER $$
CREATE PROCEDURE Aggiungi_Mattone(IN _alveoli INT, IN _materiale VARCHAR(50), IN _peso INT, IN _lun INT, IN _lar INT, IN _alt INT, IN _costo INT, IN _isolante BIT)
BEGIN
	IF	NOT EXISTS(
		SELECT *
		FROM Alveoli
		WHERE PercentualeFori = _alveoli)
	THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Non esiste un alveolatura con questa percentuale di fori';
	ELSE
		INSERT INTO Mattone(Alveoli, Materiale, Peso, Lunghezza, Larghezza, Altezza, Costo, Isolante) VALUES(_alveoli, _materiale, _peso, _lun, _lar, _alt, _costo, _isolante);
	END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiungi_Alveolatura;
DELIMITER $$
CREATE PROCEDURE Aggiungi_Alveolatura(IN _PercentualeFori INT, IN _Nome VARCHAR(50))
BEGIN
	INSERT INTO Alveoli(PercentualeFori, Nome) 
		VALUES (_PercentualeFori, _Nome);
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiorna_Costo_PresetMateriale;
DELIMITER $$
CREATE PROCEDURE Aggiorna_Costo_PresetMateriale(IN _costo INT, IN _id INT)
BEGIN
	UPDATE PresetMateriale
	SET CostoPerUnitaDiMisura = _costo
	WHERE codLotto = _id;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiorna_Costo_Pietra;
DELIMITER $$
CREATE PROCEDURE Aggiorna_Costo_Pietra(IN _costo INT, IN _id INT)
BEGIN
	UPDATE Pietra
	SET CostoKG  = _costo
	WHERE idPietra = _id;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiorna_Costo_Intonaco;
DELIMITER $$
CREATE PROCEDURE Aggiorna_Costo_Intonaco(IN _costo INT, IN _id INT)
BEGIN
	UPDATE Intonaco 
	SET CostoM2 = _costo
	WHERE idIntonaco = _id;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiorna_Costo_Parquet;
DELIMITER $$
CREATE PROCEDURE Aggiorna_Costo_Parquet(IN _costo INT, IN _id INT)
BEGIN
	UPDATE Parquet_
	SET CostoM2  = _costo
	WHERE idParquet_ = _id;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS Aggiorna_Costo_Piastrella;
DELIMITER $$
CREATE PROCEDURE Aggiorna_Costo_Piastrella(IN _costo INT, IN _id INT)
BEGIN
	UPDATE Piastrella
	SET CostoM2  = _costo
	WHERE idPiastrella = _id;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS Aggiorna_Costo_Mattone;
DELIMITER $$
CREATE PROCEDURE Aggiorna_Costo_Mattone(IN _costo INT, IN _id INT)
BEGIN
	UPDATE Mattone
	SET Costo  = _costo
	WHERE codMattone = _id;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Messaggio_Errore;
DELIMITER $$
CREATE PROCEDURE Messaggio_Errore()
BEGIN 
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Il materiale che vuoi aggiornare non esiste';
END $$
DELIMITER ;
DROP PROCEDURE IF EXISTS Aggiungi_Preset_3D;
DELIMITER $$
CREATE PROCEDURE Aggiungi_Preset_3D(IN _codice INT, IN _Nome VARCHAR(50), IN _costo INT, IN _dataAcquisto DATE, IN _nomeFornitore VARCHAR(50), IN _lun INT, IN _lar INT, IN _alt INT)
BEGIN
	INSERT INTO PresetMateriale VALUES(_codice, _Nome, _dataAcquisto, _costo, _nomeFornitore, _lun, _lar, _alt);
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiungi_Preset_2D;
DELIMITER $$
CREATE PROCEDURE Aggiungi_Preset_2D(IN _codice INT, IN _Nome VARCHAR(50), IN _costo INT, IN _dataAcquisto DATE, IN _nomeFornitore VARCHAR(50), IN _lun INT, IN _lar INT)
BEGIN
	INSERT INTO PresetMateriale VALUES(_codice, _Nome, _dataAcquisto, _costo, _nomeFornitore, _lun, _lar, NULL);
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiungi_Preset_1D;
DELIMITER $$
CREATE PROCEDURE Aggiungi_Preset_1D(IN _codice INT, IN _Nome VARCHAR(50), IN _costo INT, IN _dataAcquisto DATE, IN _nomeFornitore VARCHAR(50), IN _lun INT)
BEGIN
	INSERT INTO PresetMateriale VALUES(_codice, _Nome, _dataAcquisto, _costo, _nomeFornitore, _lun, NULL, NULL);
END $$
DELIMITER ;
DROP PROCEDURE IF EXISTS Aggiungi_Preset_0D;
DELIMITER $$
CREATE PROCEDURE Aggiungi_Preset_0D(IN _codice INT, IN _Nome VARCHAR(50), IN _costo INT, IN _dataAcquisto DATE, IN _nomeFornitore VARCHAR(50))
BEGIN
	INSERT INTO PresetMateriale VALUES(_codice, _Nome, _dataAcquisto, _costo, _nomeFornitore, NULL, NULL, NULL);
END $$
DELIMITER ;

/*
trigger su alert
se ci sono sufficienti alert simili inserimento evento calamitoso in tot tempo 
se c'è un altro evento nello stesso giorno aumenta gravità
*/

DROP PROCEDURE IF EXISTS checkInserimentoCalamita;
DELIMITER $$
CREATE PROCEDURE checkInserimentoCalamita(IN _campionamento INT, IN _sensore INT, IN _dateTimeAlert DATETIME)
BEGIN
	DECLARE valoreMisurato FLOAT DEFAULT (
							SELECT valMisurato FROM Campionamento
							WHERE numCampionamento = _campionamento
							AND Sensore = _sensore
							);
	/*DECLARE soglia FLOAT DEFAULT(
					SELECT Soglia FROM Sensore
					WHERE codSensore = _sensore
					);*/
	DECLARE tipoSensore VARCHAR(50) DEFAULT(
						SELECT Tipo FROM Sensore
						WHERE codSensore = _sensore
						);
	DECLARE area INT DEFAULT(
					SELECT E.Area 
					FROM Edificio E 
					INNER JOIN Muro M
					ON E.idEdificio = M.Edificio
					INNER JOIN Sensore S
					ON S.Muro = M.idMuro
					WHERE S.codSensore = _sensore
					);
	DECLARE valMis FLOAT DEFAULT (
		SELECT valMisurato 
		FROM Campionamento 
		WHERE numCampionamento = _campionamento AND Sensore = _sensore);
	DECLARE valMin FLOAT DEFAULT ( SELECT valMinimo FROM Sensore WHERE codSensore = _sensore);
	DECLARE soglia_ FLOAT DEFAULT ( SELECT soglia FROM Sensore WHERE codSensore = _sensore);
	DECLARE tipoCalamita VARCHAR(100) DEFAULT getTipoCalamita(tipoSensore);
	DECLARE dataAlert DATE DEFAULT CAST(_dateTimeAlert AS DATE);
    DECLARE idCalamita INT DEFAULT ( SELECT IF(count(*)=0, 1, MAX(idCalamita)+1) FROM EventoCalamitoso);
	IF tipoSensore = 'termometro' THEN
		IF (abs(valMin - valMis) <= soglia_) THEN SET tipoCalamita = CONCAT(tipoCalamita, 'freddo');
		ELSE SET tipoCalamita = CONCAT(tipoCalamita, 'caldo'); END IF;
	END IF;
	IF tipoCalamita <> ''
	THEN 
		IF (
			SELECT COUNT(*) FROM EventoCalamitoso
			WHERE Tipo = tipoCalamita
			AND DataEvento = dataAlert
			) > 0
		THEN IF (
				SELECT (COUNT(*) - 10) % 3 FROM Alert A
				INNER JOIN Sensore S ON S.codSensore = A.Sensore
				INNER JOIN Campionamento C ON C.numCampionamento = A.Campionamento
				INNER JOIN Muro M ON M.idMuro = S.Muro
				INNER JOIN Edificio E ON E.idEdificio = M.Edificio
				WHERE S.Tipo = tipoSensore AND (C.ValMisurato > valoreMisurato - 0.5 AND C.ValMisurato < valoreMisurato + 0.5)
				AND CAST(C.Data_ AS DATE) = dataAlert AND E.Area = area
			) = 0
			THEN	
				UPDATE EventoCalamitoso
				SET Gravita = Gravita + 1
				WHERE Tipo = tipoCalamita
				AND DataEvento = dataAlert AND Gravita < 10;
			END IF;
		ELSE
			IF(
				SELECT COUNT(*) FROM Alert A
				INNER JOIN Sensore S ON S.codSensore = A.Sensore
				INNER JOIN Campionamento C ON C.numCampionamento = A.Campionamento
				WHERE S.Tipo = tipoSensore AND (C.ValMisurato > valoreMisurato - 0.5 AND C.ValMisurato < valoreMisurato + 0.5)
				AND C.Data_ > _dateTimeAlert - INTERVAL 10 MINUTE AND C.Data_ < _dateTimeAlert + INTERVAL 10 MINUTE AND A.Sensore = _sensore
			) > 10
			THEN INSERT INTO EventoCalamitoso VALUES(idCalamita, tipoCalamita, dataAlert, 4, area);
			END IF;
		END IF;
	END IF;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS getTipoCalamita;
DELIMITER $$
CREATE FUNCTION getTipoCalamita(tipoSensore VARCHAR(50))
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
	DECLARE returmCalamita VARCHAR(100);
	CASE 
		WHEN tipoSensore = 'pluviometro' THEN SET returmCalamita = 'alluvione';
		WHEN tipoSensore = 'accelerometro' OR tipoSensore = 'giroscopio' THEN SET returmCalamita = 'sisma';
		WHEN tipoSensore = 'rilevatore di infiltrazioni' THEN SET returmCalamita = 'esondazione';
		WHEN tipoSensore = 'termometro' THEN SET returmCalamita = 'ondata di ';
		ELSE SET returmCalamita = '';
	END CASE;
	RETURN returmCalamita;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiorna_Data_Fine_Progetto;
DELIMITER $$
CREATE PROCEDURE Aggiorna_Data_Fine_Progetto(IN _DataFine DATE, IN _id INT)
BEGIN
	IF _DataFine > (
		SELECT P.DataInizio 
		FROM Progetto P
		WHERE P.CodProgetto = _id
		) 
	THEN 
		UPDATE Progetto
		SET DataFine = _DataFine
		WHERE CodProgetto = _id;
	ELSE 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'La data di fine progetto è antecedente alla data di inizio progetto';
	END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Aggiorna_Data_Fine_Stadio;
DELIMITER $$
CREATE PROCEDURE Aggiorna_Data_Fine_Stadio(IN _DataFine DATE, IN _numStadio INT, IN _progetto INT)
BEGIN
	IF _DataFine > (
		SELECT P.DataInizio 
		FROM Stadio S
		WHERE S.numStadio = _numStadio AND S.Progetto = _progetto
		) 
	THEN 
		UPDATE Stadio
		SET DataFine = _DataFine
		WHERE numStadio = _numStadio AND Progetto = _progetto;
	ELSE 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'La data di fine stadio è antecedente alla data di inizio stadio';
	END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS SimulazioneCalamita;
DELIMITER $$
CREATE PROCEDURE SimulazioneCalamita(IN _TipoCalamita VARCHAR(100), IN _Gravita INT, IN _AreaCAP INT)
BEGIN
	DECLARE finito INT DEFAULT 0;
	DECLARE edificio_ INT DEFAULT 0;
    DECLARE countEdifici_ FLOAT DEFAULT (SELECT count(*) FROM Edificio WHERE Area = _AreaCAP);
	DECLARE rispostaMedia, rispostaSingoloEdificio_ FLOAT DEFAULT 0;
	DECLARE idSim_ INT DEFAULT (SELECT IF(count(*)=0,0,max(idSimulazione)+1) FROM simulazionecalamita);
	DECLARE descrizione_ VARCHAR(100);
    DECLARE cursoreEdifici CURSOR FOR (SELECT idEdificio FROM Edificio WHERE Area = _AreaCAP);
    DECLARE cursoreEdifici2 CURSOR FOR (SELECT idEdificio FROM Edificio WHERE Area = _AreaCAP);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
	IF _Gravita > 10 OR _Gravita < 1 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'La gravità della calamita dev`essere compresa tra 1 e 10, estremi inclusi';
    END IF;
	IF NOT EXISTS (SELECT * FROM Area WHERE CAP = _AreaCAP) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Non esiste alcuna area con il CAP specificato';
    END IF;
	IF (_tipoCalamita <> 'sisma' AND _tipoCalamita <> 'alluvione' AND _tipoCalamita <> 'esondazione' AND _tipoCalamita <> 'frana') THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Calamità non supportata da questo database';
    END IF;
    IF (SELECT count(*) FROM EventoCalamitoso WHERE Tipo = _TipoCalamita AND abs(Gravita - _gravita) <= 1 AND Area = _AreaCAP) < 3  THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Numero di calamità di questo tipo con gravità simile non sufficiente a stimare correttamente la risposta';
    END IF;
    IF countEdifici_ < 5 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Numero di edifici non sufficiente a stimare correttamente la risposta alla calamità simulata';
    ELSE SET rispostaMedia = rispostaMedia / countEdifici_;
    END IF;
    
    -- osservo le risposte di tutti gli edifici a tutte le calamità dello stesso tipo con stessa gravita o simile (+- 1)
    -- scalo le risposte medie di ogni edificio per ogni calamita per il loro parametro modale
    -- divido sommatoria per il numero di fattori -> risp media a quella calamita
    OPEN cursoreEdifici;
    loopEdifici: LOOP
		FETCH cursoreEdifici INTO edificio_;
        IF finito = 1 THEN LEAVE loopEdifici; END IF;
        SET rispostaMedia = rispostaMedia + RispostaMediaEdificio(edificio_, _TipoCalamita, _Gravita, 1);
    END LOOP;
    CLOSE cursoreEdifici;
    SET rispostaMedia = rispostaMedia / countEdifici_;
    SET finito = 0;
    
    INSERT INTO simulazionecalamita(idSimulazione, Tipo, Gravita, Area) VALUES(idSim_, _TipoCalamita, _Gravita, _AreaCAP);

    -- pessima 1 <= rispostaMedia <= 5 perfetta
    OPEN cursoreEdifici2;
    loopEdifici2: LOOP
		FETCH cursoreEdifici2 INTO edificio_;
        IF finito = 1 THEN LEAVE loopEdifici2; END IF;
        -- modifico leggermente la risposta media in base all'edificio che sto considerando
        -- la base è la risposta media alla data calamità ma si considera anche la risposta generale del singolo edificio 
        -- (un edificio ben costruito risponderà in media meglio rispetto agli altri e viceversa)
        SET rispostaSingoloEdificio_ = rispostaMedia + ((RispostaMediaEdificio(edificio_, _TipoCalamita, 0, 10) - 3) / 3);
        SET descrizione_ = generaDescrizioneDannoStimato(rispostaSingoloEdificio_, _TipoCalamita);
        INSERT INTO dannistimati(Simulazione, Edificio, Descrizione) VALUES(idSim_, edificio_, descrizione_);
    END LOOP;
    CLOSE cursoreEdifici2;
END $$
DELIMITER ;


DROP FUNCTION IF EXISTS RispostaMediaEdificio;
DELIMITER $$
CREATE FUNCTION RispostaMediaEdificio(_Edificio INT, _TipoCalamita VARCHAR(100), _Gravita INT, err INT)
RETURNS FLOAT DETERMINISTIC
BEGIN
	-- scorre tra tutte le calamità (direttamente le date) avvenute nella zona dell'edificio
	DECLARE finito BIT DEFAULT 0;
	DECLARE dataCalamita_ DATE;
	DECLARE gravita_ INT;
	DECLARE retMedia FLOAT DEFAULT 0;
	DECLARE countCalamita_ FLOAT DEFAULT 0;
	DECLARE reportPrec_, reportSucc_ INT;
	DECLARE statoPrec_ FLOAT DEFAULT 0;
	DECLARE statoSucc_ FLOAT DEFAULT 0;
	DECLARE countMonit INT DEFAULT 0;
    DECLARE parametroModale INT DEFAULT 3;
    DECLARE dannoTarget1, dannoTarget2 VARCHAR(50);

	DECLARE cursoreCalamita CURSOR FOR (
		SELECT C.DataEvento, C.Gravita -- , count(*) as calamitaZona
		FROM EventoCalamitoso C NATURAL JOIN Edificio E -- fa il join su Area
		WHERE E.idEdificio = _Edificio
			AND C.Tipo = _TipoCalamita
			AND abs(Gravita - _gravita) <= err
		ORDER BY C.DataEvento DESC);
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

	CASE
		WHEN _TipoCalamita = 'sisma' OR _TipoCalamita = 'frana' THEN
			SET dannoTarget1 = 'crepa';
            SET dannoTarget2 = 'crepa';
		WHEN _TipoCalamita = 'alluvione'THEN
			SET dannoTarget1 = 'infiltrazione';
            SET dannoTarget2 = 'umidità capillare';
		WHEN _TipoCalamita = 'esondazione'THEN
			SET dannoTarget1 = 'infiltrazione';
            SET dannoTarget2 = 'crepa';
    END CASE;

	-- controlla la risposta a ogni calamità avventua
		-- si stima la risposta confrontando il peggioramento dello stato con la gravità della calamita
		-- non calcola esattamente lo stato, ma un qualcosa di vagamente simile (stato medio dei muri)
		-- quello che interessa qui è il peggioramento, non il valore in sè
	-- si fa una media dei valori

	OPEN cursoreCalamita;
	cicloCalamita: LOOP
		FETCH cursoreCalamita INTO dataCalamita_, gravita_;
		IF finito = 1 THEN LEAVE cicloCalamita; END IF;
		
		SET reportPrec_ = (SELECT R.idReport FROM Report R
			WHERE R.Edificio = _Edificio AND R.Data_ < dataCalamita_
			ORDER BY R.Data_ DESC LIMIT 1);
		SET reportSucc_ = (SELECT R.idReport FROM Report R
			WHERE R.Edificio = _Edificio AND R.Data_ > dataCalamita_
			ORDER BY R.Data_ ASC LIMIT 1);

		IF(reportPrec_ IS NULL OR reportSucc_ IS NULL) THEN LEAVE cicloCalamita; END IF;
		SET countCalamita_ = countCalamita_ + 1;

		SELECT IF(count(*) = 0, 2, avg(Stato))
		INTO statoPrec_
		FROM Monitorazione
		WHERE Report = reportPrec_ AND (Danno = dannoTarget1 OR Danno = dannoTarget2);

		SELECT IF(count(*) = 0, 2, avg(Stato))
		INTO statoSucc_
		FROM Monitorazione
		WHERE Report = reportSucc_ AND (Danno = dannoTarget1 OR Danno = dannoTarget2);

		SET retMedia = retMedia + RispostaCalamita(statoSucc_ - statoPrec_, _Gravita);
	END LOOP;
	CLOSE cursoreCalamita;

	IF countCalamita_ <> 0 THEN SET retMedia = retMedia / countCalamita_;
    ELSE SET retMedia = 3;
    END IF;
    
    RETURN retMedia;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS generaDescrizioneDannoStimato;
DELIMITER $$
CREATE FUNCTION generaDescrizioneDannoStimato(_risp FLOAT, _tipoCalamita VARCHAR(50))
RETURNS VARCHAR(100) DETERMINISTIC
BEGIN
	DECLARE descr VARCHAR(100);
    CASE
	-- 1 -> pessimo
	-- 5 -> ottimo
		WHEN _tipoCalamita = 'sisma' THEN CASE
			WHEN _risp < 1.5 THEN SET descr = 'Crolli in varie parti dell`edificio, anche ad elementi portanti dello stesso';
			WHEN _risp >= 1.5 AND _risp < 2.5 THEN SET descr = 'Probabili crolli, principalmente riguardanti elementi non portanti';
			WHEN _risp >= 2.5 AND _risp < 3.5 THEN SET descr = 'Integrità dell`edificio compromessa, improbabili crolli di grave entità';
			WHEN _risp >= 3.5 AND _risp < 4.5 THEN SET descr = 'Probabile comparsa di crepe lungo i muri più sollecitati';
			WHEN _risp >= 4.5 THEN SET descr = 'Danni superficiali';
		END CASE;
		WHEN _tipoCalamita = 'alluvione' THEN CASE
			WHEN _risp < 1.5 THEN SET descr = 'Rischio di allagamento e inflitrazioni gravi nell`intero edificio, compromettendone l`intergità strutturale';
			WHEN _risp >= 1.5 AND _risp < 2.5 THEN SET descr = 'Probabili danni alla copertura dell`edificio con conseguenti infiltrazioni';
			WHEN _risp >= 2.5 AND _risp < 3.5 THEN SET descr = 'Possibili danni alla copertura dell`edificio';
			WHEN _risp >= 3.5 AND _risp < 4.5 THEN SET descr = 'Possibili danni superficiali alla copertura dell`edificio e/o danni superficiali sui muri esterni';
			WHEN _risp >= 4.5 THEN SET descr = 'Improbabile la presenza di danni sull`edificio';
		END CASE;
		WHEN _tipoCalamita = 'esondazione' THEN CASE
			WHEN _risp < 1.5 THEN SET descr = 'Rischio di crollo dell`intero edificio';
			WHEN _risp >= 1.5 AND _risp < 2.5 THEN SET descr = 'Compromessa l`intergità strutturale dell`edificio';
			WHEN _risp >= 2.5 AND _risp < 3.5 THEN SET descr = 'Probabili allagamenti al piano terra dell`edificio';
			WHEN _risp >= 3.5 AND _risp < 4.5 THEN SET descr = 'Probabile infiltrazione al piano terra dell`edificio';
			WHEN _risp >= 4.5 THEN SET descr = 'Danni esterni superficiali';
		END CASE;
		WHEN _tipoCalamita = 'frana' THEN CASE
			WHEN _risp < 1.5 THEN SET descr = 'Rischio di crollo dell`intero edificio';
			WHEN _risp >= 1.5 AND _risp < 2.5 THEN SET descr = 'Compromessa la stabilità dell`edificio nelle sue fondamenta';
			WHEN _risp >= 2.5 AND _risp < 3.5 THEN SET descr = 'Probabili danni strutturali nella parte bassa dell`edificio';
			WHEN _risp >= 3.5 AND _risp < 4.5 THEN SET descr = 'Danni superificiali su tutti i lati dell`edificio, possibili danni strutturali sul lato esposto alla frana';
			WHEN _risp >= 4.5 THEN SET descr = 'Danni esterni superficiali sul lato esposto alla frana';
		END CASE;
	END CASE;
    RETURN descr;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS costoLavoroTrigger;
DELIMITER $$
CREATE TRIGGER costoLavoroTrigger
AFTER INSERT ON LavoroProgetto
FOR EACH ROW
BEGIN
	IF ( SELECT count(*) FROM Responsabile WHERE Lavoro = NEW.Lavoro) = 0 THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Un lavoro facente parte di un progetto deve avere un responsabile';
    END IF;
	CALL costoLavoroSP(NEW.Lavoro);
END $$ 
DELIMITER ;

DROP PROCEDURE IF EXISTS costoLavoroSP;
DELIMITER $$
CREATE PROCEDURE costoLavoroSP(IN _idLavoro INT)
BEGIN 
	DECLARE CostoMan INT DEFAULT 0;
	DECLARE CostoMat INT DEFAULT 0;

	SET CostoMan = costoManodopera(_idLavoro);
	IF CostoMan = 0 THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Il lavoro non è stato assegnato a nessuno';
    END IF;
	SET CostoMat = FLOOR(costoMateriali(_idLavoro));
	IF CostoMat = 0 THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Non ci sono informazioni sufficienti sui muri e vani soggetti al lavoro per stimare un costo';
	END IF;
	UPDATE Lavoro
	SET Costo = CostoMat + CostoMan
	WHERE idLavoro = _idLavoro;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS costoManodopera;
DELIMITER $$ 
CREATE FUNCTION costoManodopera(_idLavoro INT)
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE TotaleStipendi INT DEFAULT 0;

	DECLARE giorniDiLavoro INT DEFAULT (
		SELECT DATEDIFF(S.StimaDataFine, S.DataInizio)
		FROM Stadio S
			INNER JOIN LavoroProgetto LP
				ON S.numStadio = LP.Stadio 
				AND S.Progetto = LP.Progetto
				AND S.Edificio = LP.Edificio
		WHERE LP.Lavoro = _idLavoro);

	DECLARE stipendiLavoratori INT DEFAULT (
		SELECT IF(count(*)=0, 0, sum(Stip)) FROM(
			SELECT DISTINCT L.Stipendio as Stip, L.codiceFiscale
			FROM Lavoratore L 
				INNER JOIN PianoSettimanale PS ON L.PianoSettimanale = PS.idPiano
				INNER JOIN Turno T ON T.PianoSettimanale = PS.idPiano
				INNER JOIN Lavoro W ON W.idLavoro = T.Lavoro
			WHERE W.idLavoro = _idLavoro) as stipendiLav);

	DECLARE stipendiCapocantieri INT DEFAULT (
		SELECT IF(count(*)=0, 0, sum(Stip)) FROM(
			SELECT DISTINCT C.Stipendio as Stip, C.codiceFiscale
			FROM Capocantiere C 
				INNER JOIN PianoSettimanale PS ON C.PianoSettimanale = PS.idPiano
				INNER JOIN Turno T ON T.PianoSettimanale = PS.idPiano
				INNER JOIN Lavoro W ON W.idLavoro = T.Lavoro
			WHERE W.idLavoro = _idLavoro) as stipendiCap);
            
	DECLARE stipendioResponsabile INT DEFAULT (
		SELECT Stipendio 
		FROM Responsabile
		WHERE Lavoro = _idLavoro);

	SET TotaleStipendi = (stipendiLavoratori + stipendiCapocantieri + stipendioResponsabile) * giorniDiLavoro;
    RETURN TotaleStipendi;
END $$
DELIMITER ;


DROP FUNCTION IF EXISTS costoMateriali;
DELIMITER $$
CREATE FUNCTION costoMateriali(_idLavoro INT)
RETURNS FLOAT DETERMINISTIC
BEGIN
	DECLARE _vano, _muro INT;
    DECLARE finito BIT DEFAULT 0;
    DECLARE costoFinale FLOAT DEFAULT 0;
    DECLARE cursoreVani CURSOR FOR(
		SELECT idVano 
		FROM BaseLavoroVano
		WHERE Lavoro = _idLavoro);
    DECLARE cursoreMuri CURSOR FOR(
		SELECT Muro
		FROM BaseLavoroMuro
		WHERE Lavoro = _idLavoro);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;   
	
    OPEN cursoreVani;
    loopVani: LOOP
		FETCH cursoreVani INTO _vano;
        IF finito = 1 THEN LEAVE loopVani; END IF;
        SET costoFinale = costoFinale + costoPavimentazioneVano(_vano) + costoStratoVano(_vano);
    END LOOP;
    CLOSE cursoreVani;
    
    SET finito = 0;
    OPEN cursoreMuri;
    loopMuri: LOOP
		FETCH cursoreMuri INTO _muro;
        IF finito = 1 THEN LEAVE loopMuri; END IF;
        SET costoFinale = costoFinale + costoStrutturaMuro(_muro);
    END LOOP;
    CLOSE cursoreMuri;
    
    RETURN costoFinale;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS costoStrutturaMuro;
DELIMITER $$
CREATE FUNCTION costoStrutturaMuro(_idMuro INT)
RETURNS FLOAT DETERMINISTIC
BEGIN
	DECLARE costoMattone FLOAT DEFAULT(
		-- Lunghezza e altezza sono in cm
		SELECT IF(count(*)=0, 0, (Costo * 10000 / (M.Lunghezza * M.Altezza))) as CostoM2
		FROM Mattone M
			INNER JOIN MuroMattone MM ON (MM.Mattone = M.codMattone AND MM.Alveoli = M.Alveoli)
		WHERE MM.Muro = _idMuro);
        
	DECLARE costoPresetMuro INT DEFAULT(
		SELECT IF(count(*)=0, 0, CostoPerUnitaDiMisura)
		FROM PresetMateriale
			INNER JOIN MuroPreset ON Preset = CodLotto
		WHERE Muro = _idMuro);
        
	DECLARE costoPietraMuro FLOAT DEFAULT(
		SELECT IF(count(*)=0, 0, (CostoKG * PesoMedio / 0.06)) as CostoM2
		FROM Pietra
			INNER JOIN MuroPietra ON Pietra = idPietra
	WHERE Muro = _idMuro);
    
    DECLARE supMuro FLOAT DEFAULT(
		SELECT sqrt((X2-X1)*(X2-X1) + (Y2-Y1)*(Y2-Y1)) * Altezza AS Sup
		FROM Muro 
		WHERE idMuro = _idMuro);
    
    RETURN (costoMattone + costoPresetMuro + costoPietraMuro) * supMuro;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS costoPavimentazioneVano;
DELIMITER $$
CREATE FUNCTION costoPavimentazioneVano(_idVano INT)
RETURNS FLOAT DETERMINISTIC
BEGIN
	DECLARE costoPiastrella INT DEFAULT(
		SELECT IF(count(*)=0, 0, (CostoM2))
		FROM Piastrella
			INNER JOIN VanoPiastrella ON idPiastrella = Piastrella
		WHERE idVano = _idVano);
                    
	DECLARE costoParquet INT DEFAULT(
		SELECT IF(count(*)=0, 0, (CostoM2))
		FROM Parquet_
			INNER JOIN VanoParquet ON Parquet_ = idParquet_
		WHERE idVano = _idVano);
        
	DECLARE costoPavimentazione FLOAT DEFAULT(
		SELECT IF(count(*)=0, 0, CostoPerUnitaDiMisura)
		FROM PresetMateriale
			INNER JOIN VanoPavimentazione ON Pavimentazione = CodLotto
		WHERE idVano = _idVano);
        
	DECLARE supVano FLOAT DEFAULT(
		SELECT Lunghezza * Larghezza
		FROM Vano
		WHERE idVano = _idVano);
        
    RETURN (costoPiastrella + costoParquet + costoPavimentazione) * supVano;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS costoStratoVano;
DELIMITER $$
CREATE FUNCTION costoStratoVano(_idVano INT)
RETURNS FLOAT DETERMINISTIC
BEGIN
	DECLARE costoPietraVano FLOAT DEFAULT(
		-- SuperficieMedia è in cm
		SELECT IF(count(*)=0, 0, ((P.CostoKG * P.PesoMedio * 10000) / (VP.SuperficieMedia))) as CostoM2
		FROM Pietra P
			INNER JOIN VanoPietra VP ON Pietra = idPietra
		WHERE idVano = _idVano);
        
	DECLARE costoIntonaco INT DEFAULT(
		SELECT IF(count(*)=0, 0, (CostoM2 * numStrati)) as costoTot
		FROM Intonaco 
			INNER JOIN VanoIntonaco ON Intonaco = idIntonaco
		WHERE idVano = _idVano);
        
	DECLARE costoStrato INT DEFAULT(
		SELECT IF(count(*)=0, 0, (CostoPerUnitaDiMisura))
		FROM PresetMateriale
			INNER JOIN VanoStrato ON Strato = codLotto
		WHERE idVano = _idVano);

	DECLARE supLatVano FLOAT DEFAULT(
		SELECT SUM(superficieMuro(D.Muro))
		FROM Vano V
			INNER JOIN delimitazione D ON V.idVano = D.Vano
		WHERE V.idVano = _idVano);
        
    RETURN (costoPietraVano + costoIntonaco + costoStrato) * supLatVano;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS superficieMuro;
DELIMITER $$
CREATE FUNCTION superficieMuro(_idMuro INT)
RETURNS FLOAT DETERMINISTIC
BEGIN
	RETURN (
		SELECT sqrt((X2-X1)*(X2-X1) + (Y2-Y1)*(Y2-Y1)) * Altezza AS Sup
		FROM Muro 
		WHERE idMuro = _idMuro);
END $$
DELIMITER ;