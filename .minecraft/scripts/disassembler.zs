// WARNING WARNING WARNING !!!
// Be very careful if editing this file.
// Crafttweaker has a very nasty bug where if you don't handle doubles just right it
// explodes.  You should always make sure that your literals and the rhs of initialization
// to double variables is marked with `as double`, that double literals are spelled out
// with `1.0D`, and that double variables are marked as double in initialization.
// If you do not, the syntax checker will crash and it will not give you a meaningful error.
// For example, consider the following code:
//     val tiered_results as double[string][string] = {...} as double[string][string];
//     for item_name, base_result_map in tiered_results {
//         for component_name, base_yield in base_result_map {
//             var modified_yield as double = base_yield;
//         }
//     }
// This code will syntax check but will crash at runtime without reporting a proper error.
// The problem is that even though `base_yield` is a double according to the type we
// gave `tiered_results`, when crafttweaker encounters an iteration variable (ie `base_yield`)
// it silently promotes it to the type "nullable double" which is represented as a boxed double
// in the underlying java bytecode.  Contenttweaker will improperly store this boxed double
// to a primitive double local variable directly without unboxing it, causing an error which
// only reports a bytecode index and not a line number.  The solution is a redundant `as double`
// on `base_yield` on the line where `modified_yield` is initialized.
//
// Putting an integer literal like `1` instead of a double literal like `1.0D` in
// a map literal will cause the syntax checker to crash with the only error being
// "null" and "arrayindexoutofbounds" in the crafttweaker log.  If you change this
// file and encounter any of the above errors, look for the problems mentioned above.
import crafttweaker.world.IFacing;
import crafttweaker.block.IBlock;
import crafttweaker.item.IIngredient;
import crafttweaker.item.IItemStack;

import mods.gregtech.multiblock.Builder;
import mods.gregtech.multiblock.FactoryBlockPattern;
import mods.gregtech.multiblock.IBlockMatcher;
import mods.gregtech.multiblock.MultiblockAbility;
import mods.gregtech.multiblock.RelativeDirection;
import mods.gregtech.multiblock.FactoryMultiblockShapeInfo;
import mods.gregtech.multiblock.IBlockInfo;
import mods.gregtech.multiblock.IBlockWorldState;
import mods.gregtech.multiblock.Multiblock;

import mods.gregtech.MetaTileEntities;

import mods.gregtech.recipe.FactoryRecipeMap;

import mods.gregtech.render.ITextureArea;
import mods.gregtech.render.MoveType;
import mods.gregtech.render.ICubeRenderer;
import mods.gregtech.render.Textures;

print("----------------Disassembler Start-------------------");

var id = 3000 as int;
var loc = "disassembler" as string;

val disassembler_recipe_map = FactoryRecipeMap.start(loc)
	.minInputs(1)
	.maxInputs(1)
	.minFluidInputs(0)
	.maxFluidInputs(1)
	.minOutputs(1)
	.maxOutputs(16)
	.minFluidOutputs(0)
	.maxFluidOutputs(1)
	.build();

val disassembler = Builder.start(loc, id)
	// set the multiblock pattern.  variable layers and hatch/capability places go here
	.withPattern(
		FactoryBlockPattern.start(RelativeDirection.RIGHT, RelativeDirection.BACK, RelativeDirection.UP)
			.aisle(
				"CCC",
				"CCC",
				"CSC")
			.aisle(
				"CCC",
				"C C",
				"CCC")
			.aisle(
				"CCC",
				"CCC",
				"CCC")
			.where('S', IBlockMatcher.controller(loc))
			.where(' ', IBlockMatcher.ANY)
			.whereOr('C', <metastate:gregtech:metal_casing:3> as IBlockMatcher,
				IBlockMatcher.abilityPartPredicate(MultiblockAbility.INPUT_ENERGY,
					MultiblockAbility.IMPORT_FLUIDS,
					MultiblockAbility.IMPORT_ITEMS,
					MultiblockAbility.EXPORT_FLUIDS,
					MultiblockAbility.EXPORT_ITEMS))
			.setAmountAtMost('p', 4)
			.where('p', IBlockMatcher.abilityPartPredicate(MultiblockAbility.INPUT_ENERGY))
			.setAmountAtMost('f', 1)
			.where('f', IBlockMatcher.abilityPartPredicate(MultiblockAbility.IMPORT_FLUIDS))
			.setAmountAtMost('i', 1)
			.where('i', IBlockMatcher.abilityPartPredicate(MultiblockAbility.IMPORT_ITEMS))
			.setAmountAtMost('F', 1)
			.where('F', IBlockMatcher.abilityPartPredicate(MultiblockAbility.EXPORT_FLUIDS))
			.setAmountAtMost('I', 1)
			.where('I', IBlockMatcher.abilityPartPredicate(MultiblockAbility.EXPORT_ITEMS))
			.build())
	// add a multiblock pattern to display in jei and in world preview.  this is required by mbt to give previews
	.addDesign(
		FactoryMultiblockShapeInfo.start()
			.aisle(
				"CpC",
				"fCF",
				"iSI")
			.aisle(
				"CCC",
				"C C",
				"CCC")
			.aisle(
				"CCC",
				"CCC",
				"CCC")
			.where('S', IBlockInfo.controller(loc))
			.where(' ', IBlockInfo.EMPTY)
			.where('C', <metastate:gregtech:metal_casing:3>)
			.where('p', MetaTileEntities.ENERGY_INPUT_HATCH[3], IFacing.north())
			.where('f', MetaTileEntities.FLUID_IMPORT_HATCH[1], IFacing.west())
			.where('i', MetaTileEntities.ITEM_IMPORT_BUS[1], IFacing.west())
			.where('F', MetaTileEntities.FLUID_EXPORT_HATCH[1], IFacing.east())
			.where('I', MetaTileEntities.ITEM_EXPORT_BUS[3], IFacing.east())
			.build())
	// initialize the recipe manager for the disassembler, populated later
	// the recipe map itself is a part of gtce's own crafttweaker support not mbt
	// these limits are not all required
	// other methods include setProgressBar to have a custom progress bar for the machine
	.withRecipeMap(disassembler_recipe_map)
	.buildAndRegister() as Multiblock;

// TODO: move to .lang files
game.setLocalization(
    "multiblocktweaker.machine.disassembler.name",
    "Disassembler"
);
game.setLocalization(
    "multiblocktweaker.multiblock.disassembler.description",
    "The Disassembler can recover some of the microcomponents and materials that went into crafting many items."
);
game.setLocalization(
	"recipemap.disassembler.name",
	"Item Disassembly"
);

val mvArm = <gregtech:meta_item_1:32651>;
recipes.addShaped("disassembler_controller", <gregtech:machine:3000>, [
	[<ore:circuitMedium>, mvArm, <ore:circuitMedium>],
	[mvArm, <gregtech:machine:502>, mvArm],
	[<ore:circuitMedium>, <cyclicmagic:void_anvil>, <ore:circuitMedium>]
]);


//begin disassembly categories
//should be able to disassemble
//-gtce single block machines (done)
//-gtce multiblock machines and hatches (incl disassembler) (TODO)
//-mm controller and hatches (TODO)
//-industrial foregoing black hole tech, thermal foundation machines, etc (TODO high priority)
//-secondary microcomponents (done)
//machines and hatches disassemble into microcomponents (motors, circuits, pistons, etc)
//secondary microcomponents disassemble into dusts and primary microcomponents (motors and circuits are primary)
//to avoid exploits, yield lowest tier circuits and other materials in the lowest amounts (eg 2 assemblies for lsb but not the lbb)
//probabilities and scaling are taken from variables to ease tweaking

