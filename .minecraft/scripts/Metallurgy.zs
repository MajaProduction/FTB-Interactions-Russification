import crafttweaker.item.IItemStack;
import crafttweaker.liquid.ILiquidStack;
import crafttweaker.item.IIngredient;
import crafttweaker.data.IData;
import mods.thaumcraft.Crucible;
import mods.gregtech.material.MaterialRegistry;
import mods.gregtech.material.Material;
import crafttweaker.oredict.IOreDict;
import crafttweaker.oredict.IOreDictEntry;


val blast_furnace = mods.gregtech.recipe.RecipeMap.getByName("blast_furnace");
val macerator = mods.gregtech.recipe.RecipeMap.getByName("macerator");
val mixer = mods.gregtech.recipe.RecipeMap.getByName("mixer");
val autoclave = mods.gregtech.recipe.RecipeMap.getByName("autoclave");
val pyrolyse = mods.gregtech.recipe.RecipeMap.getByName("pyro");
val chemReactor = mods.gregtech.recipe.RecipeMap.getByName("chemical_reactor");
val plasma_arc_furnace = mods.gregtech.recipe.RecipeMap.getByName("plasma_arc_furnace");
val chemical_bath = mods.gregtech.recipe.RecipeMap.getByName("chemical_bath");



	#Adding the ores to the appropriate oredict for use in Squeezer
var squeezerOreDicts as string[][string] = {
	"Aluminium" : [ "Aluminium"],
	"Apatite": ["Apatite"],
	"Bauxite" : ["Bauxite"],
	"Bentonite" : ["Bentonite"],
	"Beryllium" : ["Beryllium"],
	"BlueTopaz" : ["BlueTopaz"],
	"Calcite" : ["Calcite"],
	"Cassiterite" : ["Cassiterite"],
	"CertusQuartz" : ["CertusQuartz"],
	"Copper" : [
		"Copper",
		"Tetrahedrite",
		"Malachite",
		"Chalcopyrite"
	],
	"Chromite" : ["Chromite"],
	"Cinnabar" : ["Cinnabar"],
	"Coal" : ["Coal"],
	"Diamond" : ["Diamond"],
	"Emerald" : ["Emerald"],
	"Galena" : ["Galena"],
	"GreenSapphire" : ["GreenSapphire"],
	"Glauconite" : ["Glauconite"],
	"Gold" : ["Gold"],
	"Graphite" : ["Graphite"],
	"Grossular" : ["Grossular"],
	"Ilmenite" : ["Ilmenite"],
	"Iron" : [
		"Iron",
		"YellowLimonite",
		"Pyrite",
		"BandedIron",
		"Magnetite",
		"BrownLimonite",
	],
	"Jasper" : ["Jasper"],
	"Lapis" : ["Lapis"],
	"Lead" : ["Lead"],
	"Lepidolite" : ["Lepidolite"],
	"Lignite" : ["Lignite"],
	"Magnesite" : ["Magnesite"],
	"Manganese" : ["Pyrolusite"],
	"Monazite" : ["Monazite"],
	"NetherQuartz" : ["NetherQuartz"],
	"Nickel" : [
		"Nickel",
		"Garnierite",
		"Pentlandite"
	],
	"Olivine" : ["Olivine"],
	"Phosphor" : ["Phosphor"],
	"Redstone" : ["Redstone"],
	"GarnetRed" : ["GarnetRed"],
	"Ruby" : ["Ruby"],
	"Rutile" : ["Rutile"],
	"Quartzite" : ["Quartzite"],
	"Sapphire" : ["Sapphire"],
	"Silver" : ["Silver"],
	"Soapstone" : ["Soapstone"],
	"Sodalite" : ["Sodalite"],
	"Spessartine" : ["Spessartine"],
	"Spodumene" : ["Spodumene"],
	"Stibnite" : ["Stibnite"],
	"Sulfur" : ["Sulfur"],
	"Talc" : ["Talc]"],
	"Tantalite" : ["Tantalite"],
	"Topaz" : ["Topaz"],
	"Tin" : [
		"Tin"
	],
	"Uraninite" : ["Uraninite"],
	"Uranium" : ["Uranium"],
	"Uranium235" : ["Uranium235"],
	"VanadiumMagnetite" : ["VanadiumMagnetite"],
	"Sphalerite" : ["Sphalerite"]
};

