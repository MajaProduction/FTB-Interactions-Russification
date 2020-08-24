import crafttweaker.item.IItemStack;
import crafttweaker.item.IIngredient;
import mods.chisel.Carving;

print("---------------Chisel Start------------------");

	#remove Zest, will become portal Block
mods.chisel.Carving.removeVariation("zest", <xtones:zest:4>);
mods.chisel.Carving.removeVariation("jelt", <xtones:jelt:15>);
mods.chisel.Carving.removeVariation("marble", <astralsorcery:blockmarble:6>);
	
	#remove block crafting
recipes.remove(<chisel:blockbronze>);
recipes.remove(<chisel:blockcobalt>);
recipes.remove(<chisel:blockcopper>);
recipes.remove(<chisel:diamond>);
recipes.remove(<chisel:blockelectrum>);
recipes.remove(<chisel:emerald>);
recipes.remove(<chisel:blockgold>);
recipes.remove(<chisel:blockinvar>);
recipes.remove(<chisel:lapis>);
recipes.remove(<chisel:blocklead>);
recipes.remove(<chisel:blocknickel>);
recipes.remove(<chisel:blockplatinum>);
recipes.remove(<chisel:redstone>);
recipes.remove(<chisel:blocksilver>);
recipes.remove(<chisel:blocksteel>);
recipes.remove(<chisel:blocktin>);
recipes.remove(<chisel:blockuranium>);
recipes.remove(<chisel:block_coal>);
recipes.remove(<chisel:block_charcoal>);

	#Letting Aluminium Blocks get Chiseled
furnace.addRecipe(<chisel:blockaluminum:2>, <ore:blockAluminium>);
furnace.addRecipe(<ore:blockAluminium>.firstItem, <chisel:blockaluminum:2>);


	#chiseling tinkers stained variants to/from vanilla stained variants
mods.chisel.Carving.addVariation("glass", <tconstruct:clear_glass>);
mods.chisel.Carving.addVariation("glassdyedblack", <tconstruct:clear_stained_glass:15>);
mods.chisel.Carving.addVariation("glassdyedred", <tconstruct:clear_stained_glass:14>);
mods.chisel.Carving.addVariation("glassdyedgreen", <tconstruct:clear_stained_glass:13>);
mods.chisel.Carving.addVariation("glassdyedbrown", <tconstruct:clear_stained_glass:12>);
mods.chisel.Carving.addVariation("glassdyedblue", <tconstruct:clear_stained_glass:11>);
mods.chisel.Carving.addVariation("glassdyedpurple", <tconstruct:clear_stained_glass:10>);
mods.chisel.Carving.addVariation("glassdyedcyan", <tconstruct:clear_stained_glass:9>);
mods.chisel.Carving.addVariation("glassdyedlightgray", <tconstruct:clear_stained_glass:8>);
mods.chisel.Carving.addVariation("glassdyedgray", <tconstruct:clear_stained_glass:7>);
mods.chisel.Carving.addVariation("glassdyedpink", <tconstruct:clear_stained_glass:6>);
mods.chisel.Carving.addVariation("glassdyedlime", <tconstruct:clear_stained_glass:5>);
mods.chisel.Carving.addVariation("glassdyedyellow", <tconstruct:clear_stained_glass:4>);
mods.chisel.Carving.addVariation("glassdyedlightblue", <tconstruct:clear_stained_glass:3>);
mods.chisel.Carving.addVariation("glassdyedmagenta", <tconstruct:clear_stained_glass:2>);
mods.chisel.Carving.addVariation("glassdyedorange", <tconstruct:clear_stained_glass:1>);
mods.chisel.Carving.addVariation("glassdyedwhite", <tconstruct:clear_stained_glass>);


print("----------------Chisel End-------------------");