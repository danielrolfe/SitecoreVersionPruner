function PruneItem()
{
    param(
        [Sitecore.Data.Items.Item]$item,
        [string]$liveDb,
        [int]$versionsToKeep,
        [bool]$savePrunedItemsToFolder
    )
    
    if($item.Versions.Count -gt $versionsToKeep) 
    {
        WriteMessage("Pruning candidate found: $($item.Paths.FullPath), language $($item.Language.Name), $($item.Versions.Count) versions. Versions to keep: $($versionsToKeep)")
        
        WriteMessage("Item ID: $($item.ID) and Item LanguageName: $($item.Language.Name)")
        $publishedItem = Get-Item -Path "$($liveDb):" -ID $item.ID -Language $item.Language.Name
        if (!$publishedItem) { 
            WriteMessage("Prunning skipped: item has no published version in this language.")
        }
        else 
        {
            if($publishedItem.Version.Number -ne $item.Version.Number)
            {                
                $versionsToKeep = $versionsToKeep + ($item.Version.Number - $publishedItem.Version.Number)
                
                WriteMessage("Published item version ($($publishedItem.Version.Number)) does not match latest version ($($item.Version.Number)). Versions to keep: $($versionsToKeep)")

                if($item.Versions.Count -eq $versionsToKeep) 
                {
                    WriteMessage("Prunning skipped: keeping all $($item.Versions.Count) item versions.")
                    return
                }
            }
            
            #back up item that's about to be pruned
            if($savePrunedItemsToFolder -eq $true)
            {
                WriteMessage("Serializing item to data folder path.")
                $item | Serialize-Item -Target $backupFolder -ItemPathsAbsolute 
            }
           
            Remove-ItemVersion -Item $item -Language $item.Language.Name -MaxRecentVersions $versionsToKeep -Permanently
            WriteMessage("Pruned: $($item.Paths.FullPath), language $($item.Language.Name). Versions kept: $($versionsToKeep)")
        }
    }
}
