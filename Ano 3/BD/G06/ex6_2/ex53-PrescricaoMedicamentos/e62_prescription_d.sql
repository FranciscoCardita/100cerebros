-- d) Para a farmac�utica com registo n�mero 906, lista dos seus f�rmacos nunca prescritos
SELECT F.Nome_comercial,F.Formula
FROM prescrition_system.Farmaco AS F LEFT OUTER JOIN prescrition_system.PrescricoesEnvolvemFarmacos AS P ON F.Nome_comercial=P.Nome_farmaco
WHERE F.Registo_farmaceutica=906 AND P.No_prescricao IS NULL