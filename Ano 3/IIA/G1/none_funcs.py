# Dada uma lista, retornar o elemento que esta a cabeca (ou seja, na posicao 0).
def first_elem(list):
	if list == []:
		return None

	return list[0]

# Dada uma lista, retornar a sua cauda (ou seja, todos os elementos
# a excepcao do primeiro).
def list_tail(list):
	if len(list) < 2:
		return None

	return list[1:]

# Dado um par de listas com igual comprimento, produzir uma lista dos
# pares dos elementos homologos.
# def index_pairs(list1, list2):
# 	if list1 == []:
# 		return None

# 	return [(list1[0], list2[0])] + index_pairs(list1[1:], list2[1:])

# Dada uma lista de numeros, retorna o menor elemento.

# Dada uma lista de numeros, retorna um par formado pelo menor elemento
# e pela lista dos restantes elementos.

# Dada uma lista de numeros, calcular o maximo e o mınimo, retornando-os num tuplo.

# Dada uma lista de numeros, retorna um triplo formado pelos dois menores
# elementos e pela lista dos restantes elementos.

# Dada uma lista ordenada de numeros, calcular se possıvel a respectiva media
# e mediana, retornando-as num tuplo.