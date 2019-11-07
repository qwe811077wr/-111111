#ifndef __FOXAIR_COMMONS_H__
#define __FOXAIR_COMMONS_H__

#include "cocos2d.h"
#include <string>

#include <algorithm>
#include <sstream>

class Commons:public cocos2d::Ref{
    public:
        Commons();
        ~Commons();
    
    static std::string& trimChar(std::string &s,char c);
    // base64
    static std::string base64_encode( std::string text );
    static std::string base64_decode( std::string text );
    
    /*
     SHA1
     安全哈希算法（Secure Hash Algorithm）
     */
    static std::string sha1( std::string text );
    
    /*
     HMAC
     哈希运算消息认证码（Hash-based Message Authentication Code）, HMAC运算利用哈希算法，以一个密钥和一个消息为输入，生成一个消息摘要作为输出。
     */
    static std::string hmacSha1(std::string key, std::string data);

	static bool unzip(std::string &zip, const std::string &dst_dir);
    
    static std::string md5(const std::string &str);
};
#endif