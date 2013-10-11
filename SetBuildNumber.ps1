# SetVersion.ps1
#
# This purpose of this script is to set the version string in TeamCity to be a mix of the version
# from the project's AssemblyInfo.cs and the build counter from TeamCity.
#
# The convention we are using for the version string is: <major>.<minor>.<patch>.<build number>.
# In this case, we want TeamCity to use the <major>, <minor> and <patch> fields that were checked
# in to AssemblyInfo.cs, but we want to use TeamCity's build counter for the build number
#
# adapted from: http://blogs.msdn.com/b/dotnetinterop/archive/2008/04/21/powershell-script-to-batch-update-assemblyinfo-cs-with-new-version.aspx?Redirected=true


function Update-SourceVersion
{
  Param ([string]$newBuildNumber)

  foreach ($o in $input) 
  {
    $assemblyPattern = "[0-9]+(\.([0-9]+|\*)){3}"  
    $assemblyVersionPattern = 'AssemblyVersion\("([0-9]+(\.([0-9]+|\*)){3})"\)'  
    
    $rawVersionNumberGroup = get-content $o.FullName | select-string -pattern $assemblyVersionPattern | select -first 1 | % { $_.Matches }
    $rawVersionNumber = $rawVersionNumberGroup.Groups[1].Value 
    
    $versionParts = $rawVersionNumber.Split('.')
    $versionParts[3] = $newBuildNumber
    $updatedAssemblyVersion = "{0}.{1}.{2}.{3}" -f $versionParts[0], $versionParts[1], $versionParts[2], $versionParts[3] 
    
    $NewVersion = 'AssemblyVersion("' + $updatedAssemblyVersion + '")';
    $NewFileVersion = 'AssemblyFileVersion("' + $updatedAssemblyVersion + '")';
    
    Write-Host -NoNewline "updating build number in file: '" $o.FullName "' to be: " $updatedAssemblyVersion
    Write-Host

    $TmpFile = $o.FullName + ".tmp"

     get-content $o.FullName | 
       %{$_ -replace 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){3}"\)', $NewVersion } |
       %{$_ -replace 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){3}"\)', $NewFileVersion }  > $TmpFile

     move-item $TmpFile $o.FullName -force
     
     #now notify TeamCity of our new version string (http://confluence.jetbrains.com/display/TCD5/Build+Script+Interaction+with+TeamCity#BuildScriptInteractionwithTeamCity-ReportingBuildStatus)
     Write-Host -NoNewline "##teamcity[buildNumber '"$updatedAssemblyVersion"']"
     Write-Host
  }
}


function Update-AllAssemblyInfoFiles ( $version )
{
  foreach ($file in "AssemblyInfo.cs", "AssemblyVersion.cs" ) 
  {
    get-childitem -recurse |? {$_.Name -eq $file} | Update-SourceVersion $version ;
  }
}

#get the build counter from an environment var set automatically by TeamCity
$teamcityBuildCounter = $env:build_number
Update-AllAssemblyInfoFiles $teamcityBuildCounter;
