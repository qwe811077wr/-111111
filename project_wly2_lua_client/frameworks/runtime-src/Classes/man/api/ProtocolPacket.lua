
--------------------------------
-- @module ProtocolPacket
-- @parent_module uq

--------------------------------
-- 
-- @function [parent=#ProtocolPacket] readUChar 
-- @param self
-- @return unsigned char#unsigned char ret (return value: unsigned char)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] writeString 
-- @param self
-- @param #string str
-- @param #int len
-- @return ProtocolPacket#ProtocolPacket self (return value: uq.ProtocolPacket)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] writeShort 
-- @param self
-- @param #short val
-- @return ProtocolPacket#ProtocolPacket self (return value: uq.ProtocolPacket)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] readLongLong 
-- @param self
-- @return long long#long long ret (return value: long long)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] readUShort 
-- @param self
-- @return unsigned short#unsigned short ret (return value: unsigned short)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] readUInt 
-- @param self
-- @return unsigned int#unsigned int ret (return value: unsigned int)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] size 
-- @param self
-- @return unsigned int#unsigned int ret (return value: unsigned int)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] readFloat 
-- @param self
-- @return float#float ret (return value: float)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] writeDouble 
-- @param self
-- @param #double val
-- @return ProtocolPacket#ProtocolPacket self (return value: uq.ProtocolPacket)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] readBuffer 
-- @param self
-- @param #uq.ProtocolPacket packet
-- @param #int size
-- @return ProtocolPacket#ProtocolPacket self (return value: uq.ProtocolPacket)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] buffer 
-- @param self
-- @return Buffer#Buffer ret (return value: uq.Buffer)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] writeFloat 
-- @param self
-- @param #float val
-- @return ProtocolPacket#ProtocolPacket self (return value: uq.ProtocolPacket)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] subShort 
-- @param self
-- @param #unsigned int pos
-- @return short#short ret (return value: short)
        
--------------------------------
-- @overload self, int         
-- @overload self         
-- @function [parent=#ProtocolPacket] type
-- @param self
-- @param #int val
-- @return ProtocolPacket#ProtocolPacket self (return value: uq.ProtocolPacket)

--------------------------------
-- 
-- @function [parent=#ProtocolPacket] readShort 
-- @param self
-- @return short#short ret (return value: short)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] writeChar 
-- @param self
-- @param #char ch
-- @return ProtocolPacket#ProtocolPacket self (return value: uq.ProtocolPacket)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] subChar 
-- @param self
-- @param #unsigned int pos
-- @return char#char ret (return value: char)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] readInt 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] readReportData 
-- @param self
-- @param #char filename
-- @param #bool is_zip
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] readChar 
-- @param self
-- @return char#char ret (return value: char)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] readDouble 
-- @param self
-- @return double#double ret (return value: double)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] readString 
-- @param self
-- @param #unsigned int size
-- @return string#string ret (return value: string)
        
--------------------------------
-- 合并中间包，像装备，邮件，待合并的包头应该有2个字节的长度
-- @function [parent=#ProtocolPacket] concat 
-- @param self
-- @param #uq.ProtocolPacket packet
-- @param #int size
-- @return ProtocolPacket#ProtocolPacket self (return value: uq.ProtocolPacket)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] writeLongLong 
-- @param self
-- @param #long long val
-- @return ProtocolPacket#ProtocolPacket self (return value: uq.ProtocolPacket)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] readLLongString 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] del 
-- @param self
-- @return ProtocolPacket#ProtocolPacket self (return value: uq.ProtocolPacket)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] writeInt 
-- @param self
-- @param #int val
-- @return ProtocolPacket#ProtocolPacket self (return value: uq.ProtocolPacket)
        
--------------------------------
-- 
-- @function [parent=#ProtocolPacket] ProtocolPacket 
-- @param self
-- @return ProtocolPacket#ProtocolPacket self (return value: uq.ProtocolPacket)
        
return nil
