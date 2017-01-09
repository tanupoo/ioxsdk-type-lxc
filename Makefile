#
# @file
#	Makefile
#
# @description
#	Makefile used to create a simple IOx native C application
#
# @copyright
#	Copyright (c) 2015-2016 by Cisco Systems, Inc.
#	All rights reserved.
#

# Include common definitions and utilities makefile fragment
include ../shared/prologue.mk

# Select the target machine to build this application for
#YOCTO_MACHINE ?= ie4k-lxc
YOCTO_MACHINE ?= ir800-lxc
#YOCTO_MACHINE ?= isr800-lxc
#YOCTO_MACHINE ?= isr800-qemu
#YOCTO_MACHINE ?= isr4k-qemu
YOCTO_VERSION = 1.7

# Base image - this application needs python interpreter
YOCTO_IMAGE_TARGET = iox-core-image-minimal

# This application performs rootfs image post processing; we need .tar.gz from Yocto
ROOTFS_IMAGE_POSTPROCESSING = 1


# Include common definitions and utilities for native apps
# Note: Must have defined the following variables before including this one
# - YOCTO_MACHINE
# - YOCTO_VERSION
# - YOCTO_IMAGE_TARGET
# - ROOTFS_IMAGE_POSTPROCESSING
include ../shared/native.mk

# Yocto mirror location (optional)
YOCTO_MIRROR ?=

# Set of source files to compile
SOURCES := \
		display-date-time.c

# Directory to place the compiled object files and bin files
OBJ_DIR = $(OUTPUT_YOCTO_MACHINE_DIR)/obj

# Set of object files to generate the application binaries
OBJS := $(patsubst %.c,$(OBJ_DIR)/%.o,$(SOURCES))

# C application binary
PROGRAM_BIN = $(OBJ_DIR)/display-date-time.bin

#
# Default Makefile Target

all: setup $(APP_PKG) teardown

#
# Application specific setup of project
# This setup ensures that the right local.conf is configured for the project
#
.PHONY = setup
setup: setup_common

#
# Create the application package
#
$(APP_PKG): $(APP_PKG_DESCRIPTOR) $(OUTPUT_ROOTFS_IMAGE) $(OUTPUT_KERNEL_IMAGE)
	$(call separator)
	@echo "Creating the application package..."
	cd $(OUTPUT_DIR) && \
		$(IOX) package create --proj-file $(PROJECT_CONFIG) --img-id $(YOCTO_MACHINE)
	mv $(OUTPUT_DIR)/application.tar $@
	@echo "Done"

#
# Create the application package descriptor
#
$(APP_PKG_DESCRIPTOR): $(SRC_PKG_DESCRIPTOR)
	$(call separator)
	$(call create_pkg_descriptor)
	@echo "Done"

#
# Define Application specific rootfs update logic
#
UPDATE_ROOTFS=\
    cp $(IOXAPP_DIR)/$(IOXAPP_NAME) $(ROOTFS_STAGING_DIR)/usr/bin/ ; \
    cp $(IOXAPP_LIBS) $(ROOTFS_STAGING_DIR)/usr/lib/ ; \
    cp $(IOXAPP_RC) $(ROOTFS_STAGING_DIR)/etc/init.d/ ; \
    echo 'bot:2345:respawn:/etc/init.d/sparkbot-notify.sh start' >> $(ROOTFS_STAGING_DIR)/etc/inittab ;


#
# Ready the final rootfs image using the one built by Yocto build system
# For this application, the "helloworld.py" file is inserted
#
$(OUTPUT_ROOTFS_IMAGE): $(YOCTO_ROOTFS_IMAGE) build_app
	$(call separator)
	$(call mk_dir,$(@D))
	$(RM) -rf $@
	@echo -e "$(UNPACK_IMAGE) $(UPDATE_ROOTFS) ${REPACK_IMAGE}" | fakeroot
	@echo "Done"

#
# Copy the kernel to the staging directory.
# This application doesn't modify the kernel, copy as is
#
$(OUTPUT_KERNEL_IMAGE): $(YOCTO_KERNEL_IMAGE)
	$(call separator)
	$(call mk_dir,$(@D))
	cp $< $@
	touch $@
	@echo "Done"

#
# Build the Yocto rootfs image
# If the Yocto project configuration file is modified, we want to rebuild the image
#
$(YOCTO_ROOTFS_IMAGE): $(YOCTO_PROJECT_LOCAL_CONF)
	$(call separator)
	@echo "Building image: $(YOCTO_IMAGE_TARGET)..."
	@cd $(YOCTO_PROJECT_DIR) && \
		source ./SOURCEME && \
		bitbake $(YOCTO_IMAGE_TARGET) -c clean && \
		bitbake $(YOCTO_IMAGE_TARGET)
	@echo "Done"

#
# Create the build environment setup file
#
$(BUILD_ENV_FILE): $(YOCTO_PROJECT_LOCAL_CONF)
	$(call separator)
	$(IOX) ldsp execute yocto-1.7 buildenv create -p $(YOCTO_PROJECT_DIR)

#
# Source the build environment script and re-invoke this makefile for PROGRAM_BIN target
# The re-invocation step is required only for compiling the C program with the target
# build environment
# Once the re-invocation is done, it will go back to the original pristine environment
# for executing the rest of the steps
#
.PHONY = build_app
build_app: $(BUILD_ENV_FILE)
	$(call separator)
	@echo "Sourcing build environment: environment-setup-$(YOCTO_MACHINE)..."; \
	source $(BUILD_ENV_FILE)

#
# Rule to generate the bin file
#
$(PROGRAM_BIN): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

#
# Rule to compile the C files
#
$(OBJ_DIR)/%.o: $(SOURCES_DIR)/%.c
	$(call separator)
	@mkdir -p $(@D)
	@echo "Compiling C application..."
	$(CC) $(CFLAGS) -c $< -o $@

#
# Application specific cleanup tasks after each run
#
.PHONY = teardown
teardown:

#
# Remove some of the output files created by the build process
#
clean:
	$(call separator)
	@echo "Cleaning up application generated files..."
	$(RM) -rf $(APP_PKG) $(OUTPUT_YOCTO_MACHINE_DIR)
	@echo "Done"

#
# Remove all output files created by the build process
#
cleanall: clean
	$(call separator)
	@echo "Cleaning up all build generated files..."
	$(RM) -rf $(OUTPUT_DIR)
	@echo "Done"

#
# Simple debug target to debug this Makefile
#
debug:
	$(call separator)
	$(call debug_common)
	$(call debug_native)

.PHONY: cleanall clean debug
