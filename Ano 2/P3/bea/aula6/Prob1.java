package aula6;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.time.DayOfWeek;

import aula6.prob1.Cereal;
import aula6.prob1.Fish;
import aula6.prob1.FishType;
import aula6.prob1.Food;
import aula6.prob1.Legume;
import aula6.prob1.Meal;
import aula6.prob1.MealDiet;
import aula6.prob1.MealVegetarian;
import aula6.prob1.Meat;
import aula6.prob1.MeatVariety;
import aula6.prob1.Menu;

/**
 * Prob1
 * 
 * @author Beatriz Borges, 79857 | Pedro Teixeira, 84715, MIECT
 */

public class Prob1 {

	public static void main(String[] args) {
		Menu ementa = new Menu("Especial Caloiro", "Snack da UA"); 
		Meal[] pratos = new Meal[10];

		for (int i=0; i < pratos.length; i++){ 
			pratos[i] = randPrato(i); 
			int cnt = 0;

			while (cnt <2) { // Adicionar 2 Ingredientes a cada Prato
				Food aux = randAlimento();
				if (pratos[i].addIngredient(aux))
					cnt++;
				else
					System.out.println("ERRO: Não é possivel adicionar '" + aux + "' ao -> " + pratos[i]);
			}

			ementa.addMeal(pratos[i], DayOfWeek.of((int)Math.ceil(Math.random()*7))); // Dia Aleatório
		}

		System.out.println("\n" + ementa);

		// Serialization Test
		String path = "Menu.bin";
		exportMenu(ementa, path);
		System.out.println("\nImported from " + path + ": \n"  + importMenu(path));
	}

	// Retorna um Alimento Aleatoriamente 
	public static Food randAlimento() {
		switch ((int) (Math.random() * 4)) { 
			default:
			case 0:
				return new Meat(300, 22.3, 345.3, MeatVariety.Chicken);
			case 1:
				return new Fish(200, 31.3, 25.3, FishType.Frozen);
			case 2:
				return new Legume(150, 21.3, 22.4, "Couve Flor");
			case 3:
				return new Cereal(110, 19.3, 32.4, "Milho");
		} 
	}

	// Retorna um Tipo de Prato Aleatoriamente 
	public static Meal randPrato(int i) {
		switch ((int) (Math.random() * 3)) { 
			default:
			case 0:
				return new Meal("Prato N." + i);
			case 1:
				return new MealVegetarian("Prato N." + i + " (Vegetariano)");
			case 2:
				return new MealDiet("Prato N." + i + " (Dieta)", 90.8);
		} 
	}

	public static Menu importMenu (String path) {
		try {
			ObjectInputStream in = new ObjectInputStream(new FileInputStream(path));
			Object obj = in.readObject();
			in.close();
			if ((obj instanceof Menu)) return (Menu) obj;
			return null;
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return null;

	}

	public static void exportMenu (Menu m, String path) {
		ObjectOutputStream out;
		try {
			out = new ObjectOutputStream(new FileOutputStream(path));
			out.writeObject(m);
			out.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

}
