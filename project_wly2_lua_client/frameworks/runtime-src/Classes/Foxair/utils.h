#ifndef __FOXAIR_UTILS_H__
#define __FOXAIR_UTILS_H__

#include <map>
#include <string>
#include <vector>

#include "cocos2d.h"

namespace Foxair {
    class ProtocolPacket;
    class Utils {
    public:
        static std::string md5(const std::string &str);
        static ProtocolPacket* getFileData(const std::string &path);
        static void createGrayImage(cocos2d::Image* img);
        static unsigned int getPixelColor(cocos2d::Image *img, size_t x , size_t y);
        static unsigned int getNodePixelColor(cocos2d::Node *node, size_t x , size_t y);
        static long getMilliSecond();
    };
}
#endif
