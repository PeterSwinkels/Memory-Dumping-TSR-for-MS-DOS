; Memory Dumping module for TSR.

MOV WORD BX, [CEInDOS_Offset]    ; Skips memory dumping if either the critical error or InDOS flag are set.
MOV WORD ES, [CEInDOS_Segment]   ;
ES                               ;
CMP BYTE [BX - 0x01], 0x00       ;
JNE Done                         ;
ES                               ;
CMP BYTE [BX], 0x00              ;
JNE Done                         ;

IN AL, 0x60             ; Skips memory dumping unless the F12 key is being pressed.
CMP AL, 0x58            ;
JNE Done                ;

CMP BYTE [Busy], 0x00   ; Checks whether a dump is already in progress.
JNE Done                ;

MOV BYTE [Busy], 0x01   ; Sets the flag indicating a dump is in progress.

MOV AH, 0x3C            ; Creates the output file.
XOR CX, CX              ;
LEA DX, OutputFile      ;
INT 0x21                ;
JC Done                 ;

MOV BX, AX              ; Closes the newly created output file.
MOV AH, 0x3E            ;
INT 21h                 ;
JC Done                 ;

MOV AX, 0x3D01          ; Opens the output file for writing.
LEA DX, OutputFile      ;
INT 0x21                ;
JC Done                 ;

MOV BX, AX              ; Retrieves the filehandle.

MOV WORD [MemorySegment], 0x0000    ; Sets the first memory block.

MOV AX, DS   ; Saves the current data segment.
MOV ES, AX   ;

Dump:
   ES                          ; Sets the memory block to be written to the output file.
   MOV AX, [MemorySegment]     ;
   MOV DS, AX                  ;

   MOV AH, 0x40                ; Writes the memory block to the output file.
   MOV CX, 0xFFFF              ;
   XOR DX, DX                  ;
   INT 0x21                    ;
   JC Done                     ;

   ES                          ; Checks whether the last memory block has been reached.
   MOV AX, [MemorySegment]     ;
   CMP AX, 0xF000              ;
   JAE DumpFinished            ;

   ADD AX, 0x1000              ; Moves to the next memory block.
   ES                          ;
   MOV [MemorySegment], AX     ;
JMP SHORT Dump                 ;

DumpFinished:
MOV AH, 0x3E          ; Closes the output file.
INT 21h               ;
JMP SHORT Done        ;

Busy DB 0x00
CEInDOS_Offset DW 0x0000
CEInDOS_Segment DW 0x0000
MemorySegment DW 0x0000
OutputFile DB "MemDump.dat", 0x00

Done:
MOV BYTE [Busy], 0x00   ; Clears the flag indicating a dump is progress.
