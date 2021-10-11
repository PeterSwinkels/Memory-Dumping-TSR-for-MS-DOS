; Memory Dumping TSR for MS-DOS - By: Peter Swinkels, ***2021***
ALIGN 0x01, DB 0x90     ; Defines alignment.
BITS 16                 ; Defines the segment size used by this program.
ORG 0x0100              ; Indicates that all relative pointers to data are moved forward by 0x0100 bytes.

TSR_VECTOR EQU 0x08       ; Defines the interrupt to be redirected.

JMP NEAR Main             ; Jumps to the main entry point.

TSR:
PUSHA                     ; Saves the registers.
PUSH DS                   ;
PUSH ES                   ;

PUSH CS                   ; Restores the data segment register.
POP DS                    ;

%INCLUDE "Memdump.asm"    ; Includes the TSR's code file.

PUSHF                     ; Calls the redirected interrupt.
CS                        ;
CALL FAR [Redirected]     ;

POP ES                    ; Restores the registers.
POP DS                    ;
POPA                      ;

IRET                      ; Returns.
EndTSR:

Main:
MOV AH, 0x09              ; Displays the TSR "start" message.
MOV DX, TSR_Start_Msg     ;
INT 0x21                  ;

MOV AL, [IsActiveFlag]    ; Checks whether this TSR is already active.
CMP AL, 0x00              ;
JNE IsActive              ;

MOV BYTE [IsActiveFlag], 0x01  ; Sets this TSR as being active.

MOV AH, 0x34                ; Retrieves the address of the critical error and InDOS flags.
INT 0x21                    ;
MOV [CEInDOS_Offset], BX    ;
MOV [CEInDOS_Segment], ES   ;

MOV AH, 0x35                  ; Retrieves vector the vector for the interrupt to be redirected.
MOV AL, TSR_VECTOR            ;
INT 0x21                      ;
MOV [Redirected_Segment], ES  ;
MOV [Redirected_Offset], BX   ;

PUSH CS                   ; Sets this TSR's interrupt vector.
POP DS                    ;
MOV DX, TSR               ;
MOV AH, 0x25              ;
MOV AL, TSR_VECTOR        ;
INT 0x21                  ;

MOV AH, 0x09              ; Displays the TSR "activated" message.
MOV DX, TSR_Activated_Msg ;
INT 0x21                  ;

MOV AX, 0x3100            ; Terminates and stays resident.
MOV DX, EndTSR            ;
ADD DX, 0x0F              ;
SHR DX, 0x04              ;
INT 0x21                  ;

IsActive:                 ; 
MOV AH, 0x09              ; Displays the TSR "already active" message.
MOV DX, TSR_Activate_Msg  ;
INT 0x21                  ;

MOV AH, 0x4C              ; Quits if the TSR is already active.
INT 0x21                  ;

IsActiveFlag DB 0x00
Redirected:
Redirected_Offset DW 0x0000
Redirected_Segment DW 0x0000
TSR_Activate_Msg DB "Already active!", 0x0D, 0x0A, "$"
TSR_Activated_Msg DB "Activated.", 0x0D, 0x0A, "$"
TSR_Start_Msg DB "Memory Dumping TSR for MS-DOS v1.08 - by: Peter Swinkels, ***2021***"
DB 0x0D, 0x0A
DB "F12 = Dump conventional memory."
DB 0x0D, 0x0A
DB "$"
