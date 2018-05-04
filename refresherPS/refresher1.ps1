Get-CIPolicy
dir . -Recurse
Get-Alias
help Set-Alias -Detailed
echo "sooodddd `
sddsdsds"

echo @"
I am
chillin
"@
&{ 1 + 1 }

$test=1
. { $test += 1 }
& { $test += 1 }

$test1 = [scriptblock]::Create("1+1")
$test1
&$test1

([int] "1").ToString().GetType()

("what about","an array").GetType()
$ar=@("sd","ty","rr")
$ar | measure-object -sum |  Sum

1..5 | %{
    "Recieved $_"
    }

foreach ($ar in @(1..5)){
    "Recieved $ar"
    }


$env

cd env:
ls
Set-Item COMPUTERNAME "Bro"

ls c:/ | clip
notepad

$files = Get-ChildItem C:\Windows
$files | measure-object
$files | ConvertTo-Csv | Set-Content C:\demo\bra.csv

$file1 = Get-Content C:\demo\bra.csv | ConvertFrom-csv

$file1 | Select-Object -Property Name, Attributes | ConvertTo-Csv | Set-Content C:\demo\bra.csv 

