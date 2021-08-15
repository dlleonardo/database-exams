/* 
 * Introdurre una ridondanza SpesaGiornaliera nella tabella PAZIENTE per mantenere l’attuale spesa giornaliera 
 * in farmaci di ciascun paziente. Nel computo, si ignorino le patologie con diritto di esenzione. 
 * Scrivere il codice per creare, popolare e mantenere costantemente aggiornata la ridondanza. 
*/ 
CREATE OR REPLACE VIEW SpesePazienti AS
SELECT T.Paziente,
	   IF(SUM(F.Costo*(I.DoseGiornaliera/F.Pezzi)) > 0, SUM(F.Costo*(I.DoseGiornaliera/F.Pezzi)), 0) AS CostoGiornaliero
FROM Farmaco F INNER JOIN Terapia T
	 ON F.NomeCommerciale = T.Farmaco
     INNER JOIN Indicazione I 
     ON T.Farmaco = I.Farmaco
     INNER JOIN Patologia P
     ON I.Patologia = P.Nome
WHERE T.DataFineTerapia IS NULL
	  AND P.PercEsenzione = 0
GROUP BY T.Paziente;

ALTER TABLE Paziente
	DROP COLUMN SpesaGiornaliera;

ALTER TABLE Paziente
	ADD COLUMN SpesaGiornaliera DOUBLE NOT NULL DEFAULT 0;
    
UPDATE Paziente
SET SpesaGiornaliera = (SELECT CostoGiornaliero
						FROM SpesePazienti
                        WHERE Paziente = CodFiscale)
WHERE CodFiscale IN (SELECT Paziente
					 FROM SpesePazienti);

DELIMITER $$
CREATE TRIGGER AggiornaSpesa
AFTER INSERT ON Terapia FOR EACH ROW
BEGIN 
	UPDATE Paziente
    SET SpesaGiornaliera = (SELECT CostoGiornaliero
							FROM SpesePazienti
							WHERE Paziente = NEW.Paziente)
	WHERE CodFiscale = NEW.Paziente;
END $$
DELIMITER ;