local sys = require "luci.sys"

m = Map("msd_lite", "多播转发轻量化程序（MSD Lite）",
    translate("MSD Lite 是一个UDP到HTTP多播流量中继转发守护进程，您可以在此处配置参数！"))

m:section(SimpleSection).template = "msd_lite/msdlite_status"

s = m:section(TypedSection, "msd_lite", translate("设置"))
s.addremove = false
s.anonymous = true

s:tab("basic", translate("基础设置"))
s:tab("advanced", translate("高级设置"))

-----------------------------------
-- 基础设置
-----------------------------------

enable = s:taboption("basic", Flag, "enable", translate("启用服务"))
enable.rmempty = false

bind_address = s:taboption("basic", Value, "bind_address", translate("绑定地址（IP:端口）"))
bind_address.datatype = "hostport"
bind_address.default = "0.0.0.0:7088"
bind_address.placeholder = "0.0.0.0:7088"
bind_address.description = translate("监听的本地地址和端口，例如 0.0.0.0:7088")
bind_address.rmempty = false

source_interface = s:taboption("basic", Value, "source_interface", translate("信号源接口"))
source_interface.rmempty = false
source_interface.description = translate("选择接收组播或输入流的接口")
for _, e in ipairs(sys.net.devices()) do
    if e ~= "lo" then source_interface:value(e) end
end

-----------------------------------
-- 高级设置
-----------------------------------

threads = s:taboption("advanced", Value, "threads", translate("CPU 线程数"))
threads.default = "0"
threads.datatype = "uinteger"
threads.rmempty = false
threads:value("0", translate("自动"))
threads:value("1")
threads:value("2")
threads:value("3")
threads:value("4")
threads.description = translate("0 表示自动根据 CPU 核心数分配线程")

thread_bind_cpu = s:taboption("advanced", Flag, "thread_bind_cpu", translate("线程绑定 CPU 核心"))
thread_bind_cpu.rmempty = false
thread_bind_cpu.description = translate("启用后每个线程将绑定到指定 CPU 核心，提高多核效率")

hub_drop_slow_client = s:taboption("advanced", Flag, "hub_drop_slow_client", translate("丢弃慢速客户端"))
hub_drop_slow_client.rmempty = false
hub_drop_slow_client.description = translate("当客户端接收速度过慢时自动断开连接")

hub_use_polling_for_send = s:taboption("advanced", Flag, "hub_use_polling_for_send", translate("使用轮询方式发送数据"))
hub_use_polling_for_send.rmempty = false
hub_use_polling_for_send.description = translate("启用后使用轮询模式替代阻塞式发送，适合高并发场景")

hub_zero_copy_on_send = s:taboption("advanced", Flag, "hub_zero_copy_on_send", translate("启用零拷贝发送"))
hub_zero_copy_on_send.rmempty = false
hub_zero_copy_on_send.description = translate("开启零拷贝发送以降低 CPU 占用，提升性能")

hub_persist_when_no_client = s:taboption("advanced", Flag, "hub_persist_when_no_client", translate("无客户端时保持频道"))
hub_persist_when_no_client.rmempty = false
hub_persist_when_no_client.description = translate("启用后即使没有客户端连接也不销毁频道实例，减少频道重建开销")

hub_persist_when_no_source = s:taboption("advanced", Flag, "hub_persist_when_no_source", translate("无信号源时保持频道"))
hub_persist_when_no_source.rmempty = false
hub_persist_when_no_source.description = translate("启用后即使无信号源也不销毁频道实例，等待信号源恢复")

hub_wait_precache = s:taboption("advanced", Flag, "hub_wait_precache", translate("启用预缓存等待"))
hub_wait_precache.rmempty = false
hub_wait_precache.description = translate("启用后在客户端连接前预先缓存数据，确保播放开始时数据完整")

hub_precache_size = s:taboption("advanced", Value, "hub_precache_size", translate("预缓存大小（KB）"))
hub_precache_size.datatype = "uinteger"
hub_precache_size.default = "2048"
hub_precache_size.placeholder = "2048"
hub_precache_size.description = translate("设置频道启动时的预缓存大小，数值越大启动延迟越高但抗抖动能力越强")

source_ring_buffer_size = s:taboption("advanced", Value, "source_ring_buffer_size", translate("环形缓冲区大小（KB）"))
source_ring_buffer_size.datatype = "uinteger"
source_ring_buffer_size.default = "8192"
source_ring_buffer_size.placeholder = "8192"
source_ring_buffer_size.description = translate("设置输入流缓冲区大小，数值越大可减少丢包但占用内存更多")

multicast_recv_buffer_size = s:taboption("advanced", Value, "multicast_recv_buffer_size", translate("接收缓冲区大小（KB）"))
multicast_recv_buffer_size.default = "512"
multicast_recv_buffer_size.datatype = "uinteger"
multicast_recv_buffer_size.optional = true
multicast_recv_buffer_size.rmempty = true
multicast_recv_buffer_size.description = translate("用于设置系统层面的 UDP 接收缓冲区大小（SO_RCVBUF），单位 KB。增大可减少高负载下的丢包。")

source_multicast_rejoin_interval = s:taboption("advanced", Value, "source_multicast_rejoin_interval", translate("组播重连间隔（秒）"))
source_multicast_rejoin_interval.datatype = "uinteger"
source_multicast_rejoin_interval.default = "180"
source_multicast_rejoin_interval.placeholder = "180"
source_multicast_rejoin_interval.description = translate("设置 IGMP 组播重入（Rejoin）的时间间隔，0 表示关闭。定期重连可保持组播组成员关系")

return m