for squeezerDict, materialArray in squeezerOreDicts {
	var squeezerOreDict = oreDict["ore" + squeezerDict + "Squeezer"];
	for material in materialArray {
		squeezerOreDict.addAll(oreDict["ore" + material]);
		//print("added " + "ore" + material + " to metallurgy" + material);
		squeezerOreDict.addAll(oreDict["oreBasalt" + material]);
		//print("added " + "oreBasalt" + material + " to metallurgy" + material);
		squeezerOreDict.addAll(oreDict["oreBlackgranite" + material]);
		//print("added " + "oreBlackgranite" + material + " to metallurgy" + material);
		squeezerOreDict.addAll(oreDict["oreEndstone" + material]);
		//print("added " + "oreEndstone" + material + " to metallurgy" + material);
		squeezerOreDict.addAll(oreDict["oreGravel" + material]);
		//print("added " + "oreGravel" + material + " to metallurgy" + material);
		squeezerOreDict.addAll(oreDict["oreMarble" + material]);
		//print("added " + "oreMarble" + material + " to metallurgy" + material);
		squeezerOreDict.addAll(oreDict["oreRedgranite" + material]);
		//print("added " + "oreRedgranite" + material + " to metallurgy" + material);
		squeezerOreDict.addAll(oreDict["oreNetherrack" + material]);
		//print("added " + "oreNetherrack" + material + " to metallurgy" + material);
		squeezerOreDict.addAll(oreDict["oreSand" + material]);
		//print("added " + "oreSand" + material + " to metallurgy" + material);
	}
}



var autoclaveMapExisting as IOreDictEntry[IOreDictEntry] = {
	<ore:dustCertusQuartz> : <ore:gemCertusQuartz>,
	<ore:dustQuartzite> : <ore:gemQuartzite>,
	<ore:dustCinnabar> : <ore:gemCinnabar>,
	<ore:dustSodalite> : <ore:gemSodalite>,
	<ore:dustNetherQuartz> : <ore:gemNetherQuartz>,
	<ore:dustLapis> : <ore:gemLapis>,
	<ore:dustApatite> : <ore:gemApatite>
};

for dust, gem in autoclaveMapExisting {
	mods.gregtech.recipe.RecipeMap.getByName("autoclave").recipeBuilder()
    	.inputs(dust)
    	.fluidInputs(<liquid:astralsorcery.liquidstarlight> * 25)
    	.outputs(gem.firstItem)
    	.duration(100)
    	.EUt(24)
    	.buildAndRegister();
}

var autoclaveMapNew as IOreDictEntry[IOreDictEntry] = {
	<ore:dustQuartzBlack> : <ore:gemQuartzBlack>,
	<ore:dustMonazite> : <ore:gemMonazite>,
	<ore:dustDiamond> : <ore:gemDiamond>,
	<ore:dustGreenSapphire> : <ore:gemGreenSapphire>,
	<ore:dustRutile> : <ore:gemRutile>,
	<ore:dustRuby> : <ore:gemRuby>,
	<ore:dustSapphire> : <ore:gemSapphire>,
	<ore:dustOlivine> : <ore:gemOlivine>,
	<ore:dustOpal> : <ore:gemOpal>,
	<ore:dustEmerald> : <ore:gemEmerald>,
	<ore:dustEnderPearl> : <ore:gemEnderPearl>,
	<ore:dustTopaz> : <ore:gemTopaz>,
	<ore:dustJasper> : <ore:gemJasper>,
	<ore:dustGarnetRed> : <ore:gemGarnetRed>
};

for dust, gem in autoclaveMapNew {
	mods.gregtech.recipe.RecipeMap.getByName("autoclave").recipeBuilder()
    	.inputs(dust)
    	.fluidInputs(<liquid:water> * 200)
    	.chancedOutput(gem.firstItem, 7000, 2700)
    	.duration(2000)
    	.EUt(24)
    	.buildAndRegister();

	mods.gregtech.recipe.RecipeMap.getByName("autoclave").recipeBuilder()
    	.inputs(dust)
    	.fluidInputs(<liquid:distilled_water> * 200)
    	.chancedOutput(gem.firstItem, 9000, 3000)
    	.duration(1000)
    	.EUt(24)
    	.buildAndRegister();

	mods.gregtech.recipe.RecipeMap.getByName("autoclave").recipeBuilder()
    	.inputs(dust)
    	.fluidInputs(<liquid:astralsorcery.liquidstarlight> * 25)
    	.outputs(gem.firstItem)
    	.duration(100)
    	.EUt(24)
    	.buildAndRegister();
}

