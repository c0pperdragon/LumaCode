// Create a Lumacode270p test image.
// Run on an Attiny1604 with 24MHz, 5V
// Disable millis() to save flash space

// pin  port   usage
// 13   PA3    EXTCLK (24 MHz)
// 11   PA1    CSYNC
// 9    PB0    LUM0
// 8    PB1    LUM1

PROGMEM const byte picture[256*48+16] = {
  #include "picture.h"
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  // to not overrun end
};

void setup() {
  noInterrupts();

  // configure ports
  PORTA.DIR = B00000010;
  PORTB.DIR = B00000011;
}

#define W1   " nop \n"
#define W2   " nop \n nop \n"
#define W3   " nop \n nop \n nop \n"
#define W4   " nop \n nop \n nop \n nop \n"
#define W5   " nop \n nop \n nop \n nop \n nop \n"
#define W6   " call wait6 \n"
#define W7   " call wait6 \n nop \n"
#define W8   " call wait6 \n nop \n nop \n"
#define W9   " call wait6 \n nop \n nop \n nop \n"
#define W10  " call wait10 \n"
#define W20  " call wait10 \n call wait10 \n"
#define W30  " call wait10 \n call wait10 \n call wait10 \n"
#define W40  " call wait10 \n call wait10 \n call wait10 \n call wait10 \n"
#define W50  " call wait50 \n"
#define W60  " call wait50 \n call wait10 \n"
#define W70  " call wait50 \n call wait10 \n call wait10 \n"
#define W80  " call wait50 \n call wait10 \n call wait10 \n call wait10 \n"
#define W90  " call wait50 \n call wait10 \n call wait10 \n call wait10 \n call wait10 \n"
#define W100 " call wait100 \n"
#define W200 " call wait100 \n call wait100 \n"
#define W300 " call wait100 \n call wait100 \n call wait100 \n"
#define W400 " call wait100 \n call wait100 \n call wait100 \n call wait100 \n"
#define W500 " call wait500 \n"
#define W600 " call wait500 \n call wait100 \n"
#define W700 " call wait500 \n call wait100 \n call wait100 \n"
#define W800 " call wait500 \n call wait100 \n call wait100 \n call wait100 \n"
#define W900 " call wait500 \n call wait100 \n call wait100 \n call wait100 \n call wait100 \n"
#define W1000 " call wait500 \n call wait500 \n"

#define HSYNC " cbi %[porta],1 \n" W70 W1 " sbi %[porta],1 \n" 

#define X0 " out %[portb],r20 \n out %[portb],r24 \n out %[portb],r25 \n"
#define X1 " out %[portb],r21 \n out %[portb],r24 \n out %[portb],r25 \n"
#define X2 " out %[portb],r22 \n out %[portb],r24 \n out %[portb],r25 \n"
#define X3 " out %[portb],r23 \n out %[portb],r24 \n out %[portb],r25 \n"
#define X4 " out %[portb],r20 \n out %[portb],r24 \n out %[portb],r26 \n"
#define X5 " out %[portb],r21 \n out %[portb],r24 \n out %[portb],r26 \n"
#define X6 " out %[portb],r22 \n out %[portb],r24 \n out %[portb],r26 \n"
#define X7 " out %[portb],r23 \n out %[portb],r24 \n out %[portb],r26 \n"

#define PREP0 " lpm r0,Z+ \n lpm r1,Z+ \n lpm r2,Z+ \n lpm r3,Z+ \n lpm r4,Z+ \n lpm r5,Z+ \n lpm r6,Z+ \n lpm r7,Z+ \n"
#define PREP1 " lpm r8,Z+ \n lpm r9,Z+ \n lpm r10,Z+\n lpm r11,Z+\n lpm r12,Z+\n lpm r13,Z+\n lpm r14,Z+\n lpm r15,Z+\n"
#define PREP " lpm r17,Z+ \n push r17 \n"
#define MONO " pop r17 \n out %[portb],r17 \n lsr r17 \n lsr r17 \n out %[portb],r17 \n lsr r17 \n lsr r17 \n out %[portb],r17 \n lsr r17 \n lsr r17 \n out %[portb],r17 \n" 

