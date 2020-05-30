#include"font.h"

extern void *vidmem;
unsigned char *jagscreen;

void DrawCharLine (int charloc, int screenloc)
{
  static unsigned char shift[] = { 7, 6, 5, 4, 3, 2, 1, 0 };
  int xcnt;

  for (xcnt = 0; xcnt < F_WIDTH; xcnt++) 
  {
    if (((textfont[charloc] >> shift[xcnt]) & 0x1)) 
      jagscreen[screenloc++] = 1;
    else
      jagscreen[screenloc++] = 0;
  }
}

void DrawChar (int x, int y, char ch)
{
  int ycnt, charloc, screenloc;

  charloc = ch * F_CHARSIZE;

  screenloc = (y * T_XREZ) + x ;

  for (ycnt = 0; ycnt < F_HEIGHT; ycnt++) 
  {
    DrawCharLine (charloc, screenloc);
    screenloc += T_XREZ;
    charloc++;
  }
}

void DrawString (int x, int y, char *str)
{
  int cnt;

  for (cnt = 0; str[cnt] != 0; cnt++) 
  {
    DrawChar (x, y, str[cnt]);
    x += F_WIDTH;
  }
}

void __main(void) 
{
  int w;

  jagscreen = (unsigned char *)&vidmem;

  *(unsigned short int *) 0xf00400 = 0x0000; /* Color reg 0 = black */
  *(unsigned short int *) 0xf00402 = 0xffff; /* Color reg 1 = white */

  for(w=0;w<64000;w++) jagscreen[w]=0;

  DrawString(1,1,"Hello Jag Users");

  for(;;);  /* Infinite Loop.  Alpine users can delete this.  */
}



