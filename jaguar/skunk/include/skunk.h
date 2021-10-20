#ifndef _SKUNKC_H_
#define _SKUNKC_H_

extern void skunkRESET(void);

extern void skunkRESET6MB(void);

extern void skunkNOP(void);

extern void skunkCONSOLEWRITE(const char *str);

extern void skunkCONSOLECLOSE(void);

/* Returns non-zero if setup succeeded, 0 otherwise */
extern unsigned long skunkCONSOLESETUPREAD(void);

/* Returns 1 if data is available to read, 0 otherwise */
extern unsigned long skunkCONSOLECHECKREAD(void);

/* NOTE: Does NOT NUL-terminate!  <numbytes> must be <= 4064. Returns number of
 * bytes actually read.*/
extern unsigned long skunkCONSOLEFINISHREAD(char *str, unsigned long numbytes);

/* NOTE: Does NOT NUL-terminate!  <numbytes> must be <= 4064 */
extern void skunkCONSOLEREAD(char *str, unsigned long numbytes);

extern void skunkFILEOPEN(const char *filename, int mode);

/* NOTE: <numbytes> must be even and <= 4060 */
extern void skunkFILEWRITE(const void *data, unsigned long numbytes);

/* Returns number of bytes actually read, 0 on EOF or error */
extern unsigned long skunkFILEREAD(void *data, unsigned long maxbytes);

extern void skunkFILECLOSE(void);

#endif /* _SKUNKC_H_ */
