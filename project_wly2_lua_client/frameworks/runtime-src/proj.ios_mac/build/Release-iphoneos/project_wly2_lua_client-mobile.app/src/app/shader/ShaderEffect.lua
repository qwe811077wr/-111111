--本文来自 夜色魅影 的CSDN 博客 ，全文地址请点击：https://blog.csdn.net/u010223072/article/details/49640147?utm_source=copy

local ShaderEffect = {
    vertDefaultSource = "\n"..
    "attribute vec4 a_position; \n" ..
    "attribute vec2 a_texCoord; \n" ..
    "attribute vec4 a_color; \n"..
    "#ifdef GL_ES  \n"..
    "varying lowp vec4 v_fragmentColor;\n"..
    "varying mediump vec2 v_texCoord;\n"..
    "#else                      \n" ..
    "varying vec4 v_fragmentColor; \n" ..
    "varying vec2 v_texCoord;  \n"..
    "#endif    \n"..
    "void main() \n"..
    "{\n" ..
    "gl_Position = CC_PMatrix * a_position; \n"..
    "v_fragmentColor = a_color;\n"..
    "v_texCoord = a_texCoord;\n"..
    "}",

    pszFragSource2 = "#ifdef GL_ES \n" ..
    "precision mediump float; \n" ..
    "#endif \n" ..
    "uniform sampler2D u_texture; \n" ..
    "varying vec2 v_texCoord; \n" ..
    "varying vec4 v_fragmentColor;\n"..
    "uniform vec2 pix_size;\n"..
    "void main(void) \n" ..
    "{ \n" ..
    "vec4 sum = vec4(0, 0, 0, 0); \n" ..
    "sum += texture2D(u_texture, v_texCoord - 4.0 * pix_size) * 0.05;\n"..
    "sum += texture2D(u_texture, v_texCoord - 3.0 * pix_size) * 0.09;\n"..
    "sum += texture2D(u_texture, v_texCoord - 2.0 * pix_size) * 0.12;\n"..
    "sum += texture2D(u_texture, v_texCoord - 1.0 * pix_size) * 0.15;\n"..
    "sum += texture2D(u_texture, v_texCoord                 ) * 0.16;\n"..
    "sum += texture2D(u_texture, v_texCoord + 1.0 * pix_size) * 0.15;\n"..
    "sum += texture2D(u_texture, v_texCoord + 2.0 * pix_size) * 0.12;\n"..
    "sum += texture2D(u_texture, v_texCoord + 3.0 * pix_size) * 0.09;\n"..
    "sum += texture2D(u_texture, v_texCoord + 4.0 * pix_size) * 0.05;\n"..
    "gl_FragColor = sum;\n"..
    "}",

    --变灰
    psGrayShader = "#ifdef GL_ES \n" ..
    "precision mediump float; \n" ..
    "#endif \n" ..
    "varying vec4 v_fragmentColor; \n" ..
    "varying vec2 v_texCoord; \n" ..
    "void main(void) \n" ..
    "{ \n" ..
    "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
    "gl_FragColor.xyz = vec3(0.35*c.r + 0.35*c.g + 0.35*c.b); \n"..
    "gl_FragColor.w = c.w; \n"..
    "}" ,

    --移除变灰
    psRemoveGrayShader = "#ifdef GL_ES \n" ..
    "precision mediump float; \n" ..
    "#endif \n" ..
    "varying vec4 v_fragmentColor; \n" ..
    "varying vec2 v_texCoord; \n" ..
    "void main(void) \n" ..
    "{ \n" ..
    "gl_FragColor = texture2D(CC_Texture0, v_texCoord); \n" ..
    "}" ,

    psFlashShader = "#ifdef GL_ES \n" ..
    "precision mediump float; \n" ..
    "#endif \n" ..
    "varying vec4 v_fragmentColor; \n" ..
    "varying vec2 v_texCoord; \n" ..
    "void main(void) \n" ..
    "{ \n" ..
    "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
    "gl_FragColor.xyz = vec3(%f*c.r + %f*c.g + %f*c.b); \n"..
    "gl_FragColor.w = c.w; \n"..
    "}" ,

    psHightShader = "varying vec4 v_fragmentColor; \n" ..
    "varying vec2 v_texCoord; \n" ..
    "//unifor m sampler2D CC_Texture0; \n" ..
    "void main() \n" ..
    "{ \n" ..
    "vec4 v_orColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);\n" ..
    "gl_FragColor = vec4(v_orColor.r+0.4, v_orColor.g+0.4, v_orColor.b+0.4, v_orColor.a);\n}",

    psHightShaderRemove = "varying vec4 v_fragmentColor; \n" ..
    "varying vec2 v_texCoord; \n" ..
    "//unifor m sampler2D CC_Texture0; \n" ..
    "void main() \n" ..
    "{ \n" ..
    "vec4 v_orColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);\n" ..
    "gl_FragColor = vec4(v_orColor.r, v_orColor.g, v_orColor.b, v_orColor.a);\n}"
}

