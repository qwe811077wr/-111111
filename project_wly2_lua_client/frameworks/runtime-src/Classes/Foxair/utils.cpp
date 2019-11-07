#include "utils.h"

#include "crypto_helper.h"
#include "game_connection.h"

namespace Foxair {
    std::string Utils::md5(const std::string &str) {
        return Foxair::md5(str);
    }

    ProtocolPacket* Utils::getFileData(const std::string &path) {
        Data data = FileUtils::getInstance()->getDataFromFile(path);
        ProtocolPacket *ret(new ProtocolPacket);
        ret->buffer()->copyIn(data.getBytes(), data.getSize());
        return ret;
    }

    void Utils::createGrayImage(cocos2d::Image* img) {
        unsigned char* data = img->getData();
        size_t len = img->getDataLen();
        int alpha_size = img->hasAlpha() ? 1 : 0;
        for (size_t idx = 0; idx + 3 + alpha_size < len;) {
            int ibpos = idx;
            unsigned int ib = data[idx++];
            unsigned int ig = data[idx++];
            unsigned int ir = data[idx++];
            idx += alpha_size;
            unsigned int gray = 0.3 * ir + 0.4 * ig + 0.2 * ib;
            data[ibpos] = data[ibpos + 1] = data[ibpos + 2] = (unsigned char)gray;
        }
    }

    unsigned int Utils::getPixelColor(cocos2d::Image *img, size_t x, size_t y) {
        unsigned int ret = 0;
        unsigned char *pdata = img->getData();
        short pixel_size = img->hasAlpha() ? 4 : 3;
        int idx = (y * img->getWidth() + x) * pixel_size;
        if (idx + pixel_size >= img->getDataLen()) {
            return ret;
        }
        for (int i = 0; i < pixel_size; ++i) {
            ret += pdata[idx + i];
            ret <<= 8;
        }
        return ret;
    }

    unsigned int Utils::getNodePixelColor(cocos2d::Node *node, size_t x, size_t y) {
        cocos2d::Image *img = utils::captureNode(node, 1);
        return getPixelColor(img, x, y);
    }
    
    //毫秒
    long Utils::getMilliSecond() {
        struct timeval tv;
        gettimeofday(&tv, NULL);
        long millisecond = (tv.tv_sec * 1000000 + tv.tv_usec) / 1000;
        return millisecond;
    }
}
