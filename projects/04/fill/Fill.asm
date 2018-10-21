// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed.
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

@8191
D=A
@max
M=D // memory width of Hack screen


(LISTEN)
  @pos // pos = 0
  M=0

  @KBD
  D=M
  @FILLBLACK
  D;JGT // if KBP > 0 goto FILLBLACK
  @FILLWHITE
  0;JMP // else goto FILLWHITE


(FILLBLACK)
  // if (pos==max) goto LISTEN
  @max
  D=M
  @pos
  D=M-D
  @LISTEN
  D;JGT

  // RAM[SCREEN + pos] = -1
  @SCREEN
  D=A
  @pos
  A=D+M
  M=-1

  // pos++
  @pos
  M=M+1

  // Repeat
  @FILLBLACK
  0;JMP


(FILLWHITE)
  // if (pos==max) goto LISTEN
  @max
  D=M
  @pos
  D=M-D
  @LISTEN
  D;JGT

  // RAM[SCREEN + pos] = 0
  @SCREEN
  D=A
  @pos
  A=D+M
  M=0

  // pos++
  @pos
  M=M+1

  // Repeat
  @FILLWHITE
  0;JMP
