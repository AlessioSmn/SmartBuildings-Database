INSERT INTO Progetto(CodProgetto, Edificio, DataPresentazione, DataApprovazione, DataInizio, StimaDataFine, DataFine)
	VALUES(1, 1, '2020-01-01', '2020-04-01', '2020-05-01', '2023-10-01', NULL);
INSERT INTO Stadio(numStadio, Progetto, Edificio, DataInizio, StimaDataFine, DataFine)
	VALUES(1, 1, 1, '2020-07-01', '2021-07-01', '2021-07-01');
INSERT INTO Lavoro(idLavoro, Descrizione, Costo) VALUES(111, 'Costruzione vani più grandi', 0);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(111, 100);
INSERT INTO Responsabile(CodiceFiscale, Nome, Cognome, Stipendio, Lavoro)
	VALUES('LOMFRA01A70QGHUM', 'Francesco', 'Lombardi', 3030, 111);
INSERT INTO LavoroProgetto(Lavoro, Edificio, Progetto, Stadio) VALUES(111, 1, 1, 1);
INSERT INTO Lavoro(idLavoro, Descrizione, Costo) VALUES(112, 'Costruzione vani più piccoli', 0);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(112, 101);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(112, 102);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(112, 103);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(112, 104);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(112, 105);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(112, 106);
INSERT INTO Responsabile(CodiceFiscale, Nome, Cognome, Stipendio, Lavoro)
	VALUES('RSSLRN01A70QGHUM', 'Lorenzo', 'Rossi', 3030, 112);
INSERT INTO LavoroProgetto(Lavoro, Edificio, Progetto, Stadio) VALUES(112, 1, 1, 1);

INSERT INTO Stadio(numStadio, Progetto, Edificio, DataInizio, StimaDataFine, DataFine)
	VALUES(2, 1, 1, '2021-07-01', '2023-07-01', NULL);
INSERT INTO Lavoro(idLavoro, Descrizione, Costo) VALUES(121, 'Costruzione muri esterni', 0);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 100);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 101);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 102);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 103);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 121);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 120);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 119);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 122);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 110);
INSERT INTO Responsabile(CodiceFiscale, Nome, Cognome, Stipendio, Lavoro)
	VALUES('LOMBEA01A70RCVSC', 'Beatrice', 'Lombardi', 3030, 121);
INSERT INTO LavoroProgetto(Lavoro, Edificio, Progetto, Stadio) VALUES(121, 1, 1, 2);
INSERT INTO Lavoro(idLavoro, Descrizione, Costo) VALUES(122, 'Costruzione muri interni', 0);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 104);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 105);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 106);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 107);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 108);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 109);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 111);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 112);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 113);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 114);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 115);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 116);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 117);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 118);
INSERT INTO Responsabile(CodiceFiscale, Nome, Cognome, Stipendio, Lavoro)
	VALUES('FONAUR01A70BWKFN', 'Aurora', 'Fontana', 3060, 122);
INSERT INTO LavoroProgetto(Lavoro, Edificio, Progetto, Stadio) VALUES(122, 1, 1, 2);

