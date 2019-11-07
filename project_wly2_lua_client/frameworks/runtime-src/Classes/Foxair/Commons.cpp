#include "Commons.h"
#include "CCLuaEngine.h"
#include <openssl/bio.h>
#include <openssl/buffer.h>
#include <openssl/evp.h>
#include <openssl/hmac.h>
#include <openssl/sha.h>

#ifdef MINIZIP_FROM_SYSTEM
#include <minizip/unzip.h>
#else // from our embedded sources
#include "unzip/unzip.h"
#endif

#include "crypto_helper.h"

#define BUFFER_SIZE    8192
#define MAX_FILENAME   512

using namespace cocos2d;


Commons::Commons(){
}

Commons::~Commons(){
}

std::string& Commons::trimChar(std::string &s,char c){
    if (s.empty())
    {
        return s;
    }
    int i=0;
    while(i<s.length())
    {
        if(s[i]==c)
        {
            s.erase(i,1);
            i--;
        }
        i++;
    }
    return s;
}


std::string __hash_digest_to_hex( const unsigned char *digest, int len ){
    char hexstring[1024] = { 0 };
    int i;
    for( i=0; i<len; i++ ){
        sprintf( &hexstring[2*i], "%02x", digest[i] );
    }
    return hexstring;
}
    
// base64
std::string Commons::base64_encode( std::string text ){
    EVP_ENCODE_CTX ectx;
    int size = (int)(text.size() * 2);
    size = size > 64 ? size : 64;
    unsigned char* out = (unsigned char*)malloc( size );
    int outlen = 0;
    int tlen = 0;
    
    EVP_EncodeInit( &ectx );
    EVP_EncodeUpdate( &ectx, out, &outlen, (const unsigned char*)text.c_str(), (int)text.size() );
    tlen += outlen;
    EVP_EncodeFinal( &ectx, out+tlen, &outlen );
    tlen += outlen;
    out[outlen - 1] = 0;
    
    std::string str( (char*)out, tlen);
    free( out );
    return Commons::trimChar(str,'\n');
}

std::string Commons::base64_decode( std::string text ){
    EVP_ENCODE_CTX ectx;
    unsigned char* out = (unsigned char*)malloc( text.size() );
    int outlen = 0;
    int tlen = 0;
    
    EVP_DecodeInit( &ectx );
    EVP_DecodeUpdate( &ectx, out, &outlen, (const unsigned char*)text.c_str(), (int)text.size() );
    tlen += outlen;
    EVP_DecodeFinal( &ectx, out+tlen, &outlen );
    tlen += outlen;
    
    std::string data( (char*)out, tlen );
    free( out );
    
    return Commons::trimChar(data,'\n');
}

// SHA1
std::string Commons::sha1( std::string text ){
    EVP_MD_CTX mdctx;
    unsigned char md_value[EVP_MAX_MD_SIZE];
    unsigned int md_len;
    
    EVP_DigestInit( &mdctx, EVP_sha1() );
    EVP_DigestUpdate( &mdctx, text.c_str(), text.size() );
    EVP_DigestFinal_ex( &mdctx, md_value, &md_len );
    EVP_MD_CTX_reset( &mdctx );
    
    return __hash_digest_to_hex( md_value, md_len );
}

// HMAC
std::string Commons::hmacSha1(std::string key, std::string data)
{
    unsigned char* digest = HMAC(EVP_sha1(), key.c_str(), (int)key.size(), (const unsigned char *)data.c_str(), data.size(), NULL, NULL);
    std::string resStr = __hash_digest_to_hex(digest, 20);
    
    return __hash_digest_to_hex(digest, 20);
}

/*
std::string basename(const std::string& path)
{
	size_t found = path.find_last_of("/\\");

	if (std::string::npos != found)
	{
		return path.substr(0, found);
	}
	else
	{
		return path;
	}
}*/
std::string& replace_all_string(std::string& str, const std::string& old_value, const std::string& new_value)
{
	for (std::string::size_type pos(0); pos != std::string::npos; pos += new_value.length())   {
		if ((pos = str.find(old_value, pos)) != std::string::npos)
            str.replace(pos, old_value.length(), new_value);
        else   break;

	}
    return   str;
}