//the tiers are: 0 LV, 1 MV, 2 HV, 3 EV, 4 IV, 5 LuV, 6 ZPM, 7 UV, 8 MAX
//the sensor also uses metal_emitter
//the polarizer also uses wire_separator and rod_separator
//metal_holder is the same as metal_hull at hv and luv and is hsss at max (hsss would probably be metal_components for max)
//metal_fan is used in the chem reactor, mixer, washer, turbines, and item collector
//for iv- it is metal_pump but for luv+ it is metal_hull
val tiered_items as IItemStack[][string]= {
	"circuit": [<gregtech:meta_item_2:32507>,<gregtech:meta_item_2:32489>,<gregtech:meta_item_2:32491>,<gregtech:meta_item_2:32493>,<gregtech:meta_item_2:32495>,<gregtech:meta_item_2:32497>,<gregtech:meta_item_2:32499>,<gregtech:meta_item_2:32500>,<gregtech:meta_item_2:32501>],
	"motor": [<gregtech:meta_item_1:32600>,<gregtech:meta_item_1:32601>,<gregtech:meta_item_1:32602>,<gregtech:meta_item_1:32603>,<gregtech:meta_item_1:32604>,<gregtech:meta_item_1:32606>,<gregtech:meta_item_1:32607>,<gregtech:meta_item_1:32608>,null],
	"pump": [<gregtech:meta_item_1:32610>,<gregtech:meta_item_1:32611>,<gregtech:meta_item_1:32612>,<gregtech:meta_item_1:32613>,<gregtech:meta_item_1:32614>,<gregtech:meta_item_1:32615>,<gregtech:meta_item_1:32616>,<gregtech:meta_item_1:32617>,null],
	"conveyor": [<gregtech:meta_item_1:32630>,<gregtech:meta_item_1:32631>,<gregtech:meta_item_1:32632>,<gregtech:meta_item_1:32633>,<gregtech:meta_item_1:32634>,<gregtech:meta_item_1:32635>,<gregtech:meta_item_1:32636>,<gregtech:meta_item_1:32637>,null],
	"piston": [<gregtech:meta_item_1:32640>,<gregtech:meta_item_1:32641>,<gregtech:meta_item_1:32642>,<gregtech:meta_item_1:32643>,<gregtech:meta_item_1:32644>,<gregtech:meta_item_1:32645>,<gregtech:meta_item_1:32646>,<gregtech:meta_item_1:32647>,null],
	"robot_arm": [<gregtech:meta_item_1:32650>,<gregtech:meta_item_1:32651>,<gregtech:meta_item_1:32652>,<gregtech:meta_item_1:32653>,<gregtech:meta_item_1:32654>,<gregtech:meta_item_1:32655>,<gregtech:meta_item_1:32656>,<gregtech:meta_item_1:32657>,null],
	"field_generator": [<gregtech:meta_item_1:32670>,<gregtech:meta_item_1:32671>,<gregtech:meta_item_1:32672>,<gregtech:meta_item_1:32673>,<gregtech:meta_item_1:32674>,<gregtech:meta_item_1:32675>,<gregtech:meta_item_1:32676>,<gregtech:meta_item_1:32677>,null],
	"emitter": [<gregtech:meta_item_1:32680>,<gregtech:meta_item_1:32681>,<gregtech:meta_item_1:32682>,<gregtech:meta_item_1:32683>,<gregtech:meta_item_1:32684>,<gregtech:meta_item_1:32685>,<gregtech:meta_item_1:32686>,<gregtech:meta_item_1:32687>,null],
	"sensor": [<gregtech:meta_item_1:32690>,<gregtech:meta_item_1:32691>,<gregtech:meta_item_1:32692>,<gregtech:meta_item_1:32693>,<gregtech:meta_item_1:32694>,<gregtech:meta_item_1:32695>,<gregtech:meta_item_1:32696>,<gregtech:meta_item_1:32697>,null],
	"battery": [<gregtech:meta_item_1:32518>,<gregtech:meta_item_1:32528>,<gregtech:meta_item_1:32538>,<gregtech:meta_item_2:32213>,<gregtech:meta_item_1:32597>,<gregtech:meta_item_1:32598>,<gregtech:meta_item_1:32598>,<gregtech:meta_item_1:32605>,<gregtech:meta_item_1:32605>],
	"field_generator_core": [<gregtech:meta_item_1:2218>,<gregtech:meta_item_1:2219>,<gregtech:meta_item_1:32724>,<gregtech:meta_item_1:2331>,<gregtech:meta_item_1:32725>,<gregtech:meta_item_1:32725>,<gregtech:meta_item_1:32725>,<gregtech:meta_item_1:32726>,null],
	"emitter_core": [<gregtech:meta_item_1:2203>,<gregtech:meta_item_1:2201>,<gregtech:meta_item_1:2113>,<gregtech:meta_item_1:2218>,<gregtech:meta_item_1:2219>,<gregtech:meta_item_1:2154>,<gregtech:meta_item_1:2113>,<gregtech:meta_item_1:2111>,null],
	"grinding_head": [<gregtech:meta_item_1:2111>,<gregtech:meta_item_1:2111>,<gregtech:meta_item_1:32722>,<gregtech:meta_item_1:32722>,<gregtech:meta_item_1:32722>,<gregtech:meta_item_1:32722>,<gregtech:meta_item_1:32722>,<gregtech:meta_item_1:32722>,null],
	"metal_hull": [<gregtech:meta_item_1:1184>,<gregtech:meta_item_1:1001>,<gregtech:meta_item_1:1183>,<gregtech:meta_item_1:1072>,<gregtech:meta_item_1:1235>,<gregtech:meta_item_1:1016>,<gregtech:meta_item_1:1032>,<gregtech:meta_item_1:1047>,<gregtech:meta_item_1:1972>],
	"metal_components": [<gregtech:meta_item_1:184>,<gregtech:meta_item_1:1>,<gregtech:meta_item_1:183>,<gregtech:meta_item_1:72>,<gregtech:meta_item_1:235>,<gregtech:meta_item_1:302>,<gregtech:meta_item_1:303>,<gregtech:meta_item_1:972>,null],
	"metal_pump": [<gregtech:meta_item_1:71>,<gregtech:meta_item_1:95>,<gregtech:meta_item_1:184>,<gregtech:meta_item_1:183>,<gregtech:meta_item_1:235>,<gregtech:meta_item_1:302>,<gregtech:meta_item_1:303>,<gregtech:meta_item_1:972>,null],
	"metal_pipe": [<gregtech:meta_item_1:1095>,<gregtech:meta_item_1:1184>,<gregtech:meta_item_1:1183>,<gregtech:meta_item_1:1072>,<gregtech:meta_item_1:1235>,<gregtech:meta_item_1:192>,<gregtech:meta_item_1:1192>,<gregtech:meta_item_1:1192>,null],
	"metal_emitter": [<gregtech:meta_item_1:1094>,<gregtech:meta_item_1:1112>,<gregtech:meta_item_1:1016>,<gregtech:meta_item_1:1051>,<gregtech:meta_item_1:1047>,<gregtech:meta_item_1:1112>,<gregtech:meta_item_1:1051>,<gregtech:meta_item_1:1207>,null],
	"metal_fan": [<gregtech:meta_item_1:71>,<gregtech:meta_item_1:95>,<gregtech:meta_item_1:184>,<gregtech:meta_item_1:183>,<gregtech:meta_item_1:235>,<gregtech:meta_item_1:16>,<gregtech:meta_item_1:32>,<gregtech:meta_item_1:47>,null],
	"metal_holder": [null,null,<gregtech:meta_item_1:2183>,null,null,<gregtech:meta_item_1:2016>,null,null,<gregtech:meta_item_1:2304>],
	"rubber_pump": [<gregtech:meta_item_1:1325>,<gregtech:meta_item_1:1152>,<gregtech:meta_item_1:1152>,<gregtech:meta_item_1:1152>,<gregtech:meta_item_1:1152>,<gregtech:meta_item_1:1391>,<gregtech:meta_item_1:1391>,<gregtech:meta_item_1:1391>,null],
	"rubber_conveyor": [<gregtech:meta_item_1:1152>,<gregtech:meta_item_1:1152>,<gregtech:meta_item_1:1152>,<gregtech:meta_item_1:1152>,<gregtech:meta_item_1:1152>,<gregtech:meta_item_1:1398>,<gregtech:meta_item_1:1398>,<gregtech:meta_item_1:1398>,null],
	"wire_hull": [<gregtech:cable:71>,<gregtech:cable:18>,<gregtech:cable:26>,<gregtech:cable:1>,<gregtech:cable:74>,<gregtech:cable:195>,<gregtech:cable:307>,<gregtech:cable:2308>,<gregtech:cable:354>],
	"wire_components": [<gregtech:cable:71>,<gregtech:cable:18>,<gregtech:cable:26>,<gregtech:cable:1>,<gregtech:cable:74>,<gregtech:cable:200>,<gregtech:cable:195>,<gregtech:cable:135>,<gregtech:cable:354>],
	"wire_coil": [<gregtech:cable:18>,<gregtech:cable:109>,<gregtech:cable:127>,<gregtech:cable:133>,<gregtech:cable:235>,<gregtech:cable:302>,<gregtech:cable:307>,<gregtech:cable:308>,null],
	"wire_osmium": [<gregtech:cable:47>,<gregtech:cable:1047>,<gregtech:cable:2047>,<gregtech:cable:3047>,<gregtech:cable:4047>,<gregtech:cable:2047>,<gregtech:cable:2047>,<gregtech:cable:2047>,null],
	"wire_electrolyzer": [<gregtech:cable:26>,<gregtech:cable:62>,<gregtech:cable:112>,<gregtech:cable:51>,<gregtech:cable:47>,<gregtech:cable:47>,<gregtech:cable:47>,<gregtech:cable:47>,null],
	"wire_separator": [<gregtech:cable:1071>,<gregtech:cable:1018>,<gregtech:cable:2018>,<gregtech:cable:3087>,<gregtech:cable:3087>,<gregtech:cable:2200>,<gregtech:cable:3354>,<gregtech:cable:4354>,null],
	"rod_separator": [<gregtech:meta_item_1:14033>,<gregtech:meta_item_1:14184>,<gregtech:meta_item_1:14184>,<gregtech:meta_item_1:14042>,<gregtech:meta_item_1:14195>,<gregtech:meta_item_1:14195>,<gregtech:meta_item_1:14195>,<gregtech:meta_item_1:14195>,null],
	"rod_naqreactor": [null,null,null,<gregtech:meta_item_1:14076>,<gregtech:meta_item_1:14053>,<gregtech:meta_item_1:14309>,<gregtech:meta_item_1:14002>,null,null],
	"glass": [<minecraft:glass>,<minecraft:glass>,<minecraft:glass>,<minecraft:glass>,<minecraft:glass>,<gtadditions:ga_transparent_casing>,<gtadditions:ga_transparent_casing>,<gtadditions:ga_transparent_casing>,<gtadditions:ga_transparent_casing>],
	"furnace": [<gregtech:machine:50>,<gregtech:machine:51>,<gregtech:machine:52>,<gregtech:machine:53>,<gregtech:machine:2016>,<gregtech:machine:2017>,<gregtech:machine:2018>,<gregtech:machine:2019>,null],
	"macerator": [<gregtech:machine:60>,<gregtech:machine:61>,<gregtech:machine:62>,<gregtech:machine:63>,<gregtech:machine:2020>,<gregtech:machine:2021>,<gregtech:machine:2022>,<gregtech:machine:2023>,null],
	"alloy_smelter": [<gregtech:machine:70>,<gregtech:machine:71>,<gregtech:machine:72>,<gregtech:machine:73>,<gregtech:machine:2024>,<gregtech:machine:2025>,<gregtech:machine:2026>,<gregtech:machine:2027>,null],
	"arc_furnace": [<gregtech:machine:90>,<gregtech:machine:91>,<gregtech:machine:92>,<gregtech:machine:93>,<gregtech:machine:2032>,<gregtech:machine:2033>,<gregtech:machine:2034>,<gregtech:machine:2035>,null],
	"assembler": [<gregtech:machine:100>,<gregtech:machine:101>,<gregtech:machine:102>,<gregtech:machine:103>,<gregtech:machine:104>,<gregtech:machine:2037>,<gregtech:machine:2038>,<gregtech:machine:2039>,null],
	"autoclave": [<gregtech:machine:110>,<gregtech:machine:111>,<gregtech:machine:112>,<gregtech:machine:113>,<gregtech:machine:114>,<gregtech:machine:2041>,<gregtech:machine:2042>,<gregtech:machine:2043>,null],
	"bender": [<gregtech:machine:120>,<gregtech:machine:121>,<gregtech:machine:122>,<gregtech:machine:123>,<gregtech:machine:2044>,<gregtech:machine:2045>,<gregtech:machine:2046>,<gregtech:machine:2047>,null],
	"brewry": [<gregtech:machine:130>,<gregtech:machine:131>,<gregtech:machine:132>,<gregtech:machine:133>,<gregtech:machine:2048>,<gregtech:machine:2049>,<gregtech:machine:2050>,<gregtech:machine:2051>,null],
	"canner": [<gregtech:machine:140>,<gregtech:machine:141>,<gregtech:machine:142>,<gregtech:machine:143>,<gregtech:machine:2052>,<gregtech:machine:2053>,<gregtech:machine:2054>,<gregtech:machine:2055>,null],
	"centrifuge": [<gregtech:machine:150>,<gregtech:machine:151>,<gregtech:machine:152>,<gregtech:machine:153>,<gregtech:machine:2056>,<gregtech:machine:2057>,<gregtech:machine:2058>,<gregtech:machine:2059>,null],
	"bath": [<gregtech:machine:180>,<gregtech:machine:181>,<gregtech:machine:182>,<gregtech:machine:183>,<gregtech:machine:2060>,<gregtech:machine:2061>,<gregtech:machine:2062>,<gregtech:machine:2063>,null],
	"chem_reactor": [<gregtech:machine:190>,<gregtech:machine:191>,<gregtech:machine:192>,<gregtech:machine:193>,<gregtech:machine:2064>,<gregtech:machine:2065>,<gregtech:machine:2066>,<gregtech:machine:2067>,null],
	"compressor": [<gregtech:machine:210>,<gregtech:machine:211>,<gregtech:machine:212>,<gregtech:machine:213>,<gregtech:machine:2068>,<gregtech:machine:2069>,<gregtech:machine:2070>,<gregtech:machine:2071>,null],
	"cutting_machine": [<gregtech:machine:220>,<gregtech:machine:221>,<gregtech:machine:222>,<gregtech:machine:223>,<gregtech:machine:2072>,<gregtech:machine:2073>,<gregtech:machine:2074>,<gregtech:machine:2075>,null],
	"distillery": [<gregtech:machine:230>,<gregtech:machine:231>,<gregtech:machine:232>,<gregtech:machine:233>,<gregtech:machine:2076>,<gregtech:machine:2077>,<gregtech:machine:2078>,<gregtech:machine:2079>,null],
	"electrolyzer": [<gregtech:machine:240>,<gregtech:machine:241>,<gregtech:machine:242>,<gregtech:machine:243>,<gregtech:machine:2080>,<gregtech:machine:2081>,<gregtech:machine:2082>,<gregtech:machine:2083>,null],
	"separator": [<gregtech:machine:250>,<gregtech:machine:251>,<gregtech:machine:252>,<gregtech:machine:253>,<gregtech:machine:2084>,<gregtech:machine:2085>,<gregtech:machine:2086>,<gregtech:machine:2087>,null],
	"extractor": [<gregtech:machine:260>,<gregtech:machine:261>,<gregtech:machine:262>,<gregtech:machine:263>,<gregtech:machine:2088>,<gregtech:machine:2089>,<gregtech:machine:2090>,<gregtech:machine:2091>,null],
	"fermenter": [<gregtech:machine:280>,<gregtech:machine:281>,<gregtech:machine:282>,<gregtech:machine:283>,<gregtech:machine:2096>,<gregtech:machine:2097>,<gregtech:machine:2098>,<gregtech:machine:2099>,null],
	"f_canner": [<gregtech:machine:290>,<gregtech:machine:291>,<gregtech:machine:292>,<gregtech:machine:293>,<gregtech:machine:2100>,<gregtech:machine:2101>,<gregtech:machine:2102>,<gregtech:machine:2103>,null],
	"f_extractor": [<gregtech:machine:300>,<gregtech:machine:301>,<gregtech:machine:302>,<gregtech:machine:303>,<gregtech:machine:2104>,<gregtech:machine:2105>,<gregtech:machine:2106>,<gregtech:machine:2107>,null],
	"f_heater": [<gregtech:machine:310>,<gregtech:machine:311>,<gregtech:machine:312>,<gregtech:machine:313>,<gregtech:machine:2108>,<gregtech:machine:2109>,<gregtech:machine:2110>,<gregtech:machine:2111>,null],
	"f_solidifier": [<gregtech:machine:320>,<gregtech:machine:321>,<gregtech:machine:322>,<gregtech:machine:323>,<gregtech:machine:2112>,<gregtech:machine:2113>,<gregtech:machine:2114>,<gregtech:machine:2115>,null],
	"forge_hammer": [<gregtech:machine:330>,<gregtech:machine:331>,<gregtech:machine:332>,<gregtech:machine:333>,<gregtech:machine:2116>,<gregtech:machine:2117>,<gregtech:machine:2118>,<gregtech:machine:2119>,null],
	"forming_press": [<gregtech:machine:340>,<gregtech:machine:341>,<gregtech:machine:342>,<gregtech:machine:343>,<gregtech:machine:2120>,<gregtech:machine:2121>,<gregtech:machine:2122>,<gregtech:machine:2123>,null],
	"lathe": [<gregtech:machine:350>,<gregtech:machine:351>,<gregtech:machine:352>,<gregtech:machine:353>,<gregtech:machine:2124>,<gregtech:machine:2125>,<gregtech:machine:2126>,<gregtech:machine:2127>,null],
	"microwave": [<gregtech:machine:360>,<gregtech:machine:361>,<gregtech:machine:362>,<gregtech:machine:363>,<gregtech:machine:2128>,<gregtech:machine:2129>,<gregtech:machine:2130>,<gregtech:machine:2131>,null],
	"mixer": [<gregtech:machine:370>,<gregtech:machine:371>,<gregtech:machine:372>,<gregtech:machine:373>,<gregtech:machine:2132>,<gregtech:machine:2133>,<gregtech:machine:2134>,<gregtech:machine:2135>,null],
	"washer": [<gregtech:machine:380>,<gregtech:machine:381>,<gregtech:machine:382>,<gregtech:machine:383>,<gregtech:machine:2136>,<gregtech:machine:2137>,<gregtech:machine:2138>,<gregtech:machine:2139>,null],
	"packager": [<gregtech:machine:390>,<gregtech:machine:391>,<gregtech:machine:392>,<gregtech:machine:393>,<gregtech:machine:2140>,<gregtech:machine:2141>,<gregtech:machine:2142>,<gregtech:machine:2143>,null],
	"unpackager": [<gregtech:machine:400>,<gregtech:machine:401>,<gregtech:machine:402>,<gregtech:machine:403>,<gregtech:machine:2144>,<gregtech:machine:2145>,<gregtech:machine:2146>,<gregtech:machine:2147>,null],
	"polarizer": [<gregtech:machine:420>,<gregtech:machine:421>,<gregtech:machine:422>,<gregtech:machine:423>,<gregtech:machine:2152>,<gregtech:machine:2153>,<gregtech:machine:2154>,<gregtech:machine:2155>,null],
	"sifter": [<gregtech:machine:450>,<gregtech:machine:451>,<gregtech:machine:452>,<gregtech:machine:453>,<gregtech:machine:2160>,<gregtech:machine:2161>,<gregtech:machine:2162>,<gregtech:machine:2163>,null],
	"wiremill": [<gregtech:machine:470>,<gregtech:machine:471>,<gregtech:machine:472>,<gregtech:machine:473>,<gregtech:machine:2168>,<gregtech:machine:2169>,<gregtech:machine:2170>,<gregtech:machine:2171>,null],
	"diesel_generator": [<gregtech:machine:480>,<gregtech:machine:481>,<gregtech:machine:482>,<gregtech:machine:517>,null,null,null,null,null],
	"steam_turbine": [<gregtech:machine:485>,<gregtech:machine:486>,<gregtech:machine:487>,null,null,null,null,null,null],
	"gas_turbine": [<gregtech:machine:490>,<gregtech:machine:491>,<gregtech:machine:492>,null,null,null,null,null,null],
	"item_collector": [<gregtech:machine:494>,<gregtech:machine:495>,<gregtech:machine:496>,<gregtech:machine:497>,null,null,null,null,null],
	"hull": [<gregtech:machine:501>,<gregtech:machine:502>,<gregtech:machine:503>,<gregtech:machine:504>,<gregtech:machine:505>,<gregtech:machine:506>,<gregtech:machine:507>,<gregtech:machine:508>,<gregtech:machine:509>],
	"transformer": [<gregtech:machine:601>,<gregtech:machine:602>,<gregtech:machine:603>,<gregtech:machine:604>,<gregtech:machine:605>,<gregtech:machine:606>,<gregtech:machine:607>,null,null],
	"b_buffer_1x": [<gregtech:machine:614>,<gregtech:machine:618>,<gregtech:machine:622>,<gregtech:machine:626>,<gregtech:machine:630>,<gregtech:machine:634>,<gregtech:machine:638>,<gregtech:machine:642>,<gregtech:machine:646>],
	"b_buffer_4x": [<gregtech:machine:615>,<gregtech:machine:619>,<gregtech:machine:623>,<gregtech:machine:627>,<gregtech:machine:631>,<gregtech:machine:635>,<gregtech:machine:639>,<gregtech:machine:643>,<gregtech:machine:647>],
	"b_buffer_9x": [<gregtech:machine:616>,<gregtech:machine:620>,<gregtech:machine:624>,<gregtech:machine:628>,<gregtech:machine:632>,<gregtech:machine:636>,<gregtech:machine:640>,<gregtech:machine:644>,<gregtech:machine:648>],
	"b_buffer_16x": [<gregtech:machine:617>,<gregtech:machine:621>,<gregtech:machine:625>,<gregtech:machine:629>,<gregtech:machine:633>,<gregtech:machine:637>,<gregtech:machine:641>,<gregtech:machine:645>,<gregtech:machine:649>],
	"b_charger_4x": [<gregtech:machine:681>,<gregtech:machine:682>,<gregtech:machine:683>,<gregtech:machine:684>,<gregtech:machine:685>,<gregtech:machine:686>,<gregtech:machine:687>,<gregtech:machine:688>,<gregtech:machine:689>],
	"i_input": [<gregtech:machine:710>,<gregtech:machine:720>,<gregtech:machine:730>,<gregtech:machine:740>,<gregtech:machine:750>,<gregtech:machine:760>,<gregtech:machine:770>,<gregtech:machine:780>,<gregtech:machine:790>],
	"i_output": [<gregtech:machine:711>,<gregtech:machine:721>,<gregtech:machine:731>,<gregtech:machine:741>,<gregtech:machine:751>,<gregtech:machine:761>,<gregtech:machine:771>,<gregtech:machine:781>,<gregtech:machine:791>],
	"f_input": [<gregtech:machine:712>,<gregtech:machine:722>,<gregtech:machine:732>,<gregtech:machine:742>,<gregtech:machine:752>,<gregtech:machine:762>,<gregtech:machine:772>,<gregtech:machine:782>,<gregtech:machine:792>],
	"f_output": [<gregtech:machine:713>,<gregtech:machine:722>,<gregtech:machine:733>,<gregtech:machine:743>,<gregtech:machine:753>,<gregtech:machine:763>,<gregtech:machine:773>,<gregtech:machine:783>,<gregtech:machine:793>],
	"e_input": [<gregtech:machine:714>,<gregtech:machine:724>,<gregtech:machine:734>,<gregtech:machine:744>,<gregtech:machine:754>,<gregtech:machine:764>,<gregtech:machine:774>,<gregtech:machine:764>,<gregtech:machine:794>],
	"e_output": [<gregtech:machine:715>,<gregtech:machine:725>,<gregtech:machine:735>,<gregtech:machine:745>,<gregtech:machine:755>,<gregtech:machine:765>,<gregtech:machine:775>,<gregtech:machine:785>,<gregtech:machine:795>],
	"fisher": [<gregtech:machine:820>,<gregtech:machine:821>,<gregtech:machine:822>,<gregtech:machine:823>,null,null,null,null,null],
	"f_pump": [<gregtech:machine:900>,<gregtech:machine:910>,<gregtech:machine:920>,<gregtech:machine:930>,<gregtech:machine:2201>,<gregtech:machine:2202>,<gregtech:machine:2203>,<gregtech:machine:2204>,null],
	"air_collector": [<gregtech:machine:950>,<gregtech:machine:960>,<gregtech:machine:970>,<gregtech:machine:980>,<gregtech:machine:2205>,<gregtech:machine:2206>,null,null,null],
	"ceu_1x": [<gregtech:machine:10658>,<gregtech:machine:10666>,<gregtech:machine:10674>,<gregtech:machine:10682>,<gregtech:machine:10690>,<gregtech:machine:10698>,<gregtech:machine:10706>,<gregtech:machine:10714>,null],
	"cef_1x": [<gregtech:machine:10659>,<gregtech:machine:10667>,<gregtech:machine:10675>,<gregtech:machine:10683>,<gregtech:machine:10691>,<gregtech:machine:10699>,<gregtech:machine:10707>,<gregtech:machine:10715>,null],
	"ceu_4x": [<gregtech:machine:10660>,<gregtech:machine:10668>,<gregtech:machine:10676>,<gregtech:machine:10684>,<gregtech:machine:10692>,<gregtech:machine:10700>,<gregtech:machine:10708>,<gregtech:machine:10716>,null],
	"cef_4x": [<gregtech:machine:10661>,<gregtech:machine:10669>,<gregtech:machine:10677>,<gregtech:machine:10685>,<gregtech:machine:10693>,<gregtech:machine:10701>,<gregtech:machine:10709>,<gregtech:machine:10717>,null],
	"ceu_9x": [<gregtech:machine:10662>,<gregtech:machine:10671>,<gregtech:machine:10678>,<gregtech:machine:10686>,<gregtech:machine:10694>,<gregtech:machine:10702>,<gregtech:machine:10710>,<gregtech:machine:10718>,null],
	"cef_9x": [<gregtech:machine:10663>,<gregtech:machine:10671>,<gregtech:machine:10679>,<gregtech:machine:10687>,<gregtech:machine:10695>,<gregtech:machine:10703>,<gregtech:machine:10711>,<gregtech:machine:10719>,null],
	"ceu_16x": [<gregtech:machine:10664>,<gregtech:machine:10672>,<gregtech:machine:10680>,<gregtech:machine:10688>,<gregtech:machine:10696>,<gregtech:machine:10704>,<gregtech:machine:10712>,<gregtech:machine:10720>,null],
	"cef_16x": [<gregtech:machine:10665>,<gregtech:machine:10673>,<gregtech:machine:10681>,<gregtech:machine:10689>,<gregtech:machine:10697>,<gregtech:machine:10705>,<gregtech:machine:10713>,<gregtech:machine:10721>,null],
	"casing": [<gregtech:machine_casing:1>,<gregtech:machine_casing:2>,<gregtech:machine_casing:3>,<gregtech:machine_casing:4>,<gregtech:machine_casing:5>,<gregtech:machine_casing:6>,<gregtech:machine_casing:7>,<gregtech:machine_casing:8>,<gregtech:machine_casing:9>],
	"extruder+": [<gregtech:machine:271>,<gregtech:machine:272>,<gregtech:machine:273>,null,null,null,null,null,null],
	"extruder": [null,null,null,null,<gregtech:machine:2092>,<gregtech:machine:2093>,<gregtech:machine:2094>,<gregtech:machine:2095>,null],
	"plasma_furnace": [<gregtech:machine:410>,<gregtech:machine:411>,<gregtech:machine:412>,<gregtech:machine:413>,<gregtech:machine:2148>,<gregtech:machine:2149>,<gregtech:machine:2150>,<gregtech:machine:2151>,null],
	"mass_fabricator": [<gregtech:machine:2175>,<gregtech:machine:2176>,<gregtech:machine:2177>,<gregtech:machine:2178>,<gregtech:machine:2179>,<gregtech:machine:2180>,<gregtech:machine:2181>,<gregtech:machine:2182>,null],
	"replicator": [<gregtech:machine:2183>,<gregtech:machine:2184>,<gregtech:machine:2185>,<gregtech:machine:2186>,<gregtech:machine:2187>,<gregtech:machine:2188>,<gregtech:machine:2189>,<gregtech:machine:2190>,null],
	"naquadah_reactor": [null,null,null,<gregtech:machine:2172>,<gregtech:machine:2173>,<gregtech:machine:2174>,<gregtech:machine:2191>,null,null],
	"rotor_holder": [null,null,<gregtech:machine:817>,null,null,<gregtech:machine:818>,null,null,<gregtech:machine:819>],
	"engraver": [null,<gregtech:machine:431>,<gregtech:machine:432>,<gregtech:machine:433>,<gregtech:machine:434>,<gregtech:machine:2157>,<gregtech:machine:2158>,<gregtech:machine:2159>,null],
	"t_centrifuge": [null,<gregtech:machine:461>,<gregtech:machine:462>,<gregtech:machine:463>,<gregtech:machine:2164>,<gregtech:machine:2165>,<gregtech:machine:2166>,<gregtech:machine:2167>,null],
	"quantum_chest": [null,<gregtech:machine:1010>,<gregtech:machine:1011>,<gregtech:machine:1012>,<gregtech:machine:1013>,null,null,null,null],
	"quantum_tank": [null,<gregtech:machine:1020>,<gregtech:machine:1021>,<gregtech:machine:1022>,<gregtech:machine:1023>,null,null,null,null],

	"coke_oven": [<gregtech:machine:526>,null,null,null,null,null,null,null,null],
	"vacuum_freezer": [null,null,<gregtech:machine:512>,null,null,null,null,null,null],
	"implosion_compressor": [null,null,<gregtech:machine:513>,null,null,null,null,null,null],
	"pyrolyse": [null,<gregtech:machine:514>,null,null,null,null,null,null,null],
	"cracker": [null,null,<gregtech:machine:525>,null,null,null,null,null,null],
	"distillation_tower": [null,null,<gregtech:machine:515>,null,null,null,null,null,null],
	"ebf": [<gregtech:machine:511>,null,null,null,null,null,null,null,null],
	"multismelter": [<gregtech:machine:516>,null,null,null,null,null,null,null,null],
	"lbb": [<gregtech:machine:521>,null,null,null,null,null,null,null,null],
	"lsb": [null,null,<gregtech:machine:522>,null,null,null,null,null,null],
	"large_steam_turbine": [null,null,null,<gregtech:machine:518>,null,null,null,null,null],
	"large_gas_turbine": [null,null,null,<gregtech:machine:519>,null,null,null,null,null],
	"plasma_turbine": [null,null,null,null,null,null,null,<gregtech:machine:520>,null],
	"assembly_line": [null,null,null,null,<gregtech:machine:2502>,null,null,null,null],
	"processing_array": [null,null,null,null,<gregtech:machine:2507>,null,null,null,null],
	"reactor_i": [null,null,null,null,<gregtech:machine:2504>,null,null,null,null],
	"reactor_ii": [null,null,null,null,null,<gregtech:machine:2505>,null,null,null],
	"reactor_iii": [null,null,null,null,null,null,<gregtech:machine:2506>,null,null],
	"disassembler": [null,<gregtech:machine:3000>,null,null,null,null,null,null,null],
	"black_hole_unit": [null,null,null,<industrialforegoing:black_hole_unit:0>,null,null,null,null,null],
	"black_hole_tank": [null,null,null,<industrialforegoing:black_hole_tank:0>,null,null,null,null,null],
	"magic_absorber": [null,<gregtech:machine:493>,null,null,null,null,null,null,null]
} as IItemStack[][string];

