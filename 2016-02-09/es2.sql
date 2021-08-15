/* 
 * Implementare una stored function therapy_failures()che riceva in ingresso il codice fiscale di un
 * paziente e il nome commerciale di un farmaco e restituisca, solo se esiste, il settore medico con il più alto
 * numero di terapie iniziate dal paziente nel mese scorso, terminate senza guarigione nello stesso mese
*/
DROP FUNCTION IF EXISTS therapy_failures;

DELIMITER $$
CREATE FUNCTION therapy_failures(
	_codice_fiscale VARCHAR(60),
    _farmaco VARCHAR(60)
    )
RETURNS VARCHAR(60) DETERMINISTIC
BEGIN
	DECLARE settore_medico VARCHAR(60) DEFAULT "";
    DECLARE max_terapie INT DEFAULT 0;

	SELECT MAX(D.NumeroTerapie) INTO max_terapie
    FROM (
    SELECT M.Specializzazione,
		   COUNT(*) AS NumeroTerapie
    FROM Terapia T INNER JOIN Esordio E
		 ON T.Paziente = E.Paziente
         INNER JOIN Visita V
         ON E.Paziente = V.Paziente
         INNER JOIN Medico M
         ON V.Medico = M.Matricola
	WHERE T.Farmaco = _farmaco
		  AND T.Paziente = _codice_fiscale
          AND (MONTH(T.DataFineTerapia) = MONTH(T.DataInizioTerapia)
			   AND YEAR(T.DataFineTerapia) = YEAR(T.DataInizioTerapia))
		  AND E.DataGuarigione IS NULL
          AND T.DataInizioTerapia = CURRENT_DATE - INTERVAL 1 MONTH
	GROUP BY M.Specializzazione ) AS D;

	SELECT IF(COUNT(*) = 1, D3.Specializzazione, "") INTO settore_medico
	FROM (
		SELECT D2.Specializzazione
		FROM (
			SELECT M.Specializzazione,
				COUNT(*) AS NumeroTerapie
			FROM Terapia T INNER JOIN Esordio E
				ON T.Paziente = E.Paziente
				INNER JOIN Visita V
				ON E.Paziente = V.Paziente
				INNER JOIN Medico M
				ON V.Medico = M.Matricola
			WHERE T.Farmaco = _farmaco
				AND T.Paziente = _codice_fiscale
				AND (MONTH(T.DataFineTerapia) = MONTH(T.DataInizioTerapia)
				AND YEAR(T.DataFineTerapia) = YEAR(T.DataInizioTerapia))
				AND E.DataGuarigione IS NULL
				AND T.DataInizioTerapia = CURRENT_DATE - INTERVAL 1 MONTH
			GROUP BY M.Specializzazione ) AS D2
		WHERE D2.NumeroTerapie = max_terapie ) AS D3;

	RETURN (settore_medico);
END $$
DELIMITER ;