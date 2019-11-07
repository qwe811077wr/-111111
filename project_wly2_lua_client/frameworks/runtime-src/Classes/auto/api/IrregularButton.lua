
--------------------------------
-- @module IrregularButton
-- @extend Button
-- @parent_module uq

--------------------------------
-- 
-- @function [parent=#IrregularButton] setDistanceCancelle 
-- @param self
-- @param #float distance
-- @return IrregularButton#IrregularButton self (return value: IrregularButton)
        
--------------------------------
-- 
-- @function [parent=#IrregularButton] getFileDataForLua 
-- @param self
-- @param #string filePath
-- @return string#string ret (return value: string)
        
--------------------------------
-- @overload self, string, string, string, int         
-- @overload self         
-- @function [parent=#IrregularButton] create
-- @param self
-- @param #string normalImage
-- @param #string selectedImage
-- @param #string disableImage
-- @param #int texType
-- @return IrregularButton#IrregularButton ret (return value: IrregularButton)

--------------------------------
-- 
-- @function [parent=#IrregularButton] hitTest 
-- @param self
-- @param #vec2_table pt
-- @param #cc.Camera camera
-- @param #vec3_table p
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- A callback which will be called when touch moved event is issued.<br>
-- param touch The touch info.<br>
-- param unusedEvent The touch event info.
-- @function [parent=#IrregularButton] onTouchMoved 
-- @param self
-- @param #cc.Touch touch
-- @param #cc.Event unusedEvent
-- @return IrregularButton#IrregularButton self (return value: IrregularButton)
        
--------------------------------
-- A callback which will be called when touch ended event is issued.<br>
-- param touch The touch info.<br>
-- param unusedEvent The touch event info.
-- @function [parent=#IrregularButton] onTouchEnded 
-- @param self
-- @param #cc.Touch touch
-- @param #cc.Event unusedEvent
-- @return IrregularButton#IrregularButton self (return value: IrregularButton)
        
--------------------------------
-- A callback which will be called when touch cancelled event is issued.<br>
-- param touch The touch info.<br>
-- param unusedEvent The touch event info.
-- @function [parent=#IrregularButton] onTouchCancelled 
-- @param self
-- @param #cc.Touch touch
-- @param #cc.Event unusedEvent
-- @return IrregularButton#IrregularButton self (return value: IrregularButton)
        
--------------------------------
-- A callback which will be called when touch began event is issued.<br>
-- param touch The touch info.<br>
-- param unusedEvent The touch event info.<br>
-- return True if user want to handle touches, false otherwise.
-- @function [parent=#IrregularButton] onTouchBegan 
-- @param self
-- @param #cc.Touch touch
-- @param #cc.Event unusedEvent
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#IrregularButton] IrregularButton 
-- @param self
-- @return IrregularButton#IrregularButton self (return value: IrregularButton)
        
return nil
