import crafttweaker.item.IItemStack;
import crafttweaker.item.IIngredient;
import mods.gregtech.recipe.RecipeMap;
import crafttweaker.data.IData;
import crafttweaker.liquid.ILiquidStack;


val assembler = mods.gregtech.recipe.RecipeMap.getByName("assembler");

var logic = <appliedenergistics2:material:22>;
var calc = <appliedenergistics2:material:23>;
var eng = <appliedenergistics2:material:24>;
var wrec = <appliedenergistics2:material:41>;
var ironplt = <gregtech:meta_item_1:12033>;
var lithbat = <gregtech:meta_item_1:32518>;
var netvis =<aenetvistool:net_visualizer>;

assembler.recipeBuilder()
	.inputs(wrec * 2, calc, eng, logic, ironplt *2, lithbat)	
    .outputs(netvis)
	.fluidInputs([<liquid:soldering_alloy> * 72])
    .duration(100)
    .EUt(32)
    .buildAndRegister();

