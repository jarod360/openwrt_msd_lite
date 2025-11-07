# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=msd_lite
PKG_RELEASE:=1.11.2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rozhuk-im/msd_lite.git
PKG_SOURCE_DATE:=2024-05-02
PKG_SOURCE_VERSION:=79a6c62c8fced6128a5e445ee110709b3b51bb78
PKG_MIRROR_HASH:=18f148eff910849767e852130d104876f8e6be7c7f2adfb046c6fdd94602b78

PKG_MAINTAINER:=Tianling Shen <cnsztl@immrotalwrt.org>
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

# 指定配置目录
CMAKE_OPTIONS+= -DCONFDIR=../etc/msd_lite

# RK3568 Cortex-A55 编译优化
CMAKE_OPTIONS+= \
  -DCMAKE_C_FLAGS="-O3 -march=armv8-a -mcpu=cortex-a55 -mtune=cortex-a55 -ffunction-sections -fdata-sections -flto -fuse-linker-plugin -ffast-math -fomit-frame-pointer" \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,--gc-sections -flto -fuse-linker-plugin" \
  -DCMAKE_SHARED_LINKER_FLAGS="-Wl,--gc-sections -flto -fuse-linker-plugin" \
  -DCMAKE_STRIP=/usr/bin/strip

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

$(eval $(call BuildPackage,msd_lite))
