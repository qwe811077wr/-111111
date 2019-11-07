
--------------------------------
-- @module EventHttpDownload
-- @extend EventCustom
-- @parent_module uq

--------------------------------
-- 
-- @function [parent=#EventHttpDownload] getLoaded 
-- @param self
-- @return float#float ret (return value: float)
        
--------------------------------
-- 
-- @function [parent=#EventHttpDownload] getDownloader 
-- @param self
-- @return HttpDownload#HttpDownload ret (return value: uq.HttpDownload)
        
--------------------------------
-- 
-- @function [parent=#EventHttpDownload] getAssetId 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- 
-- @function [parent=#EventHttpDownload] getCURLECode 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#EventHttpDownload] getTotal 
-- @param self
-- @return float#float ret (return value: float)
        
--------------------------------
-- 
-- @function [parent=#EventHttpDownload] getMessage 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- 
-- @function [parent=#EventHttpDownload] getCURLMCode 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#EventHttpDownload] getEventCode 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#EventHttpDownload] EventHttpDownload 
-- @param self
-- @param #string event_name
-- @param #uq.HttpDownload downloader
-- @param #int code
-- @param #float loaded
-- @param #float total
-- @param #string assetId
-- @param #string message
-- @param #int curle_code
-- @param #int curlm_code
-- @return EventHttpDownload#EventHttpDownload self (return value: uq.EventHttpDownload)
        
return nil
