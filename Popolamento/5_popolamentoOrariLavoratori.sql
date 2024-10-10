INSERT INTO PianoSettimanale(idPiano) VALUES(1);
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(10, 1, 111, 'lun', '08:30:00', '12:30:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(11, 1, 111, 'lun', '14:30:00', '18:30:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(12, 1, 111, 'mar', '08:30:00', '12:30:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(13, 1, 111, 'mar', '14:30:00', '18:30:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(14, 1, 111, 'mer', '08:30:00', '12:30:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(15, 1, 111, 'mer', '14:30:00', '18:30:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(16, 1, 112, 'gio', '08:30:00', '12:30:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(17, 1, 112, 'gio', '14:30:00', '18:30:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(18, 1, 112, 'ven', '08:30:00', '12:30:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(19, 1, 112, 'ven', '14:30:00', '18:30:00');
INSERT INTO PianoSettimanale(idPiano) VALUES(2);
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(20, 2, 121, 'lun', '08:00:00', '12:00:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(21, 2, 121, 'lun', '14:00:00', '18:00:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(22, 2, 121, 'mar', '08:00:00', '12:00:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(23, 2, 121, 'mar', '14:00:00', '18:00:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(24, 2, 122, 'mer', '08:00:00', '12:00:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(25, 2, 122, 'mer', '14:00:00', '18:00:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(26, 2, 122, 'gio', '08:00:00', '12:00:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(27, 2, 122, 'gio', '14:00:00', '18:00:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(28, 2, 122, 'ven', '08:00:00', '12:00:00');
INSERT INTO Turno(idTurno, PianoSettimanale, Lavoro, Giorno, OraInizio, OraFine) VALUES(29, 2, 122, 'ven', '14:00:00', '18:00:00');

INSERT INTO Capocantiere(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale, Maxlavoratori)
	VALUES('FRNLLN70A41ABCDX', 'Liliana', 'Fiorentino', 3000, 1, 15);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('MRCFRN81A01ABCDX', 'Franco', 'Marcelo', 1200, 1);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('PGNLMA82A41ABCDX', 'Alma', 'Pagnotto', 1200, 1);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('MNCGRG83A01ABCDX', 'Gregorio', 'Mancini', 1200, 1);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('LCHDLM84A01ABCDX', 'Adelmio', 'Lucchesi', 1200, 1);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('SLABND85A41ABCDX', 'Benedetta', 'Sal', 1200, 1);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('CLMRCC86A01ABCDX', 'Riccardo', 'Colombo', 1200, 1);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('MLNVLR87A01ABCDX', 'Valerio', 'Milano', 1200, 1);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('GRCRCE88A41ABCDX', 'Erica', 'Greco', 1200, 1);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('CSSNGL89A41ABCDX', 'Cassandra', 'Angelo', 1200, 1);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('PDVLSS80A41ABCDX', 'Alessandra', 'Padovesi', 1200, 1);

INSERT INTO Capocantiere(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale, Maxlavoratori)
	VALUES('RCCMRN70A01ABCDX', 'Marino', 'Ricci', 2700, 2, 10);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('DRSGDT81A41ABCDX', 'Giuditta', 'DeRose', 1100, 2);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('CPNLDB82A01ABCDX', 'Ildebrando', 'Capon', 1100, 2);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('LGOPNC83A41ABCDX', 'Olga', 'Panicucci', 1100, 2);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('MZZMLE84A41ABCDX', 'Emilia', 'Mazzanti', 1100, 2);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('TRVVRG85A01ABCDX', 'Virginio', 'Trevisan', 1100, 2);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('BNVGCB86A01ABCDX', 'Giacobbe', 'Beneventi', 1100, 2);
INSERT INTO Lavoratore(CodiceFiscale, Nome, Cognome, Stipendio, PianoSettimanale) VALUES('RSLSGS87A41ABCDX', 'Rosalia', 'Sagese', 1100, 2);