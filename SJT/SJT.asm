%include "asm_io.inc"
;
; Petrea Stefan
;   
; Steinhaus-Johnson-Trotter algorithm for generating permutations
; 
; Purpose: Will use this from witin XS code inside SJT_xs
;
; Code was assembled on Linux using nasm(not sure if the syntax is compatible with any other assemblers)
;
; TODO:
;	- the single thing callable outside will be next_perm, C should be able to read the array
;	- low use of any subroutines for sheer speed
;	- heavy commenting so I don't forget things 
;	- after the algo is working properly, make the code take the effective address(pointer?) needed to
;	  write the data at, instead of using "permutation" from the .data section,or find a way of telling C
;	  that the data resides at the pointer "permutation" in the .data section so it can hand it to Perl which will
;	  pack/unpack(use perldoc to find out more about those) on it in order to get the needed data
;	- further optimizations would include taking advantage of the fact that inside a 32bit
;	  register I can fit two 8-bit integers with their directions also, so I can store the
;	  max and its neighbour
;	- write tests .. in assembly , or maybe Perl ?  :)
;
;
; Note: this code was written and tested on x86 linux, I do not plan to port it to any other platform/architecture
;	(at least not very soon)
;


%define PERM_SIZE 100 ; don't think we'll have permutations of more than 100 numbers to generate..  just allocate space for these
%define NEW_LINE 10
%define ITERATIONS 23 ; this will be removed after testing is over
%define LEFT  0
%define RIGHT 1

segment .bss



segment .data
Message         db      "Permutation: ",13,10, 0
dbg1         db      "------end of loop---------",13,10, 0
N            dd	    4 ; number of elements to permute
max	     dd	    0
maxpos	     dd	    0

;permutation resd PERM_SIZE ; this would be the normal definition but we'll use something else for testing
permutation  dd  0,1,2,3,4,5,6,7,8,9
dbg_array    dd  0,0  ; array with neighbours to be swapped

segment .text
        extern  puts, printf, scanf, dump_line
	global asm_main


asm_main:
        enter   0,0               ; setup routine
        pusha

;#########################################################
; init array
;
; 
; DDDDDDDDNNNNNNNN
; in first 8 bits we store direction, next 8 bits we store the number
; this code should be rougly equivalent to the C     
; for(int i=1;i<=5;i++)permutation[i]= i + (0<<8) // writing that to indicate that direction if equivalent to LEFT initially




	;mov ecx,1
	;mov ebx,permutation ; we print starting at permutation[1]
;init_array_loop:

	;mov edx,ecx

	;mov [ebx + 4*ecx],edx
	;inc ecx
	;cmp ecx,[N]
	;jbe init_array_loop




	mov	ebx, [N]
	push 	ebx
	push    dword permutation + 4 ; we just don't print permutation[0] , we just skip it with +4
	call    print_array           
	add	esp,8
	call    print_nl ; this was the identical permutation




	mov ecx,ITERATIONS ; 24 permutations in total
	perm_loop:
		call next_perm
		;#########################################################
		; print first N elements of array
		mov	ebx, [N]
		push 	ebx
		push    dword permutation + 4 ; we just don't print permutation[0] , we just skip it with +4
		call    print_array           
		add	esp,8
		call    print_nl           
		;#########################################################
	loop perm_loop

	the_bug:
		call next_perm
	



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

;int nextperm(SV *self) {
;	int k = emobile(self);
;	int max_mob = df(permut(k));
;	int n = getn(self);
;	int i;
;
;	//printf("mobile integer on position: %d with value:%d\n",k,max_mob);
;
;	if(k==0)
;		return 0;
;
;	xchg2__(self,k,p(k)); // exchange positions k and p(k)
;
;	//invert direction of mobile integers
;	for(i=1;i<=n;i++)
;		if(df(permut(i))>max_mob)
;			invert_direct(self,i);
;}

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx

	mov eax,1 ; i
	mov dword [max],0    ;max = 0
	mov dword [maxpos],0 ;maxpos = 0

