/*
 * Implementare una stored procedure cheapest_drug che, dato un farmaco, restituisca in uscita il nome
 * commerciale di quello più conveniente basato sullo stesso principio attivo, e la loro differenza di prezzo
*/
DROP PROCEDURE IF EXISTS cheapest_drug;

DELIMITER $$
CREATE PROCEDURE cheapest_drug(
	IN _farmaco VARCHAR(60),
	INOUT _nomecommerciale VARCHAR(60),
    INOUT _differenzaprezzo DOUBLE
	)
BEGIN
	DECLARE principio_attivo VARCHAR(60) DEFAULT "";
    DECLARE costo DOUBLE DEFAULT 0;
    DECLARE costo_conveniente INT DEFAULT 0;
    DECLARE finito INTEGER DEFAULT 0;
    DECLARE farmaci VARCHAR(255) DEFAULT "";
    
    DECLARE ListaFarmaci CURSOR FOR
		SELECT F3.NomeCommerciale
        FROM Farmaco F3
        WHERE F3.PrincipioAttivo IN (SELECT F4.PrincipioAttivo
									 FROM Farmaco F4
                                     WHERE F4.NomeCommerciale = _farmaco)
			  AND F3.Costo = (SELECT MIN(F5.Costo)
							   FROM Farmaco F5
                               WHERE F5.PrincipioAttivo IN (SELECT F6.PrincipioAttivo
															 FROM Farmaco F6
                                                             WHERE F6.NomeCommerciale = _farmaco))
		GROUP BY F3.NomeCommerciale;
    
    DECLARE CONTINUE HANDLER 
    FOR NOT FOUND SET finito = 1;
    
    SELECT F.PrincipioAttivo, F.Costo INTO principio_attivo, costo
    FROM Farmaco F
    WHERE F.NomeCommerciale = _farmaco;
    
    SELECT MIN(D.Costo) INTO costo_conveniente 
    FROM (
    SELECT F.NomeCommerciale,
		   F.Costo
    FROM Farmaco F
    WHERE F.PrincipioAttivo = principio_attivo
    GROUP BY F.NomeCommerciale ) AS D;

	SET _differenzaprezzo = costo - costo_conveniente;
          
	SET _nomecommerciale = (
							SELECT IF(COUNT(*) = 1, F2.NomeCommerciale, "")
                            FROM Farmaco F2
                            WHERE F2.PrincipioAttivo = principio_attivo
								  AND F2.Costo = costo_conveniente
							);
                            
	IF LENGTH(_nomecommerciale) = 0 THEN
		OPEN ListaFarmaci;
        
        preleva: LOOP
			FETCH ListaFarmaci INTO farmaci;
			IF finito = 1 THEN
				LEAVE preleva;
			END IF;
            SET _farmaco = CONCAT(farmaci, " ",_farmaco);
		END LOOP preleva;
        
        CLOSE ListaFarmaci;
	END IF;
END $$
DELIMITER ;

SET @nomecommerciale = "";
SET @differenzaprezzo = 0;
CALL cheapest_drug('valium', @nomecommerciale, @differenzaprezzo);
SELECT @nomecommerciale, @differenzaprezzo;