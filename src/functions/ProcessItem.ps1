function ProcessItem() {    
    param(
        [Sitecore.Data.Items.Item]$item,
        [string]$liveDb,
        [int]$versionsToKeep,
        [Sitecore.Data.Items.Item[]]$exclusions,
        [bool]$savePrunedItemsToFolder
    )
    
    $includeChildren = $true
    $disablePruning = $false

    $languageExclusions = $exclusions | Where-Object { $_.Language.Name -eq $item.Language.Name }
    foreach($setting in $languageExclusions) 
    {
        # switch language context, so that we can get the selected Node items in the specific language
        $langSwitcher = New-Object Sitecore.Globalization.LanguageSwitcher $item.Language.Name
        
        foreach($node in $setting._.Nodes.GetItems())
        {
            if($node.ID -eq $item.ID)
            {
                # the current item matches a selected node item in the current item language
                WriteMessage("Item $($item.Paths.FullPath) found in exclusion setting for language $($item.Language.Name)")
                
                $includeChildren = $setting._.IncludeChildren.Checked
                $disablePruning = $setting._.DisablePruning.Checked
                $versionsToKeepOverride = $setting.VersionsToKeep
                
                WriteMessage("Include Children: $($setting._.IncludeChildren.Checked)")
                WriteMessage("Disable Pruning: $($setting._.DisablePruning.Checked)")
                
                if($versionsToKeepOverride -gt 0)
                {
                    WriteMessage("Overriding Versions To Keep: $($setting.VersionsToKeep)")
                    $versionsToKeep = $versionsToKeepOverride
                }
            }
        }
            
        $langSwitcher.Dispose()
    }
     
    if($disablePruning -eq $true)
    {
        WriteMessage("Pruning is disabled for item $($item.Paths.FullPath)")
    }
    else 
    {
        PruneItem -item $item -liveDb $liveDb -versionsToKeep $versionsToKeep -savePrunedItemsToFolder $savePrunedItemsToFolder
    }
    
    if(($disablePruning -eq $true) -and ($includeChildren -eq $true))
    {
        WriteMessage("Pruning is disabled for all children of $($item.Paths.FullPath)")
        return
    }
    
    #grab children and evaluate
    $itemsToProcess = Get-ChildItem -Path 'master:' -ID $item.ID -Language $item.Language.Name
    
    foreach($child in $itemsToProcess)
    {
        #WriteMessage("Processing item $($child.Paths.FullPath) in language $($child.Language.Name)")
        ProcessItem -item $child -liveDb $liveDb -versionsToKeep $versionsToKeep -exclusions $exclusions -savePrunedItemsToFolder $savePrunedItemsToFolder
    }
}
