INSTALL_TARGET_PROCESSES = WeChat
include $(THEOS)/makefiles/common.mk
export THEOS_DEVICE_IP=127.0.0.1
export THEOS_DEVICE_PORT=10010

TWEAK_NAME = LLWXExtension

LLWXExtension_FILES = $(wildcard src/*.xm) $(wildcard src/Helper/*.m) 

LLWXExtension_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk


