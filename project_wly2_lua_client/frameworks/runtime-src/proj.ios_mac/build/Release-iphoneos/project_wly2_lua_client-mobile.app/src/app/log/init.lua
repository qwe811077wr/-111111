require('app.log.logging')
require('app.log.config')
require('app.log.console')
require('app.log.file')
require('app.log.rolling_file')
--require('app.log.socket') --因需要将其同步到服务端，若开放，则服务端需要安装luasock
require('app.log.sql')

uq.logging = require('app.log.logging')
uq.log_config = require('app.log.config')
uq.log_console = require('app.log.console')