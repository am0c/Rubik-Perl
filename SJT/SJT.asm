%include "asm_io.inc"
;
; Petrea Stefan
;   
; Steinhaus - Johnson - Trotter algorithm for generating permutations
; 
; Purpose: Will use this from witin XS code inside SJT_xs

; code was compiled on Linux using nasm(not sure if the syntax is compatible with any other compilers)
;
; TODO:
;	- the single thing callable outside will be next_perm, C should be able to read the array
;	- low use of any subroutines for sheer speed
;	- heavy commenting so I don't forget things 
;	- after the algo is working properly, make the code take the effective address(pointer?) needed to
;	  write the data at, instead of using "permutation" from the .data section,or find a way of telling C
;	  that the data resides at the pointer "permutation" in the .data section so it can hand it to Perl which will
;	  pack/unpack(use perldoc to find out more about those) on it in order to get the needed data
;	- write tests .. in assembly , or maybe Perl ?  :)
;

%define PERM_SIZE 100 ; don't think we'll have permutations of more than 100 numbers to generate..  just allocate space for these
%define NEW_LINE 10
%define LEFT  0
%define RIGHT 1

segment .bss



segment .data
Message         db      "Permutation: ",13,10, 0
dbg1         db      "------end of loop---------",13,10, 0
N            dd	    9 ; number of elements to permute
max	     dd	    0
maxpos	     dd	    0
permutation resd PERM_SIZE
segment .text
        extern  puts, printf, scanf, dump_line
	global asm_main


asm_main:
        enter   0,0               ; setup routine
        pusha

;#########################################################
; init array
; 
; DDDDDDDDNNNNNNNN
; in first 8 bits we store direction, next 8 bits we store the number
; this code should be rougly equivalent to the C     
; for(int i=1;i<=5;i++)permutation[i]= i + (0<<8) // writing that to indicate that direction if equivalent to LEFT initially

	mov ecx,1
	mov ebx,permutation ; we print starting at permutation[1]

init_array_loop:

	mov edx,ecx
	;add edx,0		; i + (1<<8)

	mov [ebx + 4*ecx],edx
	inc ecx
	cmp ecx,[N]
	jbe init_array_loop
;#########################################################


	call next_perm




;#########################################################
; print first 5 elements of array
        mov     eax,  Message
        call    print_string

	mov	ebx, [N]
	push 	ebx
        push    dword permutation + 4 ; we just don't print permutation[0] , we just skip it with +4
        call    print_array           

	add	esp,8
;#########################################################

	jmp just_exit



;#########################################################
; compute the next permutation inside permutation array
next_perm:
	enter	0,0
	pusha
	pushf

; The C code which we'll be porting :
;int mobile(SV *self,int pos) {
;	if(p(pos) > getn(self) || p(pos)==0)
;		return 0;
;	return df(permut(p(pos))) < df(permut(pos));
;}
;
;
;
;// gets the biggest mobile integer if any
;int emobile(SV *self) {
;	int maxpos = 0;
;	int max    = 0;
;	int n = getn(self);
;	int i;
;	for(i=1;i<=n;i++) {
;		if(!mobile(self,i))
;			continue;
;		int perm = df(permut(i));
;		if(perm > max) {
;			maxpos = i;
;			max    = perm;
;			if(max == n) {
;				return maxpos;
;			}
;		};
;	}
;	return maxpos;
;}




	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx

	mov eax,1 ; i
emobile_loop:
	; here we'll find if permutation[eax] is a mobile integer and if so we'll store eax in maxpos

	mov dword [max],0    ;max = 0
	mov dword [maxpos],0 ;maxpos = 0


	mov ebx,eax
	shl ebx,2
	mov ecx,permutation
	add ecx,ebx  ; pointer to the eaxth integer in the permutation array a.k.a  permutation + 4*eax



	;next we'll determin if permutation[eax] is mobile or not
	mov ebx,[ecx] ; ebx = permutation[eax]
	shr ebx,8     ; ebx now contains the direction of the integer

	;first check edge cases


	; if it's the first position and direction is LEFT then it's not mobile
	cmp eax,1
	jne jump_over1

		cmp ebx,LEFT
		je  not_mobile

	jump_over1:



	; if it's the last position and direction is RIGHT then it's not mobile
	cmp eax, [N]
	jne jump_over2

		cmp ebx,RIGHT
		je not_mobile

	jump_over2:


	cmp ebx,LEFT    ; if ebx is LEFT , that means 0 , then turn it into -1 so we can use it to add to positions
	jne jump_over3
	sub ebx,1
	jump_over3:     ; here ebx can contain -1 or +1 depending on the direction LEFT or RIGHT



	add ebx,eax
	shl ebx,2
	mov edx,ebx
	add edx,permutation
	
	; edx = permutation + 4*(eax+ebx)
	; edx will be the neighbour of permutation[eax] in the appropriate direction
	mov edx,[edx]

	xor dh,dh; we're not interested in the direction any more,just the number
	mov ebx,[permutation+4*eax]
	xor bh,bh; only interested in the number again

	cmp dh,bh
	jge not_mobile

	mobile:


	push edx       ; print the mobile integer
	call print_int


	jmp after_mobility_check
	not_mobile:
	
	after_mobility_check:



	mov eax,dbg1
	call print_string

	inc eax
	cmp eax,[N]
	jbe emobile_loop







; exchanging permutation[1] and permutation[2]
	mov ecx,[permutation+4];put value at address eax in ecx
	mov edx,[permutation+8];put value at address eax in edx
	mov [permutation+4],edx;rewrite them back to memory
	mov [permutation+8],ecx





	popf
	popa
	leave
	ret
;#########################################################



just_exit:
        popa
        mov     eax, 0            ; return back to C
        leave                     
        ret

;#########################################################
; routine print_array
; C-callable routine that prints out elements of a double word array as unsigned integers.
; C prototype:
; void print_array( const int * a, int n);
; Parameters:
;   a - pointer to array to print out (at ebp+8 on stack)
;   n - number of integers to print out (at ebp+12 on stack)

segment .data
OutputFormat    db   "%u,", 0 
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