val untiered_items as IItemStack[string] = {
	"graphite": <ore:dustGraphite>.firstItem,
	"blazerod": <item:minecraft:blaze_rod>,
	"diamond": <ore:dustDiamond>.firstItem,
	"cutting_saw": <ore:craftingDiamondBlade>.firstItem,
	"chest": <ore:chestWood>.firstItem,
	"lead": <ore:dustLead>.firstItem,
	"filter": <item:gregtech:meta_item_1:32729>,
	"plain_glass": <ore:blockGlassColorless>.firstItem,
	"iron": <ore:dustTinyIron>.firstItem,
	"red_wire": <item:gregtech:cable:237>,
	"coke_bricks": <item:gregtech:metal_casing:8>,
	"frost_casing": <item:gregtech:metal_casing:3>,
	"atomic_alloy": <item:mekanism:atomicalloy>,
	"solidsteel_casing": <item:gregtech:metal_casing:4>,
	"obsidian": <ore:dustObsidian>.firstItem,
	"cupronickel_wire": <item:gregtech:cable:109>,
	"heat_casing": <item:gregtech:metal_casing:2>,
	"annealed_wire": <item:gregtech:cable:87>,
	"bronze_casing": <item:gregtech:metal_casing:0>,
	"steel": <ore:dustSteel>.firstItem,
	"vinteum": <ore:dustVinteum>.firstItem,
	"tungstensteel": <ore:dustTungstenSteel>.firstItem,
	"assembly_casing": <item:gregtech:multiblock_casing:2>,
	"data_orb": <item:gregtech:meta_item_1:32707>,
	"hpic": <item:gregtech:meta_item_2:32479>,
	"superconductor_wire": <item:gregtech:cable:354>,
	"fusion_coil": <item:gregtech:wire_coil:8>,
	"plutonium": <ore:dustPlutonium241>.firstItem,
	"nether_star": <ore:dustNetherStar>.firstItem,
	"europium": <ore:dustEuropium>.firstItem,
	"americium": <ore:dustAmericium>.firstItem,
	"void_anvil": <item:cyclicmagic:void_anvil>,
	"ptfe": <ore:dustPolytetrafluoroethylene>.firstItem
} as IItemStack[string]
;

