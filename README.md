# SitecoreVersionPruner

This script was primarily developed by @ezlateva with some slight tweaks by @danielrolfe. 

Powershell script that prunes sitecore item versions to a configurable number.

## Configuration

### Global settings item:

  /sitecore/system/Settings/Feature/Item Version Pruner/Version Pruner Settings

*Note: the script itself has a reference to this path in order to grab settings, so if the item path changes, the script should be updated*

Fields:

**VersionsToKeep** - the global default number of max recent versions to keep in master

Note: the script does a comparison between the version number in the live content database, and the most recent version number in master.

If they do not match, the VersionsToKeep number is overwritten with default VersionsToKeep + (the master version number - the live version number) for example, if the default VersionsToKeep setting is 5, and an item has 12 versons in master, but the latest published version is version 7, then, the script will keep (5 + (12-7)) = 10 versions and only prune the oldest 2

**LiveContentDatabase** - this should define the database where the live content lives in order to look up the published items' version

**ContentRoots** - defines the roots at which the script processing would start

**SavePrunedItemsToFolder** - When checked will cause all versions pruned to be saved to a folder on the CM. This can be used to restored the pruned versions.

![Version Pruner Root Settings](/documentation/images/VersionPrunerRootSettings.png)

### Exclusion settings

Children of the global settings item, of template Version Pruner Exclusion Setting

Each exclusion settings can define:

**Nodes** - which items the exclusion settings apply to [Shared field]

**IncludeChildren** - whether or not the exclusion settings should apply to descendants of the selected Nodes [Shared field]

**DisablePruning** - if checked, the defined items will not be pruned [this setting can vary per language]

**VersionsToKeep** - an override for the default VersionsToKeep setting that will apply to the defined items [this setting can vary per language]

Item structure of settings and exclusions:

![Version Pruner Root Settings](/documentation/images/VersionPrunerSettingsFolderStructure.png)

Child Exclusion Settings:

![Version Pruner Root Settings](/documentation/images/VersionPrunerExclusionSettings.png)

### Scheduled task

  /sitecore/system/Tasks/Schedules/Item Version Pruner/Prune Item Versions

The task is configured to run a Powershell Sript Command and run the /sitecore/system/Modules/PowerShell/Script Library/Carnival/Item Version Pruner/PruneVersions script

*Note: if you rename the script or change the folder structure, you'll need to update the scheduled task definition item, as the item path field is a string, not and ID*

## Backup

Any pruned items get serialized and backed up to a serialization folder in a[SitecoreDataFolder]\ItemVerisonPruner\[MMddyyyyTHHmmss] folder

Each script run creates a new timestamped folder, so this process will eventually need a cleanup job to remove old backup folders

## Installation Packages

ItemVersionPruner.zip

Contents:

  templates under /sitecore/templates/Feature/Item Version Pruner
  SPE module under /sitecore/system/Modules/PowerShell/Script Library/Carnival/Item Version Pruner
  settings items under /sitecore/system/Settings/Feature/Item Version Pruner
