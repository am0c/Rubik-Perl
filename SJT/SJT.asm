%include "asm_io.inc"
;
; Petrea Stefan
;   
; Steinhaus - Johnson - Trotter algorithm for generating permutations
; 
; Purpose: Will use this from witin XS code inside SJT_xs

; code was compiled on Linux using nasm(not sure if the syntax is compatible with any other compilers)
; TODO:
;	- the single thing callable outside will be next_perm, C should be able to read the array
;	- 

%define PERM_SIZE 100 ; don't think we'll have permutations of more than 100 numbers to generate..  just allocate space for these
%define NEW_LINE 10

segment .bss
N            dd	    6  ; number of elements to permute

permutation  resd   PERM_SIZE
; how do I initialize permutation with numbers ?


segment .data
Message         db      "Permutation: ",13,10, 0


segment .text
        extern  puts, printf, scanf, dump_line
	global asm_main


asm_main:
        enter   0,0               ; setup routine
        pusha

;#########################################################
; init array
; this code should be rougly equivalent to the C     for(int i=1;i<=5;i++)permutation[i]=i

	mov ecx,1
	mov ebx,permutation ; we print starting at permutation[1]


	


init_array_loop:
	mov [ebx + 4*ecx],ecx
	inc ecx
	cmp ecx,5
	jbe init_array_loop
;#########################################################




; exchanging permutation[1] and permutation[2]
	mov ecx,[ebx+4];put value at address eax in ecx
	mov edx,[ebx+8];put value at address eax in edx
	mov [ebx+4],edx;rewrite them back to memory
	mov [ebx+8],ecx




;#########################################################
; print first 5 elements of array
        mov     eax,  Message
        call    print_string

	mov	ebx, 5
	push 	ebx
        push    dword permutation + 4 ; we just don't print permutation[0]
        call    print_array           

	add	esp,8
;#########################################################

	jmp just_exit




just_exit:
        popa
        mov     eax, 0            ; return back to C
        leave                     
        ret

;#########################################################
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