val tiered_results as double[string][string] = {
	"pump": {"rubber_pump":0.5D,"wire_components":1.0D,"metal_pipe":3.0D,"motor":1.0D,"metal_pump":4.375D} as double[string],
	"conveyor": {"rubber_conveyor":6.0D,"wire_components":1.0D,"motor":2.0D} as double[string],
	"piston": {"metal_components":5.0D,"wire_components":2.0D,"motor":1.0D} as double[string],
	"robot_arm": {"metal_components":1.0D,"wire_components":3.0D,"piston":1.0D,"motor":2.0D,"circuit":1.0D} as double[string],
	"field_generator": {"circuit":4.0D,"field_generator_core":1.0D,"wire_osmium":4.0D} as double[string],
	"emitter": {"circuit":2.0D,"emitter_core":1.0D,"wire_components":2.0D,"metal_emitter":2.0D} as double[string],
	"sensor": {"circuit":1.0D,"metal_components":4.0D,"emitter_core":1.0D,"metal_emitter":0.5D} as double[string],
	"furnace": {"hull":1.0D,"wire_hull":2.0D,"wire_coil":8.0D,"circuit":2.0D} as double[string],
	"macerator": {"hull":1.0D,"wire_hull":3.0D,"motor":1.0D,"piston":1.0D,"grinding_head":1.0D,"circuit":2.0D} as double[string],
	"alloy_smelter": {"hull":1.0D,"wire_hull":2.0D,"wire_coil":16.0D,"circuit":2.0D} as double[string],
	"arc_furnace": {"hull":1.0D,"wire_hull":8.0D,"metal_components":3.0D,"graphite":1.0D,"circuit":1.0D} as double[string],
	"assembler": {"hull":1.0D,"wire_hull":2.0D,"conveyor":2.0D,"robot_arm":2.0D,"circuit":2.0D} as double[string],
	"autoclave": {"hull":1.0D,"metal_components":4.0D,"circuit":2.0D,"pump":1.0D,"glass":1.0D} as double[string],
	"bender": {"hull":1.0D,"wire_hull":2.0D,"motor":2.0D,"piston":2.0D,"circuit":2.0D} as double[string],
	"brewry": {"hull":1.0D,"wire_hull":2.0D,"pump":1.0D,"blazerod":1.0D,"circuit":2.0D,"glass":2.0D} as double[string],
	"canner": {"hull":1.0D,"wire_hull":2.0D,"pump":1.0D,"circuit":2.0D,"glass":3.0D} as double[string],
	"centrifuge": {"hull":1.0D,"wire_hull":2.0D,"motor":2.0D,"circuit":4.0D} as double[string],
	"bath": {"hull":1.0D,"wire_hull":1.0D,"conveyor":2.0D,"pump":1.0D,"glass":2.0D,"circuit":2.0D} as double[string],
	"chem_reactor": {"hull":1.0D,"wire_hull":2.0D,"motor":1.0D,"circuit":2.0D,"glass":2.0D,"metal_fan":4.25D} as double[string],
	"compressor": {"hull":1.0D,"wire_hull":2.0D,"piston":2.0D,"circuit":2.0D} as double[string],
	"cutting_machine": {"hull":1.0D,"wire_hull":2.0D,"motor":1.0D,"conveyor":1.0D,"circuit":1.0D,"glass":1.0D,"cutting_saw":1.0D} as double[string],
	"distillery": {"hull":1.0D,"wire_hull":2.0D,"piston":1.0D,"blazerod":1.0D,"circuit":2.0D,"glass":2.0D} as double[string],
	"electrolyzer": {"hull":1.0D,"wire_hull":1.0D,"circuit":2.0D,"glass":1.0D,"wire_electrolyzer":4.0D} as double[string],
	"separator": {"hull":1.0D,"wire_hull":3.0D,"conveyor":1.0D,"circuit":1.0D,"rod_separator":1.0D,"wire_separator":2.0D} as double[string],
	"extractor": {"hull":1.0D,"wire_hull":2.0D,"piston":1.0D,"pump":1.0D,"circuit":2.0D,"glass":2.0D} as double[string],
	"fermenter": {"hull":1.0D,"wire_hull":4.0D,"glass":2.0D,"pump":1.0D,"circuit":1.0D} as double[string],
	"f_canner": {"hull":1.0D,"wire_hull":2.0D,"glass":4.0D,"pump":1.0D,"circuit":1.0D} as double[string],
	"f_extractor": {"hull":1.0D,"wire_hull":2.0D,"glass":2.0D,"pump":1.0D,"piston":1.0D,"circuit":2.0D} as double[string],
	"f_heater": {"hull":1.0D,"wire_hull":2.0D,"glass":1.0D,"pump":2.0D,"circuit":1.0D,"wire_coil":8.0D} as double[string],
	"f_solidifier": {"hull":1.0D,"wire_hull":2.0D,"glass":1.0D,"pump":2.0D,"circuit":2.0D,"chest":1.0D} as double[string],
	"forge_hammer": {"hull":1.0D,"wire_hull":4.0D,"piston":1.0D,"iron":31.0D,"circuit":2.0D} as double[string],
	"forming_press": {"hull":1.0D,"wire_hull":4.0D,"piston":2.0D,"circuit":2.0D} as double[string],
	"lathe": {"hull":1.0D,"wire_hull":3.0D,"motor":1.0D,"piston":1.0D,"circuit":2.0D,"diamond":1.0D} as double[string],
	"microwave": {"hull":1.0D,"wire_hull":1.0D,"motor":1.0D,"emitter":1.0D,"circuit":2.0D,"lead":3.0D} as double[string],
	"mixer": {"hull":1.0D,"motor":1.0D,"circuit":2.0D,"glass":4.0D,"metal_fan":4.25D} as double[string],
	"washer": {"hull":1.0D,"wire_hull":2.0D,"motor":1.0D,"circuit":2.0D,"glass":1.0D,"metal_fan":8.5D} as double[string],
	"packager": {"hull":1.0D,"wire_hull":2.0D,"conveyor":1.0D,"robot_arm":1.0D,"circuit":2.0D,"chest":2.0D} as double[string],
	"unpackager": {"hull":1.0D,"wire_hull":2.0D,"conveyor":1.0D,"robot_arm":1.0D,"circuit":2.0D,"chest":2.0D} as double[string],
	"polarizer": {"hull":1.0D,"wire_hull":2.0D,"rod_separator":2.0D,"wire_separator":4.0D} as double[string],
	"sifter": {"hull":1.0D,"wire_hull":2.0D,"piston":2.0D,"circuit":2.0D,"filter":2.0D} as double[string],
	"wiremill": {"hull":1.0D,"wire_hull":2.0D,"motor":4.0D,"circuit":2.0D} as double[string],
	"diesel_generator": {"hull":1.0D,"wire_hull":1.0D,"motor":2.0D,"piston":2.0D,"circuit":1.0D,"metal_components":8.0D} as double[string],
	"steam_turbine": {"hull":1.0D,"wire_hull":1.0D,"motor":2.0D,"circuit":1.0D,"metal_fan":8.5D,"metal_pipe":6.0D} as double[string],
	"gas_turbine": {"hull":1.0D,"wire_hull":1.0D,"motor":2.0D,"circuit":2.0D,"metal_fan":12.75D} as double[string],
	"item_collector": {"hull":1.0D,"wire_hull":1.0D,"motor":2.0D,"circuit":2.0D,"metal_fan":12.75D} as double[string],
	"hull": {"casing":1.0D,"wire_hull":2.0D} as double[string],
	"transformer": {"hull":1.0D,"wire_hull":4.0D} as double[string],
	"b_buffer_1x": {"hull":1.0D,"wire_hull":4.0D,"chest":1.0D} as double[string],
	"b_buffer_4x": {"hull":1.0D,"wire_hull":16.0D,"chest":1.0D} as double[string],
	"b_buffer_9x": {"hull":1.0D,"wire_hull":36.0D,"chest":1.0D} as double[string],
	"b_buffer_16x": {"hull":1.0D,"wire_hull":64.0D,"chest":1.0D} as double[string],
	"b_charger_4x": {"hull":1.0D,"wire_hull":64.0D,"chest":1.0D,"circuit":1.0D,"battery":2.0D} as double[string],
	"i_input": {"hull":1.0D,"chest":1.0D} as double[string],
	"i_output": {"hull":1.0D,"chest":1.0D} as double[string],
	"f_input": {"hull":1.0D,"plain_glass":1.0D} as double[string],
	"f_output": {"hull":1.0D,"plain_glass":1.0D} as double[string],
	"e_input": {"hull":1.0D,"wire_hull":1.0D} as double[string],
	"e_output": {"hull":1.0D,"wire_hull":1.0D} as double[string],
	"fisher": {"hull":1.0D,"motor":3.0D,"piston":2.0D,"pump":1.0D,"circuit":2.0D} as double[string],
	"f_pump": {"hull":1.0D,"pump":4.0D,"circuit":2.0D,"metal_pipe":2.0D} as double[string],
	"air_collector": {"hull":1.0D,"pump":2.0D,"circuit":1.0D,"filter":1.0D,"iron":1.5D} as double[string],
	"ceu_1x": {"hull":1.0D,"circuit":1.0D,"chest":1.0D,"wire_hull":4.0D,"red_wire":2.0D} as double[string],
	"cef_1x": {"hull":1.0D,"circuit":1.0D,"chest":1.0D,"wire_hull":4.0D,"red_wire":2.0D} as double[string],
	"ceu_4x": {"hull":1.0D,"circuit":1.0D,"chest":1.0D,"wire_hull":16.0D,"red_wire":8.0D} as double[string],
	"cef_4x": {"hull":1.0D,"circuit":1.0D,"chest":1.0D,"wire_hull":16.0D,"red_wire":8.0D} as double[string],
	"ceu_9x": {"hull":1.0D,"circuit":1.0D,"chest":1.0D,"wire_hull":36.0D,"red_wire":18.0D} as double[string],
	"cef_9x": {"hull":1.0D,"circuit":1.0D,"chest":1.0D,"wire_hull":36.0D,"red_wire":18.0D} as double[string],
	"ceu_16x": {"hull":1.0D,"circuit":1.0D,"chest":1.0D,"wire_hull":64.0D,"red_wire":32.0D} as double[string],
	"cef_16x": {"hull":1.0D,"circuit":1.0D,"chest":1.0D,"wire_hull":64.0D,"red_wire":32.0D} as double[string],
	"casing": {"metal_hull":8.0D} as double[string],
	"extruder+": {"hull":1.0D,"piston":1.0D,"circuit":2.0D,"metal_pipe":3.0D,"wire_coil":16.0D} as double[string],
	"extruder": {"hull":1.0D,"piston":1.0D,"circuit":2.0D,"metal_pipe":3.0D,"wire_coil":16.0D} as double[string],
	"plasma_furnace": {"hull":1.0D,"circuit":2.0D,"wire_hull":8.0D,"pump":2.0D,"graphite":1.0D,"metal_components":1.0D} as double[string],
	"mass_fabricator": {"hull":1.0D,"circuit":4.0D,"field_generator":2.0D,"wire_hull":8.0D} as double[string],
	"replicator": {"hull":1.0D,"circuit":4.0D,"field_generator":1.0D,"emitter":4.0D,"wire_hull":4.0D} as double[string],
	"naquadah_reactor": {"hull":1.0D,"field_generator":2.0D,"wire_hull":8.0D,"circuit":2.0D,"rod_naqreactor":2.0D} as double[string],
	"rotor_holder": {"hull":1.0D,"wire_components":112.0D,"metal_holder":4.0D} as double[string],
	"engraver": {"hull":1.0D,"wire_hull":2.0D,"piston":2.0D,"circuit":3.0D,"emitter":1.0D} as double[string],
	"t_centrifuge": {"hull":1.0D,"wire_hull":2.0D,"motor":2.0D,"wire_coil":8.0D,"circuit":2.0D} as double[string],
	"quantum_chest": {"hull":1.0D,"metal_components":3.0D,"circuit":4.0D,"field_generator":1.0D} as double[string],
	"quantum_tank": {"hull":1.0D,"metal_components":3.0D,"circuit":4.0D,"field_generator":1.0D} as double[string],

	"coke_oven": {"iron":4.0D,"coke_bricks":4.0D} as double[string],
	"vacuum_freezer": {"frost_casing":1.0D,"wire_hull":2.0D,"pump":3.0D,"atomic_alloy":3.0D} as double[string],
	"implosion_compressor": {"solidsteel_casing":1.0D,"wire_hull":2.0D,"circuit":3.0D,"obsidian":3.0D} as double[string],
	"pyrolyse": {"hull":1.0D,"piston":2.0D,"pump":1.0D,"circuit":3.0D,"wire_coil":8.0D} as double[string],
	"cracker": {"hull":1.0D,"pump":2.0D,"circuit":2.0D,"cupronickel_wire":64.0D} as double[string],
	"distillation_tower": {"hull":1.0D,"pump":2.0D,"circuit":4.0D,"metal_pipe":12.0D} as double[string],
	"ebf": {"circuit":1.0D,"heat_casing":1.0D,"wire_hull":2.0D,"furnace":1.0D,"graphite":3.0D} as double[string],
	"multismelter": {"furnace":2.0D,"circuit":3.0D,"heat_casing":2.0D,"annealed_wire":2.0D} as double[string],
	"lbb": {"circuit":4.0D,"wire_hull":4.0D,"bronze_casing":1.0D} as double[string],
	"lsb": {"circuit":2.0D} as double[string],
	"large_steam_turbine": {"hull":1.0D,"circuit":2.0D,"steel":16.0D,"vinteum":2.0D} as double[string],
	"large_gas_turbine": {"hull":1.0D,"circuit":2.0D,"metal_pump":28.0D} as double[string],
	"plasma_turbine": {"hull":1.0D,"circuit":2.0D,"tungstensteel":28.0D} as double[string],
	"assembly_line": {"hull":1.0D,"robot_arm":2.0D,"circuit":2.0D,"assembly_casing":4.0D} as double[string],
	"processing_array": {"hull":1.0D,"robot_arm":2.0D,"circuit":4.0D,"battery":1.0D,"data_orb":1.0D} as double[string],
	"reactor_i": {"hpic":32.0D,"superconductor_wire":32.0D,"field_generator":2.0D,"fusion_coil":1.0D,"plutonium":1.0D,"nether_star":1.0D,"circuit":4.0D} as double[string],
	"reactor_ii": {"hpic":48.0D,"superconductor_wire":64.0D,"field_generator":2.0D,"fusion_coil":1.0D,"europium":4.0D,"circuit":4.0D} as double[string],
	"reactor_iii": {"hpic":64.0D,"superconductor_wire":128.0D,"field_generator":2.0D,"fusion_coil":1.0D,"americium":4.0D,"circuit":4.0D} as double[string],
	"disassembler": {"hull":1.0D,"robot_arm":3.0D,"circuit":4.0D,"void_anvil":1.0D} as double[string],
	"black_hole_unit": {"hull":1.0D,"field_generator":1.0D,"circuit":4.0D,"ptfe":3.0D} as double[string],
	"black_hole_tank": {"hull":1.0D,"field_generator":1.0D,"circuit":4.0D,"ptfe":3.0D} as double[string],
	"magic_absorber": {"hull":1.0D,"pump":4.0D,"sensor":2.0D,"circuit":2.0D} as double[string]
} as double[string][string];

