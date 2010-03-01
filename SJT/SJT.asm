%include "asm_io.inc"
;
; Petrea Stefan
;   
; Steinhaus - Johnson - Trotter algorithm for generating permutations
; 
; Purpose: Will use Inline::ASM and use this to replace Algorithm::Permute from Perl

%define PERM_SIZE 100 ; don't think we'll have permutations of more than 100 numbers to generate..
%define NEW_LINE 10

segment .data
Message         db      "Permutation: ", 0


segment .bss
N            dd	    4               ; number of elements to permute
permutation  resd   PERM_SIZE




segment .text
        extern  puts, printf, scanf, dump_line
	global asm_main


asm_main:
        enter   0,0               ; setup routine
        pusha


        mov     eax,  Message
        call    print_string

	mov	ebx, 4
	push 	ebx
        push    dword permutation
        call    print_array           ; print first 10 elements of array
	add	esp,8



        popa
        mov     eax, 0            ; return back to C
        leave                     
        ret

;
; routine print_array
; C-callable routine that prints out elements of a double word array as
; signed integers.
; C prototype:
; void print_array( const int * a, int n);
; Parameters:
;   a - pointer to array to print out (at ebp+8 on stack)
;   n - number of integers to print out (at ebp+12 on stack)

segment .data
OutputFormat    db   "%-5d %5d", NEW_LINE, 0

segment .text
        global  print_array
print_array:
        enter   0,0
        push    esi
        push    ebx

        xor     esi, esi                  ; esi = 0
        mov     ecx, [ebp+12]             ; ecx = n
        mov     ebx, [ebp+8]              ; ebx = address of array
print_loop:
        push    ecx                       ; printf might change ecx!

        push    dword [ebx + 4*esi]       ; push array[esi]
        push    esi
        push    dword OutputFormat
        call    printf
        add     esp, 12                   ; remove parameters (leave ecx!)

        inc     esi
        pop     ecx
        loop    print_loop

        pop     ebx
        pop     esi
        leave
        ret

