local sys = require "luci.sys"

m = SimpleForm("logview", "", "")
m.submit = false
m.reset = false

-- 创建一个 section 来容纳所有内容
s = m:section(SimpleSection, nil, nil)

-- 添加控制按钮区域
control_section = s:option(DummyValue, "_control", "")
control_section.rawhtml = true
control_section.cfgvalue = function()
    return [[
    <div style="margin-bottom: 5px; display: flex; align-items: center; gap: 10px;">
        <div style="display: flex; align-items: center;">
            <input type="checkbox" id="auto_refresh" checked>
            <label for="auto_refresh" style="margin-left: 5px;">自动刷新</label>
        </div>
        <button type="button" id="clear_log" style="background-color: #FFA500; color: #fff; border: 1px solid #CC8400; padding: 4px 12px; border-radius: 3px; cursor: pointer; font-weight: bold;">
            清除日志
        </button>
    </div>
    ]]
end

-- 添加日志显示
log_view = s:option(TextValue, "log_content")
log_view.rows = 25
log_view.readonly = true
log_view.wrap = "off"

function log_view.cfgvalue()
    -- 获取当前时间戳（用于比较）
    local current_time = os.time()
    
    -- 检查是否有清除时间戳
    local clear_time_file = io.open("/tmp/msd_lite_clear_time", "r")
    local filter_cmd = "logread | grep -E 'msd_lite|Multi stream daemon lite' | tail -50"
    
    if clear_time_file then
        local clear_time_str = clear_time_file:read("*a")
        clear_time_file:close()
        
        if clear_time_str and clear_time_str ~= "" then
            clear_time_str = clear_time_str:gsub("\n", "")
            
            -- 使用更精确的方法过滤日志
            -- 先获取所有日志，然后在Lua中进行时间比较
            local all_logs = sys.exec("logread | grep -E 'msd_lite|Multi stream daemon lite'")
            local filtered_logs = ""
            
            if all_logs and all_logs ~= "" then
                for line in all_logs:gmatch("[^\r\n]+") do
                    -- 提取日志行的时间戳部分
                    local timestamp = line:match("^([A-Za-z]+%s+[A-Za-z]+%s+%d+%s+%d+:%d+:%d+%s+%d+)")
                    
                    -- 如果时间戳存在且晚于清除时间，则保留该行
                    if timestamp then
                        -- 将时间戳转换为可比较的格式
                        local log_time = os.time({
                            year = timestamp:match("%d+$"),
                            month = ({Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12})[timestamp:match("%a+", 5)],
                            day = timestamp:match("%d+", 9),
                            hour = timestamp:match("(%d+):%d+:%d+", 12),
                            min = timestamp:match("%d+:(%d+):%d+", 12),
                            sec = timestamp:match("%d+:%d+:(%d+)", 12)
                        })
                        
                        local clear_time = tonumber(clear_time_str)
                        
                        if log_time and clear_time and log_time > clear_time then
                            filtered_logs = filtered_logs .. line .. "\n"
                        end
                    end
                end
                
                -- 只取最后50行
                local line_count = 0
                local lines = {}
                for line in filtered_logs:gmatch("[^\r\n]+") do
                    table.insert(lines, line)
                end
                
                -- 从后往前取最多50行
                local result = ""
                local start_idx = math.max(1, #lines - 49)
                for i = start_idx, #lines do
                    result = result .. lines[i] .. "\n"
                end
                
                return result ~= "" and result or "暂无日志（清除后）"
            end
        end
    end
    
    local logs = sys.exec(filter_cmd)
    return logs or "暂无日志"
end

-- 添加 JavaScript
js = s:option(DummyValue, "_javascript")
js.rawhtml = true
js.cfgvalue = function()
    return [[
    <script type="text/javascript">
    // 自动滚动到底部功能
    function scrollToBottom() {
        var textareas = document.getElementsByTagName('textarea');
        for (var i = 0; i < textareas.length; i++) {
            if (textareas[i].readOnly && textareas[i].rows == 25) {
                textareas[i].scrollTop = textareas[i].scrollHeight;
                break;
            }
        }
    }
    
    var refreshInterval;
    
    // 初始化自动刷新
    function initAutoRefresh() {
        var autoRefreshCheckbox = document.getElementById('auto_refresh');
        if (autoRefreshCheckbox.checked) {
            refreshInterval = setInterval(function() {
                window.location.reload();
            }, 10000);
        }
    }
    
    // 清除日志功能
    function setupClearLog() {
        var clearBtn = document.getElementById('clear_log');
        clearBtn.onclick = function() {
            if (confirm('确定要清除 MSD Lite 日志吗？此操作将隐藏所有当前日志，只显示新产生的日志。')) {
                // 创建并提交清除日志的表单
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = window.location.href;
                
                var input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'clear_log';
                input.value = '1';
                form.appendChild(input);
                
                document.body.appendChild(form);
                form.submit();
            }
        };
    }
    
    // 设置自动刷新切换
    function setupAutoRefreshToggle() {
        var autoRefreshCheckbox = document.getElementById('auto_refresh');
        autoRefreshCheckbox.onchange = function() {
            if (this.checked) {
                refreshInterval = setInterval(function() {
                    window.location.reload();
                }, 10000);
            } else {
                if (refreshInterval) {
                    clearInterval(refreshInterval);
                }
            }
        };
    }
    
    // 页面加载后初始化
    window.addEventListener('load', function() {
        setTimeout(scrollToBottom, 100);
        initAutoRefresh();
        setupClearLog();
        setupAutoRefreshToggle();
    });
    </script>
    ]]
end

-- 处理清除日志请求
if luci.http.formvalue("clear_log") then
    -- 获取当前时间戳（Unix时间戳）
    local current_time = os.time()
    
    -- 将时间戳保存到文件
    local f = io.open("/tmp/msd_lite_clear_time", "w")
    if f then
        f:write(tostring(current_time))
        f:close()
    end
    
    luci.http.redirect(luci.dispatcher.build_url("admin/services/msd_lite/log"))
    return
end

return m