taskkill /f /t /im unity.exe
cd D:/project_wly2_u3d_client/
git fetch --all
::git stash
::git merge
git reset --hard origin/master
cd D:\wly2_svn\
svn update
cd D:\wly2_svn\¾²Ì¬Êý¾Ý\1.0.0\local\scripts
start node.bat
echo %time%
pause