// amount of various items the actual items give, eg if we specify tiny dust for metal_hull this would be 0.11
// but for small dust it would be 0.25 and for dust it would be 1, etc
// 1 by default.  Note that one wire for a wire_* is 1 not 0.5
// tiny dusts cause inherent losses, eg a pump should return 4.325 metal_pump but this must be rounded down to 4.222222
// there are also inherent losses for luv and uv recipes which yield metal_pipe because I just picked the largest dust
// up to 1/3rd of the material in a pipe for that tier, which for small and large ultimet pipes is not
// the correct fraction.  Also, ultimet pipes can be made from tungsten pipes and ev pumps, but they are
// pulverizable into ultimet dust by default so I did not consider this exploitable
val item_units as double[string] = {
	"iron": 0.25D,
	"metal_hull": 0.25D,
	"metal_components": 0.111111D,
	"metal_pump": 0.111111D,
	"metal_pipe": 0.25D,
	"metal_emitter": 0.25D,
	"metal_fan": 0.111111D,
	"rubber_pump": 0.25D,
	"rubber_conveyor": 0.25D
} as double[string];

// NOTE luv+ robot arms, emitters, and sensors TIER SHIFT the required circuits by -2
// also note that the emitters in emitters and sensors in sensors are a tier lower (duh)
val high_tiered_extras as double[string][string] = {
	"pump": {"rubber_pump":3.5D,"wire_components":1.0D,"motor":1.0D,"metal_pump":5.625D,"metal_pipe":3.0D} as double[string],
	"conveyor": {"rubber_conveyor":4.0D,"wire_components":1.0D,"metal_components":28.0D} as double[string],
	"piston": {"metal_components": 17.0D} as double[string],
	"robot_arm": {"metal_components":10.0D,"wire_components":29.0D,"circuit":7.0D} as double[string],
	"field_generator": {"circuit":12.0D,"emitter":4.0D,"wire_components":32.0D,"metal_components":1.375D} as double[string],
	"emitter": {"circuit":6.0D,"emitter_core":7.0D,"wire_components":14.0D,"metal_emitter":46.0D,"metal_components":1.375D,"emitter":2.0D} as double[string],
	"sensor": {"circuit":6.0D,"metal_components":-2.625D,"emitter_core":7.0D,"metal_emitter":47.5D,"wire_components":16.0D,"sensor":2.0D} as double[string]
} as double[string][string];

