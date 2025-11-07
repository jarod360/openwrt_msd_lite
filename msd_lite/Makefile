# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=msd_lite
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rozhuk-im/msd_lite.git
PKG_SOURCE_DATE:=2024-05-02
PKG_SOURCE_VERSION:=79a6c62c8fced6128a5e445ee110709b3b51bb78
PKG_MIRROR_HASH:=18f148eff910849767e852130d104876f8e6be7c7f2adfb046c6fdd94602b78

PKG_MAINTAINER:=Jarod Chang <your-email@example.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# -------------------------
# 针对 RK3568 / Cortex-A55 优化
# -------------------------
TARGET_CFLAGS += -O3 -march=armv8-a -mcpu=cortex-a55 -mtune=cortex-a55 \
                 -ffunction-sections -fdata-sections \
                 -flto -fuse-linker-plugin \
                 -ffast-math -fomit-frame-pointer
TARGET_LDFLAGS += -Wl,--gc-sections -flto -fuse-linker-plugin
# 最终二进制使用 strip 减小体积
TARGET_STRIPFLAGS += --strip-unneeded

define Package/msd_lite
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Program for IP TV streaming on the network via HTTP
  URL:=http://www.netlab.linkpc.net/wiki/ru:software:msd:lite
endef

define Package/msd_lite/description
  msd_lite - Multi stream daemon lite. The lightweight version of
  Multi Stream daemon (msd) Program for organizing IP TV streaming
  on the network via HTTP.
  Optimized for RK3568 (Cortex-A55) with LTO and strip enabled.
endef

define Package/msd_lite/conffiles
/etc/config/msd_lite
endef

CMAKE_OPTIONS+= -DCONFDIR=../etc/msd_lite

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
        CC="$(TARGET_CC)" \
        CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(EXTRA_CFLAGS)" \
        LDFLAGS="$(TARGET_LDFLAGS) $(EXTRA_LDFLAGS)" \
        STRIP="$(TARGET_STRIP) $(TARGET_STRIPFLAGS)"
endef

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
