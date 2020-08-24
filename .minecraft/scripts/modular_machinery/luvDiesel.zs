import mods.modularmachinery.RecipePrimer;
import mods.modularmachinery.RecipeBuilder;

var machineName = "dieselgenerator_luv";

function createRecipeName(machineName as string, recipeName as string) as string {
	return machineName + "_" + recipeName;
}

	#
mods.modularmachinery.RecipeBuilder.newBuilder(createRecipeName(machineName, "zpmnaquadahfuel"), machineName, 10)
	.addEnergyPerTickOutput(131072)
	.addFluidOutput(<liquid:sludge> * 1)
	.addFluidInput(<liquid:oxygen> * 10)
	.addFluidInput(<liquid:naquadriaticfuel> * 14)
	.build();
	
mods.modularmachinery.RecipeBuilder.newBuilder(createRecipeName(machineName, "zpminfusedfuel"), machineName, 10)
	.addEnergyPerTickOutput(131072)
	.addFluidOutput(<liquid:sludge> * 1)
	.addFluidInput(<liquid:oxygen> * 10)
	.addFluidInput(<liquid:infused_nitrofuel> * 340)
	.build();		