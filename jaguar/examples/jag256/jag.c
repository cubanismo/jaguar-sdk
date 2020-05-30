/******************************************************************************
jag.c 

Copyright (C) 2005 Michael Hill

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
******************************************************************************/

/******************************************************************************
This code will setup the jag for a 320 X 200 X 256 color display. 

The startup.s file is a basic standard Atari sample file.  It has been edited
for our video settings, it jumps to our main() routine in this file.  The 
startup.s file also includes the raw image that is displayed on the screen.

This file has routines to do some SIMPLE text output on the screen.  It also
handles setting the CLUT on the Jag to the palette values contained in pal16.h

font.h contains a simple character font.

Upon execution the code displayes the image stored in pic.raw using the color
palette values in pal16.h and displays some text in a couple sizes and colors
using the text routines.

It then goes into an infinite loop.

To compile type "make".  

Load the code into address $4000 and execute from there also.

******************************************************************************/

#include"pal16.h"
#include"font.h"

extern void *vidmem;
unsigned char *jagscreen;

unsigned char shift[] = { 7, 6, 5, 4, 3, 2, 1, 0 };
int TextSize=1,TextColor=2;

void DrawCharLine (int charloc, int screenloc)
{
  int xcnt;
  int xsize;

  for (xcnt = 0; xcnt < F_WIDTH; xcnt++) {
    if (((textfont[charloc] >> shift[xcnt]) & 0x1)) {
      for (xsize = 0; xsize < TextSize; xsize++)
            jagscreen[screenloc++] = TextColor;
    }
    else {
      for (xsize = 0; xsize < TextSize; xsize++) {
            /*if (!Transparency)
              jagscreen[screenloc++] = 0;
            else
              jagscreen[screenloc++] = 1;*/
              screenloc++;
      }
    }
  }
}

void DrawChar (int x, int y, char ch)
{
  int ycnt, charloc, screenloc;
  int ysize;

  charloc = ch * F_CHARSIZE;

  screenloc = (y * T_XREZ) + x ;

  for (ycnt = 0; ycnt < F_HEIGHT; ycnt++) {
    for (ysize = 1; ysize <= TextSize; ysize++) {
      DrawCharLine (charloc, screenloc);
      screenloc += T_XREZ;
    }
    charloc++;
  }
}

void DrawString (int x, int y, char *str)
{
  int cnt;

  for (cnt = 0; str[cnt] != 0; cnt++) {
    DrawChar (x, y, str[cnt]);
    x += (F_WIDTH * TextSize);
  }
}


void __main(void) {
  jagscreen = (unsigned char *)&vidmem;

  TextColor = 1;

  DrawString(10,10,"Atari Jaguar");

  TextColor = 45;
  TextSize  = 3;

  DrawString(70,100,"Hot Chicks");

  for(;;); /* Infinite loop added so BJL users dont hit illegal instruct*/
  asm(" illegal");
}

void SetPallete(void) {
  int x;
  unsigned long add=0xf00400;

  for(x=0;x<256;x++) {
    *(unsigned short int *) add = pallete[x];
    add+=2;
  }
}

