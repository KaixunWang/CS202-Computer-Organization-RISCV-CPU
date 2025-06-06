.data
test: .word 1
.text

_start:
    # 构造 led 地址：0xFFFFF000 -504  + 00001000= 0xFFFFFE08（读8位有符号）
    lui t2, 0x1                 # t2 = 0x00001000，用于补高地址
    lui a1,0xfffff
    addi a1,a1, -504
    add a1,a1,t2
    
    li s0, 0x00000100  # save to a
    li s1, 0x00000104  # save to b
    li s2, 0x00000108  # save to c
    #segment hex
    lui t2,0x1
    lui a2,0xfffff
    addi a2,a2,-380
    add a2,a2,t2
    
    #segment decimal
    lui t2,0x1
    lui a3,0xfffff
    addi a3,a3,-376
    add a3,a3,t2
    
    # 构造 switch 地址：0xFFFFFE40 + 8 = 0xFFFFFE48（读8位）
    lui t2, 0x1                 # t2 = 0x00001000，用于补高地址
    lui a4, 0xfffff             # a4 = 0xfffff000
    addi a4, a4, -432           # a4 = 0xfffff000 - 432 = 0xffffee50
    add a4, a4, t2              # a4 = 0xfffffe50（最终 switch 地址）
    #a4: address of switch right 8 bit (input)
    
    # 构造 switch 地址：0xFFFFFE40 + 8 = 0xFFFFFE50（testcase）
    lui t2, 0x1                 # t2 = 0x00001000，用于补高地址
    lui a5, 0xfffff             # a5 = 0xfffff000
    addi a5, a5, -444           # a5 = 0xfffff000 - 440 = 0xffffee44
    add a5, a5, t2              # a5 = 0xfffffe44（最终 switch 地址）
    #a5: address of switch left 3 bits (input testcase number)
    
    # 构造 enter_key 地址：0xFFFFFE54
    lui a6, 0xfffff             # a6 = 0xfffff000
    addi a6, a6, -428           # a6 = 0xfffff000 - 428 = 0xffffee54
    add a6, a6, t2              # a6 = 0xfffffe54（最终 switch 地址）
    lw s10,(a6)
    lw t1,0(a5)
    sw t1,0(a1)
    sw t1,0(a3)
    beqz s10,_start 		#为1跳出死循环
    
    #clean led and seg content
    sw x0,0(a1)
    sw x0,0(a3)


    li    t2, 0
    beq   t1, t2, case_0
    li    t2, 1
    beq   t1, t2, case_1
    li    t2, 2
    beq   t1, t2, case_2
    li    t2, 3
    beq   t1, t2, case_3
    li    t2, 4
    beq   t1, t2, case_4
    li    t2, 5
    beq   t1, t2, case_5
    li    t2, 6
    beq   t1, t2, case_6
    li    t2, 7
    beq   t1, t2, case_7
    j     _start
    
    case_0:
    # 从 switch 读取无符号8位数值 000000FF
    lbu t3, 0(a4)               # 读取 switch 的右8位无符号值
    sw t3,0(a1)
    lw s8,(a6)
    bnez s8,case_0
    case_0_stop:
    lw s8,(a6)
    beqz s8,case_0_stop
    
    li t0,8
    li t4,0
    loop0:
    andi t2,t3,1
    add t4,t4,t4
    add t4,t4,t2		# 把取出的 bit 加入到 t4 低位
    srli t3,t3,1
    addi t0,t0,-1
    bnez t0,loop0
    
    # 写入 LED 的右8位
    sw t4, 0(a1)                # 写入 LED 的左8位
    j end
    
    case_1: #lb a FFFFFFFF
    # 从 switch 读取无符号8位数值 000000FF
    lbu t3, 0(a4)               # 读取 switch 的右8位无符号值
    add t5,t3,zero
    li t0,8
    li t4,0
    loop1:
    andi t2,t3,1
    add t4,t4,t4
    add t4,t4,t2		# 把取出的 bit 加入到 t4 低位
    srli t3,t3,1
    addi t0,t0,-1
    bnez t0,loop1
    beq t5,t4,is_palindrome
    sw zero,(a1)
    j end
    is_palindrome: 
    li t0,1#palindrom
    sw t0,(a1)
    j end
    
    case_2: #lb 2 000000FF
    #input a
    
    lbu t1,(a4)
    sw t1,(s0)		# 存进a
    
    andi t2,t1,112
    beq t2,zero,sw2_a	# 判断非规格
    li t2,16		# t2存答案(初始为10000)
    mv t3,t1
    andi t3,t3,15	# 得到位数
    
    srli t4,t1,4		
    andi t4,t4,7
    addi t4,t4,-7	# 得到指数
    srli t5,t1,7	# 得到符号位
    
    add t2,t2,t3
    
    bgt t4,zero,loop2_a1
    blt t4,zero,loop2_a2
    beq t4,zero,sw2_a #111111111111111111111111111111111111111111111111111111111111111
    
    loop2_a1:
    add t2,t2,t2
    addi t4,t4,-1
    bgt t4,zero,loop2_a1
    j sw2_a
    
    loop2_a2:
    srli t2,t2,1
    addi t4,t4,1
    blt t4,zero,loop2_a2
    
    sw2_a:
    beqz t5,show2_a
    sub t2,zero,t2
    show2_a:
    sw t5,(a1)
    sw t2,(a3)		# seg
    

   loop2_mid1:
    lw s10,(a6)# enter_key5431111111111111111111111111111111111
    bne s10,zero,loop2_mid1 	# 为0跳出死循环 
    
    loop2_mid2: # enter_key 
    lw s10,(a6)
    beqz  s10,loop2_mid2	# 为1跳出死循环
    
     
    
    #input b
    lbu t1,(a4)
    sw t1,(s1)		# 存进b
    andi t2,t1,112
    beq t2,zero,sw2_b	# 判断非规格
    
    li t2,16		# t2存答案(初始为10000)
    mv t3,t1
    andi t3,t3,15	# 得到位数
    
    srli t4,t1,4		
    andi t4,t4,7
    addi t4,t4,-7	# 得到指数
    srli t5,t1,7	# 得到符号位
    
    add t2,t2,t3
    
    bgt t4,zero,loop2_b1
    blt t4,zero,loop2_b2
    beq t4,zero,sw2_b
    
    loop2_b1:
    add t2,t2,t2
    addi t4,t4,-1
    bgt t4,zero,loop2_b1
    j sw2_b
    
    loop2_b2:
    srli t2,t2,1
    addi t4,t4,1
    blt t4,zero,loop2_b2
    
    sw2_b:
    beqz t5,show2_b
    sub t2,zero,t2
    show2_b:
    sw t5,(a1)
    sw t2,(a3)		# LED
    
    j end
    
    case_3: 
    lbu t1,(s0)# a + b11111111111111111111111111111111111111111111111111111
    lbu t2,(s1)
    
    andi t3,t1,112
    bnez t3,normal3_a	# 判断非规格(小)
    andi t3,t3,15
    slli t3,t3,1
    j solve3_b
    normal3_a:
    andi t3,t1,15	# and 00001111 = 15 
    addi t3,t3,16	# 得到位数
    
    srli t4,t1,4	
    andi t4,t4,7
    # addi t4,t4,-3	# 得到指数
    beqz t4,solve3_b
    loop3_a:
    slli t3,t3,1
    addi t4,t4,-1
    bnez t4,loop3_a
    
    solve3_b:
    
    andi t4,t2,112
    bnez t4,normal3_b	# 判断非规格(小)
    andi t4,t4,15
    slli t4,t4,1
    j add3
    
    normal3_b:
    andi t4,t2,15	# and 00001111 = 15 
    addi t4,t4,16	# 得到位数
    
    srli t5,t2,4	
    andi t5,t5,7
    # addi t4,t4,-3	# 得到指数
    beqz t5,add3
    loop3_b:
    slli t4,t4,1
    addi t5,t5,-1
    bnez t5,loop3_b
    
    add3:
    srli t1,t1,7
    srli t2,t2,7	# t1,t2之后为符号位
    beq t1,t2,same_sign
    j diff_sign
    
    same_sign:
    add t3,t3,t4# t3 = t3 + t4 
    srli t3,t3,7
    beq t1,zero,show3
    sub t3,zero,t3
    sw t1,(a1)
    j show3
    
    diff_sign:
    blt t3,t4,less3
    j greater3
    less3:
    sub t3,t4,t3
    srli t3,t3,7
    beqz t2,show3
    sub t3,zero,t3
    sw t2,(a1)
    j show3
    greater3:
    sub t3,t3,t4
    srli t3,t3,7
    beqz t1,show3
    sub t3,zero,t3
    sw t1,(a1)
    j show3
    
    show3:
    sw t3,(a3)	# show in led decimal
    
    j end
    
   case_4: # CRC 4bit
    lbu t0,(a4)
    li t1,19
    slli t0,t0,4
    li t2,3 # 除数左移的位数
    li t3,7 # 判断当前被除数位数是否为1需要右移的位数
    
    loop4:
    sll t4,t1,t2
    srl t5,t0,t3
    andi t6,t5,1
    beqz t6,cont4
    xor t0,t0,t4 # 除
    cont4:
    addi t2,t2,-1
    addi t3,t3,-1
    bge t2,zero,loop4
    
    loop4_2: # 找到四位有效数字
    li t1,16
    blt t0,t1,done4
    srli t0,t0,1
    j loop4_2
    
    done4:
    lw t1, (a4)        # 重新读取原始数据
    andi t1, t1, 0xF   # 保留低4位
    slli t1, t1, 4     # 左移4位，准备作为高4位
    or t0, t0, t1      # 将原始数据拼到高位，CRC 在低位
    sw t0, (a1)
    sw t0, (s2)
    j end
    
    case_5: # CRC 8bit
    lbu t1,(s2)
    lbu t0,(a4)
    li t2,1
    beq t0,t1,pass5 # 判断是否通过
    li t2,0
    pass5:
    sw t2,(a1)
    j end
    
    case_6: # 
    li a7,0
    ecall
    li t2,2
    li t3,4
    mul a0,a0,t2
    div a0,a0,t3
    la t2,test
    lw a7,(t2)
    ecall
    j end
    
    case_7: #sltu should be 00000000 because FFFFFFFF > 000000FF if unsigned
    lw t0,(a4) #sltu should be 00000000 because FFFFFFFF > 000000FF if unsigned
    li t1,0
    la t2,func
    jalr t2#2222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
    beq t0,t1,pass7
    
    pass7:
    li t2,1#funcfuncfuncfuncfuncfuncfuncfuncfuncfuncfuncfuncfuncfunc
    sw t2,(a1)
    j end
    
    fail7:
    li t2,0
    sw t2,(a1)
    j end
    
    ecall
    
    func:
    mv t1,t0 #funcfuncfuncfuncfuncfuncfuncfuncfuncfuncfuncfuncfuncfunc
    ret
    
    
end: 				# 为0跳出死循环回到开头
  # 构造 enter_key 地址：0xFFFFFE54
    lui t2, 0x1                 # t2 = 0x00001000，用于补高地址
    lui t4, 0xfffff             # t4 = 0xfffff000
    addi t4, t4, -428           # t4 = 0xfffff000 - 428 = 0xffffee54
    add t4, t4, t2              # t4 = 0xfffffe48（最终 switch 地址）
    lw s11,(t4)
    beqz s11,_start 		#为0跳出死循环
    bne  s11,zero,end