/*

INSERT INTO Progetto(CodProgetto, Edificio, DataPresentazione, DataApprovazione, DataInizio, StimaDataFine, DataFine)
	VALUES(1, 1, '2020-01-01', '2020-04-01', '2020-05-01', '2023-10-01', NULL);
INSERT INTO Stadio(numStadio, Progetto, Edificio, DataInizio, StimaDataFine, DataFine)
	VALUES(1, 1, 1, '2020-07-01', '2021-07-01', '2021-07-01');
INSERT INTO Lavoro(idLavoro, Descrizione, Costo) VALUES(111, 'Scavi', 3000);
INSERT INTO Responsabile(CodiceFiscale, Nome, Cognome, Stipendio, Lavoro)
	VALUES('LOMFRA01A70QGHUM', 'Francesco', 'Lombardi', 3030, 111);
INSERT INTO LavoroProgetto(Lavoro, Edificio, Progetto, Stadio) VALUES(111, 1, 1, 1);
INSERT INTO Lavoro(idLavoro, Descrizione, Costo) VALUES(112, 'Posa delle fondazioni', 8000);
INSERT INTO Responsabile(CodiceFiscale, Nome, Cognome, Stipendio, Lavoro)
	VALUES('MARALE01A70LNLFD', 'Alessandro', 'Marino', 3110, 112);
INSERT INTO LavoroProgetto(Lavoro, Edificio, Progetto, Stadio) VALUES(112, 1, 1, 1);
INSERT INTO Lavoro(idLavoro, Descrizione, Costo) VALUES(113, 'Costruzione travi portanti', 5000);
INSERT INTO Responsabile(CodiceFiscale, Nome, Cognome, Stipendio, Lavoro)
	VALUES('LOMBEA01A70RCVSC', 'Beatrice', 'Lombardi', 3030, 113);
INSERT INTO LavoroProgetto(Lavoro, Edificio, Progetto, Stadio) VALUES(113, 1, 1, 1);
INSERT INTO Lavoro(idLavoro, Descrizione, Costo) VALUES(114, 'Costruzione tetto', 10000);
INSERT INTO Responsabile(CodiceFiscale, Nome, Cognome, Stipendio, Lavoro)
	VALUES('FONAUR01A70BWKFN', 'Aurora', 'Fontana', 3060, 114);
INSERT INTO LavoroProgetto(Lavoro, Edificio, Progetto, Stadio) VALUES(114, 1, 1, 1);
INSERT INTO Stadio(numStadio, Progetto, Edificio, DataInizio, StimaDataFine, DataFine)
	VALUES(2, 1, 1, '2021-07-01', '2021-11-01', '2021-11-01');
INSERT INTO Lavoro(idLavoro, Descrizione, Costo) VALUES(121, 'Costruzione e rivestimenti muri portanti', 0);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 100);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 101);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 102);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 103);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 110);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 119);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 120);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 121);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(121, 122);
INSERT INTO Responsabile(CodiceFiscale, Nome, Cognome, Stipendio, Lavoro)
	VALUES('MORGIU01A70XWFNF', 'Giulia', 'Moretti', 3090, 121);
INSERT INTO LavoroProgetto(Lavoro, Edificio, Progetto, Stadio) VALUES(121, 1, 1, 2);
INSERT INTO Lavoro(idLavoro, Descrizione, Costo) VALUES(122, 'Costruzione e rivestimenti muri non portanti', 0);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 104);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 105);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 106);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 107);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 108);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 109);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 111);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 112);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 113);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 114);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 115);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 116);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 117);
INSERT INTO baseLavoroMuro(Lavoro, Muro) VALUES(122, 118);
INSERT INTO Responsabile(CodiceFiscale, Nome, Cognome, Stipendio, Lavoro)
	VALUES('BRULOR01A70SRTKJ', 'Lorenzo', 'Bruno', 3010, 122);
INSERT INTO LavoroProgetto(Lavoro, Edificio, Progetto, Stadio) VALUES(122, 1, 1, 2);
INSERT INTO Stadio(numStadio, Progetto, Edificio, DataInizio, StimaDataFine, DataFine)
	VALUES(3, 1, 1, '2021-11-01', '2022-03-01', '2022-03-01');
INSERT INTO Lavoro(idLavoro, Descrizione, Costo) VALUES(131, 'Pavimentazione vani', 0);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(131, 100);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(131, 101);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(131, 102);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(131, 103);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(131, 104);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(131, 105);
INSERT INTO baseLavoroVano(Lavoro, idVano) VALUES(131, 106);
INSERT INTO Responsabile(CodiceFiscale, Nome, Cognome, Stipendio, Lavoro)
	VALUES('GIOGIN01A70PGGXR', 'Ginevra', 'Giordano', 3040, 131);
INSERT INTO LavoroProgetto(Lavoro, Edificio, Progetto, Stadio) VALUES(131, 1, 1, 3);
*/