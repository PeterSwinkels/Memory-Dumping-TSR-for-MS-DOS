; Memory Dumping TSR for MS-DOS v1.01 - By: Peter Swinkels, ***2021***
ORG 0x0100                ; Indicates that all relative pointers to data are moved forward by 0x0100 bytes.

RedirectedFrom EQU 0x08   ; Defines the interrupt to be redirected.
RedirectedTo EQU 0xFF     ; Defines the redirected interrupt's new vector.

MOV AH, 0x35              ; Checks whether this TSR is already active by checking for a redirected interrupt.
MOV AL, RedirectedTo      ;
INT 0x21                  ;
MOV AX, ES                ;
CMP AX, 0x0000            ;
JNE IsActive              ;
    CMP BX, 0x0000        ;
    JNE IsActive          ;

MOV AH, 0x35              ; Retrieves vector the vector for the interrupt to be redirected.
MOV AL, RedirectedFrom    ;
INT 0x21                  ;

MOV AX, DS                ; Saves the data segment register.
MOV FS, AX                ;

MOV DX, BX                ; Places the retrieved vector at another interrupt.
PUSH ES                   ;
POP DS                    ;
MOV AH, 0x25              ;
MOV AL, RedirectedTo      ;
INT 0x21                  ;

PUSH CS                   ; Sets this TSR's interrupt vector.
POP DS                    ;
MOV DX, TSR               ;
MOV AH, 0x25              ;
MOV AL, RedirectedFrom    ;
INT 0x21                  ;

MOV AX, 0x3100            ; Terminates and stays resident.
MOV DX, 0x00FF            ;
INT 0x21                  ;



IsActive:                 ; Quits if the TSR is already active.
MOV AH, 0x4C              ;
INT 0x21                  ;

TSR:

PUSHA                     ; Saves the registers.
PUSH DS                   ;
PUSH ES

PUSH FS                   ; Restores the data segment register.
POP DS                    ;

%INCLUDE "Memdump.asm"    ; Includes the TSR's main body.

POP ES                    ; Restores the registers.
POP DS                    ;
POPA                      ;

INT RedirectedTo          ; Calls the redirected interrupt.

IRET                      ; Returns.
