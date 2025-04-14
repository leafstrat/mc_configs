# MC Configs

## Purpose
- Saves the state of folders and files inside users local `.minecraft/` folders to share configs updated across multiple clients.
- Powershell script will be created that syncs these folders and files to clients windows folder locations.

### Editing on desktop/master
1. **PULL** from `GitHub`
2. `/home/user/minecraft/CLIENT/`- Edit the files
3. **PUSH** to `GitHub`

### Editing on laptop/client
1. **PULL** from `GitHub`
2. `/home/user/mc_configs/` - Edit the files
3. **PUSH** to `GitHub`


# Folders for syncing:
```sh
patchouli_books/
server-resource-packs/
local/
config/
kubejs/
scripts/
maessentials/
resourcepacks/
```

# config/ Folder
```sh
improvedmobs/
nameless_trinkets/
voicechat/
editmobdrops/
pregen/
zombieawareness/
CoroUtil/
custom trades/
worldedit/
xaerominimap_entities.json
xaerominimap.txt
xaeroworldmap.txt
extragore-property.toml
embeddium-options.json
zombienation-common.toml
watersource-common.toml
watersource-client.toml
usefulhats-legacy-common.toml
union.common.toml
union.client.toml
treasure2-common.toml
torchmaster.toml
timecontrol-common.toml
smoothchunk-common.toml
simplezoom-client.toml
projectvibrantjourneys-common.toml
patchouli-client.toml
modernfix-common.toml
maessentials.toml
# ...
# etc
```