function ShaderEffect:init()
end

function ShaderEffect:addSharpenEffect(node)
    local sharpen_program = cc.GLProgramCache:getInstance():getGLProgram("SharpenEffect")
    if not sharpen_program then
        local file_utils = cc.FileUtils:getInstance()
        local vert_source = file_utils:getStringFromFile("app/shader/ccFilterShader_sharpen_vert.h")
        local frag_source = file_utils:getStringFromFile("app/shader/ccFilterShader_sharpen_frag.h")
        sharpen_program = cc.GLProgram:createWithByteArrays(vert_source, frag_source)

        sharpen_program:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
        sharpen_program:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
        sharpen_program:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)

        sharpen_program:link()
        sharpen_program:use()
        sharpen_program:updateUniforms()
        cc.GLProgramCache:getInstance():addGLProgram(sharpen_program, "SharpenEffect")
    end
    node:setGLProgram(sharpen_program)
    local size = node:getTexture():getContentSizeInPixels()
    --node:getGLProgramState():setUniformFloat(4, sharp)
    node:getGLProgramState():setUniformFloat(5, size.width)
    node:getGLProgramState():setUniformFloat(6, size.height)
end

function ShaderEffect:addHightLightNode(node)
    --高亮
    local pProgram = cc.GLProgramCache:getInstance():getGLProgram("pHightLightProgram")
    if not pProgram then
        pProgram = cc.GLProgram:createWithByteArrays(self.vertDefaultSource, self.psHightShader)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
        pProgram:link()
        pProgram:use()
        pProgram:updateUniforms()
        cc.GLProgramCache:getInstance():addGLProgram(pProgram, "pHightLightProgram")
    end
    node:setGLProgram(pProgram)
end

function ShaderEffect:addGrayNode(node)
    --变灰的
    local pProgram = cc.GLProgramCache:getInstance():getGLProgram("pGrayProgram")
    if not pProgram then
        pProgram = cc.GLProgram:createWithByteArrays(self.vertDefaultSource, self.psGrayShader)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
        pProgram:link()
        pProgram:use()
        pProgram:updateUniforms()
        cc.GLProgramCache:getInstance():addGLProgram(pProgram, "pGrayProgram")
    end
    node:setGLProgram(pProgram)
end

function ShaderEffect:removeGrayNode(node)
    local pProgram = cc.GLProgramCache:getInstance():getGLProgram("RemoveGrayProgram")
    if not pProgram then
        pProgram = cc.GLProgram:createWithByteArrays(self.vertDefaultSource,self.psRemoveGrayShader)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
        pProgram:link()
        pProgram:use()
        pProgram:updateUniforms()
        cc.GLProgramCache:getInstance():addGLProgram(pProgram, "RemoveGrayProgram")
    end

    node:setGLProgram(pProgram)
end

function ShaderEffect:removeHightLight(node)
    local pProgram = cc.GLProgramCache:getInstance():getGLProgram("RemoveHightLightProgram")
    if not pProgram then
        pProgram = cc.GLProgram:createWithByteArrays(self.vertDefaultSource, self.psHightShaderRemove)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
        pProgram:link()
        pProgram:use()
        pProgram:updateUniforms()
        cc.GLProgramCache:getInstance():addGLProgram(pProgram, "RemoveHightLightProgram")
    end

    node:setGLProgram(pProgram)
end

function ShaderEffect:AddBlur(node)
    local fileUtiles = cc.FileUtils:getInstance()
    local vertSource = self.vertDefaultSource
    local fragSource = fileUtiles:getStringFromFile("shaders/example_Blur.fsh")
    local pProgram = cc.GLProgram:createWithByteArrays(vertSource, fragSource)
    node:setGLProgram(pProgram)
    --local glprogramstate = cc.GLProgramState:getOrCreateWithGLProgram(pProgram)
    local size = node:getTexture():getContentSizeInPixels()
    node:getGLProgramState():setUniformVec2("pix_size", size)
    node:getGLProgramState():setUniformFloat("blurRadius", 20.0);
    node:getGLProgramState():setUniformFloat("sampleNum", 0.1);
--
--    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
--    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
--    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:use()
    pProgram:updateUniforms()
end

-- 按钮置灰
function ShaderEffect:addGrayButton(button)
    if button == nil then
        uq.log("param can't be nil")
        return
    end
    -- 遍历按钮的子节点
    --[[local children = button:getChildren()
    if children and #children>0 then
        for _, aSprite in ipairs(children) do
            if aSprite.getVirtualRenderer then
                self:addGrayNode(aSprite:getVirtualRenderer():getSprite())
            elseif aSprite.setGLProgram then
                self:addGrayNode(aSprite)
            end
        end
    end
    ]]
    -- 按钮本身
    button:setBright(true)
    button:getVirtualRenderer():setState(1)
