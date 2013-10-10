# SetVersion.ps1
#
# Set the version in all the AssemblyInfo.cs or AssemblyInfo.vb files in any subdirectory.
#
# usage:  
#  from cmd.exe: 
#     powershell.exe SetBuildNumber.ps1  1234
# 
#  from powershell.exe prompt: 
#     .\SetBuildNumber.ps1  99
#
# adapted from: http://blogs.msdn.com/b/dotnetinterop/archive/2008/04/21/powershell-script-to-batch-update-assemblyinfo-cs-with-new-version.aspx?Redirected=true


function Usage
{
  echo "Usage: ";
  echo "  from cmd.exe: ";
  echo "     powershell.exe SetBuildNumber.ps1  1234";
  echo " ";
  echo "  from powershell.exe prompt: ";
  echo "     .\SetBuildNumber.ps1  99";
  echo " ";
}


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
  }
}


function Update-AllAssemblyInfoFiles ( $version )
{
  foreach ($file in "AssemblyInfo.cs", "AssemblyInfo.vb" ) 
  {
    get-childitem -recurse |? {$_.Name -eq $file} | Update-SourceVersion $version ;
  }
}


# validate arguments 
$r= [System.Text.RegularExpressions.Regex]::Match($args[0], "^[0-9]+$");

if ($r.Success)
{
  Update-AllAssemblyInfoFiles $args[0];
}
else
{
  echo " ";
  echo "Bad Input!"
  echo " ";
  Usage ;
}