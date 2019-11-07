local cache = uq.cache or {}

--------------------基础信息--------------------
cache.server                = {}
cache.game_time             = {year = 184, season = 0}
cache.passwd                = ""
cache.uid                   = 0
cache.server_time           = 0
cache.client_time           = 0
cache.server_create_ts      = 0 -----服务器开服时间
cache.is_connet             = false ----是否连接
cache.enter_game            = false


function cache.initCache()
    cache.account        = {loginname="", rand_name = '', role_id=0, session_seed = 0,}
    cache.role           = require('app.cache.role'):new()
    cache.formation      = require('app.cache.formation'):new()
    cache.generals       = require('app.cache.generals'):new()
    cache.equipment      = require('app.cache.equipment'):new()
    cache.official       = require('app.cache.official'):new()
    cache.chat           = require('app.cache.chat'):new()
    cache.nodes          = require('app.cache.PeerNode'):new()
    cache.mail           = require('app.cache.mail'):new()
    cache.technology     = require('app.cache.technology'):new()
    cache.task           = require('app.cache.task'):new()
    cache.crop           = require('app.cache.crop'):new()
    cache.world          = require('app.cache.world'):new()
    --cache.area         = require('app.cache.area'):new()
    cache.rank           = require('app.cache.rank'):new()
    cache.tavern         = require('app.cache.tavern'):new()
    cache.recruit        = require('app.cache.recruit'):new()
    cache.arena          = require('app.cache.arena'):new()
    cache.ancient_city   = require('app.cache.ancientcity'):new()
    cache.trials_tower   = require('app.cache.trialsTower'):new()
    cache.illustration   = require('app.cache.illustration'):new()
    cache.athletics      = require('app.cache.athletics'):new()
    cache.instance       = require('app.cache.instance'):new()
    cache.server_data    = require('app.cache.serverData'):new()
    cache.client_data    = require('app.cache.clientData'):new()
    cache.hint_status    = require('app.cache.HintState'):new()
    cache.fly_nail       = require('app.cache.flyNail'):new()
    cache.retainer       = require('app.cache.retainer'):new()
    cache.daily_activity = require('app.cache.dailyActivity'):new()
    cache.achievement    = require('app.cache.achievement'):new()
    cache.guide          = require('app.cache.guide'):new()
    cache.level_up       = require('app.cache.levelUp'):new()
    cache.pass_check     = require('app.cache.passCheck'):new()
    cache.world_war      = require('app.cache.worldWar'):new()
    cache.random_event   = require('app.cache.RandomEvent'):new()
    cache.drill          = require('app.cache.drill'):new()
    cache.decree         = require('app.cache.decree'):new()
    cache.draft          = require('app.cache.draft'):new()
end

cache.initCache()


uq.cache = cache