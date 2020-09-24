Import-Function -Name WriteMessage 
Import-Function -Name ProcessItem
Import-Function -Name PruneItem

$watch = [System.Diagnostics.Stopwatch]::StartNew()
WriteMessage("Item Version Pruner script started")

#constants
$settingsItem = Get-Item 'master:/sitecore/system/Settings/Feature/Item Version Pruner/Version Pruner Settings'
$backupFolder = "$($SitecoreDataFolder)\ItemVersionPruner\$(get-date -f MMddyyyyTHHmmss)"
WriteMessage("Serialization folder for backup: $($backupFolder)")

#default settings - shared across languages
$versionsToKeep = $settingsItem.VersionsToKeep
$liveDb = $settingsItem.LiveContentDatabase
$contentRoots = $settingsItem._.ContentRoots.GetItems()
$savePrunedItemsToFolder = ($settingsItem.SavePrunedItemsToFolder -eq 1)

WriteMessage("SavePrunedItemsToFolder: $($savePrunedItemsToFolder)")

$availableLanguages = [Sitecore.Data.Managers.LanguageManager]::GetLanguages([Sitecore.Context]::ContentDatabase)

#exclusions - can vary per language
$exclusionSettings = @()
foreach($language in $availableLanguages)
{
    $exclusionSettings += Get-ChildItem -Item $settingsItem -Language $language.Name
}

foreach($root in $contentRoots)
{
    foreach ($language in $availableLanguages)
    {
        $item = Get-Item -Path "master:" -ID $root.ID -Language $language.Name
        if($item)
        { 
            Write-Host "About to prune item: " $item.Paths.FullPath
            WriteMessage("Processing start item $($item.Paths.FullPath)")
            ProcessItem -item $item -liveDb $liveDb -versionsToKeep $versionsToKeep -exclusions $exclusionSettings -savePrunedItemsToFolder $savePrunedItemsToFolder 
            WriteMessage("Processing complete: $($item.Paths.FullPath)")
        }
    }
}

$watch.Stop()
WriteMessage("Item Version Pruner script finished in $($watch.ElapsedMilliseconds / 1000) seconds.")