var metallurgyOreDicts as string[] = [
	"Aluminium",
	"Apatite",
	"Bauxite",
	"Bentonite",
	"Beryllium",
	"BlueTopaz",
	"Calcite",
	"Cassiterite",
	"CertusQuartz",
	"Copper",
	"Tetrahedrite",
	"Malachite",
	"Chalcopyrite",
	"Chromite",
	"Cinnabar",
	"Coal",
	"Cobalt",
	"Cobaltite",
	"Diamond",
	"Emerald",
	"Galena",
	"GreenSapphire",
	"Glauconite",
	"Gold",
	"Graphite",
	"Grossular",
	"Ilmenite",
	"Iridium",
	"Iron",
	"YellowLimonite",
	"Pyrite",
	"BandedIron",
	"Magnetite",
	"BrownLimonite",
	"Jasper",
	"Lapis",
	"Lead",
	"Lepidolite",
	"Lignite",
	"Magnesite",
	"Pyrolusite",
	"Monazite",
	"NetherQuartz",
	"Nickel",
	"Niobium",
	"Garnierite",
	"Pentlandite",
	"Olivine",
	"Phosphor",
	"Platinum",
	"Redstone",
	"GarnetRed",
	"Ruby",
	"Rutile",
	"Quartzite",
	"Sapphire",
	"Scheelite",
	"Silver",
	"Soapstone",
	"Sodalite",
	"Spessartine",
	"Sphalerite",
	"Spodumene",
	"Stibnite",
	"Sulfur",
	"Talc",
	"Tantalite",
	"Topaz",
	"Tin",
	"Tungstate",
	"Tungsten",
	"Uraninite",
	"Uranium",
	"Vinteum",
	"Uranium235",
	"VanadiumMagnetite"
];

for material in metallurgyOreDicts {
	var metallurgyOreDict = oreDict["metallurgy" + material];

	metallurgyOreDict.addAll(oreDict["ore" + material]);
	//print("added " + "ore" + material + " to metallurgy" + material);
	metallurgyOreDict.addAll(oreDict["oreBasalt" + material]);
	//print("added " + "oreBasalt" + material + " to metallurgy" + material);
	metallurgyOreDict.addAll(oreDict["oreBlackgranite" + material]);
	//print("added " + "oreBlackgranite" + material + " to metallurgy" + material);
	metallurgyOreDict.addAll(oreDict["oreEndstone" + material]);
	//print("added " + "oreEndstone" + material + " to metallurgy" + material);
	metallurgyOreDict.addAll(oreDict["oreGravel" + material]);
	//print("added " + "oreGravel" + material + " to metallurgy" + material);
	metallurgyOreDict.addAll(oreDict["oreMarble" + material]);
	//print("added " + "oreMarble" + material + " to metallurgy" + material);
	metallurgyOreDict.addAll(oreDict["oreRedgranite" + material]);
	//print("added " + "oreRedgranite" + material + " to metallurgy" + material);
	metallurgyOreDict.addAll(oreDict["oreNetherrack" + material]);
	//print("added " + "oreNetherrack" + material + " to metallurgy" + material);
	metallurgyOreDict.addAll(oreDict["oreSand" + material]);
	//print("added " + "oreSand" + material + " to metallurgy" + material);
}

	#Early Game Melting Recipes
var metalMelt as ILiquidStack[IOreDictEntry] = {
	<ore:oreIronSqueezer> : <liquid:iron>,
	<ore:oreCopperSqueezer> : <liquid:copper>,
	<ore:oreCassiteriteSqueezer> : <liquid:tin>,
	<ore:oreNickelSqueezer> : <liquid:nickel>
};

for ore, fluid in metalMelt {
	mods.tconstruct.Melting.addRecipe(fluid * 144, ore);
}

	#nonGT Metallurgy OreDicts
<ore:metallurgyBlackQuartzy>.addAll(<ore:oreQuartzBlack>);
<ore:metallurgyArdite>.addAll(<ore:oreArdite>);


