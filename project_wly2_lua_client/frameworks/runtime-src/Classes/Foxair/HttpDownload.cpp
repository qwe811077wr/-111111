#include "HttpDownload.h"

#include "base/CCDirector.h"

namespace Foxair {
	HttpDownload::HttpDownload() {
		m_eventDispatcher = Director::getInstance()->getEventDispatcher();
		m_downloader = std::shared_ptr<network::Downloader>(new network::Downloader);
		m_downloader->onTaskError = bind(&HttpDownload::onError, this, std::placeholders::_1,
			std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
		m_downloader->onTaskProgress = [this](const network::DownloadTask& task, int64_t bytesReceived,
			int64_t totalBytesReceived, int64_t totalBytesExpected) {
			this->onProgress(totalBytesExpected, totalBytesReceived, task.requestURL, task.identifier);
		};
		m_downloader->onFileTaskSuccess = [this](const network::DownloadTask &task) {
			this->onSuccess(task.requestURL, task.storagePath, task.identifier);
		};
		std::stringstream ss;
		ss << "__foxair_http_download__" << this;
		m_eventName = ss.str();
		m_loaded = 0;
		m_total = 1;
	}

	void HttpDownload::downloadFile(const std::string &url, const std::string &storage_path, const std::string &custom_id) {
		m_downloader->createDownloadFileTask(url, storage_path, custom_id);
	}

	void HttpDownload::onError(const network::DownloadTask &task, int errorCode, int errorCodeInternal, const std::string &error_str) {
		dispatchUpdateEvent(EventHttpDownload::EventCode::ERROR_CODE_ERROR, task.identifier, error_str, errorCode, errorCodeInternal);
	}

	void HttpDownload::onProgress(double total, double downloaed, const std::string &url, const std::string &custom_id) {
		m_loaded = downloaed;
		m_total = total;
		dispatchUpdateEvent(EventHttpDownload::EventCode::ERROR_CODE_PROGRESS, custom_id);
	}

	void HttpDownload::onSuccess(const std::string &url, const std::string &storage_path, const std::string &custom_id) {
		if (m_total <= 0) {
			m_total = 1;
		}
		m_loaded = m_total;
		dispatchUpdateEvent(EventHttpDownload::EventCode::ERROR_CODE_OK, custom_id);
	}

	void HttpDownload::dispatchUpdateEvent(EventHttpDownload::EventCode code, const std::string &assetId, const std::string &message, int curle_code, int curlm_code) {
		EventHttpDownload event(m_eventName, this, code, m_loaded, m_total, assetId, message, curle_code, curlm_code);
		m_eventDispatcher->dispatchEvent(&event);
	}
	
	HttpDownload* HttpDownload::create() {
		HttpDownload *ret = new(std::nothrow) HttpDownload;
		if (!ret) {			
			CC_SAFE_DELETE(ret);
		}
		return ret;
	}

	HttpDownload::~HttpDownload() {
		m_downloader->onTaskError = (nullptr);
		m_downloader->onFileTaskSuccess = (nullptr);
		m_downloader->onTaskProgress = (nullptr);
	}
}