emobile_loop:
	; here we'll find if permutation[eax] is a mobile integer and if so we'll store eax in maxpos



	mov ebx,eax
	shl ebx,2
	mov ecx,permutation
	add ecx,ebx  ; pointer to the eaxth integer in the permutation array a.k.a  permutation + 4*eax



	;next we'll determine if permutation[eax] is mobile or not
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



	add ebx,eax ; ebx = direction + position (aka neighbour)
	shl ebx,2
	mov edx,ebx
	add edx,permutation; edx = permutation + 4*(eax+ebx)
	
	
	; edx will be the neighbour of permutation[eax] in the appropriate direction
	mov edx,[edx]
	xor dh,dh; we're not interested in the direction any more,just the number

	; edx has the following structure 
	; [ 16 bits          | dh-8 bits | dl-8 bits]

	mov ebx,eax
	shl ebx,2
	add ebx,permutation; ebx = permutation + 4*ebx

	mov ebx,[ebx]
	xor bh,bh; only interested in the number again

	; after this ebx and edx are neighbours and we're on ebx right now

	cmp edx,ebx     ; if it's bigger than its neighbour then it's mobile
	jge not_mobile

	mobile:

	mov edx,[max]
	xor dh,dh


	cmp edx,ebx
	jb new_max
	jmp jump_over4
	new_max:
		push ebx
			mov [max],ebx   
			mov [maxpos],eax
		pop ebx
	jump_over4:


	;push eax
		;mov eax,ebx
		;call print_int; print the mobile integer
	;pop eax



	jmp after_mobility_check
	not_mobile:
	
	after_mobility_check:




	;push eax
		;mov eax,dbg1
		;call print_string
	;pop eax

	inc eax
	cmp eax,[N]
	jbe emobile_loop
	;eax can be used again as we want...we aren't using it
	;any more as a loop counter from here on



	cmp dword [max],0   ; if(k==0) return 0
	je finish_next_permute


swap: ; tried to store in neighbours just addresses(need to look more on this)

	


	;xchg2
	mov ecx,[maxpos]
	shl ecx,2
	add ecx,permutation; ecx is pointer to position where max is located


	;edx will be its neighbour
	mov edx,ecx
	mov edx,[edx]
	shr edx,8

	cmp edx,LEFT    
	jne jump_over6
	sub edx,1
	jump_over6:; so edx is -1 if direction of neighbour is LEFT and +1 if RIGHT

	add edx,[maxpos]
	shl edx,2
	add edx,permutation ; edx points to neighbour of max


	mov eax,[ecx]
	mov ebx,[edx]
	mov [ecx],ebx
	mov [edx],eax
	;swapped max and its neighbour


; next we'll flip direction for the positions which are greater than [max]

	mov ecx,[N]
	mov edx,[max]
flip_dir_loop:

	mov ebx,[permutation+ecx*4]
	xor bh,bh 
	cmp ebx,edx ; we compare just the numbers and not use the direction
	jbe skip_flip

		mov eax,[permutation+ecx*4]
		xor ah,1
		mov [permutation+ecx*4],eax

	skip_flip:


	loop flip_dir_loop



; exchanging permutation[1] and permutation[2]



finish_next_permute:


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
        push    ecx

        xor     esi, esi                  ; esi = 0
        mov     ecx, [ebp+12]             ; ecx = n
        mov     ebx, [ebp+8]              ; ebx = address of array
print_loop:
        push    ecx                       ; printf might change ecx!

        ;push    dword [ebx + 4*esi] (this is the esi-th position of the array,
	;			      but we don't need the direction so we xor it)

	mov     eax, [ebx+4*esi]

	push eax
		shr eax,8

		cmp eax,RIGHT
		jne skip_increase
			inc eax
		skip_increase

		add eax,0x3C  ; at the end of this eax contains '<' if LEFT and '>' if RIGHT was in AH

		call print_char 
	pop eax

	xor ah,ah
	push eax

        push    dword OutputFormat
        call    printf

        add     esp,8                  ; remove parameters (leave ecx!)

        inc     esi
        pop     ecx
        loop    print_loop


        pop     ecx
        pop     ebx
        pop     esi
        leave
        ret

