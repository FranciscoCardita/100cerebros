/************************************************************************
 Ficheiro de implementa��o do Tipo de Dados Abstracto Data (date.c).
 A estrutura de dados de suporte do tempo � um registo constitu�do pelos
 tr�s campos de tipo inteiro Day, Month e Year.

 Autor : Beatriz M Borges R                                NMEC : 79857         
************************************************************************/

#include <stdio.h> 
#include <stdlib.h>
#include <string.h>
#include "date.h" /* Ficheiro de interface do TDA - ADT Interface file */

/*************** Defini��o da Estrutura de Dados da Data ***************/

struct date
{
	unsigned int Day; unsigned int Month; unsigned int Year;
};

/******************** Controlo Centralizado de Erro ********************/

static unsigned int Error = OK;	/* inicializa��o do erro */

static char *ErrorMessages[] = { "sem erro", "data inexistente",
                                 "memoria esgotada", "data invalida",
																 "ponteiro inexistente" };

static char *AbnormalErrorMessage = "erro desconhecido";

/*********** N�mero de mensagens de erro previstas no m�dulo ***********/

#define N (sizeof (ErrorMessages) / sizeof (char *))

/***************** Prot�tipos dos Subprogramas Internos ****************/

/* Criei uma fun��o auxiliar, exists(), que valida um ponteiro para uma
 dada data. � �til para evitar repeti��o no c�digo, uma vez que esta
 valida��o � feita em quase todas as fun��es. */
static int exists (PtDate);

static int LeapYear (int); /* ano bissexto */
static int ValidDate (int, int, int); /* validar data */

/********************** Defini��o dos Subprogramas *********************/

void DateClearError (void)
{ Error = OK; }

int DateError (void)
{ return Error; }

char *DateErrorMessage (void)
{
	if (Error < N) return ErrorMessages [Error];
	else return AbnormalErrorMessage; /* sem mensagem de erro */
}

PtDate DateCreate (int pday, int pmonth, int pyear) /* construtor inicializador */
{
	// TODO

  if (!ValidDate(pday, pmonth, pyear)) return NULL; // validate

  PtDate Date; 										 									 // allocate memory
  Date = malloc(sizeof(struct date));
  if (Date == NULL)
  { 
  	Error = NO_MEM; 
  	return NULL; 
  }
                                                     // save date to memory
  Date->Day = pday; Date->Month = pmonth; Date->Year = pyear;
  Error = OK;
  return Date;
}

void DateDestroy (PtDate *pdate) /* destrutor */
{
	// TODO

  PtDate TmpDate = *pdate;

  // free memory if pointed-to date exists
  if (!exists(TmpDate)) 
  { 
  	return; 
  }
  free (TmpDate);

  Error = OK;
  *pdate = NULL;
}

PtDate DateStringCreate (char *pstrdate) /* construtor a partir de uma string */
{
	if (pstrdate == NULL) { Error = NULL_PTR; return NULL; }
	if (strlen (pstrdate) != 10) { Error = INVALID; return NULL; }

	char * date[4]; int i = 0;

	date[i] = strtok (pstrdate, "-");
	while (date[i] != NULL) date[++i] = strtok (NULL, "-");

	if (i != 3) { Error = INVALID; return NULL; }

	int Year, Month, Day;
	sscanf (date[0], "%d", &Year);
	sscanf (date[1], "%d", &Month);
	sscanf (date[2], "%d", &Day);

	return DateCreate (Day, Month, Year);
}

PtDate DateCopy (PtDate pdate)	/* construtor c�pia */
{
	if (pdate == NULL) { Error = NO_DATE; return NULL; }
	else return DateCreate (pdate->Day, pdate->Month, pdate->Year);
}

int  DateGetYear (PtDate pdate) /* observador do ano */
{
	// TODO
	if (!exists(pdate)) 
	{
		return 0;
	}

	Error = OK;
	return pdate->Year;
}

int DateGetMonth (PtDate pdate) /* observador do m�s */
{
	if (pdate == NULL) { Error = NO_DATE; return 0; }
	else { Error = OK; return pdate->Month; }
}

int DateGetDay (PtDate pdate) /* observador do dia */
{
	// TODO
	if (!exists(pdate)) 
	{
		return 0;
	}
	
	Error = OK;
	return pdate->Day;
}

void DateSet (PtDate pdate, int pday, int pmonth, int pyear) /* modificador da data */
{
	// TODO
	if (!exists(pdate)) 
	{
		return;
	}

	if(ValidDate(pday, pmonth, pyear)) 
	{
		pdate->Day = pday;
		pdate->Month = pday;
		pdate->Year = pyear;
	}
	
}

int DateEquals (PtDate pdate1, PtDate pdate2)  /* comparador de igualdade */
{
	// TODO
	if (exists(pdate1) && exists(pdate2)) 
	{
		if (pdate1 == pdate2) {
			return 1;
		}
		return DateCompareTo(pdate1, pdate2) == 0;
	}
	return 0;
}

int DateCompareTo (PtDate pdate1, PtDate pdate2)  /* operador relacional (> == <) */
{
	// TODO
	if (exists(pdate1) && exists(pdate2)) 
	{
		if (pdate1 == pdate2) {
			return 1;
		}
		if (pdate1->Year != pdate2->Year)
			return pdate1->Year - pdate2->Year;
		if (pdate1->Month != pdate2->Month)
			return pdate1->Month - pdate2->Month;
		return pdate1->Day - pdate2->Day;
	}
	return 0;
}

