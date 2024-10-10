-- controlla che siano inseriti max piani = NumeroPiani per edificio
DROP TRIGGER IF EXISTS BI_Piano;
DELIMITER $$
CREATE TRIGGER BI_Piano
BEFORE INSERT ON Piano
FOR EACH ROW
BEGIN
	CALL checkNumeroPiani(NEW.Edificio, NEW.NumeroPiano);
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS BU_Piano;
DELIMITER $$
CREATE TRIGGER BU_Piano
BEFORE UPDATE ON Piano
FOR EACH ROW
BEGIN
	IF (OLD.Edificio <> NEW.Edificio OR OLD.NumeroPiano <> NEW.NumeroPiano) THEN
		CALL checkNumeroPiani(NEW.Edificio, NEW.NumeroPiano);
	END IF;
END $$
DELIMITER ;



-- se si sta inserendo l'ultimo -> si mette edificio.inCostruzione a 0
DROP TRIGGER IF EXISTS AI_Piano;
DELIMITER $$
CREATE TRIGGER AI_Piano
AFTER INSERT ON Piano
FOR EACH ROW
BEGIN
	CALL setEdificioInCostruzione(NEW.Edificio);
END $$
DELIMITER ;
-- se si sta cambiando l'edificio -> si controlla edificio.inCostruzione di vecchio e nuovo
DROP TRIGGER IF EXISTS AU_Piano;
DELIMITER $$
CREATE TRIGGER AU_Piano
AFTER UPDATE ON Piano
FOR EACH ROW
BEGIN
	IF (OLD.Edificio <> NEW.Edificio) THEN
		CALL setEdificioInCostruzione(OLD.Edificio);
		CALL setEdificioInCostruzione(NEW.Edificio);
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS AD_Piano;
DELIMITER $$
CREATE TRIGGER AD_Piano
AFTER DELETE ON Piano
FOR EACH ROW
BEGIN
	CALL setEdificioInCostruzione(OLD.Edificio);
END $$
DELIMITER ;

-- controlla che siano inseriti max vani = NumeroVani per piano prima di inserire un nuovo vano
DROP TRIGGER IF EXISTS BI_Vano;
DELIMITER $$
CREATE TRIGGER BI_Vano
BEFORE INSERT ON Vano
FOR EACH ROW
BEGIN
	CALL checkNumeroVani(NEW.Piano);
END $$
DELIMITER ;
-- controlla che siano inseriti max vani = NumeroVani per piano prima di cambiare il piano di un vano
DROP TRIGGER IF EXISTS BU_Vano;
DELIMITER $$
CREATE TRIGGER BU_Vano
BEFORE UPDATE ON Vano
FOR EACH ROW
BEGIN
	IF (OLD.Piano <> NEW.Piano) THEN
		CALL checkNumeroVani(NEW.Piano);
	END IF;
END $$
DELIMITER ;


-- se si e' inserito l'ultimo -> si mette piano.inCostruzione a 0
-- altrimenti si mette piano.inCostruzione a 1
DROP TRIGGER IF EXISTS AI_Vano;
DELIMITER $$
CREATE TRIGGER AI_Vano
AFTER INSERT ON Vano
FOR EACH ROW
BEGIN
	CALL setPianoInCostruzione(NEW.Piano);
END $$
DELIMITER ;

