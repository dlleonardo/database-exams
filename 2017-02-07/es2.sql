/*
 * Implementare una business rule che consenta aumenti di prezzo dei farmaci a base di paracetamolo non superiori
 * al 5% del prezzo medio attuale dei farmaci basati sullo stesso principio attivo.
*/
DROP TRIGGER IF EXISTS aumenta_prezzo;

DELIMITER $$
CREATE TRIGGER aumenta_prezzo
BEFORE UPDATE ON Farmaco FOR EACH ROW
BEGIN
	DECLARE prezzo_medio DOUBLE DEFAULT 0;

	SELECT AVG(F.Costo) INTO prezzo_medio
    FROM Farmaco F
    WHERE F.PrincipioAttivo = 'paracetamolo';
	
    IF NEW.Costo < 0.05*prezzo_medio THEN
		UPDATE Farmaco
        SET Costo = NEW.Costo
        WHERE Farmaco = NEW.Farmaco
			  AND PrincipioAttivo = 'paracetamolo';
	ELSE
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'errore';
	END IF;
    
END $$
DELIMITER ;