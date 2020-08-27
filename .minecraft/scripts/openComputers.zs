import crafttweaker.item.IItemStack;
import crafttweaker.item.IIngredient;
import mods.appliedenergistics2.Grinder;
import mods.gregtech.recipe.RecipeMap;
import crafttweaker.data.IData;
import crafttweaker.liquid.ILiquidStack;
import mods.thermalexpansion.Infuser;



print("---------------Open Computers Start------------------");

val assembler = mods.gregtech.recipe.RecipeMap.getByName("assembler");
val laser = mods.gregtech.recipe.RecipeMap.getByName("laser_engraver");
val mixer = mods.gregtech.recipe.RecipeMap.getByName("mixer");
val macerator = mods.gregtech.recipe.RecipeMap.getByName("macerator");
val alloyer = mods.gregtech.recipe.RecipeMap.getByName("alloy_smelter");
val autoclave = mods.gregtech.recipe.RecipeMap.getByName("autoclave");
val lathe = mods.gregtech.recipe.RecipeMap.getByName("lathe");
val implosion = mods.gregtech.recipe.RecipeMap.getByName("implosion_compressor");


#removals
	#trading upgrade
	mods.jei.JEI.removeAndHide(<opencomputers:upgrade:29>);

	#cable - this will not work until OC fixes it
	//recipes.addShapeless(<opencomputers:cable> * 4, [<ore:cableGtSingleIron>,<ore:dustRedstone>]);
	
	#boots
	recipes.remove(<opencomputers:hoverboots>);
	<opencomputers:hoverboots>.addTooltip(format.darkRed("Moon or later Loot only."));
	
	#nanomachines
	recipes.remove(<opencomputers:tool:5>);
	assembler.recipeBuilder()
	.inputs(<metaitem:plate.central_processing_unit>,<ore:pearlFluix>, <ore:oc:materialTransistor>*2, <ore:wireFineElectrum>*4)
    .outputs(<opencomputers:tool:5>)
	.fluidInputs([<fluid:redstone> * 144])
    .duration(800)
    .EUt(42)
    .buildAndRegister();
	
	#chips
	assembler.recipeBuilder()
	.inputs(<opencomputers:material:6>*4, <ore:circuitLow>)
    .outputs(<opencomputers:material:7>*4)
	.fluidInputs([<fluid:redstone> * 144])
    .duration(40)
    .EUt(18)
    .buildAndRegister();	

	assembler.recipeBuilder()
	.inputs(<opencomputers:material:7>*4, <ore:circuitLow>)
    .outputs(<opencomputers:material:8>*4)
	.fluidInputs([<fluid:redstone> * 144])
    .duration(80)
    .EUt(18)
    .buildAndRegister();	

	assembler.recipeBuilder()
	.inputs(<opencomputers:material:8>*4, <ore:circuitGood>)
    .outputs(<opencomputers:material:9>*4)
	.fluidInputs([<fluid:redstone> * 144])
    .duration(120)
    .EUt(18)
    .buildAndRegister();
	
	#Drones
	recipes.remove(<opencomputers:material:24>);
	recipes.remove(<opencomputers:material:23>);
	<opencomputers:material:23>.addTooltip(format.darkRed("Loot only, Advanced technology such as this can't be found on our world..."));
	<opencomputers:material:24>.addTooltip(format.darkRed("Loot only, Advanced technology such as this can't be found on our world..."));


print("---------------Open Computers End------------------");