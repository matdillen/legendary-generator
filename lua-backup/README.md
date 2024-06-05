# Lua code for the Tabletop Simulator mod

The code here includes all custom Lua scripts used to automate the setup and playing process of the Tabletop Simulator listed in the main directory of this repository. It is and will remain a work in progress for quite some time.

The R script `move_luacode.R` can be used to autodeploy all lua scripts to the JSON file of a Save copy (so it can be edited) of the mod. Be careful, as this process will replace the savefile with the same name as the Save file it starts from, stored and backed up in the `currentmod` folder. The filepath (`tspath`) at the bottom of the R script is hardcoded for my Windows machine so will need changing.

The csv file `obj_guids_info.txt` includes all important GUIDs of the mod, with a name for human readability and a lua script filename if code is to be deployed into the object with this GUID.

## Main game modules
Most of the scripting is governed by a set of game modules, each with different roles which may not always be optimally distributed as this mod has organically grown. Info on the available functions in each module can be found [in this google doc](https://docs.google.com/document/d/1fXCeA5eGfciqqeXujB7L2FEAROWYYRnfX4SwPexuchM/), but there is no guarantee this document is fully up to date.

- `buysidekick.lua`: Script that creates a button to buy sidekicks from the sidekick deck.
- `buyso.lua`: Same as above but for SHIELD Officers.
- `counter.lua`: Script that makes resource counters work (attack or recruit), including those locked below each player's playermat.
- `drawbuy.lua`: Script that creates buttons to buy heroes from the HQ and shows their actual cost hovering above the hero cards. Deployed to scripting zones on each HQ space.
- `drawvillains.lua`: Script that creates a button that draws villains from the villain deck.
- `fightvillain.lua`: Script for each city space, which adds buttons to autofight villains and spend the attack needed. The actual strength of the villain (if coded) is shown by this script as well.
- `global.lua`: Globally available functions are declared here, as are all the GUIDs of objects and zones important for the mod.
- `mastermind.lua`: Scripts that set up masterminds, deal with fighting them, transforming them and setting their actual strength. Active masterminds are tracked here.
- `pushvillains2.lua`: Scripts that push villains into, throughout and out of the city, as well as other objects in the city (locations, shards, bystanders...). For very bad reasons, this script also includes code that draws bystanders and wounds, the updatePower() function which tries to update all dynamically set strengths when called from anywhere, and many many service functions that are used by numerous scripted schemes and masterminds.
- `random.lua`: Contains 100s of randomly generated setups for a quick game. These have not been updated for quite some time.
- `setup.lua`: Creates the interface for importing setups and guides the process to automatically do the whole setup process, also when schemes and masterminds have certain special modifications. Also currently governs Horror effects and the moving around of the Throne's Favor.
- `shard.lua`: Scripts for each shard.
- `yellow.lua`: Script for each playermat. Creates buttons for drawing cards, drawing new hands, autoplaying cards from hand, modifying hand size, calculating vp and more.

The following are currently NOT in use:
- `rescuebystander.lua`: Code that scripts special bystander effects.
- `topcity.lua`: Potential code for nonvillain nonlocation content in the upper city row.

## Specific game scripts
Effects particular to certain cards are scripted on those cards. Many will have general method functions that are called by the modules above. Documentation that may not be fully up to date can be found in [this google doc](https://docs.google.com/document/d/1kOg7FoSNxQZVduy02pYAMl6XWxKnlvX86S_pbVP8uWU/).

- `masterminds`: In this folder, scripts for most of the Masterminds' effects are listed in separate files. These scripts are added to the decks of mastermind cards (i.e. typically a mastermind card and four tactics cards) and the scripts are executed during setup, whereas continuous effects are scripted by loading the script from the mastermind's deck into the zone next to the mastermind zone reserved to place tactics.
- `masterminds/tactics`: Tactics for each mastermind are to be scripted here in a file for each tactic, inside a folder for each mastermind. Only few have been done. This code will be called from the tactic card (normally by the mastermind module) as it is taken from the mastermind's spot after a succesful fight.
- `schemes`: In this folder, scheme effects are scripted in separate files for each scheme. This includes mainly special setup effects and scheme twists, but may also include city bonuses and more. These scripts are called from the scheme card.

- `villains`: Effects of villain cards will be scripted here, in folders for each villain group containing scripts for each unique villain card in said group. Few have been done and these scripts are not used live yet.
- `henchmen`: Same as villains.

## To do

- Script all masterminds and schemes in initial scope. The lists can be found under `app/data` in the`_done.txt` files. Some of these are in fact not done yet.
  
- **Testing, bugfinding and bugfixing.**
- Improving the layout
- Importing backlog of newly released expansions.
- Scripting villain effects
- Scripting tactics effects
- Scripting hero effects

But above all:

- **Testing, bugfinding and bugfixing.**
