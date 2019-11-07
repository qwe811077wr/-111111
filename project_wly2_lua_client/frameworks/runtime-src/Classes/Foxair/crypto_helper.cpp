#include "crypto_helper.h"

#include <openssl/md5.h>

#include <assert.h>

#include "buffer.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

#ifndef STD_MAX
#define STD_MAX(x,y) x>y?x:y
#endif // STD_MAX

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#ifndef STD_MAX
#define STD_MAX(x,y) std::max(x,y)
#endif // STD_MAX
#else

#ifndef STD_MAX
#define STD_MAX(x,y) x>y?x:y
#endif // STD_MAX

#endif

namespace Foxair {

static const unsigned int s_cbcBlockSize = 4096;
static const unsigned int s_encryptionUnitSize = 16;

std::string __hash_digest_to_hex( const unsigned char *digest, int len ){
    char hexstring[1024] = { 0 };
    int i;
    for( i=0; i<len; i++ ){
        sprintf( &hexstring[2*i], "%02x", digest[i] );
    }
    return hexstring;
}

// MD5
void encryptBuffer(Buffer &in, Buffer &out, const std::string &key) {
    AES_KEY aesKey;
    AES_set_encrypt_key((const unsigned char*)key.c_str(),
                        STD_MAX(256, (int)key.size() * 8), &aesKey);
    Buffer buffer(in);
    appendPadding(buffer);
    unsigned int sz = buffer.readAvailable();
    unsigned char *source = (unsigned char*)buffer.readBuffer(sz, true).iov_base;
    unsigned char *dest = (unsigned char*)out.writeBuffer(sz, true).iov_base;
    encryptAES(true, source, dest, sz, &aesKey, 0);
    out.produce(sz);
}

void decryptBuffer(Buffer &in, Buffer &out, const std::string &key) {
    AES_KEY aesKey;
    AES_set_decrypt_key((const unsigned char*)key.c_str(),
                        STD_MAX(256, (int)key.size() * 8), &aesKey);
    Buffer buffer(in);
    int sz = buffer.readAvailable();
    Buffer tmpBuf;
    unsigned char *source = (unsigned char*)buffer.readBuffer(sz, true).iov_base;
    unsigned char *dest = (unsigned char*)tmpBuf.writeBuffer(sz, true).iov_base;
    encryptAES(false, source, dest, sz, &aesKey, 0);
    tmpBuf.produce(sz);
    stripPadding(tmpBuf);
    out.copyIn(tmpBuf, tmpBuf.readAvailable());
}

void decryptBuffer1(Buffer &in, Buffer &out, const std::string &key) {
    AES_KEY aesKey;
    AES_set_decrypt_key((const unsigned char*)key.c_str(),
                        STD_MAX(256, (int)key.size() * 8), &aesKey);
    Buffer buffer(in);
    int sz = buffer.readAvailable();
    Buffer tmpBuf;
    unsigned char *source = (unsigned char*)buffer.readBuffer(sz, true).iov_base;
    unsigned char *dest = (unsigned char*)tmpBuf.writeBuffer(sz, true).iov_base;
    encryptAES1(false, source, dest, sz, &aesKey, 0);
    tmpBuf.produce(sz);
    stripPadding(tmpBuf);
    out.copyIn(tmpBuf, tmpBuf.readAvailable());
}

std::string md5sum(const std::string &data) {
    MD5_CTX ctx;
    MD5_Init(&ctx);
    MD5_Update(&ctx, data.data(), data.size());
    std::string result;
    result.resize(MD5_DIGEST_LENGTH);
    MD5_Final((unsigned char*)&result[0], &ctx);
    return result;
}

std::string hexstringFromData(const std::string &data) {
    if (data.empty()) {
        return std::string();
    }
    std::string ret;
    ret.resize(data.size() << 1);
    const unsigned char *buf = (const unsigned char *)data.data();
    unsigned int len = data.size();
    unsigned int i, j;
    for (i = j = 0; i < len; ++i) {
        char c;
        c = (buf[i] >> 4) & 0xf;
        c = (c > 9) ? c + 'a' - 10 : c + '0';
        ret[j++] = c;
        c = (buf[i] & 0xf);
        c = (c > 9) ? c + 'a' - 10 : c + '0';
        ret[j++] = c;
    }
    return ret;
}

std::string md5(const std::string &data) {
    return hexstringFromData(md5sum(data));
}

// AES
void encryptAES(bool encrypt, const unsigned char *source,
                              unsigned char *dest, unsigned int bytes, AES_KEY *key,
                              unsigned long long cbc_block) {
    assert(bytes % AES_BLOCK_SIZE == 0);
    int op = encrypt ? AES_ENCRYPT : AES_DECRYPT;

    while (bytes > 0) {
        unsigned int to_crypt = s_cbcBlockSize;
        if (to_crypt > bytes) {
            to_crypt = bytes;
        }

        unsigned char iv[AES_BLOCK_SIZE];
        unsigned long long *iv8 = reinterpret_cast<unsigned long long*>(iv);
        iv8[0] = 0;
        iv8[1] = cbc_block++;
        AES_cbc_encrypt(source, dest, (const unsigned long)to_crypt, key, iv, op);
        source += to_crypt;
        dest += to_crypt;
        bytes -= to_crypt;
    }
}

void encryptAES1(bool encrypt, const unsigned char *source,
                unsigned char *dest, unsigned int bytes, AES_KEY *key,
                unsigned long long cbc_block) {
    assert(bytes % AES_BLOCK_SIZE == 0);
    int op = encrypt ? AES_ENCRYPT : AES_DECRYPT;
    
    while (bytes > 0) {
        unsigned int to_crypt = bytes;
        
        unsigned char iv[AES_BLOCK_SIZE];
        unsigned long long *iv8 = reinterpret_cast<unsigned long long*>(iv);
        iv8[0] = 0;
        iv8[1] = cbc_block++;
        AES_cbc_encrypt(source, dest, (const unsigned long)to_crypt, key, iv, op);
        source += to_crypt;
        dest += to_crypt;
        bytes -= to_crypt;
    }
}

void appendPadding(Buffer &buffer) {
    unsigned char padding_byte = (unsigned char)(s_encryptionUnitSize - (buffer.readAvailable() % s_encryptionUnitSize));
    buffer.reserve(padding_byte);
    for (unsigned char i = 0; i < padding_byte; ++i) {
        buffer.copyIn(&padding_byte, 1);
    }
}

unsigned int stripPadding(Buffer &buffer) {
    unsigned int sz = buffer.readAvailable();
    if (sz < s_encryptionUnitSize) {
        return 0;
    }
    if (sz % s_encryptionUnitSize != 0) {
        return 0;
    }

    unsigned char *data = (unsigned char*)buffer.readBuffer(sz, true).iov_base;
    unsigned char padding_byte = data[sz - 1];
    if (padding_byte < 1 || padding_byte > s_encryptionUnitSize) {
        return 0;
    }
    for (unsigned int i = sz - padding_byte; i < sz - 1; ++i) {
        if (data[i] != padding_byte) {
            return 0;
        }
    }
    buffer.truncate(sz - padding_byte);
    return padding_byte;
}
    
// base64
std::string base64_encode( std::string text ){
    EVP_ENCODE_CTX ectx;
    int size = text.size() * 2;
    size = size > 64 ? size : 64;
    unsigned char* out = (unsigned char*)malloc( size );
    int outlen = 0;
    int tlen = 0;
    
    EVP_EncodeInit( &ectx );
    EVP_EncodeUpdate( &ectx, out, &outlen, (const unsigned char*)text.c_str(), text.size() );
    tlen += outlen;
    EVP_EncodeFinal( &ectx, out+tlen, &outlen );
    tlen += outlen;
    out[outlen - 1] = 0;
    
    std::string str( (char*)out, tlen);
    free( out );
    return str;
}

std::string base64_decode( std::string text ){
    EVP_ENCODE_CTX ectx;
    unsigned char* out = (unsigned char*)malloc( text.size() );
    int outlen = 0;
    int tlen = 0;
    
    EVP_DecodeInit( &ectx );
    EVP_DecodeUpdate( &ectx, out, &outlen, (const unsigned char*)text.c_str(), text.size() );
    tlen += outlen;
    EVP_DecodeFinal( &ectx, out+tlen, &outlen );
    tlen += outlen;
    
    std::string data( (char*)out, tlen );
    free( out );
    return data;
}
    
// SHA1
std::string sha1( std::string text ){
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
std::string hmacSha1(std::string key, std::string data)
{
    unsigned char* digest = HMAC(EVP_sha1(), key.c_str(), key.size(), (const unsigned char *)data.c_str(), data.size(), NULL, NULL);
    
    return __hash_digest_to_hex(digest, 20);
}

}
