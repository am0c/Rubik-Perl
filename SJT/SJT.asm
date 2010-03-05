%include "asm_io.inc"
;
; Petrea Stefan
;   
; Steinhaus - Johnson - Trotter algorithm for generating permutations
; 
; Purpose: Will use this from witin XS code inside SJT_xs

%define PERM_SIZE 100 ; don't think we'll have permutations of more than 100 numbers to generate..  just allocate space for these
%define NEW_LINE 10

segment .bss
N            dd	    6  ; number of elements to permute

permutation  resd   PERM_SIZE
segment .data
Message         db      "Permutation: ",13,10, 0






segment .text
        extern  puts, printf, scanf, dump_line
	global asm_main


asm_main:
        enter   0,0               ; setup routine
        pusha


        mov     eax,  Message
        call    print_string



	
	mov	ebx, 5
	push 	ebx
        push    dword permutation
        call    print_array           
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
OutputFormat    db   "%d,", 0
empty_line	db   "",NEW_LINE,0

segment .text
        global  print_array
print_array:
	; ebp is the stack pointer so we need to refer to it if we're going to take elements off the stack
	; (pop could be equivalently used)
        enter   0,0
        push    esi
        push    ebx

        xor     esi, esi                  ; esi = 0
        mov     ecx, [ebp+12]             ; ecx = n
        mov     ebx, [ebp+8]              ; ebx = address of array
print_loop:
        push    ecx                       ; printf might change ecx!

        push    dword [ebx + 4*esi]       ; push array[esi]
        ;push    esi
        push    dword OutputFormat
        call    printf
        add     esp, 8                  ; remove parameters (leave ecx!)

        inc     esi
        pop     ecx
        loop    print_loop



	push	dword empty_line
	call	printf

        pop     ebx
        pop     esi
        leave
        ret

