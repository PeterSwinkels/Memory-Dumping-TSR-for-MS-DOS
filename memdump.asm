IN AL, 0x60             ; Skips memory dumping unless the F12 key is being pressed.
CMP AL, 0x58            ;
JNE Done                ;

CMP BYTE [Busy], 0x00   ; Check whether a dump is already in progress.
JNE Done                ;

MOV BYTE [Busy], 0x01   ; Sets the flag indicating a dump is progress.

MOV AH, 0x3C            ; Creates the output file.
MOV CX, 0x00            ;
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
   MOV DX, 0x0000              ;
   INT 0x21                    ;
   JC Done                     ;

   ES                          ; Checks whether the last memory block has been reached.
   MOV AX, [MemorySegment]     ;
   CMP AX, 0xF000              ;
   JAE DumpFinished            ;

   ADD AX, 0x1000              ; Moves to the next memory block.
   ES                          ;
   MOV [MemorySegment], AX     ;
JMP Dump

DumpFinished:
MOV AH, 0x3E          ; Closes the output file.
INT 21h               ;
JMP Done

Busy DB 0x00
MemorySegment DW 0x0000
OutputFile DB "MemDump.dat", 0x00

Done:
MOV BYTE [Busy], 0x00   ; Clears the flag indicating a dump is progress.