void loop() {
  __asm__ __volatile__         // AVRxt core
  (
    " ldi r16,0b00000000  \n"  // line counter
    " ldi r17,0b00000000  \n"  // temporary
    " ldi r20,0b00000000  \n"  // level 0
    " ldi r21,0b00000001  \n"  // level 1
    " ldi r22,0b00000010  \n"  // level 2
    " ldi r23,0b00000011  \n"  // level 3
    " ldi r24,0b00000000  \n"  // green level for current line
    " ldi r25,0b00000000  \n"  // blue level for left half
    " ldi r26,0b00000000  \n"  // blue level for right half
    " mov r30,r28         \n"  // z register for picture address
    " mov r31,r29         \n"  // z register for picture address

    "framestart:           \n"
    // 3 vertical syncs (r16 is pre-loaded)
    "vsync:                \n"   //       1539 each
    " cbi %[porta],1      \n"   // 1
      W1000 W400 W60 W6         // 1466
    " sbi %[porta],1      \n"   // 1
      W60 W8                    // 68
    " dec r16             \n"   // 1
    " brne vsync          \n"   // 2
    " ldi r16,37          \n"   // 0 (use saved cycle)
    // 37 lines of back porch
    "backporch:            \n"   //       1539 each
      HSYNC                     // 73
      W1000 W400 W60 W3         // 1463
    " dec r16             \n"   // 1
    " brne backporch      \n"   // 2
    " ldi r16,6           \n"   // 0 (use saved cycle)
    // first line of top decoration
    "top1:                 \n"   //      1539 each
      HSYNC                     // 73
      W10 W7                    // 17     
    " out %[portb],R23    \n"   // 1      
      W20                       // 20     
    " out %[portb],R20    \n"   // 1      
      W1000 W300 W90 W7         // 1397   
    " out %[portb],R23    \n"   // 1 
      W20                       // 20
    " out %[portb],R20    \n"   // 1 
      W8                        // 8
    // 6 extra lines of top decoration
    "top:                  \n"   //      1539 each
      HSYNC                     // 73
      W10 W7                    // 17     
    " out %[portb],R23    \n"   // 1 
      W2                        // 2     
    "  out %[portb],R20    \n"   // 1      
      W1000 W400 W30 W3         // 1433
    " out %[portb],R23    \n"   // 1      
      W2                        // 2     
    " out %[portb],R20    \n"   // 1      
      W5                        // 5     
    " dec r16             \n"   // 1
    " brne top            \n"   // 2
    " ldi r16,0           \n"   // 0 (use saved cycle)
    // 256 lines of content           
    "content:             \n"   //      1539 each
    " cbi %[porta],1      \n"   // 1
      PREP PREP PREP PREP PREP  // 20
      PREP PREP PREP PREP PREP  // 20
      PREP PREP PREP PREP PREP  // 20
      PREP                      // 4
    " mov r24,r16         \n"   // 1
    " swap r24            \n"   // 1
    " mov r25,r24         \n"   // 1
    " lsr r24             \n"   // 1
    " lsr r25             \n"   // 1
    " lsr r25             \n"   // 1
    " andi r25,0x02       \n"   // 1
    " sbi %[porta],1      \n"   // 1
    " mov r26,r25         \n"   // 1
    " ori r26,0x01        \n"   // 1
      PREP PREP PREP PREP PREP  // 20
      PREP PREP PREP PREP       // 16     // 111
      X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0 X0  
      X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 X1 
      X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2 X2
      X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3 X3
      X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 X4 
      X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 X5 
      X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6 X6
      X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7 X7  // 768
    " out %[portb],r20    \n"   // 1
      PREP PREP PREP PREP PREP  // 20
      PREP PREP                 // 8
      W2                        // 2
      MONO MONO MONO MONO MONO MONO MONO MONO
      MONO MONO MONO MONO MONO MONO MONO MONO
      MONO MONO MONO MONO MONO MONO MONO MONO
      MONO MONO MONO MONO MONO MONO MONO MONO  // 384
      W100 W90 W2               // 192    
    " out %[portb],r20    \n"   // 1
      PREP0                     // 24
      PREP1                     // 24
    " inc r16             \n"   // 1
    " breq contentdone    \n"   // 2 (if taken)
    " rjmp content        \n"   // 1 (compensate non-taken branch)
    "contentdone:          \n"   //
    " ldi r16,6           \n"   // 1 
    // 6 lines of bottom decoration
    "bottom:               \n"    //      1539 each
      HSYNC                     // 73
      W10 W7                    // 17     
    " out %[portb],R23    \n"   // 1 
      W2                        // 2     
    " out %[portb],R20    \n"   // 1      
      W1000 W400 W30 W3         // 1433
    " out %[portb],R23    \n"   // 1      
      W2                        // 2     
    " out %[portb],R20    \n"   // 1      
      W5                        // 5     
    " dec r16             \n"   // 1
    " brne bottom         \n"   // 2
    " ldi r16,3           \n"   // 0 (use saved cycle)
    // last line of bottom decoration
    "bottom7:              \n"   //      1539 each
      HSYNC                     // 73
      W10 W7                    // 17
    " out %[portb],R23    \n"   // 1 
      W20                       // 20
    " out %[portb],R20    \n"   // 1 
      W1000 W300 W90 W7         // 1397
    " out %[portb],R23    \n"   // 1 
      W20                       // 20
    " out %[portb],R20    \n"   // 1 
      W8                        // 8
    // 2 lines of front porch
    "frontporch1:          \n"   //       1539 each
      HSYNC                     // 73
      W1000 W400 W60 W6         // 1466  
    "frontporch2:          \n"   //       1539 each
      HSYNC                     // 73
      W1000 W400 W60 W1         // 1461
    " mov r30,r28         \n"   // 1     reload z register
    " mov r31,r29         \n"   // 1     reload z register
    " jmp framestart      \n"   // 3

    "wait6:                \n"   // 3 for CALL
    " ret                 \n"   // 3
    "wait10:               \n"   // 3 for CALL
      W4                        // 4
    " ret                 \n"   // 3
    "wait50:               \n"   // 3 for CALL
      W40 W4                    // 44
    " ret                 \n"   // 3
    "wait100:              \n"   // 3 for CALL
      W90 W4                    // 94
    " ret                 \n"   // 3
    "wait500:              \n"   // 3 for CALL
      W400 W90 W4               // 494
    " ret                 \n"   // 3
    :  
    : [porta] "I" (_SFR_IO_ADDR(VPORTA.OUT)),
      [portb] "I" (_SFR_IO_ADDR(VPORTB.OUT)),
              "y" (picture)
    :
  );
}
