#
TARGET = face_detection
#
ALT_DEVICE_FAMILY ?= soc_cv_av
SOCEDS_DEST_ROOT = /mnt/c/intelFPGA/16.1/embedded/
SOCEDS_ROOT ?= $(SOCEDS_DEST_ROOT)
HWLIBS_ROOT = $(SOCEDS_ROOT)/ip/altera/hps/altera_hps/hwlib
CROSS_COMPILE = arm-linux-gnueabihf-
CFLAGS = -g -Wall -D$(ALT_DEVICE_FAMILY) -I $(HWLIBS_ROOT)/include/$(ALT_DEVICE_FAMILY) -I$(HWLIBS_ROOT)/include/ -std=gnu++11 
LDFLAGS =  -g -Wall -D$(ALT_DEVICE_FAMILY) -I $(HWLIBS_ROOT)/include/$(ALT_DEVICE_FAMILY) -I$(HWLIBS_ROOT)/include/ -std=gnu++11 
CC = $(CROSS_COMPILE)g++
ARCH= arm
#LDFLAGS =  -g -Wall  -Iteraisc_pcie_qsys.so -ldl
#-ldl must be placed after the file calling lpxxxx funciton


build: $(TARGET)
#-lmpeg2 --> link libmpeg2.a (lib___.a)
$(TARGET): main.cpp FPGAManager.cpp ImageClass.cpp ResultData.cpp 
	$(CC) $(LDFLAGS)  $^ -o $@  -lpthread -lrt
#	$(CC) $(LDFLAGS)  $^ -o $@  -ldl -lmpeg2  -lmpeg2convert -lpthread
%.o : %.cpp
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *~ 
