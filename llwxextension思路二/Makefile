INSTALL_TARGET_PROCESSES = WeChat
include $(THEOS)/makefiles/common.mk
export THEOS_DEVICE_IP=127.0.0.1
export THEOS_DEVICE_PORT=10010


TWEAK_NAME = LLWXExtension

LLWXExtension_FILES = $(wildcard src/*.m) $(wildcard src/ZSFakeTouch/*.m) $(wildcard src/Helper/*.m) $(wildcard src/*.xm) 
LLWXExtension_CFLAGS = -fobjc-arc


LLWXExtension_FRAMEWORKS  = IOKit


include $(THEOS_MAKE_PATH)/tweak.mk


