DROP TABLE IF EXISTS Regione;
CREATE TABLE Regione(
	codRegione INT NOT NULL AUTO_INCREMENT,
	Nome VARCHAR(50) NOT NULL,
	PRIMARY KEY(codRegione)
);

DROP TABLE IF EXISTS Area;
CREATE TABLE Area(
	CAP INT NOT NULL,
	Regione INT NOT NULL, 
	Nome VARCHAR(50) NOT NULL,
	RischioIdrogeologico FLOAT NOT NULL,
	RischioSismico FLOAT NOT NULL,
	PRIMARY KEY(CAP),
	FOREIGN KEY(Regione) REFERENCES Regione(codRegione)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CHECK(
		RischioIdrogeologico >= 0 AND
		RischioIdrogeologico <= 1 AND
		RischioSismico <= 1 AND
		RischioSismico >= 0
	)
);

DROP TABLE IF EXISTS ConfineAree;
CREATE TABLE ConfineAree(
	Area1 INT NOT NULL, 
	Area2 INT NOT NULL,
	PRIMARY KEY(Area1, Area2),
	FOREIGN KEY(Area1) REFERENCES Area(CAP)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY(Area2) REFERENCES Area(CAP)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Vecchia_Area;
CREATE TABLE Vecchia_Area(
	Data_ DATETIME NOT NULL,
	CAP INT NOT NULL,
	RischioIdrogeologico FLOAT NOT NULL,
	RischioSismico FLOAT NOT NULL,
	PRIMARY KEY(CAP, Data_),
	CHECK(
		RischioIdrogeologico >= 0 AND
		RischioIdrogeologico <= 1 AND
		RischioSismico <= 1 AND
		RischioSismico >= 0
	)
);
DROP TABLE IF EXISTS PresetMateriale;
CREATE TABLE PresetMateriale(
	codLotto INT NOT NULL,
	Nome VARCHAR(50) NOT NULL,
	DataAcquisto DATE,
	CostoPerUnitaDiMisura INT NOT NULL,
	NomeFornitore VARCHAR(50) NOT NULL,
	Lunghezza INT NULL,
	Larghezza INT NULL,
	Altezza INT NULL,
	PRIMARY KEY(codLotto),
	CHECK(CostoPerUnitaDiMisura > 0 AND Lunghezza > 0 AND Larghezza > 0 AND Altezza > 0)
);

DROP TABLE IF EXISTS Parquet_;
CREATE TABLE Parquet_(
	idParquet_ INT NOT NULL AUTO_INCREMENT,
	CostoM2 INT NOT NULL,
	TipoLegno VARCHAR(50) NOT NULL,
	PRIMARY KEY(idParquet_),
	CHECK(CostoM2 > 0)
);

DROP TABLE IF EXISTS Piastrella;
CREATE TABLE Piastrella(
	idPiastrella  INT  NOT NULL AUTO_INCREMENT,
	CostoM2 INT NOT NULL,
	LunghezzaLato INT NOT NULL,
	NumLati INT NOT NULL,
	Materiale VARCHAR(50) NOT NULL,
	Disegno VARCHAR(50) NOT NULL,
	Fuga BIT NOT NULL,
	PRIMARY KEY(idPiastrella),
	CHECK(CostoM2 > 0 AND LunghezzaLato > 0 AND NumLati > 0)
);

DROP TABLE IF EXISTS Intonaco;
CREATE TABLE Intonaco(
	idIntonaco INT NOT NULL AUTO_INCREMENT,
	CostoM2 INT NOT NULL,
	Tipo VARCHAR(50) NOT NULL,
	PRIMARY KEY(idIntonaco),
	CHECK(CostoM2 > 0)
);

DROP TABLE IF EXISTS Pietra;
CREATE TABLE Pietra(
	idPietra INT NOT NULL AUTO_INCREMENT,
	CostoKG INT NOT NULL,
	PesoMedio INT NOT NULL,
	Tipo VARCHAR(50) NOT NULL,
	PRIMARY KEY(idPietra),
	CHECK(CostoKG > 0 AND PesoMedio > 0)
);

DROP TABLE IF EXISTS Alveoli;
CREATE TABLE Alveoli(
	PercentualeFori INT NOT NULL,
	Nome VARCHAR(50),
	PRIMARY KEY(PercentualeFori),
	CHECK(PercentualeFori >= 0 AND PercentualeFori < 100)
);

DROP TABLE IF EXISTS Mattone;
CREATE TABLE Mattone(
	codMattone INT NOT NULL AUTO_INCREMENT,
	Alveoli INT NOT NULL,
	Materiale VARCHAR(50) NOT NULL,
	Peso INT NOT NULL,
	Lunghezza INT NOT NULL,
	Larghezza INT NOT NULL,
	Altezza INT NOT NULL,
	Costo INT NOT NULL,
	Isolante BIT NOT NULL,
	PRIMARY KEY(codMattone, Alveoli),
	FOREIGN KEY(Alveoli) REFERENCES Alveoli(PercentualeFori)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CHECK(Costo > 0 AND Peso > 0 AND Lunghezza > 0 AND Altezza > 0 AND Larghezza > 0)
);
DROP TABLE IF EXISTS Edificio;
CREATE TABLE Edificio(
	idEdificio INT NOT NULL AUTO_INCREMENT,
	Area INT NOT NULL,
	NumeroPiani INT NOT NULL,
	inCostruzione BIT NOT NULL DEFAULT 1,
	completo BIT NOT NULL DEFAULT 0,
	Stato VARCHAR(50) NOT NULL DEFAULT 'perfetto',
	Salubrita VARCHAR(50) NOT NULL DEFAULT 'salubre',
	PRIMARY KEY(idEdificio),
	FOREIGN KEY(Area) REFERENCES Area(CAP)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CHECK (NumeroPiani > 0),
	CHECK (Stato = 'perfetto' 
			OR Stato = 'ottimo'
			OR Stato = 'buono'
			OR Stato = 'non sicuro'
			OR Stato = 'rischioso'
			OR Stato = 'pericolante'
	),
	CHECK (Salubrita = 'salubre'
			OR Salubrita = 'leggermente insalubre'
			OR Salubrita = 'insalubre'
			OR Salubrita = 'totalmente insalubre'
	)
);
DROP TABLE IF EXISTS Piano;
CREATE TABLE Piano(
	idPiano INT NOT NULL AUTO_INCREMENT,
	Edificio INT NOT NULL,
	NumeroPiano INT NOT NULL,
	NumeroVani INT NOT NULL,
	inCostruzione BIT NOT NULL DEFAULT 1,
	PRIMARY KEY(idPiano),
	FOREIGN KEY(Edificio) REFERENCES Edificio(idEdificio)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CHECK (NumeroVani > 0 AND NumeroPiano >= 0)
);
DROP TABLE IF EXISTS Vano;
CREATE TABLE Vano(
	idVano INT NOT NULL AUTO_INCREMENT,
	Piano INT NOT NULL,
	Altezza FLOAT NOT NULL,
	Lunghezza FLOAT NOT NULL,
	Larghezza FLOAT NOT NULL,
	X FLOAT NOT NULL,
	Y FLOAT NOT NULL,
	Tipo VARCHAR(50) NOT NULL,
	NumeroMuri INT NOT NULL,
	inCostruzione BIT NOT NULL DEFAULT 1,
	PRIMARY KEY(idVano),
	FOREIGN KEY(Piano) REFERENCES Piano(idPiano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CHECK(Altezza > 0 AND Lunghezza > 0 AND Larghezza > 0 AND X >= 0 AND Y >= 0 AND NumeroMuri > 2),
	CHECK (
		Tipo = 'cucina' OR
		Tipo = 'camera da letto' OR
		Tipo = 'sala da pranzo' OR
		Tipo = 'soggiorno' OR
		Tipo = 'mansarda' OR
		Tipo = 'cantina' OR
		Tipo = 'bagno' OR
		Tipo = 'ripostiglio' OR
		Tipo = 'magazzino' OR
		Tipo = 'ufficio' OR
		Tipo = 'scale' OR
		Tipo = 'ingresso' OR
		Tipo = 'corridoio'
	)
);
-- non ho voglia di fare file separati

DROP TABLE IF EXISTS VanoParquet;
CREATE TABLE VanoParquet(
	idVano INT NOT NULL,
	Parquet_ INT NOT NULL,
	PRIMARY KEY(idVano, Parquet_),
	FOREIGN KEY(idVano) REFERENCES Vano(idVano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY(Parquet_) REFERENCES Parquet_(idParquet_)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS VanoPiastrella;
CREATE TABLE VanoPiastrella(
	idVano INT NOT NULL,
	Piastrella INT NOT NULL,
	PRIMARY KEY(idVano, Piastrella),
	FOREIGN KEY(idVano) REFERENCES Vano(idVano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY(Piastrella) REFERENCES Piastrella(idPiastrella)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS VanoPietra;
CREATE TABLE VanoPietra(
	idVano INT NOT NULL,
	Pietra INT NOT NULL,
	SuperficieMedia INT NOT NULL,
	Disposizione VARCHAR(50) NOT NULL,
	CHECK(SuperficieMedia > 0),
	PRIMARY KEY(idVano, Pietra),
	FOREIGN KEY(idVano) REFERENCES Vano(idVano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY(Pietra) REFERENCES Pietra(idPietra)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS VanoStrato;
CREATE TABLE VanoStrato(
	idVano INT NOT NULL,
	Strato INT NOT NULL,
	PRIMARY KEY(idVano, Strato),
	FOREIGN KEY(idVano) REFERENCES Vano(idVano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY(Strato) REFERENCES PresetMateriale(codLotto)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS VanoIntonaco;
CREATE TABLE VanoIntonaco(
	idVano INT NOT NULL,
	Intonaco INT NOT NULL,
	Spessore INT NOT NULL,
	numStrati INT NOT NULL DEFAULT 1,
	PRIMARY KEY(idVano, Intonaco),
	FOREIGN KEY(idVano) REFERENCES Vano(idVano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY(Intonaco) REFERENCES Intonaco(idIntonaco)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CHECK(Spessore > 0),
	CHECK(numStrati > 0)
);

DROP TABLE IF EXISTS VanoPavimentazione;
CREATE TABLE VanoPavimentazione(
	idVano INT NOT NULL,
	Pavimentazione INT NOT NULL,
	PRIMARY KEY(idVano, Pavimentazione),
	FOREIGN KEY(idVano) REFERENCES Vano(idVano)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY(Pavimentazione) REFERENCES PresetMateriale(codLotto)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);


	-- si permette NULL a Edificio finchè non è legato a vano tramite delimitazione
-- l'attributo resta nullo solo per il periodo di inserimento di tutti i dati dell'edificio nel database
DROP TABLE IF EXISTS Muro;
CREATE TABLE Muro(
	idMuro INT NOT NULL AUTO_INCREMENT,
	Altezza FLOAT NOT NULL,
	X1 FLOAT NOT NULL,
	Y1 FLOAT NOT NULL,
	X2 FLOAT NOT NULL,
	Y2 FLOAT NOT NULL,

	Interno BIT NOT NULL,
	Edificio INT,
	PRIMARY KEY(idMuro),
	FOREIGN KEY(Edificio) REFERENCES Edificio(idEdificio)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CHECK(
		X1 >= 0 AND 
		X2 >= 0 AND
		Y2 >= 0 AND
		Y2 >= 0 AND
		(X1<>X2 OR Y1<>Y2))
);
DROP TABLE IF EXISTS MuroPietra;
CREATE TABLE MuroPietra(
	Muro INT NOT NULL,
	Pietra INT NOT NULL,
	PRIMARY KEY(Muro, Pietra),
	FOREIGN KEY(Muro) REFERENCES Muro(idMuro)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY(Pietra) REFERENCES Pietra(idPietra)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS MuroMattone;
CREATE TABLE MuroMattone(
	Muro INT NOT NULL,
	Mattone INT NOT NULL,
	Alveoli INT NOT NULL,
	PRIMARY KEY(Muro, Mattone, Alveoli),
	FOREIGN KEY(Muro) REFERENCES Muro(idMuro)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY(Mattone, Alveoli) REFERENCES Mattone(codMattone, Alveoli)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS MuroPreset;
CREATE TABLE MuroPreset(
	Muro INT NOT NULL,
	Preset INT NOT NULL,
	PRIMARY KEY(Muro, Preset),
	FOREIGN KEY(Muro) REFERENCES Muro(idMuro)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY(Preset) REFERENCES PresetMateriale(codLotto)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);
DROP TABLE IF EXISTS Balcone;
CREATE TABLE Balcone(
	Muro INT NOT NULL AUTO_INCREMENT,
	Lunghezza FLOAT NOT NULL,
	Larghezza FLOAT NOT NULL,
	PRIMARY KEY(Muro),
	FOREIGN KEY(Muro) REFERENCES Muro(idMuro)
		ON DELETE CASCADE
		ON UPDATE CASCADE, 
	CHECK (Lunghezza > 0 AND Larghezza > 0)
);
DROP TABLE IF EXISTS Delimitazione;
CREATE TABLE Delimitazione(
	Vano INT NOT NULL,
	Muro INT NOT NULL,
	PRIMARY KEY(Vano, Muro),
	FOREIGN KEY(Vano) REFERENCES Vano(idVano)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY(Muro) REFERENCES Muro(idMuro)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);
DROP TABLE IF EXISTS AperturaMuro;
CREATE TABLE AperturaMuro(
	idApertura INT NOT NULL AUTO_INCREMENT,
	Muro INT NOT NULL,
	Altezza FLOAT NOT NULL,
	AltezzaDaTerra FLOAT NOT NULL,
	Larghezza FLOAT NOT NULL,
	DistanzaMuro FLOAT NOT NULL,
	Tipo VARCHAR(50) NOT NULL,
	PuntoCardinale VARCHAR(2) NOT NULL DEFAULT 'N',
	PRIMARY KEY(idApertura),
	FOREIGN KEY(Muro) REFERENCES Muro(idMuro)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CHECK (Altezza > 0 AND AltezzaDaTerra >= 0 AND Larghezza > 0 AND DistanzaMuro >= 0),
	CHECK (
			((Tipo = 'porta' OR
			Tipo = 'portafinestra' OR
			Tipo = 'apertura senza serramenti' OR
			Tipo = 'arco') AND AltezzaDaTerra = 0)
		OR Tipo = 'finestra'
	),
    CHECK (
		PuntoCardinale = 'N' OR
		PuntoCardinale = 'NE' OR
		PuntoCardinale = 'E' OR
		PuntoCardinale = 'SE' OR
		PuntoCardinale = 'S' OR
		PuntoCardinale = 'SW' OR
		PuntoCardinale = 'W' OR
		PuntoCardinale = 'NW'
    )
);
DROP TABLE IF EXISTS Sensore;
CREATE TABLE Sensore(
	codSensore INT NOT NULL AUTO_INCREMENT,
	Muro INT NOT NULL,
	Tipo VARCHAR(50) NOT NULL,
	Soglia FLOAT NOT NULL,
	valMinimo FLOAT NOT NULL,
	valMassimo FLOAT NOT NULL,
	DistanzaOrigineMuro FLOAT NOT NULL,
	AltezzaDaTerra FLOAT NOT NULL,
	Asse CHAR(1) NOT NULL DEFAULT 'x',
	PRIMARY KEY(codSensore),
	FOREIGN KEY(Muro) REFERENCES Muro(idMuro)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CHECK (
		AltezzaDaTerra >= 0 AND
		DistanzaOrigineMuro >= 0 AND
		valMinimo < valMassimo),
	CHECK (
		Tipo = 'accelerometro' OR
		Tipo = 'giroscopio' OR
		Tipo = 'termometro' OR
		Tipo = 'rilevatore di umidità' OR
		Tipo = 'rilevatore di infiltrazioni' OR
		Tipo = 'pluviometro' OR
		Tipo = 'fessurimetro'
	),
	CHECK ( 
		(Tipo = 'termometro' AND Soglia < (valMassimo-valMinimo)/2) OR
		Tipo <> 'termometro'
	)
);

DROP TABLE IF EXISTS Campionamento;
CREATE TABLE Campionamento(
	numCampionamento INT NOT NULL AUTO_INCREMENT,
	Sensore INT NOT NULL,
	valMisurato FLOAT NOT NULL,
	Data_ DATETIME NOT NULL,
	PRIMARY KEY(numCampionamento, Sensore),
	FOREIGN KEY(Sensore) REFERENCES Sensore(codSensore)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

DROP TABLE IF EXISTS Alert;
CREATE TABLE Alert(
	Campionamento INT NOT NULL,
	Sensore INT NOT NULL,
	Timestamp_	DATETIME NOT NULL,
	PRIMARY KEY(Campionamento, Sensore),
	FOREIGN KEY(Campionamento, Sensore) REFERENCES Campionamento(numCampionamento, Sensore)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

DROP TABLE IF EXISTS Registrazione;
CREATE TABLE Registrazione(
	codRegistrazione INT NOT NULL AUTO_INCREMENT,
	Edificio INT NOT NULL,
	Data_ DATE NOT NULL,
	PRIMARY KEY(codRegistrazione, Edificio),
	FOREIGN KEY(Edificio) REFERENCES Edificio(idEdificio)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

DROP TABLE IF EXISTS Report;
CREATE TABLE Report(
	idReport INT NOT NULL AUTO_INCREMENT,
	Registrazione INT NOT NULL,
	Edificio INT NOT NULL,
	Data_ DATE NOT NULL,
	PRIMARY KEY(idReport),
	FOREIGN KEY(Registrazione, Edificio) REFERENCES Registrazione(codRegistrazione, Edificio)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

DROP TABLE IF EXISTS Monitorazione;
CREATE TABLE Monitorazione(
	Report INT NOT NULL,
	Muro INT NOT NULL,
	Stato INT NOT NULL,
	Danno VARCHAR(50) NOT NULL,
	PRIMARY KEY(Report, Muro),
	FOREIGN KEY(Report) REFERENCES Report(idReport)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY(Muro) REFERENCES Muro(idMuro)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CHECK (
		Danno = 'nessuno' OR
		Danno = 'crepa' OR
		Danno = 'infiltrazione' OR
		Danno = 'umidità capillare'
	),
	CHECK ( Stato >= 0 AND Stato < 6 )
	/*
		Stato = 'perfetto' OR
		Stato = 'ottimo' OR
		Stato = 'buono' OR
		Stato = 'non sicuro' OR
		Stato = 'pessimo' OR
		Stato = 'irrecuperabile'
		*/
);

DROP TABLE IF EXISTS RegistrazioneCampionamenti;
CREATE TABLE RegistrazioneCampionamenti(
	Campionamento INT NOT NULL,
	Sensore INT NOT NULL,
	Registrazione INT NOT NULL,
	Edificio INT NOT NULL,
	PRIMARY KEY(Campionamento, Sensore, Registrazione, Edificio),
	FOREIGN KEY(Campionamento, Sensore) REFERENCES Campionamento(numCampionamento, Sensore)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY(Registrazione, Edificio) REFERENCES Registrazione(codRegistrazione, Edificio)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

-- Progetto(codProgetto, Edificio,dataPresentazione, dataApprovazione, dataInizio, stimaDataFine, dataFine)
DROP TABLE IF EXISTS Progetto;
CREATE TABLE Progetto(
	CodProgetto INT NOT NULL AUTO_INCREMENT,
	Edificio INT NOT NULL,
	DataPresentazione DATE NOT NULL,
	DataApprovazione DATE NOT NULL,
	DataInizio DATE NOT NULL,
	StimaDataFine DATE NOT NULL,
	DataFine DATE DEFAULT NULL,
	PRIMARY KEY (codProgetto, Edificio),
	FOREIGN KEY (Edificio) REFERENCES Edificio(idEdificio)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CHECK(StimaDataFine > DataInizio AND DataFine > DataInizio)
);

-- Stadio(numStadio, Progetto, dataInizio, stimaDataFine)
DROP TABLE IF EXISTS Stadio;
CREATE TABLE Stadio(
	numStadio INT NOT NULL AUTO_INCREMENT,
	Progetto INT NOT NULL, 
	Edificio INT NOT NULL,
	DataInizio DATE NOT NULL, 
	StimaDataFine DATE NOT NULL,
	DataFine DATE DEFAULT NULL,
	PRIMARY KEY(numStadio, Progetto, Edificio),
	FOREIGN KEY(Progetto, Edificio) REFERENCES Progetto(CodProgetto, Edificio)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CHECK(StimaDataFine > DataInizio AND DataFine > DataInizio)
);

-- Lavoro( idLavoro, Stadio, Costo, Descrizione)
DROP TABLE IF EXISTS Lavoro;
CREATE TABLE Lavoro(
	idLavoro INT NOT NULL AUTO_INCREMENT,
	Descrizione VARCHAR(300) NOT NULL,
	Costo INT NOT NULL DEFAULT 0,
	PRIMARY KEY(idLavoro), 
    CHECK (Costo >= 0)
);

-- ConsiglioIntervento( Lavoro, Report, Muro, Urgenza)
-- Muro potato perche inapplicabile nel dubbio non cancello perche magari ci riserve
-- Monitorazione (Report, Muro)
DROP TABLE IF EXISTS ConsiglioIntervento;
CREATE TABLE ConsiglioIntervento(
	Lavoro INT NOT NULL,
	Report INT NOT NULL,
	Urgenza INT NOT NULL DEFAULT 3,
	PRIMARY KEY(Lavoro, Report),
	FOREIGN KEY(Lavoro) REFERENCES Lavoro(idLavoro)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY(Report) REFERENCES Report(idReport)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CHECK (Urgenza >= 1 AND Urgenza <= 3)
);
-- LavoroProgetto( Lavoro, Stadio, Progetto)
DROP TABLE IF EXISTS LavoroProgetto;
CREATE TABLE LavoroProgetto(
	Lavoro INT NOT NULL,
	Progetto INT NOT NULL,
	Stadio INT NOT NULL,
	Edificio INT NOT NULL,
	PRIMARY KEY(Lavoro, Stadio, Progetto, Edificio),
	FOREIGN KEY(Stadio, Progetto, Edificio) REFERENCES Stadio(numStadio, Progetto, Edificio)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);


DROP TABLE IF EXISTS BaseLavoroVano;
CREATE TABLE BaseLavoroVano(
	idVano INT NOT NULL,
	Lavoro INT NOT NULL,
	PRIMARY KEY(idVano, Lavoro),
	FOREIGN KEY(idVano) REFERENCES Vano(idVano)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY(Lavoro) REFERENCES Lavoro(idLavoro)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

DROP TABLE IF EXISTS BaseLavoroMuro;
CREATE TABLE BaseLavoroMuro(
	Muro INT NOT NULL,
	Lavoro INT NOT NULL,
	PRIMARY KEY(Muro, Lavoro),
	FOREIGN KEY(Muro) REFERENCES Muro(idMuro)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY(Lavoro) REFERENCES Lavoro(idLavoro)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);
-- SimulazioneCalamita(idSimulazione, Tipo, Gravita, Area)
DROP TABLE IF EXISTS SimulazioneCalamita;
CREATE TABLE SimulazioneCalamita(
	idSimulazione INT NOT NULL,
	Tipo VARCHAR(100) NOT NULL,
	Gravita INT NOT NULL DEFAULT 0,
	Area INT NOT NULL,
	PRIMARY KEY (idSimulazione),
	FOREIGN KEY (Area) REFERENCES Area(CAP)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CHECK (Gravita >= 1 AND Gravita <= 10), 
	CHECK (
		Tipo = 'sisma' OR 
		Tipo = 'alluvione' OR
		Tipo = 'esondazione' OR
		Tipo = 'ondata di caldo' OR
		Tipo = 'ondata di freddo' OR
		Tipo = 'frana')
);
-- EventoCalamitoso(idCalamita, Tipo, Data, Gravita, Area)
DROP TABLE IF EXISTS EventoCalamitoso;
CREATE TABLE EventoCalamitoso(
	idCalamita INT NOT NULL,
	Tipo VARCHAR(100) NOT NULL,
	DataEvento DATE NOT NULL,
	Gravita INT NOT NULL DEFAULT 0,
	Area INT NOT NULL,
	PRIMARY KEY (idCalamita),
	FOREIGN KEY (Area) REFERENCES Area(CAP)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CHECK (Gravita >= 1 AND Gravita <= 10), 
	CHECK (
		Tipo = 'sisma' OR 
		Tipo = 'alluvione' OR
		Tipo = 'esondazione' OR
		Tipo = 'ondata di caldo' OR
		Tipo = 'ondata di freddo' OR
		Tipo = 'frana')
);
-- NuovaCostruzione(idNuovaCostruzione, Tipo, Modificatore, Area)
DROP TABLE IF EXISTS ModificazioniTerritorio;
CREATE TABLE ModificazioniTerritorio(
	idModificazioniTerritorio INT NOT NULL,
	Tipo VARCHAR(100) NOT NULL,
	ModificatoreIdrogeologico FLOAT NOT NULL DEFAULT 0,
	ModificatoreSismico FLOAT NOT NULL DEFAULT 0,
	Area INT NOT NULL,
	PRIMARY KEY (idModificazioniTerritorio),
	FOREIGN KEY (Area) REFERENCES Area(CAP)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CHECK (ModificatoreIdrogeologico >= 0 AND ModificatoreIdrogeologico <= 0.9),
	CHECK (ModificatoreSismico >= 0 AND ModificatoreSismico <= 0.9)
);
-- DanniStimati(Simulazione, Edificio, Descrizione)
DROP TABLE IF EXISTS DanniStimati;
CREATE TABLE DanniStimati(
	Simulazione INT NOT NULL,
	Edificio INT NOT NULL,
	Descrizione VARCHAR(300) NOT NULL,
	PRIMARY KEY (Simulazione, Edificio),
	FOREIGN KEY (Simulazione) REFERENCES SimulazioneCalamita(idSimulazione)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY (Edificio) REFERENCES Edificio(idEdificio)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

-- =====================================================
-- ============ TABLES =================================
-- =====================================================

-- Responsabile(CodiceFiscale, Nome, Cognome, Lavoro)
-- Aggiunto attributo stipendio per il calcolo costo del lavoro
DROP TABLE IF EXISTS Responsabile;
CREATE TABLE Responsabile(
	CodiceFiscale CHAR(16) NOT NULL,
	Nome VARCHAR(50) NOT NULL,
	Cognome VARCHAR(50) NOT NULL,
	Lavoro INT NOT NULL,
	Stipendio INT NOT NULL,
	PRIMARY KEY(CodiceFiscale),
	FOREIGN KEY(Lavoro) REFERENCES Lavoro(idLavoro)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CHECK (Stipendio > 0)
);


-- PianoSettimanaleLavoratore(idPiano)
DROP TABLE IF EXISTS PianoSettimanale;
CREATE TABLE PianoSettimanale(
	idPiano INT NOT NULL,
	PRIMARY KEY(idPiano)
);

-- TurnoLavoratore(NumeroTurno, PianoSettimanale, Giorno, OraInizio, OraFine)
DROP TABLE IF EXISTS Turno;
CREATE TABLE Turno(
	idTurno INT NOT NULL,
	PianoSettimanale INT NOT NULL,
	Giorno CHAR(3) NOT NULL,
	OraInizio TIME(0) NOT NULL DEFAULT '08:30:00',
	OraFine TIME(0) NOT NULL DEFAULT '12:30:00',
	Lavoro INT NOT NULL,
	PRIMARY KEY(idTurno),
	FOREIGN KEY(PianoSettimanale) REFERENCES PianoSettimanale(idPiano)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY(Lavoro) REFERENCES Lavoro(idLavoro)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CHECK (Giorno = 'lun' OR Giorno = 'mar' OR Giorno = 'mer' OR Giorno = 'gio' OR Giorno = 'ven'),
	CHECK (OraFine > OraInizio)
);

-- Capocantiere(CodiceFiscale, Nome, Cognome,PianoSettimanale, MaxLavoratori)
-- aggiunto stipendio per calcolo costo del lavoro
DROP TABLE IF EXISTS Capocantiere;
CREATE TABLE Capocantiere(
	CodiceFiscale CHAR(16) NOT NULL,
	Nome VARCHAR(50) NOT NULL,
	Cognome VARCHAR(50) NOT NULL,
	PianoSettimanale INT NOT NULL,
	MaxLavoratori INT NOT NULL DEFAULT 15,
	Stipendio INT NOT NULL,
	PRIMARY KEY(CodiceFiscale),
	FOREIGN KEY(PianoSettimanale) REFERENCES PianoSettimanale(idPiano)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CHECK (MaxLavoratori > 0),
	CHECK (Stipendio > 0)
);

-- Lavoratore(CodiceFiscale, Nome, Cognome, Lavoro)
-- aggiunto stipendio per calcolo costo del lavoro
DROP TABLE IF EXISTS Lavoratore;
CREATE TABLE Lavoratore(
	CodiceFiscale CHAR(16) NOT NULL,
	Nome VARCHAR(50) NOT NULL,
	Cognome VARCHAR(50) NOT NULL,
	PianoSettimanale INT NOT NULL,
	Stipendio INT NOT NULL,
	PRIMARY KEY(CodiceFiscale),
	FOREIGN KEY(PianoSettimanale) REFERENCES PianoSettimanale(idPiano)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CHECK(Stipendio > 0)
);
