#
# Before building using this do:
#	make -f Android.mk build-local-hack
#   ndk-build
#   ndk-build
#	make -f Android.mk copy-libs-hack

PROJECT_ROOT_PATH := $(call my-dir)
LOCAL_PATH := $(PROJECT_ROOT_PATH)
LOCAL_PRELINK_MODULE := false

project_ldflags:= -Landroid-libs/$(TARGET_ARCH_ABI)/

#------------------------------------------------------------------------------#
# libsqlite3

# NOTE the following flags,
#   SQLITE_TEMP_STORE=3 causes all TEMP files to go into RAM. and thats the behavior we want
#   SQLITE_ENABLE_FTS3   enables usage of FTS3 - NOT FTS1 or 2.
#   SQLITE_DEFAULT_AUTOVACUUM=1  causes the databases to be subject to auto-vacuum
android_sqlite_cflags :=  -DHAVE_USLEEP=1 \
	-DSQLITE_DEFAULT_JOURNAL_SIZE_LIMIT=1048576 -DSQLITE_THREADSAFE=1 -DNDEBUG=1 \
	-DSQLITE_ENABLE_MEMORY_MANAGEMENT=1 -DSQLITE_TEMP_STORE=3 \
	-DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_BACKWARDS \
	-DSQLITE_ENABLE_LOAD_EXTENSION

sqlcipher_files := \
	sqlcipher/sqlite3.c

sqlcipher_cflags := -DSQLITE_HAS_CODEC -DHAVE_FDATASYNC=0 -Dfdatasync=fsync

sqlcipher_configure_opts := --enable-tempstore=yes CFLAGS=-DSQLITE_HAS_CODEC LDFLAGS=-lcrypto --disable-tcl
SQLCIPHER_FILE := $(LOCAL_PATH)/sqlcipher/sqlite3.c

include $(CLEAR_VARS)

LOCAL_STATIC_LIBRARIES += static-libcrypto
LOCAL_CFLAGS += $(android_sqlite_cflags) $(sqlcipher_cflags)
LOCAL_C_INCLUDES := $(LOCAL_PATH)/openssl/include sqlcipher
LOCAL_LDFLAGS += $(project_ldflags)
LOCAL_MODULE    := libsqlcipher
LOCAL_SRC_FILES := $(sqlcipher_files)

$(SQLCIPHER_FILE):
       cd ${PROJECT_ROOT_PATH}/openssl && ./Configure dist
       cd ${PROJECT_ROOT_PATH}/sqlcipher && ./configure $(sqlcipher_configure_opts) && make
.PHONY: $(SQLCIPHER_FILE)

include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := static-libcrypto
LOCAL_EXPORT_C_INCLUDES := openssl/include
LOCAL_SRC_FILES := android-libs/$(TARGET_ARCH_ABI)/libcrypto.a
include $(PREBUILT_STATIC_LIBRARY)