var materialMetalMap as int[string] = {
	"Aluminium" : 2,
	"Bauxite" : 6,
	"Bentonite" : 2,
	"Beryllium" : 2,
	"Calcite" : 2,
	"Cassiterite" : 12,
	"Cobaltite" : 6,
	"Cobalt" : 2,	
	"Copper" : 2,
	"Tetrahedrite" : 3,
	"Malachite" : 5,
	"Chalcopyrite" : 2,
	"Chromite" : 2,
	"Coal" : 2,
	"Galena" : 2,
	"Glauconite" : 2,
	"Gold" : 2,
	"Graphite" : 2,
	"Grossular" : 6,
	"Ilmenite" : 6,
	"Iridium" : 2,
	"Iron" : 2,
	"YellowLimonite" : 4,
	"Pyrite" : 3,
	"BandedIron" : 3,
	"Magnetite" : 3,
	"BrownLimonite" : 4,
	"Lead" : 2,
	"Lepidolite" : 10,
	"Lignite" : 2,
	"Magnesite" : 10,
	"Pyrolusite" : 6,
	"Osmium" : 2,
	"Nickel" : 2,
	"Niobium" : 2,
	"Garnierite" : 2,
	"Pentlandite" : 2,
	"Platinum" : 2,
	"Phosphor" : 3,
	"Redstone" : 12,
	"Silver" : 2,
	"Soapstone" : 2,
	"Sphalerite" : 2,
	"Sodalite" : 6,
	"Spessartine" : 2,
	"Spodumene" : 2,
	"Stibnite" : 6,
	"Sulfur" : 2,
	"Talc" : 2,
	"Tungsten" : 2,
	"Tantalite" : 4,
	"Tin" : 2,
	"Uraninite" : 2,
	"Uranium" : 2,
	"Uranium" : 2,	
	"Uranium235" : 2,
	"Vinteum" : 2,
	"VanadiumMagnetite" : 2
};


for material, multiplier in materialMetalMap {

	var ore = "metallurgy" + material;
	var crushed = "crushed" + material;
	var clump = "clump" + material;
	var cluster = "cluster" + material;
		
	macerator.recipeBuilder()
		.inputs(oreDict.get(cluster).firstItem)
		.outputs(oreDict.get(crushed).firstItem* multiplier)
		.duration(200)
		.EUt(12)
		.buildAndRegister();
		//print(cluster + " in macerator done!");
}

var materialGemMap as int[string] = {
	"Apatite" : 4,
	"BlueTopaz" : 2,
	"CertusQuartz" : 2,
	"Cinnabar" : 2,
	"Diamond" : 2,
	"Emerald" : 2,
	"GreenSapphire" : 2,
	"Lapis" : 12,
	"Monazite" : 8,
	"NetherQuartz" : 2,
	"Olivine" : 2,
	"Ruby" : 2,
	"Rutile" : 2,
	"Quartzite" : 2,
	"Sapphire" : 2
};

for material, multiplier in materialGemMap {

	var ore = "ore" + material + "Metallurgy";
	var crushed = "crushed" + material;
	var clump = "clump" + material;
	var cluster = "cluster" + material;


	macerator.recipeBuilder()
		.inputs(oreDict.get(cluster).firstItem)
		.outputs(oreDict.get(crushed).firstItem * multiplier)
		.duration(200)
		.EUt(12)
		.buildAndRegister();
		//print(cluster + " in macerator done!");
}

	#exceptions (due to no crushed ore)
	// Black Quartz
	#Ardite

macerator.recipeBuilder()
	.inputs(<ore:clusterArdite>)
	.outputs(<ore:dustArdite>.firstItem * 2 )
	.duration(200)
	.EUt(12)
	.buildAndRegister();

#Dense Titanium
macerator.recipeBuilder()
	.inputs(<ore:denseOreTitanium>)
	.outputs(<ore:dustTitanium>.firstItem * 4 )
	.duration(200)
	.EUt(120)
	.buildAndRegister();

