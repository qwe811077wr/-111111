::del "D:\check_data\TestLog4net.TXT"
cd "..\excel\excel_StaticData"


for %%i in (*.xlsx) do (
:: echo %%i
echo %%i
::"D:\gitSpace\excel2json\bin\Debug\excel2json.exe" --excel %%i --json test.json -h 2
"D:\check_data\excel2json.exe" --excel %%i --json test.json -h 2
)
::pause