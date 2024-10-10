-- Regione
-- INSERT INTO regione(codRegione, Nome) VALUES( , '');
delete from regione;
INSERT INTO regione(codRegione, Nome) VALUES(1, 'Arezzo');
INSERT INTO regione(codRegione, Nome) VALUES(2, 'Firenze');
INSERT INTO regione(codRegione, Nome) VALUES(3, 'Grosseto');
INSERT INTO regione(codRegione, Nome) VALUES(4, 'Livorno');
INSERT INTO regione(codRegione, Nome) VALUES(5, 'Lucca');
INSERT INTO regione(codRegione, Nome) VALUES(6, 'Massa-Carrara');
INSERT INTO regione(codRegione, Nome) VALUES(7, 'Pisa');
INSERT INTO regione(codRegione, Nome) VALUES(8, 'Pistoia');
INSERT INTO regione(codRegione, Nome) VALUES(9, 'Prato');
INSERT INTO regione(codRegione, Nome) VALUES(10, 'Siena');

-- Area
-- INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(5, , '', 0., 0.);
/*
-- vettore CAPs 
52100, 52021, 52010, 52046, 52025, 52038, 
50031, 50028, 50050, 50053, 50121, 50054, 50023, 50065, 50019, 50039, 
58022, 58100, 58012, 58054, 
57022, 57121, 57025, 57036, 
55011, 55051, 55012, 55032, 55100, 55040, 55049, 55019, 
54011, 54033, 54100, 54027, 
56031, 56021, 56030, 56040, 56121, 56025, 56017, 
51024, 51013, 51017, 51100, 51019, 51010, 
59013, 59100, 
53011, 53045, 53035, 53036, 53037, 53100
*/
 delete from area;
 delete from confinearee;
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(52100, 1, 'Arezzo', 0.1, 0.3);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(52021, 1, 'Bucine', 0.1, 0.3);
INSERT INTO confinearee VALUES(52100, 52021);
-- INSERT INTO confinearee VALUES(52021, 52100);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(52010, 1, 'Chitignano', 0.1, 0.3);
INSERT INTO confinearee VALUES(52100, 52010);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(52046, 1, 'Lucignano', 0.1, 0.3);
INSERT INTO confinearee VALUES(52100, 52046);
INSERT INTO confinearee VALUES(52010, 52046);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(52025, 1, 'Montevarchi', 0.1, 0.3);
INSERT INTO confinearee VALUES(52021, 52025);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(52038, 1, 'Sestino', 0.1, 0.3);
INSERT INTO confinearee VALUES(52010, 52038);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(50031, 2, 'Barberino di Mugello', 0.2, 0.3);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(50028, 2, 'Barberino Tavarnelle', 0.1, 0.3);
INSERT INTO confinearee VALUES(50031, 50028);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(50050, 2, 'Cerreto Guidi', 0.1, 0.2);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(50053, 2, 'Empoli', 0.4, 0.1);
INSERT INTO confinearee VALUES(50050, 50053);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(50121, 2, 'Firenze', 0.5, 0.2);
INSERT INTO confinearee VALUES(50121, 50031);
INSERT INTO confinearee VALUES(50121, 50028);
INSERT INTO confinearee VALUES(50121, 52025);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(50054, 2, 'Fucecchio', 0.5, 0.1);
INSERT INTO confinearee VALUES(50050, 50054);
INSERT INTO confinearee VALUES(50053, 50054);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(50023, 2, 'Impruneta', 0.1, 0.2);
INSERT INTO confinearee VALUES(50121, 50023);
INSERT INTO confinearee VALUES(52025, 50023);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(50065, 2, 'Pontassieve', 0.3, 0.3);
INSERT INTO confinearee VALUES(50121, 50065);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(50019, 2, 'Sesto Fiorentino', 0.1, 0.2);
INSERT INTO confinearee VALUES(50121, 50019);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(50039, 2, 'Vicchio', 0.1, 0.3);
INSERT INTO confinearee VALUES(50121, 50039);
INSERT INTO confinearee VALUES(50031, 50039);
INSERT INTO confinearee VALUES(50028, 50039);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(58022, 3, 'Follonica', 0.1, 0.1);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(58100, 3, 'Grosseto', 0.2, 0.1);
INSERT INTO confinearee VALUES(58100, 58022);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(58012, 3, 'Isola del Giglio', 0.7, 0.0);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(58054, 3, 'Scansano', 0.1, 0.2);
INSERT INTO confinearee VALUES(58100, 58054);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(57022, 4, 'Castagneto Carducci', 0.2, 0.0);
INSERT INTO confinearee VALUES(58022, 57022);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(57121, 4, 'Livorno', 0.3, 0.0);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(57025, 4, 'Piombino', 0.2, 0.0);
INSERT INTO confinearee VALUES(58022, 57025);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(57036, 4, 'Porto Azzurro', 0.7, 0.0);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(55011, 5, 'Altopascio', 0.1, 0.1);
INSERT INTO confinearee VALUES(50054, 55011);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(55051, 5, 'Barga', 0.1, 0.3);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(55012, 5, 'Capannori', 0.1, 0.1);
INSERT INTO confinearee VALUES(55012, 55011);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(55032, 5, 'Castelnuovo di Garfagnana', 0.1, 0.3);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(55100, 5, 'Lucca', 0.1, 0.2);
INSERT INTO confinearee VALUES(55100, 55051);
INSERT INTO confinearee VALUES(55100, 55012);
INSERT INTO confinearee VALUES(55100, 55032);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(55040, 5, 'Stazzema', 0.1, 0.3);
INSERT INTO confinearee VALUES(55100, 55040);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(55049, 5, 'Viareggio', 0.2, 0.1);
INSERT INTO confinearee VALUES(55049, 55040);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(55019, 5, 'Villa Basilica', 0.1, 0.2);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(54011, 6, 'Aulla', 0.3, 0.4);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(54033, 6, 'Carrara', 0.1, 0.3);
INSERT INTO confinearee VALUES(54011, 54033);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(54100, 6, 'Massa', 0.2, 0.2);
INSERT INTO confinearee VALUES(54100, 54033);
INSERT INTO confinearee VALUES(54100, 55049);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(54027, 6, 'Pontremoli', 0.3, 0.5);
INSERT INTO confinearee VALUES(54011, 54027);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(56031, 7, 'Buti', 0.4, 0.2);
INSERT INTO confinearee VALUES(55011, 56031);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(56021, 7, 'Cascina', 0.1, 0.1);
INSERT INTO confinearee VALUES(56021, 56031);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(56030, 7, 'Lajatico', 0.1, 0.1);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(56040, 7, 'Orciano Pisano', 0.1, 0.1);
INSERT INTO confinearee VALUES(56030, 56040);
INSERT INTO confinearee VALUES(57121, 56040);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(56121, 7, 'Pisa', 0.5, 0.2);
INSERT INTO confinearee VALUES(56121, 56021);
INSERT INTO confinearee VALUES(56121, 57121);
INSERT INTO confinearee VALUES(56121, 56040);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(56025, 7, 'Pontedera', 0.3, 0.1);
INSERT INTO confinearee VALUES(56021, 56025);
INSERT INTO confinearee VALUES(56121, 56025);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(56017, 7, 'San Giuliano Terme', 0.1, 0.1);
INSERT INTO confinearee VALUES(56121, 56017);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(51024, 8, 'Abetone Cutigliano', 0.4, 0.4);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(51013, 8, 'Chiesina Uzzanese', 0.2, 0.1);
INSERT INTO confinearee VALUES(51013, 55011);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(51017, 8, 'Pescia', 0.4, 0.3);
INSERT INTO confinearee VALUES(51013, 51017);
INSERT INTO confinearee VALUES(55019, 51017);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(51100, 8, 'Pistoia', 0.2, 0.3);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(51019, 8, 'Ponte Buggianese', 0.1, 0.2);
INSERT INTO confinearee VALUES(51013, 51019);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(51010, 8, 'Uzzano', 0.1, 0.2);
INSERT INTO confinearee VALUES(51010, 51017);
INSERT INTO confinearee VALUES(51010, 51013);
INSERT INTO confinearee VALUES(51010, 51100);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(59013, 9, 'Montemurlo', 0.1, 0.2);
INSERT INTO confinearee VALUES(59013, 51100);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(59100, 9, 'Prato', 0.3, 0.2);
INSERT INTO confinearee VALUES(59013, 59100);
INSERT INTO confinearee VALUES(50019, 59100);
INSERT INTO confinearee VALUES(50121, 59100);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(53011, 10, 'Castellina in Chianti', 0.1, 0.1);
INSERT INTO confinearee VALUES(53011, 52021);
INSERT INTO confinearee VALUES(53011, 52025);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(53045, 10, 'Montepulciano', 0.1, 0.2);
INSERT INTO confinearee VALUES(52046, 53045);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(53035, 10, 'Monteriggioni', 0.1, 0.2);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(53036, 10, 'Poggibonsi', 0.2, 0.2);
INSERT INTO confinearee VALUES(53036, 53035);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(53037, 10, 'San Gimignano', 0.1, 0.1);
INSERT INTO confinearee VALUES(53036, 53037);
INSERT INTO confinearee VALUES(53035, 53037);
INSERT INTO confinearee VALUES(56030, 53037);
INSERT INTO area(CAP, Regione, Nome, RischioIdrogeologico, RischioSismico) VALUES(53100, 10, 'Siena', 0.1, 0.2);
INSERT INTO confinearee VALUES(53100, 53011);
INSERT INTO confinearee VALUES(53100, 53035);
INSERT INTO confinearee VALUES(53100, 52046);
INSERT INTO confinearee VALUES(53100, 53045);

INSERT INTO modificazioniterritorio VALUES(1, 'diga', 0.2, 0, 52046);
INSERT INTO modificazioniterritorio VALUES(2, 'ponte', 0.1, 0.05, 51013);
