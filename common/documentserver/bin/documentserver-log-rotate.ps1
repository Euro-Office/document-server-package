Get-ChildItem "$PSScriptRoot\..\server\App_Data\cache\files\errors" -Directory -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Sort-Object FullName -Descending | Remove-Item -Recurse -Force

Get-ChildItem "$PSScriptRoot\..\Log" -Recurse -Filter *.log | Where-Object LastWriteTime -lt (Get-Date).AddDays(-30) | Remove-Item -Force
