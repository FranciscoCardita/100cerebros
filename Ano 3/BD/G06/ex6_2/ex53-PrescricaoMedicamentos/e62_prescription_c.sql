-- c) N�mero de prescri��es processadas por farm�cia
SELECT count(P.No_prescricao) as num_processadas_por_farmacias
FROM prescrition_system.Prescricao AS P
WHERE P.Farmacia_process IS NOT NULL