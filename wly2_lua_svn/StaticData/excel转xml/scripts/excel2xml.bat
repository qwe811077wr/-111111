py -2 %~dp0convert_excel.py -xml 
py -2 %~dp0move_file.py
::py -2 %~dp0convert_excel_campaign.py -xml -lua
pause