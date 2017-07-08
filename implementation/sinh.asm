BITS 64

GLOBAL era_sinh

section .text

era_sinh:
	fstcw word [rsp-10]			;save the x87 Control Word to memory

	fninit					;initialize the x87 FPU

	movlps qword [rsp-8], xmm0		;get the double argument x from SSE Register xmm0 into memory to get it into the FPU
	

	fld qword [rsp-8]			;st0 = x, st1 = precision
	fxam					;if x=0 C3 = 1, if infinity C2 = C0 = 1
	fstsw ax				;store x87 FPU SW in ax
	sahf					;load EFLAGS from ah
						;important for here CF = C0 and ZF = C3
	jbe .end				;jump if (CF or ZF) = 1

	fld st0					;st0 = x, st1 = x, st2 = precision
						
	fabs					;st0 = |x|

	fdiv st1, st0				;st1 = x/|x|, either 1 or -1
	
	fld st0					;I can only get a 64 Bit Integer out of the FPU with popping, so dublicating x here
	fistp qword [rsp-8]			;get x as integer into memory
	fwait					;wait that that is done
	mov rcx, qword [rsp-8]			;then get that integer into rxc
	shr rcx, 3				;divide it by 8
	mov rax, rcx				;save that into rax
	shl rcx, 2				;now multiply rcx with 4
	add rcx, rax				;add rax to rcx
	add rcx, 45				;add 45 to rcx, so now rcx = 45+5/8x
	cmp rcx, 489				;compare rcx with 489
	jbe .passt				;skip the next line if rcx <= 489
	mov rcx, 489				;if rcx was bigger set it to 489, this is done so that inputs > 710 don't run forever and still output +/- infinite
						;in theory we could change it to jump to an alternate end to directly output infinity, the problem with that is we still need to make it the appropriate infinity (+/-) and I'm not sure of a good way to do that.
						;but it might be, that even a "bad" way is faster than what I'm doing right now, but we need to test that once we have nice tests ready to use."
.passt:	

	fld1					;load conatant 1
						;st0 = 1, st1 = x, st2 = sign, st3 = precision	

	fld st1					;result = x
						;st0 = result, st1= 1, st2 = x, st3 = sign, st4 = precision

	fld1					;i = 1
						;st0 = i, st1 = result, st2= 1, st3 = x, st4 = sign, st5 = precision

	fld st3					;previous = x
						;st0 = previous, st1 = i, st2 = result, st3= 1, st4 = x, st5 = sign, st6 = precision
.loop:			
	fincstp					;st7= previous, st0 = i, st1 = result, st2 = 1, st3 = x, st4 = sign, st5 = precision
	fadd st0, st2				;i++
	fdecstp					;st0= previous, st1 = i, st2 = result, st3 = 1, st4 = x, st5 = sign, st6 = precision
	fdiv st0, st1				;previous = previous / i
	fmul st0, st4				;previous = previous * x

	fincstp					;st7= previous, st0 = i, st1 = result, st2 = 1, st3 = x, st4 = sign, st5 = precision
	fadd st0, st2				;i++
	fdecstp					;st0= previous, st1 = i, st2 = result, st3 = 1, st4 = x, st5 = sign, st6 = precision
	fdiv st0, st1				;previous = previous / i
	fmul st0, st4				;previous = previous * x

	fadd st2, st0				;result = result + previous

	dec ecx					;decrement ecx
	jnz .loop				;jump to .loop if ecx != 0

	fincstp
	fincstp					;st6= previous, st7 = i, st0 = result, st1 = 1, st2 = x, st3 = sign, st4 = precision
	fmul st0, st3				;st0 = result * sign

.end:
	fstp qword [rsp-8]			;save output into memory

	movlps xmm0, [rsp-8]			;load output from memory to xmm0 to return it
	fldcw word [rsp-10]			;restore the x87 FPU Control Word from memory
ret