int DateDayMonth (int pmonth, int pyear) /* dias de um m�s */
{
	// TODO
	int MonthDays[] = { 31,28,31,30,31,30,31,31,30,31,30,31 };

	if(LeapYear(pyear) && pmonth == 2)
	{
		return 29;
	}
	return MonthDays[pmonth-1];

}

char * DateToString (PtDate pdate)  /* data no formato dd/mm/yyyy */
{
	/* verifica se a data existe - verifies if date exists */
	if (pdate == NULL) { Error = NO_DATE; return NULL; }

	char * Str;
	/* cria a sequ�ncia de caracteres - allocating the string */
	if ((Str = calloc (11, sizeof (char))) == NULL)
	{ Error = NO_MEM; return NULL; }

	sprintf (Str, "%02d/%02d/%04d", pdate->Day, pdate->Month, pdate->Year);
	Error = OK;
	return Str;
}

char * DateToFullString (PtDate pdate)  /* data por extenso */
{
	char* FullMonth[] = {"janeiro", "fevereiro", "mar�o", "abril",
						 "maio", "junho", "julho", "agosto",
						 "setembro", "outubro", "novembro", "dezembro"};

	/* verifica se a data existe - verifies if date exists */
	if (pdate == NULL) { Error = NO_DATE; return NULL; }

	char * Str;  
	/* cria a sequ�ncia de caracteres - allocating the string */
	if ((Str = calloc (23, sizeof (char))) == NULL)
	{ Error = NO_MEM; return NULL; }

	sprintf (Str, "%02d de %s de %04d", pdate->Day, FullMonth[pdate->Month-1], pdate->Year);
	Error = OK;
	return Str;
}

PtDate DateTomorrow (PtDate pdate)  /* nova data com o dia seguinte */
{
	// TODO
	if (!exists(pdate)) 
	{
		return NULL;
	}

	if (pdate->Day == DateDayMonth(pdate->Month, pdate->Year)) 
	{
		if(pdate->Month == 12) 
		{
			return DateCreate(1, 1, (pdate->Year)+1);
		}
		return DateCreate(1, (pdate->Month)+1, pdate->Year);
		
	} 
	return DateCreate((pdate->Day)+1, pdate->Month, pdate->Year);
}

PtDate DateYesterday (PtDate pdate)  /* nova data com o dia anterior */
{
	// TODO
	if (!exists(pdate)) 
	{
		return NULL;
	}

	if (pdate->Day == 1) 
	{
		if(pdate->Month == 1) 
		{
			int prevMonth = 12;
			return DateCreate(DateDayMonth(prevMonth, pdate->Year), prevMonth, (pdate->Year)-1);
		}
		int prevMonth = (pdate->Month)-1;
		return DateCreate(DateDayMonth(prevMonth, pdate->Year), prevMonth, pdate->Year);
	} 
	return DateCreate((pdate->Day)-1, pdate->Month, pdate->Year);
}

/*************** Implementa��o dos Subprogramas Internos ***************/

/*******************************************************************************
 Fun��o auxiliar que verifica se uma data existe (atrav�s do ponteiro para a data,
  PtDate). Se a data n�o existe, muda o valor de Error para NO_DATE.
*******************************************************************************/
static int exists (PtDate pdate)
{
	if (pdate == NULL) 
	{ 
		Error = NO_DATE; 
		return 0; 
	}
	return 1;
}

/*******************************************************************************
 Fun��o auxiliar que verifica se um ano � bissexto. Devolve 1 em caso afirmativo
  e 0 em caso contr�rio. Valores de erro: OK.
 
 Auxiliary function to verify if a year is a leap year. Returns 1 in affirmative
 case and 0 otherwise. Error codes: OK.
*******************************************************************************/
static int LeapYear (int pyear)
{
	Error = OK;
	return ((pyear % 4 == 0) && (pyear % 100 != 0)) || (pyear % 400 == 0);
}

/*******************************************************************************
 Fun��o auxiliar que verifica se uma data definida por dia, m�s e ano � v�lida.
 Devolve 1 em caso afirmativo e 0 em caso contr�rio. Valores de erro: OK ou INVALID.
 
 Auxiliary function to verify if a date defined by day, month and year is valid.
 Returns 1 in affirmative case and 0 otherwise. Error codes: OK or INVALID.
*******************************************************************************/

static int ValidDate (int pday, int pmonth, int pyear)
{
	int leapyear;

	Error = OK;
	switch (pmonth)
	{
		case  1:
		case  3:
		case  5:
		case  7:
		case  8:
		case 10:
		case 12: 
			if (pday < 1 || pday > 31) Error = INVALID;
		 	break;
		case  4:
		case  6:
		case  9:
		case 11: 
			if (pday < 1 || pday > 30) Error = INVALID;
		 	break;
		case  2: leapyear = LeapYear (pyear);
  	 	if (pday < 1 || (pday > 29 && leapyear) || (pday > 28 && !leapyear))
				Error = INVALID;
  		break;
	}
	if (Error == OK) return 1; else return 0;
}

