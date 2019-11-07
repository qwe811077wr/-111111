// decodeLua.cpp : ¶¨Òå¿ØÖÆÌ¨Ó¦ÓÃ³ÌÐòµÄÈë¿Úµã¡£
//
#ifdef _WIN32
#include <io.h>
#else
#include <unistd.h>
#include <stdio.h>
#include <dirent.h>
#include <sys/stat.h>
#endif

#include <string>
#include <iostream>
#include <fstream>
#include <memory.h>
using namespace std;

string g_pwd = "1235789";




/*¼ÓÃÜ×Óº¯Êý¿ªÊ¼*/
void encfile(const char *in_filename, const char *pwd, const char *out_file)
{
	string filePath = in_filename;
	if (filePath.substr(filePath.length() - 4, filePath.length()) != ".lua")
		return;

	FILE *fp1, *fp2;
	char ch;
	int j = 0;
	int j0 = 0;
	fp1 = fopen(in_filename, "r");/*´ò¿ªÒª¼ÓÃÜµÄÎÄ¼þ*/
	if (fp1 == NULL){
		printf("cannot open in-file./n");
		exit(1);/*Èç¹û²»ÄÜ´ò¿ªÒª¼ÓÃÜµÄÎÄ¼þ,±ãÍË³ö³ÌÐò*/
	}
	fp2 = fopen(out_file, "w");
	if (fp2 == NULL){
		printf("cannot open or create out-file./n");
		exit(1);/*Èç¹û²»ÄÜ½¨Á¢¼ÓÃÜºóµÄÎÄ¼þ,±ãÍË³ö*/
	}

	while (pwd[++j0]);

	ch = fgetc(fp1);

	long size = 0;
	/*¼ÓÃÜËã·¨¿ªÊ¼*/
	while (!feof(fp1)){
		if (j0 > 7)
			j0 = 0;
		ch += pwd[j0++];
		fputc(ch, fp2);
		ch = fgetc(fp1);
		size++;
	}
	fclose(fp1);/*¹Ø±ÕÔ´ÎÄ¼þ*/
	fclose(fp2);/*¹Ø±ÕÄ¿±êÎÄ¼þ*/

	cout << "length :" << size << endl;

	remove(in_filename);
	string outFile = out_file;
	string out = outFile.substr(0, outFile.length());
	rename(out_file , out.c_str());
}

/*½âÃÜ×Óº¯Êý¿ªÊ¼*/
void decryptfile(const char *in_filename, const char *pwd, const char *out_file)
{
	string filePath = in_filename;
	string sub = filePath.substr(filePath.length() - 4, filePath.length());
	if (filePath.length() < 5 || filePath.substr(filePath.length() - 5, filePath.length()) != ".luac")
		return;

	FILE *fp1, *fp2;
	char ch;
	int j = 0;
	int j0 = 0;
	fp1 = fopen(in_filename, "r");/*´ò¿ªÒª½âÃÜµÄÎÄ¼þ*/
	if (fp1 == NULL){
		printf("cannot open in-file./n");
		exit(1);/*Èç¹û²»ÄÜ´ò¿ªÒª½âÃÜµÄÎÄ¼þ,±ãÍË³ö³ÌÐò*/
	}
	fp2 = fopen(out_file, "w");
	if (fp2 == NULL){
		printf("cannot open or create out-file./n");
		exit(1);/*Èç¹û²»ÄÜ½¨Á¢½âÃÜºóµÄÎÄ¼þ,±ãÍË³ö*/
	}

	while (pwd[++j0]);
	ch = fgetc(fp1);
	/*½âÃÜËã·¨¿ªÊ¼*/
	while (!feof(fp1)){
		if (j0 > 7)
			j0 = 0;
		ch -= pwd[j0++];
		fputc(ch, fp2);/*ÎÒµÄ½âÃÜËã·¨*/
		ch = fgetc(fp1);
	}
	fclose(fp1);/*¹Ø±ÕÔ´ÎÄ¼þ*/
	fclose(fp2);/*¹Ø±ÕÄ¿±êÎÄ¼þ*/

	cout << "length" << in_filename << endl;

	remove(in_filename);
	string outFile = out_file;
	string out = outFile.substr(0, outFile.length());
	rename(out_file, out.c_str());
}

void dfsFolder(string folderPath, int depth , bool bEnc)
{
#ifdef WIN32
    _finddata_t FileInfo;
    string strfind = folderPath + "\\*";
    long Handle = _findfirst(strfind.c_str(), &FileInfo);
    
    if (Handle == -1L)
    {
        cerr << "can not match the folder path" << endl;
        exit(-1);
    }
    do{
        //判断是否有子目录
        if (FileInfo.attrib & _A_SUBDIR)
        {
            //这个语句很重要
            if( (strcmp(FileInfo.name,".") != 0 ) &&(strcmp(FileInfo.name,"..") != 0))
            {
                string newPath = folderPath + "\\" + FileInfo.name;
                dfsFolder(newPath);
            }
        }
        else
        {
            string filename = (folderPath + "\\" + FileInfo.name);
            cout << folderPath << "\\" << FileInfo.name  << " " << endl;
        }
    }while (_findnext(Handle, &FileInfo) == 0);
    
    _findclose(Handle);
#else
    printf("open directory: %s\n", folderPath.c_str());
    DIR *dp;
    struct dirent *entry;
    struct stat statbuf;
    if((dp = opendir(folderPath.c_str())) == NULL) {
        fprintf(stderr,"cannot open directory: %s\n", folderPath.c_str());
        return;
    }
    chdir(folderPath.c_str());
    while((entry = readdir(dp)) != NULL) {
        lstat(entry->d_name,&statbuf);
        if(S_ISDIR(statbuf.st_mode)) {
            
            if(strcmp(".",entry->d_name) == 0 ||
               strcmp("..",entry->d_name) == 0)
                continue;
            printf("%*s%s/\n",depth," -- ",entry->d_name);
            dfsFolder(entry->d_name,depth+4 , bEnc);
        } else {
            string filename = entry->d_name;
            printf("%*s%s\n",depth," ",entry->d_name);
            
            if (bEnc) {
            	encfile(filename.c_str() , g_pwd.c_str() , (filename+"c").c_str());
            }
            else{
            	string newName = filename.substr(0, filename.length()-1);
            	decryptfile(filename.c_str() , g_pwd.c_str() , newName.c_str());
            }
                
            
        }
    }
    chdir("..");
    closedir(dp);
#endif
}

int main(int argc, char* argv[])
{
	if (argc < 4) {
		cout << "please input 3 argc";
		return 0;
	}

	string first = argv[1];
	string second = argv[2];
	string newName = argv[3];
	if (first.compare("-d") == 0){
		decryptfile(second.c_str(), g_pwd.c_str(), newName.c_str());
	}
	else if (first.compare("-e") == 0){
		encfile(second.c_str(), g_pwd.c_str(), newName.c_str());
	}
	else if (first.compare("-f") == 0){
		if (newName.compare("true") == 0) {
			dfsFolder(second.c_str() , 0 , true);
		}else{
			dfsFolder(second.c_str() , 0 , false);
		}
		
	}
	return 0;
}


