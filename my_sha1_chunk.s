.data

 
counter: 	.skip 8
upperBound: 	.skip 8
a:              .skip 4 
b:              .skip 4
c:              .skip 4
d:              .skip 4
e:              .skip 4
f:              .skip 4
temp:           .skip 4
k:              .skip 4

 
wi:             .skip 4
wi3:            .skip 4
wi8:            .skip 4
wi14:           .skip 4
wi16:           .skip 4
 

xor1:           .skip 4
xor2:           .skip 4
xor3:           .skip 4

.text



.global sha1_chunk

#.global main

sha1_chunk:

#main:

 

    # address of h0 into %rdi

    # address of the first 32-bit word of an array... into %rsi

 
    # prologue                  delete after use

    pushq   %rbp                # push the base pointer (and align the stack)
    movq    %rsp, %rbp          # copy stack pointer value to base pointer

    movq $0, %rdx
    movq $0, %rcx
    movq $0, %rax
    movq $0, %r8
    movq $0, %r9
    movq $0, %r10
    movq $0, %r11


	movq $80, upperBound	    # upperBound init
	movq $16, %rdx              # setting the initial displacement

 

	loopWord:

	movl (%rsi,%rdx,4), %r11d    # getting the next element w[i]
	movl %r11d, wi

	movq %rdx, %rcx 
	subq $3, %rcx
	movl (%rsi,%rcx,4), %r11d    # getting the next element w[i-3]
	movl %r11d, wi3

	movq %rdx, %rcx
	subq $8, %rcx
	movl (%rsi,%rcx,4), %r11d    # getting the next element w[i-8]
	movl %r11d, wi8

	movq %rdx, %rcx 
	subq $14, %rcx
	movl (%rsi,%rcx,4), %r11d    # getting the next element w[i-14]
	movl %r11d, wi14

 
	movq %rdx, %rcx 
	subq $16, %rcx
	movl (%rsi,%rcx,4), %r11d    # getting the next element w[i-16]
	movl %r11d, wi16


	movl wi3, %r8d                   # w[i-3] xor w[i-8], result is stored in xor1
	movl wi8, %r9d
	xorl %r8d, %r9d
	movl %r9d, xor1

	movl xor1, %r8d                 # prev xor w[i-14], result is stored in xor2
	movl wi14, %r9d
	xorl %r8d, %r9d
	movl %r9d, xor2

	movl xor2, %r8d                 # prev xor w[i-16], result is stored in xor3
	movl wi16, %r9d
	xorl %r8d, %r9d
	movl %r9d, xor3

	movl xor3, %r9d
	roll $1, %r9d
	
	movl %r9d, (%rsi,%rdx,4)        # storing the value at the address



    incq %rdx                               # preparing the register for fetching the next word 
    movq upperBound, %rax                   # moving upperBound in reg so we can compare
    cmpq %rax, %rdx				        # comparing the counter with the exponent


    jl loopWord

 

    movl (%rdi), %r10d             # variables initialization ??????????
    movl %r10d, a


    movl 4(%rdi), %r10d
    movl %r10d, b


    movl 8(%rdi), %r10d
    movl %r10d, c


    movl 12(%rdi), %r10d
    movl %r10d, d

 
    movl 16(%rdi), %r10d
    movl %r10d, e

 
    movq $0, counter		    # counter init


	mainLoop:

 
	movq $19, %rax                   # moving 19 in reg so we can compare
    cmpq %rax, counter				 # comparing the counter with the exponent
    jle case19

 

	movq $39, %rax                   # moving 39 in reg so we can compare
    cmpq %rax, counter				 # comparing the counter with the exponent
    jle case39

 

    movq $59, %rax                   # moving 59 in reg so we can compare
    cmpq %rax, counter				 # comparing the counter with the exponent
    jle case59

 

    movq $79, %rax                   # moving 79 in reg so we can compare
    cmpq %rax, counter				 # comparing the counter with the exponent
    jle case79

 
	    case19:

	        movl b,%r8d                   # (b and c)
	        movl c,%r9d
	        andl %r8d,%r9d

 
	        movl b,%r8d                   # ((not b) and d)
	        notl %r8d
	        movl d,%r10d
	        andl %r8d,%r10d
	        
	        orl %r9d,%r10d                 # final operation
	        movl %r10d, f                   # storing the final result in f

	        movl $0x5A827999,k

	        jmp end


	   case39:

 

	        movl b,%r8d                   # (b xor c)
	        movl c,%r9d
	        xorl %r8d,%r9d


	        movl d,%r10d                # (prev xor d)
	        xorl %r9d,%r10d

 
	        movl %r10d, f                # storing the final result in f

	        movl $0x6ED9EBA1, k

	        jmp end

 

	    case59:

 
	        movl b,%r8d                   # (b and c)
	        movl c,%r9d
	        andl %r8d,%r9d


	        movl b,%r8d                   # (b and d)
	        movl d,%r10d
	        andl %r8d,%r10d

 
	        movl c,%r8d                   # (c and d)
	        movl d,%r11d
	        andl %r8d,%r11d

 
	        orl %r9d,%r10d                 
	        orl %r10d, %r11d               # final operation

	        movl %r11d, f                # storing the final result in f

	        movl $0x8F1BBCDC, k

	        jmp end

 

	    case79:

 
	        movl b,%r8d                   # (b xor c)
	        movl c,%r9d
	        xorl %r8d, %r9d

 
	        movl d, %r10d                 # (prev xor d)
	        xorl %r9d, %r10d

 
	        movl %r10d, f                # storing the final result in f
 
	        movl $0xCA62C1D6, k

	        jmp end


	end:

 
	movl a, %eax                           # temp calculation
	roll $5, %eax

	movl f, %ecx
	movl e, %edx
	movl k, %r8d
	movq counter, %r9
	movl (%rsi,%r9,4), %r10d


 
	addl %eax, %ecx                    
	addl %ecx, %edx
	addl %edx, %r8d
	addl %r8d, %r10d
	movl %r10d, temp

 

	movl d,%r9d                         # e = d
	movl %r9d,e

 
	movl c,%r9d                         # d = c
	movl %r9d,d

 
	movl b,%r9d                         # c = b leftrotate 30
	roll $30, %r9d
	movl %r9d,c

 
	movl a,%r9d                         # b = a
	movl %r9d,b

 
	movl temp,%r9d                     # a = temp
	movl %r9d,a

 
    incq counter
    movq upperBound, %rax                   # moving upperBound in reg so we can compare
    cmpq %rax, counter				        # comparing the counter with the exponent
    jl mainLoop

 

 
    movl (%rdi), %r10d                      # Add this chunk's hash to result so far
    addl a, %r10d
    movl %r10d, (%rdi)

 
    movl 4(%rdi), %r10d
    addl b, %r10d
    movl %r10d, 4(%rdi)

 
    movl 8(%rdi), %r10d
    addl c, %r10d
    movl %r10d, 8(%rdi)

 

    movl 12(%rdi), %r10d
    addl d, %r10d
    movl %r10d, 12(%rdi)

 
    movl 16(%rdi), %r10d
    addl e, %r10d
    movl %r10d, 16(%rdi)

 

# epilogue

    movq    %rbp, %rsp      # clear local variables from stack
    popq    %rbp            # restore base pointer location 
    ret