#include <jagdefs.h>
#include <jagtypes.h>
#include <stdlib.h>

#include <interrupt.h>
#include <display.h>
#include <sprite.h>
#include <collision.h>
#include <joypad.h>
#include <screen.h>
#include <blit.h>

#include <fb2d.h>

extern phrase font;
extern long font_offset[256];

#define NB_LETTERS ((320+3*32)/32)

#define GRAVITY 0x1a

typedef struct {
  sprite s;
  short int vy;
  short int dy;
} letter;

letter *scrolltext[NB_LETTERS];

char *mytxt = "Here is a little scrolltext made with the Removers'library. Isn't it fun what we can do with a few sprites? ########   ";

char *p_text;

void init_screxx(display *d) {
  int i;
  phrase *gfx;
  for(i = 0; i < 256; i++) {
    font_offset[i] /= 8;
  }
  for(i = 0; i < NB_LETTERS; i++) {
    gfx = &font;
    gfx += font_offset[(unsigned char)' '];
    letter *l = malloc(sizeof(letter));
    set_sprite(&l->s,32,32,32*i,0,DEPTH16,gfx);
    l->s.dwidth = 320*2 / 8;
    l->vy = 0;
    scrolltext[i] = l;
    attach_sprite_to_display_at_layer(&l->s,d,0);
  }
  p_text = mytxt;
}

void do_screxx() {
  int i;
  letter *l;
  unsigned char c;
  for(i = 0; i < NB_LETTERS; i++) {
    l = scrolltext[i];
    l->s.x -= 2;
    l->s.y += l->vy >> 8;
    l->vy += GRAVITY;
    if(l->s.y >= 200) {
      l->vy = - (l->vy / 2);
    } 
    if(l->s.x <=-32) {
      l->s.x += NB_LETTERS*32;
      if((c = *p_text++) == 0) {
	p_text = mytxt;
	c = *p_text++;
      }
      phrase *gfx = &font;
      gfx += font_offset[c];
      l->s.data = gfx;
      l->s.y = -32;
      l->vy = 0;
    }
  }
}

int main(int argc, char *argv[]) {
  SET_SHORT_INT(RGB16|CSYNC|BGEN|PWIDTH4|VIDEN,VMODE);
  init_interrupts();
  init_display_driver();

  display *d = new_display(0);
  d->x = 16;
  d->y = 8;

  init_screxx(d);
  show_display(d);

  while(1) {
    vsync();
    do_screxx();
  }

  return 0;
}

