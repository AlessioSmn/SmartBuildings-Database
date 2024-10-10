delete from Mattone;
delete from Alveoli;
delete from Pietra;
delete from Intonaco;
delete from Piastrella;
delete from Parquet_;
delete from PresetMateriale;

INSERT INTO parquet_(idParquet_, CostoM2, TipoLegno) VALUES(1, 800, 'rovere');
INSERT INTO parquet_(idParquet_, CostoM2, TipoLegno) VALUES(2, 2000, 'ciliegio');
INSERT INTO parquet_(idParquet_, CostoM2, TipoLegno) VALUES(3, 1200, 'noce');
INSERT INTO parquet_(idParquet_, CostoM2, TipoLegno) VALUES(4, 3500, 'mogano');

INSERT INTO piastrella(idPiastrella, CostoM2, LunghezzaLato, NumLati, Materiale, Disegno, Fuga) VALUES(1, 17, 30, 4, 'porcellanato', 'naturale', 1);
INSERT INTO piastrella(idPiastrella, CostoM2, LunghezzaLato, NumLati, Materiale, Disegno, Fuga) VALUES(2, 13, 30, 4, 'porcellanato', 'stampato', 1);
INSERT INTO piastrella(idPiastrella, CostoM2, LunghezzaLato, NumLati, Materiale, Disegno, Fuga) VALUES(3, 10, 27, 4, 'ceramica', 'naturale', 1);
INSERT INTO piastrella(idPiastrella, CostoM2, LunghezzaLato, NumLati, Materiale, Disegno, Fuga) VALUES(4, 21, 27, 6, 'ceramica', 'naturale', 0);
INSERT INTO piastrella(idPiastrella, CostoM2, LunghezzaLato, NumLati, Materiale, Disegno, Fuga) VALUES(5, 45, 21, 8, 'ceramica', 'stampato', 1);

INSERT INTO intonaco(idIntonaco, CostoM2, Tipo) VALUES(1, 12, 'intonaco civile');
INSERT INTO intonaco(idIntonaco, CostoM2, Tipo) VALUES(2, 28, 'a base d’argilla');
INSERT INTO intonaco(idIntonaco, CostoM2, Tipo) VALUES(3, 19, 'Beton Cire');
INSERT INTO intonaco(idIntonaco, CostoM2, Tipo) VALUES(4, 15, 'decorativo');

INSERT INTO pietra(idPietra, CostoKG, PesoMedio, Tipo) VALUES(1, 12, 3, 'pietra serena');
INSERT INTO pietra(idPietra, CostoKG, PesoMedio, Tipo) VALUES(2, 10, 4, 'pietra leccese');
INSERT INTO pietra(idPietra, CostoKG, PesoMedio, Tipo) VALUES(3, 17, 10, 'granito');
INSERT INTO pietra(idPietra, CostoKG, PesoMedio, Tipo) VALUES(4, 35, 12, 'marmo');
INSERT INTO pietra(idPietra, CostoKG, PesoMedio, Tipo) VALUES(5, 15, 5, 'travertino');
INSERT INTO pietra(idPietra, CostoKG, PesoMedio, Tipo) VALUES(6, 11, 4, 'ardesia');

INSERT INTO alveoli(PercentualeFori, Nome) VALUES(00, 'pieno');
INSERT INTO alveoli(PercentualeFori, Nome) VALUES(20, 'semipieno di tipo A');
INSERT INTO alveoli(PercentualeFori, Nome) VALUES(35, 'estruso');
INSERT INTO alveoli(PercentualeFori, Nome) VALUES(50, 'semipieno di tipo B');
INSERT INTO alveoli(PercentualeFori, Nome) VALUES(85, 'forati');
INSERT INTO mattone(codMattone, alveoli, Materiale, peso, lunghezza, larghezza, altezza, costo, isolante) VALUES(1, 00, 'laterizio', 2300, 25, 10, 5, 1, 0);
INSERT INTO mattone(codMattone, alveoli, Materiale, peso, lunghezza, larghezza, altezza, costo, isolante) VALUES(2, 00, 'terra cruda', 3200, 27, 11, 6, 1, 0);
INSERT INTO mattone(codMattone, alveoli, Materiale, peso, lunghezza, larghezza, altezza, costo, isolante) VALUES(3, 20, 'laterizio', 2000, 25, 10, 5, 1, 0);
INSERT INTO mattone(codMattone, alveoli, Materiale, peso, lunghezza, larghezza, altezza, costo, isolante) VALUES(4, 20, 'Clinker', 1900, 20, 16, 4, 4, 0);
INSERT INTO mattone(codMattone, alveoli, Materiale, peso, lunghezza, larghezza, altezza, costo, isolante) VALUES(5, 35, 'laterizio', 1800, 25, 10, 5, 1, 0);
INSERT INTO mattone(codMattone, alveoli, Materiale, peso, lunghezza, larghezza, altezza, costo, isolante) VALUES(6, 85, 'laterizio', 2100, 25, 10, 5, 1, 1);
INSERT INTO mattone(codMattone, alveoli, Materiale, peso, lunghezza, larghezza, altezza, costo, isolante) VALUES(7, 85, 'cemento', 4000, 45, 20, 15, 3, 1);

INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(1, 'carta da parati bianca', '2022-11-22', 20, 'CarteDaParati spa', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(2, 'carta da parati rosa', '2022-11-23', 21, 'CarteDaParati spa', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(3, 'carta da parati verde', '2022-11-23', 21, 'CarteDaParati spa', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(4, 'carta da parati gialla', '2022-11-23', 21, 'CarteDaParati spa', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(5, 'carta da parati grigia', '2022-11-23', 21, 'CarteDaParati spa', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(6, 'vetro', '2022-07-01', 19, 'Vetro&CO', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(7, 'vetro oscurato', '2022-07-01', 19, 'Vetro&CO', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(8, 'vetro opaco', '2022-07-02', 19, 'Vetro&CO', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(9, 'finto legno di mogano', '2022-08-16', 19, 'Legno e infissi italia', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(11, 'moquette bianca', '2022-02-27', 16, 'mqt', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(12, 'moquette grigia', '2022-02-27', 18, 'mqt', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(13, 'moquette beige', '2022-02-27', 18, 'mqt', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(101, 'Assi di legno di larice', '2022-04-14', 40, 'Legno e infissi italia', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(102, 'Assi di legno di quercia', '2022-04-14', 37, 'Legno e infissi italia', 100, 100, NULL);
INSERT INTO presetmateriale(codLotto, Nome, DataAcquisto, CostoPerUnitaDiMisura, NomeFornitore, Lunghezza, Larghezza, Altezza) VALUES(103, 'Assi di legno di betulla', '2022-04-14', 42, 'Legno e infissi italia', 100, 100, NULL);
