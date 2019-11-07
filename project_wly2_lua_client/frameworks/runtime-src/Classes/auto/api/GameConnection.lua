
--------------------------------
-- @module GameConnection
-- @extend CCObject
-- @parent_module uq

--------------------------------
-- 
-- @function [parent=#GameConnection] reset 
-- @param self
-- @param #string host
-- @param #unsigned short port
-- @return GameConnection#GameConnection self (return value: uq.GameConnection)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] readRawPacket 
-- @param self
-- @return ProtocolPacket#ProtocolPacket ret (return value: uq.ProtocolPacket)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] readRawData 
-- @param self
-- @param #uq.Buffer buffer
-- @return unsigned int#unsigned int ret (return value: unsigned int)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] readKey 
-- @param self
-- @param #string key
-- @return GameConnection#GameConnection self (return value: uq.GameConnection)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] sendProxy 
-- @param self
-- @param #uq.ProtocolPacket packet
-- @param #string proxyKey
-- @return GameConnection#GameConnection self (return value: uq.GameConnection)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] sendRawDataLua 
-- @param self
-- @param #uq.ProtocolPacket packet
-- @return unsigned int#unsigned int ret (return value: unsigned int)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] setErrorHandler 
-- @param self
-- @param #int handle
-- @return GameConnection#GameConnection self (return value: uq.GameConnection)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] getServerTime 
-- @param self
-- @return long long#long long ret (return value: long long)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] sendKey 
-- @param self
-- @param #string key
-- @return GameConnection#GameConnection self (return value: uq.GameConnection)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] start 
-- @param self
-- @return GameConnection#GameConnection self (return value: uq.GameConnection)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] getState 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] getPacket 
-- @param self
-- @return ProtocolPacket#ProtocolPacket ret (return value: uq.ProtocolPacket)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] sendPacket 
-- @param self
-- @param #uq.ProtocolPacket packet
-- @param #bool crypto
-- @return GameConnection#GameConnection self (return value: uq.GameConnection)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] close 
-- @param self
-- @return GameConnection#GameConnection self (return value: uq.GameConnection)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] readRawDataLua 
-- @param self
-- @param #int size
-- @return ProtocolPacket#ProtocolPacket ret (return value: uq.ProtocolPacket)
        
--------------------------------
-- 
-- @function [parent=#GameConnection] sendRawData 
-- @param self
-- @param #uq.Buffer buffer
-- @return unsigned int#unsigned int ret (return value: unsigned int)
        
--------------------------------
-- @overload self, int         
-- @overload self         
-- @function [parent=#GameConnection] connect
-- @param self
-- @param #int handle
-- @return int#int ret (return value: int)

--------------------------------
-- @overload self, string, unsigned short         
-- @overload self         
-- @function [parent=#GameConnection] sharedGameConnection
-- @param self
-- @param #string host
-- @param #unsigned short port
-- @return GameConnection#GameConnection ret (return value: uq.GameConnection)

--------------------------------
-- 
-- @function [parent=#GameConnection] GameConnection 
-- @param self
-- @param #string host
-- @param #unsigned short port
-- @return GameConnection#GameConnection self (return value: uq.GameConnection)
        
return nil
