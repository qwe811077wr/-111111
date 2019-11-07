#ifndef __FOXAIR_CRYPTO_HELPER_H__
#define __FOXAIR_CRYPTO_HELPER_H__

#include <string>

#include "openssl/aes.h"
#include "openssl/evp.h"
#include "openssl/hmac.h"


namespace Foxair {

struct Buffer;

// MD5
std::string md5(const std::string &str);
std::string md5sum(const std::string &str);
void encryptBuffer(Buffer &in, Buffer &out, const std::string &key);
void decryptBuffer(Buffer &in, Buffer &out, const std::string &key);
void decryptBuffer1(Buffer &in, Buffer &out, const std::string &key);

// AES
void encryptAES(bool encrypt, const unsigned char *source,
                       unsigned char *dest, unsigned int bytes, AES_KEY *key,
                       unsigned long long cbc_block);
void encryptAES1(bool encrypt, const unsigned char *source,
                unsigned char *dest, unsigned int bytes, AES_KEY *key,
                unsigned long long cbc_block);

void appendPadding(Buffer &buffer);
unsigned int stripPadding(Buffer &buffer);
    
// base64
std::string base64_encode( std::string text );
std::string base64_decode( std::string text );
    
/*
    SHA1
    安全哈希算法（Secure Hash Algorithm）
*/
std::string sha1( std::string text );

/* 
    HMAC
    哈希运算消息认证码（Hash-based Message Authentication Code）, HMAC运算利用哈希算法，以一个密钥和一个消息为输入，生成一个消息摘要作为输出。
*/
std::string hmacSha1(std::string key, std::string data);

}

#endif