// [input guaranteed, input chance, output guaranteed, output chance] multipliers for yields when an item is an input and output of disassembly
// remember that guaranteed outputs must be rounded down, so keep this in mind for recipes that only use one of a microcomponent
// however, if neither guaranteed multiplier is zero, at least one item will be returned unless the return amount is smaller than the unit size for that item
// in which case none will ever be returned.
// NOTE the meaning of these numbers is a little confusing: the guaranteed multiplier is interpreted as the fraction of outputs to guarantee,
// and the chance multiplier is interpreted as the base chance to give the rest of the outputs.
// the chance always increases by 13% of the difference between the base chance and 100% every tier.
// since there are 7 times disassembling can overclock it can never reach 100%
val yield_multipliers as double[][string] = {
	"graphite": [0.0D, 0.0D, 0.4D, 0.5D],
	"blazerod": [0.0D, 0.0D, 0.0D, 0.5D],
	"diamond": [0.0D, 0.0D, 0.4D, 0.5D],
	"cutting_saw": [0.0D, 0.0D, 0.0D, 0.7D],
	"chest": [0.0D, 0.0D, 0.0D, 0.7D],
	"lead": [0.0D, 0.0D, 0.4D, 0.5D],
	"filter": [0.0D, 0.0D, 0.5D, 0.5D],
	"plain_glass": [0.0D, 0.0D, 0.0D, 0.6D],
	"iron": [0.0D, 0.0D, 0.4D, 0.4D],
	"red_wire": [0.0D, 0.0D, 0.4D, 0.6D],
	"coke_bricks": [0.0D, 0.0D, 0.6D, 0.6D],
	"frost_casing": [0.0D, 0.0D, 0.6D, 0.6D],
	"atomic_alloy": [0.0D, 0.0D, 0.6D, 0.6D],
	"solidsteel_casing": [0.0D, 0.0D, 0.6D, 0.6D],
	"obsidian": [0.0D, 0.0D, 0.6D, 0.6D],
	"cupronickel_wire": [0.0D, 0.0D, 0.6D, 0.6D],
	"heat_casing": [0.0D, 0.0D, 0.6D, 0.6D],
	"annealed_wire": [0.0D, 0.0D, 0.6D, 0.6D],
	"bronze_casing": [0.0D, 0.0D, 0.6D, 0.6D],
	"steel": [0.0D, 0.0D, 0.6D, 0.6D],
	"vinteum": [0.0D, 0.0D, 0.6D, 0.6D],
	"tungstensteel": [0.0D, 0.0D, 0.6D, 0.6D],
	"assembly_casing": [0.0D, 0.0D, 0.6D, 0.6D],
	"data_orb": [0.0D, 0.0D, 0.6D, 0.6D],
	"hpic": [0.0D, 0.0D, 0.6D, 0.6D],
	"superconductor_wire": [0.0D, 0.0D, 0.6D, 0.6D],
	"fusion_coil": [0.0D, 0.0D, 0.6D, 0.6D],
	"plutonium": [0.0D, 0.0D, 0.6D, 0.6D],
	"nether_star": [0.0D, 0.0D, 0.6D, 0.6D],
	"europium": [0.0D, 0.0D, 0.6D, 0.6D],
	"americium": [0.0D, 0.0D, 0.6D, 0.6D],
	"void_anvil": [0.0D, 0.0D, 0.6D, 0.6D],
	"ptfe": [0.0D, 0.0D, 0.6D, 0.6D],
	"circuit": [0.0D, 0.0D, 0.6D, 0.6D],
	"motor": [0.0D, 0.0D, 0.6D, 0.6D],
	"pump": [1.0D, 1.0D, 0.7D, 0.6D],
	"conveyor": [1.0D, 1.0D, 0.7D, 0.6D],
	"piston": [1.0D, 1.0D, 0.7D, 0.6D],
	"robot_arm": [1.0D, 1.0D, 0.8D, 0.6D],
	"field_generator": [1.0D, 1.0D, 0.7D, 0.6D],
	"emitter": [1.0D, 1.0D, 0.7D, 0.3D],
	"sensor": [1.0D, 1.0D, 0.7D, 0.3D],
	"battery": [0.0D, 0.0D, 0.7D, 0.5D],
	"field_generator_core": [0.0D, 0.0D, 0.4D, 0.7D],
	"emitter_core": [0.0D, 0.0D, 0.4D, 0.7D],
	"grinding_head": [0.0D, 0.0D, 0.0D, 0.7D],
	"metal_hull": [0.0D, 0.0D, 0.4D, 0.6D],
	"metal_components": [0.0D, 0.0D, 0.4D, 0.6D],
	"metal_pump": [0.0D, 0.0D, 0.5D, 0.6D],
	"metal_pipe": [0.0D, 0.0D, 0.5D, 0.6D],
	"metal_emitter": [0.0D, 0.0D, 0.4D, 0.4D],
	"metal_fan": [0.0D, 0.0D, 0.5D, 0.5D],
	"metal_holder": [0.0D, 0.0D, 0.6D, 0.6D],
	"rubber_pump": [0.0D, 0.0D, 0.3D, 0.5D],
	"rubber_conveyor": [0.0D, 0.0D, 0.3D, 0.5D],
	"wire_hull": [0.0D, 0.0D, 0.5D, 0.6D],
	"wire_components": [0.0D, 0.0D, 0.4D, 0.6D],
	"wire_coil": [0.0D, 0.0D, 0.5D, 0.7D],
	"wire_osmium": [0.0D, 0.0D, 0.5D, 0.3D],
	"wire_electrolyzer": [0.0D, 0.0D, 0.6D, 0.6D],
	"wire_separator": [0.0D, 0.0D, 0.4D, 0.5D],
	"rod_separator": [0.0D, 0.0D, 0.4D, 0.6D],
	"rod_naqreactor": [0.0D, 0.0D, 0.4D, 0.6D],
	"glass": [0.0D, 0.0D, 0.5D, 0.5D],
	"furnace": [0.9D, 0.9D, 0.8D, 0.2D],
	"macerator": [0.9D, 0.9D, 0.0D, 0.0D],
	"alloy_smelter": [0.9D, 0.9D, 0.0D, 0.0D],
	"arc_furnace": [0.8D, 0.8D, 0.0D, 0.0D],
	"assembler": [0.8D, 0.8D, 0.0D, 0.0D],
	"autoclave": [0.9D, 0.9D, 0.0D, 0.0D],
	"bender": [0.8D, 0.8D, 0.0D, 0.0D],
	"brewry": [0.9D, 0.9D, 0.0D, 0.0D],
	"canner": [0.7D, 0.7D, 0.0D, 0.0D],
	"centrifuge": [0.9D, 0.9D, 0.0D, 0.0D],
	"bath": [0.8D, 0.8D, 0.0D, 0.0D],
	"chem_reactor": [0.8D, 0.8D, 0.0D, 0.0D],
	"compressor": [0.6D, 0.6D, 0.0D, 0.0D],
	"cutting_machine": [0.9D, 0.9D, 0.0D, 0.0D],
	"distillery": [0.7D, 0.7D, 0.0D, 0.0D],
	"electrolyzer": [0.9D, 0.9D, 0.0D, 0.0D],
	"separator": [0.6D, 0.6D, 0.0D, 0.0D],
	"extractor": [0.6D, 0.6D, 0.0D, 0.0D],
	"fermenter": [0.9D, 0.9D, 0.0D, 0.0D],
	"f_canner": [0.6D, 0.6D, 0.0D, 0.0D],
	"f_extractor": [0.7D, 0.7D, 0.0D, 0.0D],
	"f_heater": [0.6D, 0.6D, 0.0D, 0.0D],
	"f_solidifier": [0.9D, 0.9D, 0.0D, 0.0D],
	"forge_hammer": [0.6D, 0.6D, 0.0D, 0.0D],
	"forming_press": [0.5D, 0.5D, 0.0D, 0.0D],
	"lathe": [0.9D, 0.9D, 0.0D, 0.0D],
	"microwave": [0.5D, 0.5D, 0.0D, 0.0D],
	"mixer": [0.8D, 0.8D, 0.0D, 0.0D],
	"washer": [0.9D, 0.9D, 0.0D, 0.0D],
	"packager": [0.6D, 0.6D, 0.0D, 0.0D],
	"unpackager": [0.6D, 0.6D, 0.0D, 0.0D],
	"polarizer": [0.6D, 0.6D, 0.0D, 0.0D],
	"sifter": [0.9D, 0.9D, 0.0D, 0.0D],
	"wiremill": [0.9D, 0.9D, 0.0D, 0.0D],
	"diesel_generator": [0.9D, 0.9D, 0.0D, 0.0D],
	"steam_turbine": [0.9D, 0.9D, 0.0D, 0.0D],
	"gas_turbine": [0.9D, 0.9D, 0.0D, 0.0D],
	"item_collector": [0.5D, 0.5D, 0.0D, 0.0D],
	"hull": [1.0D, 1.0D, 1.0D, 0.0D],
	"transformer": [1.0D, 1.0D, 0.0D, 0.0D],
	"b_buffer_1x": [0.7D, 0.7D, 0.0D, 0.0D],
	"b_buffer_4x": [0.7D, 0.7D, 0.0D, 0.0D],
	"b_buffer_9x": [0.7D, 0.7D, 0.0D, 0.0D],
	"b_buffer_16x": [0.7D, 0.7D, 0.0D, 0.0D],
	"b_charger_4x": [0.6D, 0.6D, 0.0D, 0.0D],
	"i_input": [0.6D, 0.6D, 0.0D, 0.0D],
	"i_output": [0.6D, 0.6D, 0.0D, 0.0D],
	"f_input": [0.6D, 0.6D, 0.0D, 0.0D],
	"f_output": [0.6D, 0.6D, 0.0D, 0.0D],
	"e_input": [0.6D, 0.6D, 0.0D, 0.0D],
	"e_output": [0.6D, 0.6D, 0.0D, 0.0D],
	"fisher": [0.5D, 0.5D, 0.0D, 0.0D],
	"f_pump": [0.5D, 0.5D, 0.0D, 0.0D],
	"air_collector": [0.7D, 0.7D, 0.0D, 0.0D],
	"ceu_1x": [0.6D, 0.6D, 0.0D, 0.0D],
	"cef_1x": [0.6D, 0.6D, 0.0D, 0.0D],
	"ceu_4x": [0.6D, 0.6D, 0.0D, 0.0D],
	"cef_4x": [0.7D, 0.7D, 0.0D, 0.0D],
	"ceu_9x": [0.6D, 0.6D, 0.0D, 0.0D],
	"cef_9x": [0.6D, 0.6D, 0.0D, 0.0D],
	"ceu_16x": [0.7D, 0.7D, 0.0D, 0.0D],
	"cef_16x": [0.6D, 0.6D, 0.0D, 0.0D],
	"casing": [1.0D, 1.0D, 1.0D, 0.0D],
	"extruder+": [0.9D, 0.9D, 0.0D, 0.0D],
	"extruder": [0.8D, 0.8D, 0.0D, 0.0D],
	"plasma_furnace": [0.6D, 0.6D, 0.0D, 0.0D],
	"mass_fabricator": [0.6D, 0.6D, 0.0D, 0.0D],
	"replicator": [0.6D, 0.6D, 0.0D, 0.0D],
	"naquadah_reactor": [0.6D, 0.6D, 0.0D, 0.0D],
	"rotor_holder": [0.8D, 0.8D, 0.0D, 0.0D],
	"engraver": [0.9D, 0.9D, 0.0D, 0.0D],
	"t_centrifuge": [0.7D, 0.7D, 0.0D, 0.0D],
	"quantum_chest": [0.6D, 0.6D, 0.0D, 0.0D],
	"quantum_tank": [0.6D, 0.6D, 0.0D, 0.0D],

	"coke_oven": [0.6D, 0.6D, 0.0D, 0.0D],
	"vacuum_freezer": [0.6D, 0.6D, 0.0D, 0.0D],
	"implosion_compressor": [0.6D, 0.6D, 0.0D, 0.0D],
	"pyrolyse": [0.6D, 0.6D, 0.0D, 0.0D],
	"cracker": [0.6D, 0.6D, 0.0D, 0.0D],
	"distillation_tower": [0.6D, 0.6D, 0.0D, 0.0D],
	"ebf": [0.6D, 0.6D, 0.0D, 0.0D],
	"multismelter": [0.6D, 0.6D, 0.0D, 0.0D],
	"lbb": [0.6D, 0.6D, 0.0D, 0.0D],
	"lsb": [0.6D, 0.6D, 0.0D, 0.0D],
	"large_steam_turbine": [0.6D, 0.6D, 0.0D, 0.0D],
	"large_gas_turbine": [0.6D, 0.6D, 0.0D, 0.0D],
	"plasma_turbine": [0.6D, 0.6D, 0.0D, 0.0D],
	"assembly_line": [0.6D, 0.6D, 0.0D, 0.0D],
	"processing_array": [0.6D, 0.6D, 0.0D, 0.0D],
	"reactor_i": [0.6D, 0.6D, 0.0D, 0.0D],
	"reactor_ii": [0.6D, 0.6D, 0.0D, 0.0D],
	"reactor_iii": [0.6D, 0.6D, 0.0D, 0.0D],
	"disassembler": [0.6D, 0.6D, 0.0D, 0.0D],
	"black_hole_unit": [0.6D, 0.6D, 0.0D, 0.0D],
	"black_hole_tank": [0.6D, 0.6D, 0.0D, 0.0D],
	"magic_absorber": [0.6D, 0.6D, 0.0D, 0.0D]
} as double[][string];