-- sull'update piano.inCostruzione va controllato sia al vecchio che al nuovo piano se diversi
DROP TRIGGER IF EXISTS AU_Vano;
DELIMITER $$
CREATE TRIGGER AU_Vano
AFTER UPDATE ON Vano
FOR EACH ROW
BEGIN
	IF (OLD.Piano <> NEW.Piano) THEN
		CALL setPianoInCostruzione(OLD.Piano);
		CALL setPianoInCostruzione(NEW.Piano);
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS AD_Vano;
DELIMITER $$
CREATE TRIGGER AD_Vano
AFTER DELETE ON Vano
FOR EACH ROW
BEGIN
	CALL setPianoInCostruzione(OLD.Piano);
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS BI_Delimitazione;
DELIMITER $$
CREATE TRIGGER BI_Delimitazione
BEFORE INSERT ON Delimitazione
FOR EACH ROW
BEGIN
	CALL checkNumeroMuri(NEW.Vano, NEW.Muro);
	CALL checkIntersezioneMuri(NEW.Vano, NEW.Muro);
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS BU_Delimitazione;
DELIMITER $$
CREATE TRIGGER BU_Delimitazione
BEFORE UPDATE ON Delimitazione
FOR EACH ROW
BEGIN
	CALL checkNumeroMuri(OLD.Vano, OLD.Muro);
	CALL checkNumeroMuri(NEW.Vano, NEW.Muro);
	CALL checkIntersezioneMuri(NEW.Vano, NEW.Muro);
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS AI_Delimitazione;
DELIMITER $$
CREATE TRIGGER AI_Delimitazione
AFTER INSERT ON Delimitazione
FOR EACH ROW
BEGIN
	CALL setVanoInCostruzione(NEW.Vano);
	CALL updateAttributiMuro(NEW.Muro);
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS AU_Delimitazione;
DELIMITER $$
CREATE TRIGGER AU_Delimitazione
AFTER UPDATE ON Delimitazione
FOR EACH ROW
BEGIN
	IF (OLD.Vano <> NEW.Vano) THEN
		CALL setVanoInCostruzione(OLD.Vano);
		CALL setVanoInCostruzione(NEW.Vano);
	ELSE
		CALL updateAttributiMuro(OLD.Muro);
		CALL updateAttributiMuro(NEW.Muro);
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS AD_Delimitazione;
DELIMITER $$
CREATE TRIGGER AD_Delimitazione
AFTER DELETE ON Delimitazione
FOR EACH ROW
BEGIN
	CALL setVanoInCostruzione(OLD.Vano);
	CALL updateAttributiMuro(OLD.Muro);
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS BI_AperturaMuro;
DELIMITER $$
CREATE TRIGGER BI_AperturaMuro
BEFORE INSERT ON AperturaMuro
FOR EACH ROW
BEGIN
	CALL checkAperturaMuro(NEW.idApertura, NEW.Muro, NEW.Altezza, NEW.AltezzaDaTerra, NEW.Larghezza, NEW.DistanzaMuro, NEW.Tipo, NEW.PuntoCardinale);
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS BU_AperturaMuro;
DELIMITER $$
CREATE TRIGGER BU_AperturaMuro
BEFORE UPDATE ON AperturaMuro
FOR EACH ROW
BEGIN
	CALL checkAperturaMuro(NEW.idApertura, NEW.Muro, NEW.Altezza, NEW.AltezzaDaTerra, NEW.Larghezza, NEW.DistanzaMuro, NEW.Tipo, NEW.PuntoCardinale);
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS BI_Balcone;
DELIMITER $$
CREATE TRIGGER BI_Balcone
BEFORE INSERT ON Balcone
FOR EACH ROW
BEGIN
	DECLARE Interno BIT;
	SET Interno = (
		SELECT M.Interno
		FROM Muro M
		WHERE M.idMuro = NEW.Muro);

	IF(Interno = 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Balcone non può essere legato a muro interno';
	END IF;
END
DELIMITER ;

-- inserimento in vecchia area quando viene aggiornata l'area
DROP TRIGGER IF EXISTS inserisciVecchiaArea;
DELIMITER $$
CREATE TRIGGER inserisciVecchiaArea
BEFORE UPDATE ON Area
FOR EACH ROW
BEGIN
	IF NOT EXISTS ( SELECT * FROM Vecchia_area WHERE Data_ = current_timestamp() AND CAP = OLD.CAP) THEN
		INSERT INTO Vecchia_Area VALUES (current_timestamp, OLD.CAP, OLD.RischioIdrogeologico, OLD.RischioSismico);
    ELSE 
		UPDATE Vecchia_Area
        SET RischioIdrogeologico = OLD.RischioIdrogeologico AND RischioSismico = OLD.RischioSismico
        WHERE Data_ = current_timestamp() AND CAP = OLD.CAP;
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS Aggiorna_Rischio_Edificio;
DELIMITER $$
CREATE TRIGGER Aggiorna_Rischio_Edificio
AFTER INSERT ON Edificio FOR EACH ROW
BEGIN
	DECLARE modifier_rischio_idro FLOAT DEFAULT 0.003 + NEW.NumeroPiani / 5000;
	DECLARE modifier_rischio_sisma FLOAT DEFAULT 0;
	CALL Aggiorna_Rischio_Area(NEW.Area, modifier_rischio_idro, modifier_rischio_sisma);
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS Aggiorna_Rischio_Calamita;
DELIMITER $$
CREATE TRIGGER Aggiorna_Rischio_Calamita
AFTER INSERT ON EventoCalamitoso FOR EACH ROW
BEGIN
	DECLARE modifier_rischio_idro FLOAT DEFAULT 0;
	DECLARE modifier_rischio_sisma FLOAT DEFAULT 0;
	IF NEW.Tipo = 'sisma'
	THEN 
		IF NEW.Gravita >= (
			SELECT RischioSismico
			FROM Area
			WHERE CAP = NEW.Area
			) * 10
		THEN SET modifier_rischio_sisma = NEW.Gravita / 50;
		END IF;
	ELSEIF NEW.Gravita >= (
		SELECT RischioIdrogeologico
		FROM Area
		WHERE CAP = NEW.Area) * 5
	THEN 
		IF NEW.Tipo = 'alluvione'
			THEN SET modifier_rischio_idro = 0.01 + log(3, NEW.Gravita) / 14;
		ELSEIF NEW.Tipo = 'esondazione'
			THEN SET modifier_rischio_idro = 0.01 + log(3, NEW.Gravita) / 12;
		ELSEIF NEW.Tipo = 'frana'
			THEN SET modifier_rischio_idro = 0.01 + log(3, NEW.Gravita) / 20;
		END IF;
	END IF;

	CALL Aggiorna_Rischio_Area(NEW.Area, modifier_rischio_idro, modifier_rischio_sisma);
	CALL aggiorna_rischio_aree_confinanti(NEW.Area, modifier_rischio_idro/3, modifier_rischio_sisma/3);
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS Aggiorna_Rischio_modificazioniTerritorio;
DELIMITER $$
CREATE TRIGGER Aggiorna_Rischio_modificazioniTerritorio
AFTER INSERT ON ModificazioniTerritorio FOR EACH ROW
BEGIN
	CALL Aggiorna_Rischio_Area(NEW.Area, NEW.ModificatoreIdrogeologico, NEW.ModificatoreSismico);
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS BI_Sensore;
DELIMITER $$
CREATE TRIGGER BI_Sensore
BEFORE INSERT ON Sensore
FOR EACH ROW
BEGIN
    DECLARE LunghezzaMuro, AltezzaMuro FLOAT;
    SET LunghezzaMuro = (SELECT sqrt((X1-X2)*(X1-X2) + (Y1-Y2)*(Y1-Y2)) FROM Muro M WHERE M.idMuro = NEW.Muro);
	SET AltezzaMuro = (SELECT Altezza FROM Muro M WHERE M.idMuro = NEW.Muro);
    
	IF(NEW.DistanzaOrigineMuro > LunghezzaMuro OR NEW.AltezzaDaTerra > AltezzaMuro) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Posizione del sensore incompatibile con il muro';
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS BU_Sensore;
DELIMITER $$
CREATE TRIGGER BU_Sensore
BEFORE UPDATE ON Sensore
FOR EACH ROW
BEGIN
    DECLARE LunghezzaMuro, AltezzaMuro FLOAT;
	IF(	OLD.AltezzaDaTerra <> NEW.AltezzaDaTerra OR 
		OLD.DistanzaOrigineMuro <> NEW.DistanzaOrigineMuro OR 
		OLD.Muro <> NEW.Muro) THEN
		SET LunghezzaMuro = (SELECT sqrt((X1-X2)*(X1-X2) + (Y1-Y2)*(Y1-Y2)) FROM Muro M WHERE M.idMuro = NEW.Muro);
		SET AltezzaMuro = (SELECT Altezza FROM Muro M WHERE M.idMuro = NEW.Muro);
		
		IF(NEW.DistanzaOrigineMuro > LunghezzaMuro OR NEW.AltezzaDaTerra > AltezzaMuro) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Posizione del sensore incompatibile con il muro';
		END IF;
	END IF;
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS BI_Campionamento;
DELIMITER $$
CREATE TRIGGER BI_Campionamento
BEFORE INSERT ON Campionamento
FOR EACH ROW
BEGIN
	DECLARE error_ BIT DEFAULT(
		SELECT IF(count(*) = 0, 0, 1)
		FROM Campionamento C
		WHERE C.Sensore = NEW.Sensore AND C.Data_ = NEW.Data_);
    DECLARE valMin FLOAT DEFAULT (SELECT valMinimo FROM Sensore WHERE codSensore=NEW.Sensore);
    DECLARE valMax FLOAT DEFAULT (SELECT valMassimo FROM Sensore WHERE codSensore=NEW.Sensore);
    
	IF (error_ = 1) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Campionamento già presente a questa data';
	END IF;
	IF (NEW.valMisurato < valMin) OR (NEW.valMisurato > valMax) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valore misurato fuori dalla scala del sensore';
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS AI_Campionamento_InserisciInAlert;
DELIMITER $$
CREATE TRIGGER AI_Campionamento_InserisciInAlert
AFTER INSERT ON Campionamento
FOR EACH ROW
BEGIN
	DECLARE sogliaSensore FLOAT DEFAULT ( SELECT Soglia FROM Sensore WHERE codSensore = NEW.Sensore);
	DECLARE tipo VARCHAR(50) DEFAULT ( SELECT Tipo FROM Sensore WHERE codSensore = NEW.Sensore);
    DECLARE valMin FLOAT DEFAULT ( SELECT valMinimo FROM Sensore WHERE codSensore = NEW.Sensore);
    DECLARE valMax FLOAT DEFAULT ( SELECT valMassimo FROM Sensore WHERE codSensore = NEW.Sensore);
	
    IF (Tipo <> 'termometro') THEN
		IF (NEW.valMisurato >= sogliaSensore) THEN
			INSERT INTO Alert VALUES(NEW.numCampionamento, NEW.Sensore, NEW.Data_);
		END IF;
	ELSE 
		IF (abs(NEW.valMisurato - valMin) <= sogliaSensore) OR (abs(NEW.valMisurato - valMax) <= sogliaSensore) THEN
			INSERT INTO Alert VALUES(NEW.numCampionamento, NEW.Sensore, NEW.Data_);
		END IF;
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS Inserimento_Alert;
DELIMITER $$
CREATE TRIGGER Inserimento_Alert
AFTER INSERT ON Alert FOR EACH ROW
BEGIN
	DECLARE _Edificio INT DEFAULT (
		SELECT M.Edificio
		FROM  Sensore S
			INNER JOIN Muro M ON S.Muro = M.idMuro
		WHERE NEW.Sensore = S.codSensore);
	IF _Edificio = NULL
	THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'edificio non esistente';
	ELSE
		INSERT INTO Registrazione(Edificio, Data_) VALUES (_Edificio, date(NEW.Timestamp_));
        CALL checkInserimentoCalamita(NEW.Campionamento, NEW.Sensore, NEW.Timestamp_);
	END IF;
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS Inserimento_Registrazione;
DELIMITER $$
CREATE TRIGGER Inserimento_Registrazione
AFTER INSERT ON Registrazione FOR EACH ROW
BEGIN
	CALL InserimentoRegistrazioneCampionamento(NEW.codRegistrazione, NEW.Edificio);
	INSERT INTO Report(Registrazione, Edificio, Data_) VALUES (NEW.codRegistrazione, NEW.Edificio, NEW.Data_);
END $$ 
DELIMITER ;

DROP TRIGGER IF EXISTS AI_report;
DELIMITER $$
CREATE TRIGGER AI_report
AFTER INSERT ON Report
FOR EACH ROW
BEGIN
	CALL InserimentoMonitorazioneSP(NEW.idReport, NEW.Registrazione, NEW.Edificio);
	CALL generaConsigliInterventoReport(NEW.idReport);
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS AggiornaStatoEdificio;
DELIMITER $$
CREATE TRIGGER AggiornaStatoEdificio
AFTER INSERT ON Monitorazione FOR EACH ROW 
BEGIN
	DECLARE OLDStato, NEWStato, OLDSalubrita, NEWSalubrita VARCHAR(50);
	CALL AggiornaStatoEdificioSp(NEW.Muro, NEW.Stato, NEW.Danno, OLDStato, NEWStato, OLDSalubrita, NEWSalubrita);
    IF(statoPeggiorato(OLDStato, NEWStato)) THEN 
		CALL consigli_di_intervento_edificio_Stato(NEW.Report); END IF;
    IF(salubritaPeggiorata(OLDSalubrita, NEWSalubrita)) THEN 
		CALL consigli_di_intervento_edificio_Salubrita(NEW.Report); END IF;
END $$
DELIMITER ;
DROP TRIGGER IF EXISTS On_Update_Preset;
DELIMITER $$
CREATE TRIGGER On_Update_Preset
BEFORE UPDATE ON PresetMateriale FOR EACH ROW
BEGIN
	IF NOT EXISTS(
		SELECT *
		FROM PresetMateriale
		WHERE codLotto = NEW.codLotto
	)
	THEN CALL Messaggio_Errore;
	END IF;
END $$
DELIMITER ;
DROP TRIGGER IF EXISTS AU_Preset;
DELIMITER $$
CREATE TRIGGER AU_Preset
AFTER UPDATE ON PresetMateriale FOR EACH ROW
BEGIN
	DECLARE lavoro_ INT;
	DECLARE finito BIT DEFAULT 0;
	DECLARE cursoreLavori CURSOR FOR(
		SELECT distinct(Lavoro) FROM(
			SELECT BLV.Lavoro as Lavoro
			FROM BaseLavoroVano BLV
				INNER JOIN VanoPavimentazione VP ON BLV.idVano = VP.idVano
			WHERE VP.Pavimentazione = NEW.codLotto
			UNION
			SELECT BLV.Lavoro as Lavoro
			FROM BaseLavoroVano BLV
				INNER JOIN VanoStrato VS ON BLV.idVano = VS.idVano
			WHERE VS.Strato = NEW.codLotto
			UNION
			SELECT BLM.Lavoro as Lavoro
			FROM BaseLavoroMuro BLM
				INNER JOIN MuroPreset MP ON BLM.Muro = MP.Muro
			WHERE MP.Preset = NEW.CodLotto) as Lavori);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
	OPEN cursoreLavori;
	loopLavori: LOOP
		FETCH cursoreLavori INTO lavoro_;
		IF finito = 1 THEN LEAVE loopLavori; END IF;
		CALL costoLavoroSP(lavoro_);
	END LOOP;
	CLOSE cursoreLavori;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS On_Update_Pietra;
DELIMITER $$
CREATE TRIGGER On_Update_Pietra
BEFORE UPDATE ON Pietra FOR EACH ROW
BEGIN
	IF NOT EXISTS(
		SELECT *
		FROM Pietra
		WHERE idPietra = NEW.idPietra
	)
	THEN CALL Messaggio_Errore;
	END IF;
END $$
DELIMITER ;
DROP TRIGGER IF EXISTS AU_Pietra;
DELIMITER $$
CREATE TRIGGER AU_Pietra
AFTER UPDATE ON Pietra FOR EACH ROW
BEGIN
	DECLARE lavoro_ INT;
	DECLARE finito BIT DEFAULT 0;
	DECLARE cursoreLavori CURSOR FOR(
		SELECT distinct(Lavoro) FROM(
			SELECT BLV.Lavoro as Lavoro
			FROM BaseLavoroVano BLV
				INNER JOIN VanoPietra VP ON BLV.idVano = VP.idVano
			WHERE VP.Pietra = NEW.idPietra
			UNION
			SELECT BLM.Lavoro as Lavoro
			FROM BaseLavoroMuro BLM
				INNER JOIN MuroPietra MP ON BLM.Muro = MP.Muro
			WHERE MP.Pietra = NEW.idPietra) as Lavori);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
	OPEN cursoreLavori;
	loopLavori: LOOP
		FETCH cursoreLavori INTO lavoro_;
		IF finito = 1 THEN LEAVE loopLavori; END IF;
		CALL costoLavoroSP(lavoro_);
	END LOOP;
	CLOSE cursoreLavori;
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS On_Update_Intonaco;
DELIMITER $$
CREATE TRIGGER On_Update_Intonaco
BEFORE UPDATE ON Intonaco FOR EACH ROW
BEGIN
	IF NOT EXISTS(
		SELECT *
		FROM Intonaco
		WHERE idIntonaco = NEW.idIntonaco
	)
	THEN CALL Messaggio_Errore;
	END IF;
END $$
DELIMITER ;
DROP TRIGGER IF EXISTS AU_Intonaco;
DELIMITER $$
CREATE TRIGGER AU_Intonaco
AFTER UPDATE ON Intonaco FOR EACH ROW
BEGIN
	DECLARE lavoro_ INT;
	DECLARE finito BIT DEFAULT 0;
	DECLARE cursoreLavori CURSOR FOR(
		SELECT distinct(BLV.Lavoro)
		FROM BaseLavoroVano BLV
			INNER JOIN VanoIntonaco VI ON BLV.idVano = VI.idVano
		WHERE VI.Intonaco = NEW.idIntonaco);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
	OPEN cursoreLavori;
	loopLavori: LOOP
		FETCH cursoreLavori INTO lavoro_;
		IF finito = 1 THEN LEAVE loopLavori; END IF;
		CALL costoLavoroSP(lavoro_);
	END LOOP;
	CLOSE cursoreLavori;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS On_Update_Parquet;
DELIMITER $$
CREATE TRIGGER On_Update_Parquet
BEFORE UPDATE ON Parquet_ FOR EACH ROW
BEGIN
	IF NOT EXISTS(
		SELECT *
		FROM Parquet_
		WHERE idParquet_ = NEW.idParquet_
	)
	THEN CALL Messaggio_Errore;
	END IF;
END $$
DELIMITER ;
DROP TRIGGER IF EXISTS AU_Parquet;
DELIMITER $$
CREATE TRIGGER AU_Parquet
AFTER UPDATE ON Parquet_ FOR EACH ROW
BEGIN
	DECLARE lavoro_ INT;
	DECLARE finito BIT DEFAULT 0;
	DECLARE cursoreLavori CURSOR FOR(
		SELECT distinct(BLV.Lavoro)
		FROM BaseLavoroVano BLV
			INNER JOIN VanoParquet VP ON BLV.idVano = VP.idVano
		WHERE VP.Parquet_ = NEW.idParquet_);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
	OPEN cursoreLavori;
	loopLavori: LOOP
		FETCH cursoreLavori INTO lavoro_;
		IF finito = 1 THEN LEAVE loopLavori; END IF;
		CALL costoLavoroSP(lavoro_);
	END LOOP;
	CLOSE cursoreLavori;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS On_Update_Piastrella;
DELIMITER $$
CREATE TRIGGER On_Update_Piastrella
BEFORE UPDATE ON Piastrella FOR EACH ROW
BEGIN
	IF NOT EXISTS(
		SELECT *
		FROM Piastrella
		WHERE idPiastrella = NEW.idPiastrella
	)
	THEN CALL Messaggio_Errore;
	END IF;
END $$
DELIMITER ;
DROP TRIGGER IF EXISTS AU_Piastrella;
DELIMITER $$
CREATE TRIGGER AU_Piastrella
AFTER UPDATE ON Piastrella FOR EACH ROW
BEGIN
	DECLARE lavoro_ INT;
	DECLARE finito BIT DEFAULT 0;
	DECLARE cursoreLavori CURSOR FOR(
		SELECT distinct(BLV.Lavoro)
		FROM BaseLavoroVano BLV
			INNER JOIN VanoPiastrella VP ON BLV.idVano = VP.idVano
		WHERE VP.Piastrella = NEW.idPiastrella);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
	OPEN cursoreLavori;
	loopLavori: LOOP
		FETCH cursoreLavori INTO lavoro_;
		IF finito = 1 THEN LEAVE loopLavori; END IF;
		CALL costoLavoroSP(lavoro_);
	END LOOP;
	CLOSE cursoreLavori;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS On_Update_Mattone;
DELIMITER $$
CREATE TRIGGER On_Update_Mattone
BEFORE UPDATE ON Mattone FOR EACH ROW
BEGIN
	IF NOT EXISTS(
		SELECT *
		FROM Mattone
		WHERE codMattone = NEW.codMattone
			AND Alveoli = NEW.Alveoli
	)
	THEN CALL Messaggio_Errore;
	END IF;
END $$
DELIMITER ;
DROP TRIGGER IF EXISTS AU_Mattone;
DELIMITER $$
CREATE TRIGGER AU_Mattone
AFTER UPDATE ON Mattone FOR EACH ROW
BEGIN
	DECLARE lavoro_ INT;
	DECLARE finito BIT DEFAULT 0;
	DECLARE cursoreLavori CURSOR FOR(
		SELECT distinct(BLM.Lavoro)
		FROM BaseLavoroMuro BLM
			INNER JOIN MuroMattone MM ON BLM.Muro = MM.Muro
		WHERE MM.Mattone = NEW.codMattone
			AND MM.Alveoli = NEW.Alveoli);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
	OPEN cursoreLavori;
	loopLavori: LOOP
		FETCH cursoreLavori INTO lavoro_;
		IF finito = 1 THEN LEAVE loopLavori; END IF;
		CALL costoLavoroSP(lavoro_);
	END LOOP;
	CLOSE cursoreLavori;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS checkMaterialiMuroPietra;
DELIMITER $$
CREATE TRIGGER checkMaterialiMuroPietra
BEFORE INSERT ON MuroPietra
FOR EACH ROW
BEGIN
	IF checkMaterialiMuro(NEW.Muro) = 0
    THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Muro già collegato ad un materiale';
    END IF;
END $$
DELIMITER ;
DROP TRIGGER IF EXISTS checkMaterialiMuroMattone;
DELIMITER $$
CREATE TRIGGER checkMaterialiMuroMattone
BEFORE INSERT ON MuroMattone
FOR EACH ROW
BEGIN
	IF checkMaterialiMuro(NEW.Muro) = 0
    THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Muro già collegato ad un materiale';
    END IF;
END $$
DELIMITER ;
DROP TRIGGER IF EXISTS checkMaterialiMuroPreset;
DELIMITER $$
CREATE TRIGGER checkMaterialiMuroPreset
BEFORE INSERT ON MuroPreset
FOR EACH ROW
BEGIN
	IF checkMaterialiMuro(NEW.Muro) = 0
    THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Muro già collegato ad un materiale';
    END IF;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS checkMaterialiMuro;
DELIMITER $$
CREATE FUNCTION checkMaterialiMuro(_muro INT)
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE conto INT DEFAULT 0;
    SET conto = (
			SELECT COUNT(*)
            FROM muropietra
            WHERE Muro = _muro
			) + (
			SELECT COUNT(*)
            FROM muromattone
            WHERE Muro = _muro
            ) + (
            SELECT COUNT(*)
            FROM muropreset
            WHERE Muro = _muro
            );
	IF conto > 0
    THEN RETURN 0;
    ELSE RETURN 1;
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS checkMaterialiVanoParquet;
DELIMITER $$
CREATE TRIGGER checkMaterialiVanoParquet
BEFORE INSERT ON VanoParquet
FOR EACH ROW
BEGIN
	IF checkMaterialiVano_Pav(NEW.idVano) = 0
    THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vano già collegato ad un materiale';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS checkMaterialiVanoPiastrella;
DELIMITER $$
CREATE TRIGGER checkMaterialiVanoPiastrella
BEFORE INSERT ON VanoPiastrella
FOR EACH ROW
BEGIN
	IF checkMaterialiVano_Pav(NEW.idVano) = 0
    THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vano già collegato ad un materiale';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS checkMaterialiVanoPavimentazione;
DELIMITER $$
CREATE TRIGGER checkMaterialiVanoPavimentazione
BEFORE INSERT ON VanoPavimentazione
FOR EACH ROW
BEGIN
	IF checkMaterialiVano_Pav(NEW.idVano) = 0
    THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vano già collegato ad un materiale';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS checkMaterialiVanoIntonaco;
DELIMITER $$
CREATE TRIGGER checkMaterialiVanoIntonaco
BEFORE INSERT ON VanoIntonaco
FOR EACH ROW
BEGIN
    -- si ammettono più strati di intonaco
    DECLARE _err INT DEFAULT (
        (SELECT count(*)
        FROM VanoStrato
        WHERE idVano = NEW.idVano) + 
        (SELECT count(*)
        FROM VanoPietra
        WHERE idVano = NEW.idVano));
	IF _err <> 0
    THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vano già collegato ad un materiale';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS checkMaterialiVanoPietra;
DELIMITER $$
CREATE TRIGGER checkMaterialiVanoPietra
BEFORE INSERT ON VanoPietra
FOR EACH ROW
BEGIN
	IF checkMaterialiVano_Str(NEW.idVano) = 0
    THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vano già collegato ad un materiale';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS checkMaterialiVanoStrato;
DELIMITER $$
CREATE TRIGGER checkMaterialiVanoStrato
BEFORE INSERT ON VanoStrato
FOR EACH ROW
BEGIN
	IF checkMaterialiVano_Str(NEW.idVano) = 0
    THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vano già collegato ad un materiale';
    END IF;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS checkMaterialiVano_Pav;
DELIMITER $$
CREATE FUNCTION checkMaterialiVano_Pav(_vano INT)
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE ret INT DEFAULT 0;
    DECLARE conto_pav INT DEFAULT 0;
    
    SET conto_pav = (
					SELECT COUNT(*)
                    FROM vanopavimentazione
                    WHERE idVano = _vano
					) + (
                    SELECT COUNT(*)
                    FROM vanoparquet
                    WHERE idVano = _vano
                    ) + (
                    SELECT COUNT(*)
                    FROM vanopiastrella
                    WHERE idVano = _vano
                    );
	IF conto_pav = 0
        THEN RETURN 1;
        ELSE RETURN 0;
    END IF;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS checkMaterialiVano_Str;
DELIMITER $$
CREATE FUNCTION checkMaterialiVano_Str(_vano INT)
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE ret INT DEFAULT 0;
    DECLARE conto_str INT DEFAULT 0;
    
	SET conto_str = (
					SELECT COUNT(*)
                    FROM vanointonaco
                    WHERE idVano = _vano
					) + (
                    SELECT COUNT(*)
                    FROM vanostrato
                    WHERE idVano = _vano
                    ) + (
                    SELECT COUNT(*)
                    FROM vanopietra
                    WHERE idVano = _vano
                    );
	IF conto_str = 0
        THEN RETURN 1;
        ELSE RETURN 0;
    END IF;
END $$
DELIMITER ;

-- =====================================================
-- ============ TRIGGER ================================
-- =====================================================

-- controlla che ci siano max 8 ore di lavoro per giorno
-- controlla che non si sovrappongano turni dello stesso piano
DROP TRIGGER IF EXISTS BI_Turno;
DELIMITER $$
CREATE TRIGGER BI_Turno
BEFORE INSERT ON Turno
FOR EACH ROW
BEGIN
	DECLARE totSec INT DEFAULT 0;
	DECLARE newSec INT DEFAULT 0;

	DECLARE OraInizio TIME;
	DECLARE OraFine TIME;
	DECLARE endLoop INT DEFAULT 0;

	-- controllo di sovrapposizione
	DECLARE cursoreTurni CURSOR FOR 
		SELECT T.OraInizio, T.OraFine
		FROM Turno T
		WHERE T.PianoSettimanale = NEW.PianoSettimanale
			AND T.Giorno = NEW.Giorno;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endLoop = 1;
	OPEN cursoreTurni;
	controllo: LOOP
		FETCH cursoreTurni INTO OraInizio, OraFine;
		IF endLoop = 1 THEN LEAVE controllo;
		END IF;
		IF ((OraInizio <= NEW.OraInizio AND NEW.OraInizio < OraFine)
			OR (OraInizio < NEW.OraFine AND NEW.OraFine <= OraFine))
		THEN SIGNAL SQLSTATE '45000' 
			SET MESSAGE_TEXT = 'Sovrapposizione di turni';
		END IF;
	END LOOP;
	CLOSE cursoreTurni;

	-- controllo max 8 ore per giorno
	SET totSec = (
		SELECT IF(COUNT(*) = 0, 0, SUM(diff)) FROM (
			SELECT TIME_TO_SEC(TIMEDIFF(T.OraFine, T.OraInizio)) as diff, T.idTurno
			FROM Turno T
			WHERE T.PianoSettimanale = NEW.PianoSettimanale
				AND T.Giorno = NEW.Giorno) as T);
	SET newSec = TIME_TO_SEC(TIMEDIFF(NEW.OraFine, NEW.OraInizio));
	IF (newSec + totSec) > 28800 -- 28000 sec = 8 hr
		THEN SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Massimo di 8 ore lavorative per giorno';
	END IF;
END $$
DELIMITER ;

-- controlla che ci siano max 8 ore di lavoro per giorno
-- controlla che non si sovrappongano turni dello stesso piano
DROP TRIGGER IF EXISTS BU_Turno;
DELIMITER $$
CREATE TRIGGER BU_Turno
BEFORE UPDATE ON Turno
FOR EACH ROW
BEGIN
	DECLARE totSec INT DEFAULT 0;
	DECLARE newSec INT DEFAULT 0;

	DECLARE OraInizio TIME;
	DECLARE OraFine TIME;
	DECLARE endLoop INT DEFAULT 0;

	-- controllo di sovrapposizione
	DECLARE cursoreTurni CURSOR FOR 
		SELECT T.OraInizio, T.OraFine
		FROM Turno T
		WHERE T.PianoSettimanale = NEW.PianoSettimanale
			AND T.Giorno = NEW.Giorno
            AND T.idTurno <> OLD.idTurno;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET endLoop = 1;
	OPEN cursoreTurni;
	controllo: LOOP
		FETCH cursoreTurni INTO OraInizio, OraFine;
		IF endLoop = 1 THEN LEAVE controllo;
		END IF;
		IF ((OraInizio <= NEW.OraInizio AND NEW.OraInizio < OraFine)
			OR (OraInizio < NEW.OraFine AND NEW.OraFine <= OraFine))
		THEN SIGNAL SQLSTATE '45000' 
			SET MESSAGE_TEXT = 'Sovrapposizione di turni';
		END IF;
	END LOOP;
	CLOSE cursoreTurni;

	-- controllo max 8 ore per giorno
	SET totSec = (
		SELECT IF(COUNT(*) = 0, 0, SUM(diff)) FROM (
			SELECT TIME_TO_SEC(TIMEDIFF(T.OraFine, T.OraInizio)) as diff, T.idTurno
			FROM Turno T
			WHERE T.PianoSettimanale = NEW.PianoSettimanale
				AND T.Giorno = NEW.Giorno
				AND T.idTurno <> OLD.idTurno) as T);
	SET newSec = TIME_TO_SEC(TIMEDIFF(NEW.OraFine, NEW.OraInizio));
	IF (newSec + totSec) > 28800 -- 28000 sec = 8 hr
		THEN SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Massimo di 8 ore lavorative per giorno';
	END IF;
END $$
DELIMITER ;


-- controlla che ci siano un tot di lavoratori non superiore
-- al numero massimo di lavoratori controllabili dai 
-- capicantieri con lo stesso piano settimanale
DROP TRIGGER IF EXISTS controlloLavoratoriPerCapocantiere;
DELIMITER $$
CREATE TRIGGER controlloLavoratoriPerCapocantiere
BEFORE INSERT ON Lavoratore
FOR EACH ROW
BEGIN
	DECLARE numLavoratori INT DEFAULT (
		SELECT COUNT(*) FROM Lavoratore L
		WHERE L.PianoSettimanale = NEW.PianoSettimanale);
	DECLARE maxLavoratori INT DEFAULT (
		SELECT IF(COUNT(*) = 0, 0, SUM(MaxLavoratori)) FROM (
			SELECT C.CodiceFiscale, C.MaxLavoratori
			FROM Capocantiere C
			WHERE C.PianoSettimanale = NEW.PianoSettimanale) as M);
	IF (maxLavoratori <= numLavoratori) THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Numero massimo di lavoratori coperti da capocantieri raggiunto';
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS AU_Lavoratore;
DELIMITER $$
CREATE TRIGGER AU_Lavoratore
AFTER UPDATE ON Lavoratore FOR EACH ROW
BEGIN
	DECLARE lavoro_ INT;
	DECLARE finito BIT DEFAULT 0;
	DECLARE cursoreLavori CURSOR FOR(
		SELECT distinct(T.Lavoro)
		FROM Turno T
		WHERE T.PianoSettimanale = NEW.PianoSettimanale);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
	IF(OLD.Stipendio <> NEW.Stipendio) THEN
		OPEN cursoreLavori;
		loopLavori: LOOP
			FETCH cursoreLavori INTO lavoro_;
			IF finito = 1 THEN LEAVE loopLavori; END IF;
			CALL costoLavoroSP(lavoro_);
		END LOOP;
		CLOSE cursoreLavori;
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS AU_Capocantiere;
DELIMITER $$
CREATE TRIGGER AU_Capocantiere
AFTER UPDATE ON Capocantiere FOR EACH ROW
BEGIN
	DECLARE lavoro_ INT;
	DECLARE finito BIT DEFAULT 0;
	DECLARE cursoreLavori CURSOR FOR(
		SELECT distinct(T.Lavoro)
		FROM Turno T
		WHERE T.PianoSettimanale = NEW.PianoSettimanale);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
	IF(OLD.Stipendio <> NEW.Stipendio) THEN
		OPEN cursoreLavori;
		loopLavori: LOOP
			FETCH cursoreLavori INTO lavoro_;
			IF finito = 1 THEN LEAVE loopLavori; END IF;
			CALL costoLavoroSP(lavoro_);
		END LOOP;
		CLOSE cursoreLavori;
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS AU_Responsabile;
DELIMITER $$
CREATE TRIGGER AU_Responsabile
AFTER UPDATE ON Responsabile FOR EACH ROW
BEGIN
	IF(OLD.Stipendio <> NEW.Stipendio) THEN
		CALL costoLavoroSP(NEW.Lavoro);
	END IF;
END $$
DELIMITER ;
DROP TRIGGER IF EXISTS inserimentoResponsabile;
DELIMITER $$
CREATE TRIGGER inserimentoResponsabile
BEFORE INSERT ON Responsabile
FOR EACH ROW
BEGIN
	IF (
		SELECT COUNT(*) FROM Responsabile
        WHERE Lavoro = NEW.Lavoro) <> 0
	THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Esiste gia un responsabile per questo lavoro';
	END IF;
END $$
DELIMITER ;

-- cancellazione vecchia area dopo 3 mesi
DROP EVENT IF EXISTS CancellazioneVecchieAree;
CREATE EVENT CancellazioneVecchieAree
ON SCHEDULE EVERY 2 WEEK
STARTS '2022-12-01 00:00:00'
DO 
	DELETE FROM Vecchia_Area
	WHERE Data_ < DATE_SUB(current_date, INTERVAL 3 MONTH); 


DROP EVENT IF EXISTS RegistrazioneSettimanale;
CREATE EVENT RegistrazioneSettimanale
ON SCHEDULE EVERY 7 DAY
STARTS '2022-12-01 00:00:00'
DO
	CALL storedProcedureRegistrazione_2(current_date());

DROP PROCEDURE IF EXISTS storedProcedureRegistrazione_2;
DELIMITER $$
CREATE PROCEDURE storedProcedureRegistrazione_2(IN _data DATE)
BEGIN
	DECLARE current_edificio INTEGER;
	DECLARE Finito INTEGER DEFAULT 0;
	DECLARE cursoreEdifici CURSOR FOR(
							SELECT E.idEdificio
							FROM Edificio E
							WHERE E.Completo = 1
						);

	DECLARE CONTINUE HANDLER
	FOR NOT FOUND SET Finito = 1;

	OPEN cursoreEdifici;
	preleva: LOOP
		FETCH cursoreEdifici INTO current_edificio;
		IF Finito = 1
		THEN LEAVE preleva;
		END IF;
		INSERT INTO Registrazione(Edificio, Data_) VALUES (current_edificio, _data);
	END LOOP;
    CLOSE cursoreEdifici;
END $$
DELIMITER ;