-- b) N�mero de prescri��es por especialidade m�dica
SELECT M.Especialidade,count(PR.No_prescricao) as num_prescricoes
FROM prescrition_system.Prescricao AS PR JOIN prescrition_system.Medico AS M ON M.No_identificacao=PR.Med_id
GROUP BY M.Especialidade