// used as a set of what UV items need their wire_hull yield divided by 4
val uv_wire_hull_mod as bool[string] = {
	"arc_furnace": true,
	"plasma_furnace": true,
	"mass_fabricator": true,
	"replicator": true
} as bool[string];

val tier_shift_circuits as int[string] = {
	"plasma_furnace": 1,
	"mass_fabricator": 1,
	"replicator": 1,
	"cracker": 1,
	"multismelter": 2,
	"large_steam_turbine": -1,
	"plasma_turbine": -2,
	"reactor_i": 2,
	"reactor_ii": 2,
	"reactor_iii": 2,
	"black_hole_unit": 1,
	"black_hole_tank": 1
} as int[string];

// used as a set of what LuV+ items need to yield circuits two tiers lower
val luvp_tier_unshift2_circuits as bool[string] = {
	"robot_arm": true,
	"emitter": true,
	"sensor": true
} as bool[string];

//crafttweaker doesn't seem to support <<
val pow2 as int[] = [1, 2, 4, 8, 16, 32, 64, 128, 256] as int[];

for item_name, base_result_map in tiered_results {
	print("Processing recipes for " + item_name);
	// for every tier from LV to MAX
	for i in 0 to 9 {
		val item_tier_i as IItemStack = tiered_items[item_name][i] as IItemStack;
		if(!isNull(item_tier_i)){
			val item_guaranteed_multiplier as double = (yield_multipliers[item_name][0]) as double;
			val item_chance_multiplier as double = (yield_multipliers[item_name][1]) as double;
			var recipeBuilder = disassembler_recipe_map.recipeBuilder()
				.duration(2*60*20*pow2[i])
				.EUt(128)
				.inputs(tiered_items[item_name][i]);
			var guaranteed_outputs as IItemStack[] = [] as IItemStack[];
			for component_name, component_base_amount in base_result_map {
				var tier_shift as int = 0 as int;
				var component_amount as double = component_base_amount as double;
				if(!(yield_multipliers has component_name)){
					print("WARNING");
					print("component_name: " + component_name);
					print("was not present in yield_multipliers, this script will now crash");
				}
				val component_guaranteed_frac as double = (item_guaranteed_multiplier*yield_multipliers[component_name][2]) as double;
				val component_chance as double = (item_chance_multiplier*yield_multipliers[component_name][3]) as double;
				if(component_name == "circuit"){
					if(tier_shift_circuits has item_name){
						tier_shift = tier_shift_circuits[item_name] as int;
					}else if(i >= 5 && (luvp_tier_unshift2_circuits has item_name)){
						tier_shift -= 2;
					}
				}else if(component_name == item_name){
					tier_shift -= 1;
				}
				val component_item as IItemStack = ((untiered_items has component_name) ?
					untiered_items[component_name] :
					tiered_items[component_name][i + tier_shift]) as IItemStack;
				if(i >= 5 && high_tiered_extras has item_name && high_tiered_extras[item_name] has component_name){
					component_amount += high_tiered_extras[item_name][component_name];
				}
				if(i == 7 && component_name == "wire_hull" && (uv_wire_hull_mod has item_name)){
					component_amount *= 0.25D;
				}else if(i == 1 && component_name == "wire_hull" && item_name == "bender"){
					component_amount *= 0.5D;
				}
				if(item_units has component_name){
					component_amount = component_amount/item_units[component_name];
				}
				if(isNull(component_item)){
					print("WARNING: disassembling tiered item requires unregistered tiered component, skipping component");
					print("item_name: " + item_name);
					print("component_name: " + component_name);
					print("i: " + i);
					print("tier_shift: " + tier_shift);
				}else{
					var component_guaranteed_amount as int = (component_amount*component_guaranteed_frac) as int;
					if(component_guaranteed_amount == 0 && component_guaranteed_frac != 0 && component_amount >= 1.0D){
						component_guaranteed_amount += 1;
					}
					val component_chanced_amount as int = (component_amount - component_guaranteed_amount) as int;
					if(component_guaranteed_amount > 0){
						guaranteed_outputs += component_item*component_guaranteed_amount;
					}
					if(component_chanced_amount > 0){
						recipeBuilder.chancedOutput(component_item*component_chanced_amount, (component_chance*10000.0D) as int, ((1.0D-component_chance)*1300.0D) as int);
					}
				}
			}
			if(i >= 5 && (high_tiered_extras has item_name)){
				for component_name, component_base_amount in high_tiered_extras[item_name] {
					if(!(tiered_results[item_name] has component_name)){
						var tier_shift as int = 0 as int;
						if(component_name == item_name){
							tier_shift -= 1;
						}
						val component_item as IItemStack = ((untiered_items has component_name) ?
							untiered_items[component_name] :
							tiered_items[component_name][i + tier_shift]) as IItemStack;
						var component_amount as double = component_base_amount as double;
						if(item_units has component_name){
							component_amount = component_amount/item_units[component_name];
						}
						val component_guaranteed_frac as double = (item_guaranteed_multiplier*yield_multipliers[component_name][2]) as double;
						val component_chance as double = (item_chance_multiplier*yield_multipliers[component_name][3]) as double;
						var component_guaranteed_amount as int = (component_amount*component_guaranteed_frac) as int;
						if(component_guaranteed_amount == 0 && component_guaranteed_frac != 0 && component_amount >= 1.0D){
							component_guaranteed_amount += 1;
						}
						val component_chanced_amount as int = (component_amount - component_guaranteed_amount) as int;
						if(component_guaranteed_amount > 0){
							guaranteed_outputs += component_item*component_guaranteed_amount;
						}
						if(component_chanced_amount > 0){
							recipeBuilder.chancedOutput(component_item*component_chanced_amount, (component_chance*10000.0D) as int, ((1.0D-component_chance)*1300.0D) as int);
						}
					}
				}
			}
			if(item_name == "transformer"){
				val component_guaranteed_frac as double = (item_guaranteed_multiplier*yield_multipliers["wire_hull"][2]) as double;
				val component_chance as double = (item_chance_multiplier*yield_multipliers["wire_hull"][3]) as double;
				val component_amount as double = 1.0D as double;
				val component_item as IItemStack = tiered_items["wire_hull"][i + 1] as IItemStack;
				var component_guaranteed_amount as int = (component_amount*component_guaranteed_frac) as int;
				if(component_guaranteed_amount == 0 && component_guaranteed_frac != 0 && component_amount >= 1.0D){
					component_guaranteed_amount += 1;
				}
				val component_chanced_amount as int = (component_amount - component_guaranteed_amount) as int;
				
				if(component_guaranteed_amount > 0){
					guaranteed_outputs += component_item*component_guaranteed_amount;
				}
				if(component_chanced_amount > 0){
					recipeBuilder.chancedOutput(component_item*component_chanced_amount, (component_chance*10000.0D) as int, ((1.0D-component_chance)*1300.0D) as int);
				}
			}
			if(guaranteed_outputs.length > 0){
				recipeBuilder.outputs(guaranteed_outputs);
			}
			recipeBuilder.buildAndRegister();
		}
	}
}

print("----------------Disassembler End-------------------");