var denseMetallurgy as string[][IItemStack] = {
	<ore:denseOreAluminium>.firstItem : [
		"Aluminium"
	],
	<ore:denseOreBauxite>.firstItem : [
		"Bauxite"
	],
	<ore:denseOreChromite>.firstItem : [
		"Chromite"
	],
	<ore:denseOreCobalt>.firstItem : [
		"Cobaltite"
	],
	<ore:denseOreCopper>.firstItem : [
		"Copper",
		"Tetrahedrite",
		"Malachite",
		"Chalcopyrite"
	],
	<ore:denseOreDiamond>.firstItem : [
		"Diamond"
	],
	<ore:denseOreVinteum>.firstItem : [
		"Vinteum"
	],	
	<ore:denseOreLapis>.firstItem : [
		"Lapis",
		"Lazurite"
	],	
	<ore:denseOreEmerald>.firstItem : [
		"Emerald"
	],
	<ore:denseOreGold>.firstItem : [
		"Gold"
	],
	<ore:denseOreIlmenite>.firstItem : [
		"Ilmenite"
	],
	<ore:denseOreIridium>.firstItem : [
		"Iridium"
	],
	<ore:denseOreIron>.firstItem : [
		"Iron",
		"BandedIron",
		"Magnetite",
		"BrownLimonite",
		"YellowLimonite",
		"Pyrite"
	],
	<ore:denseOreLead>.firstItem : [
		"Lead"
	],
	<ore:denseOreNickel>.firstItem : [
		"Nickel",
		"Garnierite",
		"Pentlandite"		
	],	
	<ore:denseOreGraphite>.firstItem : [
		"Graphite"
	],
	<ore:denseOrePyrolusite>.firstItem : [
		"Pyrolusite",
		"Manganese"
	],	
	<ore:denseOreSaltpeter>.firstItem : [
		"Saltpeter"
	],	
	<ore:denseOreRutile>.firstItem : [
		"Rutile"
	],	
	<ore:denseOreLepidolite>.firstItem : [
		"Lepidolite"
	],
	<ore:denseOreArdite>.firstItem : [
		"Ardite"
	],	
	<ore:denseOreNiobium>.firstItem : [
		"Niobium"
	],
	<ore:denseOrePlatinum>.firstItem: [
		"Platinum"
	],
	<ore:denseOreRedstone>.firstItem : [
		"Redstone"
	],
	<ore:denseOreRuby>.firstItem : [
		"Ruby"	
	],	
	<ore:denseOreSapphire>.firstItem : [
		"Sapphire"
	],
	<ore:denseOreMagnesite>.firstItem : [
		"Magnesite"
	],	
	<ore:denseOreSilver>.firstItem : [
		"Silver"
	],
	<ore:denseOreStibnite>.firstItem : [
		"Stibnite" 
	],
	<ore:denseOreTantalite>.firstItem : [
		"Tantalite"
	],
	<ore:denseOreTin>.firstItem : [
		"Tin",
		"Cassiterite"
	],
	<ore:denseOreTungsten>.firstItem : [
		"Tungsten",
		"Tungstate",
		"Scheelite"
	],
	<ore:denseOreUraninite>.firstItem : [
		"Uraninite"
	],
	<ore:denseOreUranium>.firstItem : [
		"Uranium"
	],
	<ore:denseOreUranium235>.firstItem : [
		"Uranium235"
	],
	<ore:denseOreVanadiumMagnetite>.firstItem : [
		"VanadiumMagnetite"
	]
};



	#Hide unused dense ores

