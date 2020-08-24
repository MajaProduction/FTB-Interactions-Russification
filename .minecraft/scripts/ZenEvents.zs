import mods.contenttweaker.BlockPos;
import mods.zentriggers.PredicateBuilder;
import mods.zentriggers.Handler;
import mods.zentriggers.events.EntityLivingUpdateEvent;
import crafttweaker.entity.IEntity;
import crafttweaker.item.IItemStack;
import crafttweaker.player.IPlayer;
import crafttweaker.events.IEventManager;
import crafttweaker.block.IBlock;
import crafttweaker.world.IBlockPos;
import crafttweaker.world.IWorld;
import crafttweaker.entity.IEntityItem;
import crafttweaker.block.IMaterial;
import crafttweaker.event.IPlayerEvent;
import crafttweaker.event.PlayerTickEvent;

print("---------------Zen Events Start------------------");

Handler.onEntityUpdate(
		PredicateBuilder.create()
			.isInBlockArea(<blockstate:animus:blockfluidantimatter>.block,3,3,3,3)
			.isInstanceOf("mightyenderchicken:ent_EnderChicken")
			.isRandom(0.5)
			.isNthTick(10)
			.isRemote()
			.negateLatest()
		,function(event as EntityLivingUpdateEvent){
		//print ("event triggered correctly for enderchicken");
		val neutron = <avaritia:resource:2>;
		if(isNull(neutron)) {
		print("neutron is null in event");
		return;
		}
		if(isNull(event.entity)){
		print("Entity is null in event");
		return;
		}
		event.entity.world.spawnEntity(neutron.createEntityItem(event.entity.world, event.entity.position));
		event.entityLivingBase.health -= 5;
	}
);

mods.DimensionStages.addDimensionStage("nether", -1);
mods.DimensionStages.addDimensionStage("space", -2);
mods.DimensionStages.addDimensionStage("luna", 145);
mods.DimensionStages.addDimensionStage("euclydes", 146);
mods.DimensionStages.addDimensionStage("aurellia", 147);
mods.DimensionStages.addDimensionStage("end", 1);


events.onPlayerTick(function(tickEvent as crafttweaker.event.PlayerTickEvent) {
	if (tickEvent.player.world.time % 400 != 0) return; //dont need to call this too often
		val dim = tickEvent.player.world.getDimension();
        if (dim == 145) {
			if (!tickEvent.player.hasGameStage("luna")){
			
					tickEvent.player.server.commandManager.executeCommand(
						tickEvent.player.server,
						"/cofh tpx " + tickEvent.player.name + " 100"
					);
			
				tickEvent.player.sendChat("Incorrect gamestage for Luna, you are being ejected to the Overworld at your present coordinates.");
			}
		}	
        if (dim == 146) {
			if (!tickEvent.player.hasGameStage("euclydes")){
			
					tickEvent.player.server.commandManager.executeCommand(
						tickEvent.player.server,
						"/cofh tpx " + tickEvent.player.name + " 100"
					);
			
				tickEvent.player.sendChat("Incorrect gamestage for Euclydes Prime, you are being ejected to the Overworld at your present coordinates.");
			}
		}
        if (dim == 147) {
			if (!tickEvent.player.hasGameStage("aurellia")){
			
					tickEvent.player.server.commandManager.executeCommand(
						tickEvent.player.server,
						"/cofh tpx " + tickEvent.player.name + " 100"
					);
			
				tickEvent.player.sendChat("Incorrect gamestage for Aurellia, you are being ejected to the Overworld at your present coordinates.");
			}
		}
		
		
		
		
		
		
		

});