end

-- 按钮返回正常
function ShaderEffect:removeGrayButton(button)
    if button == nil then
        uq.log("param can't be nil")
        return
    end
    -- 按钮本身
    button:setBright(false)
    button:getVirtualRenderer():setState(0)
end

function ShaderEffect:setGrayEffect(effect_node, program, flag)
    if effect_node:getDescription() == 'ImageView' then
        if flag then
            effect_node:setBright(true)
            effect_node:getVirtualRenderer():setState(1)
        else
            effect_node:setBright(false)
            effect_node:getVirtualRenderer():setState(0)
        end
    else
        effect_node:setGLProgram(program)
    end
end

--遍历变灰
function ShaderEffect:setGrayAndChild(node, isNotRecursive)
    if node == nil then
        return
    end

    local pGrayProgram = cc.GLProgramCache:getInstance():getGLProgram("pGrayProgram")
    if not pGrayProgram then
        pGrayProgram = cc.GLProgram:createWithByteArrays(self.vertDefaultSource,self.psGrayShader)
        pGrayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
        pGrayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
        pGrayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
        pGrayProgram:link()
        pGrayProgram:use()
        pGrayProgram:updateUniforms()
        cc.GLProgramCache:getInstance():addGLProgram(pGrayProgram, "pGrayProgram")
    end

    self:setGrayEffect(node, pGrayProgram, true)

    local array = node:getChildren()
    for key, var in pairs(array) do
        self:setGrayEffect(var, pGrayProgram, true)
    end
    if isNotRecursive ~= true then
        --children
        local array = node:getChildren()
        for key, var in pairs(array) do
            self:setGrayEffect(var, pGrayProgram, true)
        end
    end
end

--遍历取消变灰
function ShaderEffect:setRemoveGrayAndChild(node, isNotRecursive)
    if node == nil then
        return
    end

    local pRemoveGrayProgram = cc.GLProgramCache:getInstance():getGLProgram("RemoveGrayProgram")
    if not pRemoveGrayProgram then
        pRemoveGrayProgram = cc.GLProgram:createWithByteArrays(self.vertDefaultSource, self.psRemoveGrayShader)
        pRemoveGrayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
        pRemoveGrayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
        pRemoveGrayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
        pRemoveGrayProgram:link()
        pRemoveGrayProgram:use()
        pRemoveGrayProgram:updateUniforms()
        cc.GLProgramCache:getInstance():addGLProgram(pRemoveGrayProgram, "RemoveGrayProgram")
    end

    self:setGrayEffect(node, pRemoveGrayProgram, false)

    local array = node:getChildren()
    for key, var in pairs(array) do
        self:setGrayEffect(var, pRemoveGrayProgram, false)
    end

    if isNotRecursive ~= true then
        local array = node:getChildren()
        for key, var in pairs(array) do
            self:setGrayEffect(var, pRemoveGrayProgram, false)
        end
    end
end

--Flash
function ShaderEffect:setFlashAndChild(node, isNotRecursive, flash_num)
    flash_num = flash_num or 1.0
    if node == nil then
        return
    end

    local pFlashProgram = cc.GLProgram:createWithByteArrays(self.vertDefaultSource, string.format(self.psFlashShader, flash_num, flash_num, flash_num))
    pFlashProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pFlashProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pFlashProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pFlashProgram:link()
    pFlashProgram:use()
    pFlashProgram:updateUniforms()

    node:setGLProgram(pFlashProgram)

    local array = node:getChildren()
    for key, var in pairs(array) do
        var:setGLProgram(pFlashProgram)
    end
    if isNotRecursive ~= true then
        --children
        local array = node:getChildren()
        for key, var in pairs(array) do
            self:setFlashAndChild(var)
        end
    end
end

function ShaderEffect:setRemoveFlashAndChild(node, isNotRecursive)
    if node == nil then
        return
    end

    local pRemoveFlashProgram = cc.GLProgramCache:getInstance():getGLProgram("pRemoveFlashProgram")
    if not pRemoveFlashProgram then
        pRemoveFlashProgram = cc.GLProgram:createWithByteArrays(self.vertDefaultSource, self.psRemoveGrayShader)
        pRemoveFlashProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
        pRemoveFlashProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
        pRemoveFlashProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
        pRemoveFlashProgram:link()
        pRemoveFlashProgram:use()
        pRemoveFlashProgram:updateUniforms()
        cc.GLProgramCache:getInstance():addGLProgram(pRemoveFlashProgram, "pRemoveFlashProgram")
    end

    local array = node:getChildren()
    for key, var in pairs(array) do
        var:setGLProgram(pRemoveFlashProgram)
    end

    if isNotRecursive ~= true then
        local array = node:getChildren()
        for key, var in pairs(array) do
            self:setRemoveFlashAndChild(var)
        end
    end
end

ShaderEffect:init()

return ShaderEffect