var denseDisabled as IItemStack[] = [
	<ore:denseOreFullersEarth>.firstItem,
	<ore:denseOreManganese>.firstItem,
	<ore:denseOreGarnierite>.firstItem,
	<ore:denseOreSaltpeter>.firstItem,
	<ore:denseOreLazurite>.firstItem,
	<ore:denseOreNaquadah>.firstItem,
	<ore:denseOreBandedIron>.firstItem,
	<ore:denseOreCooperite>.firstItem,
	<ore:denseOreGreenSapphire>.firstItem,
	<ore:denseOreMenril>.firstItem,
	<ore:denseOreMagnetite>.firstItem,
	<ore:denseOrePentlandite>.firstItem,
	<ore:denseOreMolybdenum>.firstItem,
	<ore:denseOrePyrope>.firstItem,
	<ore:denseOreMonazite>.firstItem,
	<ore:denseOreCoal>.firstItem,
	<ore:denseOreGlauconite>.firstItem,
	<ore:denseOreTetrahedrite>.firstItem,
	<ore:denseOreMalachite>.firstItem,
	<ore:denseOreBentonite>.firstItem,
	<ore:denseOreOpal>.firstItem,
	<ore:denseOrePyrite>.firstItem,
	<ore:denseOreCassiterite>.firstItem,
	<ore:denseOreTantalum>.firstItem,
	<ore:denseOreOsmium>.firstItem,
	<ore:denseOreQuartzite>.firstItem,
	<ore:denseOreGarnetSand>.firstItem,
	<ore:denseOreCobaltite>.firstItem,
	<ore:denseOreYellowLimonite>.firstItem,
	<ore:denseOreQuartzSand>.firstItem,
	<ore:denseOreSodalite>.firstItem,
	<ore:denseOreZinc>.firstItem,
	<ore:denseOreBrownLimonite>.firstItem,
	<ore:denseOreSalt>.firstItem,
	<ore:denseOrePowellite>.firstItem,
	<ore:denseOreBastnasite>.firstItem,
	<ore:denseOreSpessartine>.firstItem,
	<ore:denseOrePhosphor>.firstItem,
	<ore:denseOreNetherQuartz>.firstItem,
	<ore:denseOreLithium>.firstItem,
	<ore:denseOreChalcopyrite>.firstItem,
	<ore:denseOreBlueTopaz>.firstItem,
	<ore:denseOreBeryllium>.firstItem,
	<ore:denseOreTanzanite>.firstItem,
	<ore:denseOreTalc>.firstItem,
	<ore:denseOreSulfur>.firstItem,
	<ore:denseOreAmethyst>.firstItem,
	<ore:denseOreWulfenite>.firstItem,
	<ore:denseOreJasper>.firstItem,
	<ore:denseOreTopaz>.firstItem,
	<ore:denseOreThorium>.firstItem,
	<ore:denseOrePitchblende>.firstItem,
	<ore:denseOrePalladium>.firstItem,
	<ore:denseOreCalcium>.firstItem,
	<ore:denseOreBarite>.firstItem,
	<ore:denseOreGarnetRed>.firstItem,
	<ore:denseOreGarnetYellow>.firstItem,
	<ore:denseOreLignite>.firstItem,
	<ore:denseOreMagnesium>.firstItem,
	<ore:denseOreOlivine>.firstItem,
	<ore:denseOreRockSalt>.firstItem,
	<ore:denseOreScheelite>.firstItem,
	<ore:denseOreSpodumene>.firstItem,
	<ore:denseOreTungstate>.firstItem,
	<ore:denseOreGalena>.firstItem,
	<ore:denseOreCalcite>.firstItem,
	<ore:denseOreGrossular>.firstItem,
	<ore:denseOreNaquadahEnriched>.firstItem,
	<ore:denseOreNiobium>.firstItem,
	<ore:denseOreSoapstone>.firstItem,
	<ore:denseOreApatite>.firstItem,
	<ore:denseOreCertusQuartz>.firstItem,
	<ore:denseOreCinnabar>.firstItem
	];

for i in denseDisabled {
	mods.jei.JEI.removeAndHide(i);
}


mods.jei.JEI.removeAndHide(<botania:manasteelboots>);

//Ores into dense ores or into clusters
for denseOre, stringOreDicts in denseMetallurgy {

	for i in stringOreDicts {
		for ore in oreDict["metallurgy" + i].items{
			var cluster = "cluster" + i;
			mods.astralsorcery.LightTransmutation.addTransmutation(ore, denseOre, 300);	
				
			chemical_bath.recipeBuilder()
				.inputs(ore)
				.fluidInputs([<liquid:astralsorcery.liquidstarlight> * 20])
				.outputs(denseOre)
				.duration(60)
				.EUt(24)
				.buildAndRegister();
			
			furnace.addRecipe(oreDict.get(cluster).firstItem *2, denseOre);
			//print("dense or transmutation and smelting done");
		}	
	}
}

