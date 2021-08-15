/*
 * Implementare un event che sposti mensilmente le terapie terminate oltre sei mesi prima in una tabella di
 * archivio ARCHIVIO-TERAPIE mediante una stored procedure dump_therapies(). Salvare in
 * ARCHIVIO-TERAPIE il codice fiscale del paziente, la patologia, il nome commerciale del farmaco, l’anno d’inizio, 
 * la durata della terapia in giorni e il numero totale di compresse assunte. L’event deve salvare in una tabella
 * persistente la data dell’ultima volta in cui è andato in esecuzione e il numero di terapie archiviate.
*/
DROP PROCEDURE IF EXISTS dump_therapies;
DROP EVENT IF EXISTS sposta_terapie;
DROP TABLE ARCHIVIO_TERAPIE;
DROP TABLE ULTIMI_DUMP;

CREATE TABLE ARCHIVIO_TERAPIE(
	id INT(11) AUTO_INCREMENT NOT NULL,
	CodiceFiscale VARCHAR(60) NOT NULL DEFAULT "",
    Patologia VARCHAR(60) NOT NULL DEFAULT "",
    Farmaco VARCHAR(60) NOT NULL DEFAULT "",
    AnnoInizio INT(11) NOT NULL DEFAULT 0,
    DurataTerapia INT(11) NOT NULL DEFAULT 0,
    NumeroCompresse INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY(id)
)ENGINE=InnoDB default charset=latin1;

CREATE TABLE ULTIMI_DUMP (
	id INT(11) AUTO_INCREMENT NOT NULL,
    DataEsecuzione DATE NOT NULL DEFAULT '0000-00-00',
    NumeroTerapie INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY(id)
)ENGINE=InnoDB default charset=latin1;

DELIMITER $$
CREATE PROCEDURE dump_therapies()
BEGIN 
	TRUNCATE ARCHIVIO_TERAPIE;
    
	INSERT INTO ARCHIVIO_TERAPIE(CodiceFiscale,Patologia,Farmaco,AnnoInizio,DurataTerapia,NumeroCompresse)
		SELECT T.Paziente,
			   T.Patologia,
               T.Farmaco,
               YEAR(T.DataInizioTerapia) AS AnnoInizio,
               DATEDIFF(T.DataFineTerapia, T.DataInizioTerapia) AS DurataGiorni,
			   (T.Posologia*(DATEDIFF(T.DataFineTerapia, T.DataInizioTerapia))) AS NumeroCompresse
        FROM Terapia T
        WHERE T.DataFineTerapia IS NOT NULL
			  AND T.DataInizioTerapia < T.DataFineTerapia - INTERVAL 6 MONTH;
              
	SET @numeroterapie = (SELECT COUNT(*)
						  FROM Terapia T2
                          WHERE T2.DataFineTerapia IS NOT NULL
								AND T2.DataInizioTerapia < T2.DataFineTerapia - INTERVAL 6 MONTH);
	
END $$

CREATE EVENT sposta_terapie
ON SCHEDULE EVERY 1 MONTH DO
BEGIN 
	CALL dump_therapies();
    
    INSERT INTO ULTIMI_DUMP(DataEsecuzione, NumeroTerapie)
	VALUES(CURRENT_DATE, @numeroterapie);
        
END $$
DELIMITER ;