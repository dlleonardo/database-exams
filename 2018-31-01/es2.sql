/*
 * Implementare una stored procedure nex_visit_details che riceva in ingresso una visita e restituisca
 * in uscita il numero di giorni trascorsi da essa alla visita successiva dello stesso paziente,
 * e la specializzazione del medico dal quale il paziente è stato visitato in tale visita successiva
*/
DROP PROCEDURE IF EXISTS next_visit_details;

DELIMITER $$
CREATE PROCEDURE next_visit_details(
	IN _medico VARCHAR(60),
    IN _paziente VARCHAR(60),
    IN _data DATE,
    IN _mutuata INT(11),
    OUT numero_giorni INT(11),
    OUT specializzazione_medico VARCHAR(60)
)
BEGIN
	DECLARE data_visita_successiva DATE DEFAULT "0000-00-00";
	DECLARE medico_visita_successiva VARCHAR(60) DEFAULT "";

	SELECT V.Data, V.Medico INTO data_visita_successiva, medico_visita_successiva
    FROM Visita V
    WHERE V.Paziente = _paziente
		  AND V.Data > _data
	ORDER BY V.Data ASC
    LIMIT 1;
    
    SELECT M.Specializzazione INTO specializzazione_medico
    FROM Medico M
    WHERE M.Matricola = medico_visita_successiva;
    
    SET numero_giorni = DATEDIFF(data_visita_successiva, _data);

END $$
DELIMITER ;

SET @numero_giorni = 0;
SET @specializzazione_medico = "";
CALL next_visit_details('014','aaa1','2003-12-20',0,@numero_giorni,@specializzazione_medico);
SELECT @numero_giorni, @specializzazione_medico;