// Hide unusable clusters
var clusterDisabled as IItemStack[] = [
	<contenttweaker:green_sapphire_ore_cluster>,
	<contenttweaker:magnetite_ore_cluster>,
	<contenttweaker:cassiterite_ore_cluster>,
	<contenttweaker:garnet_sand_ore_cluster>,
	<contenttweaker:tantalum_ore_cluster>,
	<contenttweaker:osmium_ore_cluster>,
	<contenttweaker:banded_iron_ore_cluster>,
	<contenttweaker:galena_ore_cluster>,
	<contenttweaker:zinc_ore_cluster>,
	<contenttweaker:rock_salt_ore_cluster>,
	<contenttweaker:cooperite_ore_cluster>,
	<contenttweaker:olivine_ore_cluster>,
	<contenttweaker:bastnasite_ore_cluster>,
	<contenttweaker:jasper_ore_cluster>,
	<contenttweaker:salt_ore_cluster>,
	<contenttweaker:quartz_sand_ore_cluster>,
	<contenttweaker:saltpeter_ore_cluster>,
	<contenttweaker:apatite_ore_cluster>,
	<contenttweaker:manganese_ore_cluster>,
	<contenttweaker:menril_ore_cluster>,
	<contenttweaker:garnet_yellow_ore_cluster>,
	<contenttweaker:tetrahedrite_ore_cluster>,
	<contenttweaker:naquadah_enriched_ore_cluster>,
	<contenttweaker:fullers_earth_ore_cluster>,
	<contenttweaker:molybdenum_ore_cluster>,
	<contenttweaker:lithium_ore_cluster>,
	<contenttweaker:nether_quartz_ore_cluster>,
	<contenttweaker:phosphor_ore_cluster>,
	<contenttweaker:grossular_ore_cluster>,
	<contenttweaker:wulfenite_ore_cluster>,
	<contenttweaker:chalcopyrite_ore_cluster>,
	<contenttweaker:garnierite_ore_cluster>,
	<contenttweaker:malachite_ore_cluster>,
	<contenttweaker:blue_topaz_ore_cluster>,
	<contenttweaker:tanzanite_ore_cluster>,
	<contenttweaker:topaz_ore_cluster>,
	<contenttweaker:brown_limonite_ore_cluster>,
	<contenttweaker:opal_ore_cluster>,
	<contenttweaker:amethyst_ore_cluster>,
	<contenttweaker:quartzite_ore_cluster>,
	<contenttweaker:lignite_ore_cluster>,
	<contenttweaker:glauconite_ore_cluster>,
	<contenttweaker:spessartine_ore_cluster>,
	<contenttweaker:pentlandite_ore_cluster>,
	<contenttweaker:pitchblende_ore_cluster>,
	<contenttweaker:calcium_ore_cluster>,
	<contenttweaker:palladium_ore_cluster>,
	<contenttweaker:powellite_ore_cluster>,
	<contenttweaker:calcite_ore_cluster>,
	<contenttweaker:magnesium_ore_cluster>,
	<contenttweaker:talc_ore_cluster>,
	<contenttweaker:pyrite_ore_cluster>,
	<contenttweaker:titanium_ore_cluster>,
	<contenttweaker:thorium_ore_cluster>,
	<contenttweaker:scheelite_ore_cluster>,
	<contenttweaker:monazite_ore_cluster>,
	<contenttweaker:spodumene_ore_cluster>	
	];

for i in clusterDisabled {
	mods.jei.JEI.removeAndHide(i);
}	
	
	#Dense Ores to Shards
var shardList as string[] = [
	"Aluminium",
	"Bauxite",
	"Chromite",
	"Cobalt",
	"Copper",
	"Diamond",
	"Vinteum",
	"Lapis",
	"Emerald",
	"Gold",
	"Ilmenite",
	"Iridium",
	"Rutile",
	"Pyrolusite",
	"Lepidolite",
	"Ardite",
	"Graphite",
	"Iron",
	"Magnesite",
	"Lead",
	"Nickel",
	"Niobium",
	"Redstone",
	"Platinum",
	"Ruby",
	"Sapphire",
	"Silver",
	"Stibnite",
	"Tantalite",
	"Tin",
	"Tungsten",
	"Uraninite",
	"Uranium",
	"Uranium235",
	"VanadiumMagnetite"
];

	#Dense ore processing
for i in shardList {
	var oreInput = oreDict["denseOre" + i].firstItem;
	var shardOutput = oreDict["shard" + i].firstItem;
	var cluster = "cluster" + i;

	chemReactor.recipeBuilder()
		.inputs([oreInput])
		.fluidInputs([<liquid:lifeessence> * 200, <liquid:mana_fluid> * 100])
		.outputs(shardOutput)
		.duration(280)
		.EUt(48)
		.buildAndRegister();

		furnace.addRecipe(oreDict.get(cluster).firstItem *4, shardOutput);
}

	#Shards to Clumps
