// Create a Lumacode270p test image.
// Run on an Attiny1604 with 24MHz, 5V

// pin  port   usage
// 13   PA3    EXTCLK (24 MHz)
// 11   PA1    CSYNC
// 9    PB0    LUM0
// 8    PB1    LUM1

void setup() {
  noInterrupts();

  // configure ports
  PORTA.DIR = B00000010;
  PORTB.DIR = B00000011;
}


volatile byte i;
void loop() {
  for (i=0; i<255; i++);

  __asm__ __volatile__         // AVRxt core
  (
    "  ldi r20,0b00000000  \n"
    "  ldi r21,0b00000001  \n"
    "  ldi r22,0b00000010  \n"
    "  ldi r23,0b00000011  \n"

    "framestart:           \n"
    // 3 vertical syncs (r16 is pre-loaded)
    "vsync:                \n"   //       1539 each
    "  cbi %[porta],1      \n"   // 1
    "  call wait1466       \n"   // 1466
    "  sbi %[porta],1      \n"   // 1
    "  call wait68         \n"   // 68
    "  dec r16             \n"   // 1
    "  brne vsync          \n"   // 2
    "  ldi r16,37          \n"   // 0 (use saved cycle)
    // 37 lines of back porch
    "backporch:            \n"   //       1539 each
    "  cbi %[porta],1      \n"   // 1
    "  call wait71         \n"   // 71
    "  sbi %[porta],1      \n"   // 1
    "  call wait1463       \n"   // 1463
    "  dec r16             \n"   // 1
    "  brne backporch      \n"   // 2
    "  ldi r16,6           \n"   // 0 (use saved cycle)
    // first line of top decoration
    "top1:                 \n"   //      1539 each
    "  cbi %[porta],1      \n"   // 1      
    "  call wait71         \n"   // 71   
    "  sbi %[porta],1      \n"   // 1      
    "  call wait17         \n"   // 17     
    "  out %[portb],R23    \n"   // 1      
    "  call wait20         \n"   // 20     
    "  out %[portb],R20    \n"   // 1      
    "  call wait1397       \n"   // 1397   
    "  out %[portb],R23    \n"   // 1 
    "  call wait20         \n"   // 20
    "  out %[portb],R20    \n"   // 1 
    "  call wait8          \n"   // 8
    // 6 extra lines of top decoration
    "top:                  \n"   //      1539 each
    "  cbi %[porta],1      \n"   // 1
    "  call wait71         \n"   // 71
    "  sbi %[porta],1      \n"   // 1
    "  call wait17         \n"   // 17     
    "  out %[portb],R23    \n"   // 1 
    
    "  nop                 \n"   // 1     
    "  nop                 \n"   // 1     
    "  out %[portb],R20    \n"   // 1      
    "  call wait1433       \n"   // 1433
    "  out %[portb],R23    \n"   // 1      
    "  nop                 \n"   // 1     
    "  nop                 \n"   // 1     
    "  out %[portb],R20    \n"   // 1      
    "  nop                 \n"   // 1     
    "  nop                 \n"   // 1     
    "  nop                 \n"   // 1     
    "  nop                 \n"   // 1     
    "  nop                 \n"   // 1     
    "  dec r16             \n"   // 1
    "  brne top            \n"   // 2
    "  ldi r16,0           \n"   // 0 (use saved cycle)
    // 256 lines of content           
    "content:              \n"   //      1539 each
    "  cbi %[porta],1      \n"   // 1
    "  call wait71         \n"   // 71
    "  sbi %[porta],1      \n"   // 1
    "  call wait1463       \n"   // 1463
    "  dec r16             \n"   // 1
    "  brne content        \n"   // 2
    "  ldi r16,6           \n"   // 0 (use saved cycle)
    // 6 lines of bottom decoration
    "bottom:               \n"    //      1539 each
    "  cbi %[porta],1      \n"   // 1
    "  call wait71         \n"   // 71
    "  sbi %[porta],1      \n"   // 1
    "  call wait17         \n"   // 17     
    "  out %[portb],R23    \n"   // 1 
    "  nop                 \n"   // 1     
    "  nop                 \n"   // 1     
    "  out %[portb],R20    \n"   // 1      
    "  call wait1433       \n"   // 1433
    "  out %[portb],R23    \n"   // 1      
    "  nop                 \n"   // 1     
    "  nop                 \n"   // 1     
    "  out %[portb],R20    \n"   // 1      
    "  nop                 \n"   // 1     
    "  nop                 \n"   // 1     
    "  nop                 \n"   // 1     
    "  nop                 \n"   // 1     
    "  nop                 \n"   // 1     
    "  dec r16             \n"   // 1
    "  brne bottom         \n"   // 2
    "  ldi r16,3           \n"   // 0 (use saved cycle)
    // last line of bottom decoration
    "bottom7:              \n"   //      1539 each
    "  cbi %[porta],1      \n"   // 1
    "  call wait71         \n"   // 71
    "  sbi %[porta],1      \n"   // 1
    "  call wait17         \n"   // 17
    "  out %[portb],R23    \n"   // 1 
    "  call wait20         \n"   // 20
    "  out %[portb],R20    \n"   // 1 
    "  call wait1397       \n"   // 1397
    "  out %[portb],R23    \n"   // 1 
    "  call wait20         \n"   // 20
    "  out %[portb],R20    \n"   // 1 
    "  call wait8          \n"   // 8
    // 2 lines of front porch
    "frontporch1:          \n"   //       1539 each
    "  cbi %[porta],1      \n"   // 1
    "  call wait71         \n"   // 71
    "  sbi %[porta],1      \n"   // 1
    "  call wait1466       \n"   // 1466  
    "frontporch2:          \n"   //       1539 each
    "  cbi %[porta],1      \n"   // 1
    "  call wait71         \n"   // 71
    "  sbi %[porta],1      \n"   // 1
    "  call wait1463       \n"   // 1463
    "  nop                 \n"   // 1
    "  rjmp framestart     \n"   // 2

    "wait6:                \n"   // 3 for CALL
    "  ret                 \n"   // 3
    "wait7:                \n"   // 3 for CALL
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait8:                \n"   // 3 for CALL
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait10:               \n"   // 3 for CALL
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait17:               \n"   // 3 for CALL
    "  call wait10         \n"   // 10
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait20:               \n"   // 3 for CALL
    "  call wait10         \n"   // 10
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait50:               \n"   // 3 for CALL
    "  call wait10         \n"   // 10
    "  call wait10         \n"   // 10
    "  call wait10         \n"   // 10
    "  call wait10         \n"   // 10
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait63:               \n"   // 3 for CALL
    "  call wait50         \n"   // 10
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait68:               \n"   // 3 for CALL
    "  call wait50         \n"   // 50
    "  call wait10         \n"   // 10
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait71:               \n"   // 3 for the CALL
    "  call wait7          \n"   // 7
    "  call wait50         \n"   // 50
    "  call wait7          \n"   // 7
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait100:              \n"   // 3 for the CALL
    "  call wait50         \n"   // 50
    "  call wait10         \n"   // 10
    "  call wait10         \n"   // 10
    "  call wait10         \n"   // 10
    "  call wait10         \n"   // 10
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait500:              \n"   // 3 for the CALL
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait50         \n"   // 50
    "  call wait10         \n"   // 10
    "  call wait10         \n"   // 10
    "  call wait10         \n"   // 10
    "  call wait10         \n"   // 10
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait1397:             \n"   // 3 for the CALL
    "  call wait500        \n"   // 500
    "  call wait500        \n"   // 500
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait50         \n"   // 50
    "  call wait10         \n"   // 10
    "  call wait10         \n"   // 10
    "  call wait10         \n"   // 10
    "  call wait10         \n"   // 10
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait1433:             \n"   // 3 for the CALL
    "  call wait500        \n"   // 500
    "  call wait500        \n"   // 500
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait10         \n"   // 10
    "  call wait10         \n"   // 10
    "  call wait6         \n"    // 6
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait1463:             \n"   // 3 for the CALL
    "  call wait500        \n"   // 500
    "  call wait500        \n"   // 500
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait50         \n"   // 50
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    "wait1466:             \n"   // 3 for the CALL
    "  call wait500        \n"   // 500
    "  call wait500        \n"   // 500
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait100        \n"   // 100
    "  call wait50         \n"   // 50
    "  call wait8          \n"   // 7
    "  nop                 \n"   // 1
    "  nop                 \n"   // 1
    "  ret                 \n"   // 3
    :  
    :  [porta] "I" (_SFR_IO_ADDR(VPORTA.OUT)),
       [portb] "I" (_SFR_IO_ADDR(VPORTB.OUT))
    : "r20","r21","r22","r23","r24","r25","r26","r27"
  );
}
