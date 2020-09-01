include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

PICTURES = fish.bpg patrick.bpg

GENERATED += $(PICTURES)

#############################################################################
# if using CRY mode screen, then must include 'rgb2cry.o' in list of object
# module files.

OBJS = startup.o test.o bpeg.o
PROGS = testbpeg.cof

testbpeg.cof: $(OBJS) $(PICTURES)
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS) \
		-i fish.bpg fish_jpg -i patrick.bpg pat_jpg

#====================================================================
#       DEPENDENCIES
#====================================================================

fish.bpg: fish.tga
	cbpeg -quality 25 fish.tga fish.bpg

patrick.bpg: patrick.tga
	cbpeg -quality 75 patrick.tga patrick.bpg

startup.o: startup.s $(JAGSDK)/jaguar/source/sample.rgb

include $(JAGSDK)/tools/build/jagrules.mk