var multiShardMap as string[IData[]] = {
	["Aluminium", "Aluminium", 8] : "Aluminium",
	["Bauxite", "Aluminium", 8] : "Aluminium",
	["Chromite", "Chromite", 8] : "Ruby",
	["Cobalt" , "Cobalt", 8] : "Cobalt",
	["Ardite", "Ardite", 8] : "Ardite",	
	["Copper", "Copper", 8] : "Copper",
	["Diamond", "Diamond", 8] : "Diamond",
	["Vinteum", "Vinteum", 8] : "Vinteum",
	["Stibnite", "Stibnite", 8] : "Stibnite",	
	["Lapis", "Lapis", 8] : "Lapis",
	["Lapis", "Lazurite", 8] : "Lapis",	
	["Emerald", "Emerald", 8] : "Emerald",
	["Gold", "Gold", 8] : "Gold",
	["Graphite", "Graphite", 8] : "Graphite",	
	["Ilmenite", "Rutile", 8] : "Titanium",
	["Iridium", "Iridium", 8] : "Iridium",
	["Iron", "Iron", 8] : "Iron",
	["Platinum", "Platinum", 8] : "Platinum",
	["Sphalerite", "Sphalerite", 8] : "Sphalerite",	
	["Pyrolusite", "Pyrolusite", 8] : "Pyrolusite",	
	["Lead", "Lead", 8] : "Lead",
	["Nickel", "Nickel", 8] : "Nickel",
	["Redstone", "Redstone", 8] : "Redstone",
	["Ruby", "Ruby", 8] : "Ruby",
	["Rutile", "Rutile", 8] : "Titanium",	
	["Lepidolite", "Lepidolite", 8] : "Lepidolite",		
	["Sapphire", "Sapphire", 8] : "Sapphire",
	["Silver", "Silver", 8] : "Silver",
	["Tantalite", "Tantalite", 8] :  "Niobium",
	["Tin", "Tin", 8] : "Tin",
	["Tungsten", "Tungsten", 8] : "Tungsten",
	["Uraninite", "Uraninite", 8] : "Uranium",
	["Uranium","Uranium", 8] : "Uranium",
	["Uranium235", "Uranium235", 8] : "Uranium",
	["VanadiumMagnetite", "Iron", 8] : "Iron",
	["VanadiumMagnetite", "VanadiumMagnetite", 8] : "VanadiumMagnetite",
	["VanadiumMagnetite", "Gold", 8] : "Gold"
};

for outputInfo, mat in multiShardMap {
	
	var shardItem = oreDict["shard" + outputInfo[0]];
	var crystalItem = oreDict["crystal" + outputInfo[0]];
	var clumpItem = oreDict["clump" + outputInfo[0]];
	var multiplier = outputInfo[2];
	var cluster = oreDict["cluster" + outputInfo[0]];
	
	

	//print(mat + " mat and " + outputInfo[0] + " shard done!");


	//print("current output info is: " + outputInfo[0]);
	//print("current crystal is: " + crystalItem.name + " first item in oredict: " + crystalItem.firstItem.name);
	//print("current clump is: " + clumpItem.name + " first item in oredict: " + clumpItem.firstItem.name);
	//print("current cluster is: " + cluster.name + " first item in oredict: " + cluster.firstItem.name);


	plasma_arc_furnace.recipeBuilder()
		.inputs(shardItem)
		.fluidInputs([<liquid:pyrotheum> * 144])
		.outputs(crystalItem.firstItem)
		.fluidOutputs([<liquid:phosphoric_acid> * 15])
		.duration(80)
		.EUt(480)
		.buildAndRegister();
		//print("added plasma arc furnace recipe for " + crystalItem.firstItem.name);

	

		furnace.addRecipe(cluster.firstItem *8, crystalItem);
		//print("added final furnace recipe for " + cluster.firstItem.name);		
		
	//Crystals to Clumps	
		mods.gregtech.recipe.RecipeMap.getByName("autoclave").recipeBuilder()
    	.inputs(crystalItem)
    	.fluidInputs(<liquid:uumatter> * 10)
    	.outputs(clumpItem.firstItem)
    	.duration(100)
    	.EUt(480)
    	.buildAndRegister();

	furnace.addRecipe(cluster.firstItem *16, clumpItem);

	mods.thaumcraft.Crucible.registerRecipe("crucible" + clumpItem.firstItem.name, "BASEALCHEMY", cluster.firstItem*32, clumpItem.firstItem, [<aspect:desiderium> * 5, <aspect:potentia> * 5]);

}

#manual for titanium
