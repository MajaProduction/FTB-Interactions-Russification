import mods.gregtech.recipe.RecipeMaps;
import mods.gregtech.recipe.RecipeMap;
import mods.gtadditions.recipe.GARecipeMaps;

print("---------------Gregtech Start------------------");
	var infusedFuel = mods.gregtech.recipe.FuelRecipe.create(<liquid:infused_nitrofuel> *2, 15, 128);
	RecipeMaps.DIESEL_GENERATOR_FUELS.addRecipe(infusedFuel);
	
	var naqFuel = mods.gregtech.recipe.FuelRecipe.create(<liquid:naquadriaticfuel>, 175, 128);
	RecipeMaps.DIESEL_GENERATOR_FUELS.addRecipe(naqFuel);
	
	var naqFuel2 = mods.gregtech.recipe.FuelRecipe.create(<liquid:naquadriaticfuel>, 175, 128); #different value in case I want to change this later
	GARecipeMaps.NAQUADAH_REACTOR_FUELS.addRecipe(naqFuel2);
	
	var naquadria = mods.gregtech.recipe.FuelRecipe.create(<liquid:naquadria>, 20000, 128); 
	GARecipeMaps.NAQUADAH_REACTOR_FUELS.addRecipe(naquadria);
	
print("----------------Gregtech End-------------------");

