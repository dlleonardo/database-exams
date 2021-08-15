/* Scrivere una query che blocchi, cancellandole, le terapie in corso basate sul farmaco Broncho-Vaxom, 
   iniziate più di tre giorni fa, da pazienti pediatrici (età inferiore a 12 anni) attualmente affetti 
   da broncospasmo. A cancellazione avvenuta, restituire, come result set, il codice fiscale dei pazienti 
   oggetto di blocco. */
CREATE OR REPLACE VIEW PazientiTarget AS
SELECT P.CodFiscale
FROM Paziente P INNER JOIN Esordio E
	 ON P.CodFiscale = E.Paziente
     INNER JOIN Terapia T
     ON E.Paziente = T.Paziente
WHERE T.Farmaco = 'Broncho-Vaxom'
	  AND FLOOR((DATEDIFF(CURRENT_DATE, P.DataNascita))/365) < 12
      AND E.DataGuarigione IS NULL
      AND E.Patologia = 'broncospamo'
      AND T.DataInizioTerapia < CURRENT_DATE - INTERVAL 3 DAY
      AND T.DataFineTerapia IS NULL
GROUP BY P.CodFiscale;

CREATE TEMPORARY TABLE IF NOT EXISTS PazientiBloccati (
	Paziente VARCHAR(50) NOT NULL,
    PRIMARY KEY(Paziente)
)ENGINE=InnoDB default charset=latin1;

TRUNCATE TABLE PazientiBloccati;

INSERT INTO PazientiBloccati
	SELECT *
    FROM PazientiTarget;
    
DELETE FROM Terapia
WHERE Paziente IN (SELECT CodFiscale
				   FROM PazientiTarget);
                   
SELECT *
FROM PazientiBloccati;