# package/yourpath/msd_lite/Makefile
# SPDX-License-Identifier: BSD-2-Clause
#
# (based on upstream and local packaging)
include $(TOPDIR)/rules.mk

PKG_NAME:=msd_lite
PKG_RELEASE:=1.11.2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rozhuk-im/msd_lite.git
PKG_SOURCE_DATE:=2025-05-02
PKG_SOURCE_VERSION:=79a6c62c8fced6128a5e445ee110709b3b51bb78
PKG_MIRROR_HASH:=18f148eff910849767e852130d104876f8e6be7c7f2adfb046c6fdd94602b78a

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/msd_lite
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Program for IP TV streaming on the network via HTTP
  URL:=http://www.netlab.linkpc.net/wiki/ru:software:msd:lite
  DEPENDS:=+libpthread
endef

define Package/msd_lite/description
  msd_lite - Multi stream daemon lite. The lightweight version of
  Multi Stream daemon (msd) Program for organizing IP TV streaming
  on the network via HTTP.
endef

define Package/msd_lite/conffiles
/etc/config/msd_lite
endef

# 指定配置目录（传入源码 CMake）
CMAKE_OPTIONS += -DCONFDIR=../etc/msd_lite
CMAKE_OPTIONS += -DCMAKE_BUILD_TYPE=Release
CMAKE_OPTIONS += -DCMAKE_INSTALL_PREFIX=/usr

# 针对特定目标（例如 cortex-a55）启用源码内部的目标优化选项（上游 CMakeLists 必须支持）
ifeq ($(TARGET_ARCH),aarch64)
  ifeq ($(TARGET_ARCH_VARIANT),cortex-a55)
    CMAKE_OPTIONS += -DMSD_LITE_A55_OPT=ON
  endif
endif

define Package/msd_lite/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/msd_lite $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/msd_lite
	$(CP) $(CURDIR)/files/msd_lite.sample $(1)/etc/msd_lite/msd_lite.conf.sample

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/msd_lite.config $(1)/etc/config/msd_lite

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/msd_lite.init $(1)/etc/init.d/msd_lite
endef

# 如果需要 LTO/IPO，建议由 upstream CMake 可控开关处理并且在 Makefile 中只传 option，不直接注入 flags.

$(eval $(call BuildPackage,msd_lite))
