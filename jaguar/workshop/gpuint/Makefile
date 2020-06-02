include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = gpu_init.o gpu_list.o gpu_hndl.o
PROGS = gpuint.cof
 
gpuint.cof: $(OBJS) ../data/jaguar.bin
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS) -i ../data/jaguar.bin jagbits

gpu_init.o: gpu_init.s gpuint.inc

gpu_list.o: gpu_list.s gpuint.inc

gpu_hndl.o: gpu_hndl.s gpuint.inc

include $(JAGSDK)/tools/build/jagrules.mk
