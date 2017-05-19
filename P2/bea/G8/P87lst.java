
import static java.lang.System.*;
import p2utils.*;

public class P87lst
{
  // Coloca números inteiros da linha de comando numa SortedList.

  // Experimente, por exemplo:
  //    java -ea P87lst 8 31 - 4231 6 12123 64 - 213 2123 12 - 612 10

  public static void main(String[] args)
  {
    SortedList<Integer> lst = new SortedList<Integer>();

    for (int i=0; i<args.length; i++) {
      try {
        lst.insert(Integer.parseInt(args[i]));
      } catch (NumberFormatException e) {
        lst.removeFirst();
      }
    }
    out.println(lst.isSorted());

    // Verifica se os números 1, 10 e 30 pertencem à lista
    out.println(lst.contains(1));
    out.println(lst.contains(10));
    out.println(lst.contains(30));
    // acrescentar mais testes se necessário

    // Teste da função toString()
    out.println(lst.toString());

    SortedList<Integer> secondlst = new SortedList<Integer>();
    secondlst.insert(9);
    secondlst.insert(99);
    secondlst.insert(999);
    
    out.println(secondlst.toString());
    
    // Teste das função merge()
    SortedList<Integer> thirdlist = lst.merge(secondlst);
    out.println(thirdlist.toString());

    // Retira elementos de lst e confirma que estão em lst3
    while (!lst.isEmpty()) {
      assert thirdlist.contains(lst.first());
      lst.removeFirst();
    }
    // Retira elementos de lst2 e confirma que estão em lst3
    while (!secondlst.isEmpty()) {
      assert thirdlist.contains(secondlst.first());
      secondlst.removeFirst();
    }
  }
}
