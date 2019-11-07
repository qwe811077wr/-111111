local PeerNode = class('PeerNode')

function PeerNode:ctor()
    self._nodes = {}
    self._localNode = nil
end

function PeerNode:get(sid)
    return self._nodes[sid]
end

function PeerNode:localNode()
    if not self._localNode then
        return nil
    end
    return self._nodes[self._localNode]
end

function PeerNode:getReportAddress(report_id, sid)
    if not sid or string.len(sid) == 0 or sid == '0' then
        sid = self._localNode
    end
    if not sid then
        return nil
    end
    local node = self:get(sid)
    if not node then
        return nil
    end
    return 'http://' .. node.report_address .. '/battle_report?id=' .. report_id
end

return PeerNode