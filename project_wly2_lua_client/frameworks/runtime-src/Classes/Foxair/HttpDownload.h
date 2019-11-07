#ifndef __FOXAIR_HTTP_DOWNLOAD_H__
#define __FOXAIR_HTTP_DOWNLOAD_H__

#include "cocos2d.h"

#include "base/CCEventDispatcher.h"
#include "network/CCDownloader.h"

#include "CCLuaEngine.h"

USING_NS_CC;

namespace Foxair {
	class HttpDownload;
	class EventHttpDownload : public EventCustom {
	public:
		friend class HttpDownload;
		enum EventCode {
			ERROR_CODE_OK = 0,
			ERROR_CODE_PROGRESS = 1,
			ERROR_CODE_ERROR = 2
		};
		EventHttpDownload(const std::string &event_name, HttpDownload *downloader, const EventCode &code, float loaded = 0,
			float total = 0, const std::string& assetId = "", const std::string& message = "", int curle_code = 0, int curlm_code = 0)
			:EventCustom(event_name)
			,m_code(code)
			,m_message(message)
			, m_assetId(assetId)
			, m_curle_code(curle_code)
			, m_curlm_code(curlm_code)
			, m_downloader(downloader)
			, m_loaded(loaded)
			, m_total(total) {

		}

		EventCode getEventCode() const { return m_code; };

		int getCURLECode() const { return m_curle_code; };

		int getCURLMCode() const { return m_curlm_code; };

		std::string getMessage() const { return m_message; };

		std::string getAssetId() const { return m_assetId; };

		HttpDownload *getDownloader() const { return m_downloader;; };

		float getLoaded() const { return m_loaded; };

		float getTotal() const { return m_total; };

	private:
		EventCode m_code;
		std::string m_message;
		std::string m_assetId;
		int m_curle_code;
		int m_curlm_code;
		HttpDownload *m_downloader;
		float m_loaded;
		float m_total;
	};
	class HttpDownload : public Ref {
	public:
		HttpDownload();
		~HttpDownload();

		static HttpDownload* create();

		std::string eventName() { return m_eventName; };

		void downloadFile(const std::string &url, const std::string &storage_path, const std::string &custom_id);

	protected:
		void dispatchEvent(const std::string &event_name, const std::string &custom_id = "",
			const std::string &message = "", int loaded = 0, int total = 0);

		virtual void onError(const network::DownloadTask &task, int errorCode, int errorCodeInternal, const std::string &error_str);
		virtual void onProgress(double total, double downloaed, const std::string &url, const std::string &custom_id);
		virtual void onSuccess(const std::string &url, const std::string &storage_path, const std::string &custom_id);

		void dispatchUpdateEvent(EventHttpDownload::EventCode code, const std::string &assetId = "", const std::string &message = "",
			int curle_code = 0, int curlm_code = 0);

	private:
		float m_loaded;
		float m_total;
		std::string m_eventName;
		EventDispatcher *m_eventDispatcher;
		std::shared_ptr<network::Downloader> m_downloader;
	};
}
#endif