bool Commons::unzip(std::string &zip, const std::string &dst_dir)
{
	CCLOG("Commons::unzip(): %s.----------------------------------------------", zip.c_str());
	// Find root path for zip file
	size_t pos = zip.find_last_of("/\\");
	if (pos == std::string::npos)
	{
		CCLOG("Commons::unzip() : no root path specified for zip file %s\n", zip.c_str());
		return false;
	}
	const std::string rootPath = dst_dir;
	if (rootPath.empty()) {
		return false;
	}

	// Open the zip file
	unzFile zipfile = unzOpen(zip.c_str());
	if (!zipfile)
	{
		CCLOG("Commons::unzip() : can not open downloaded zip file %s\n", zip.c_str());
		return false;
	}

	// Get info about the zip file
	unz_global_info global_info;
	if (unzGetGlobalInfo(zipfile, &global_info) != UNZ_OK)
	{
		CCLOG("Commons::unzip() : can not read file global info of %s\n", zip.c_str());
		unzClose(zipfile);
		return false;
	}

	// Buffer to hold data read from the zip file
	char readBuffer[BUFFER_SIZE];
	// Loop to extract all files.
	uLong i;
	for (i = 0; i < global_info.number_entry; ++i)
	{
		// Get info about current file.
		unz_file_info fileInfo;
		char fileName[MAX_FILENAME];
		if (unzGetCurrentFileInfo(zipfile,
			&fileInfo,
			fileName,
			MAX_FILENAME,
			NULL,
			0,
			NULL,
			0) != UNZ_OK)
		{
			CCLOG("Commons::unzip() : can not read compressed file info\n");
			unzClose(zipfile);
			return false;
		}
		const size_t filenameLength = strlen(fileName);
		std::string tmpFile = fileName;
		tmpFile = replace_all_string(tmpFile, "\\", "/");

		for (int k = 0; k < filenameLength; k++) {
			if (fileName[k] == '/' || fileName[k] == '\\') {
				std::string path = rootPath + tmpFile.substr(0, k);

				//CCLOG("Commons::unzip() : create directory %s", path.c_str());
				if (!FileUtils::getInstance()->createDirectory(path)) {

					// Failed to create directory
					CCLOG("Commons::unzip() : can not create directory %s", path.c_str());
					unzClose(zipfile);
					return false;
				}
			}
		}
		const std::string fullPath = rootPath + tmpFile;


		// Check if this entry is a directory or a file.
		if (fileName[filenameLength - 1] == '/' || fileName[filenameLength - 1] == '\\')
		{
			//There are not directory entry in some case.
			//So we need to create directory when decompressing file entry
			/*if (!FileUtils::getInstance()->createDirectory(basename(fullPath)))
			{
				// Failed to create directory
				CCLOG("Commons::unzip() : can not create directory %s\n", fullPath.c_str());
				unzClose(zipfile);
				return false;
			}*/
		}
		else
		{
			CCLOG("Commons::unzip() : unzip file = %s", tmpFile.c_str());
			// Entry is a file, so extract it.
			// Open current file.
			if (unzOpenCurrentFile(zipfile) != UNZ_OK)
			{
				CCLOG("Commons::unzip() : can not extract file %s\n", tmpFile.c_str());
				unzClose(zipfile);
				return false;
			}

			// Create a file to store current file.
			FILE *out = fopen(fullPath.c_str(), "wb");
			if (!out)
			{
				CCLOG("Commons::unzip() : can not create decompress destination file %s\n", fullPath.c_str());
				unzCloseCurrentFile(zipfile);
				unzClose(zipfile);
				return false;
			}

			// Write current file content to destinate file.
			int error = UNZ_OK;
			do
			{
				error = unzReadCurrentFile(zipfile, readBuffer, BUFFER_SIZE);
				if (error < 0)
				{
					CCLOG("Commons::unzip() : can not read zip file %s, error code is %d\n", fileName, error);
					fclose(out);
					unzCloseCurrentFile(zipfile);
					unzClose(zipfile);
					return false;
				}

				if (error > 0)
				{
					fwrite(readBuffer, error, 1, out);
				}
			} while (error > 0);

			fclose(out);
		}

		unzCloseCurrentFile(zipfile);

		// Goto next entry listed in the zip file.
		if ((i + 1) < global_info.number_entry)
		{
			if (unzGoToNextFile(zipfile) != UNZ_OK)
			{
				CCLOG("Commons::unzip() : can not read next file for decompressing\n");
				unzClose(zipfile);
				return false;
			}
		}
	}

	unzClose(zipfile);
	CCLOG("Commons::unzip() success.---------------------------");
	return true;
}

std::string Commons::md5(const std::string &str){
    return Foxair::md5(str);
}
