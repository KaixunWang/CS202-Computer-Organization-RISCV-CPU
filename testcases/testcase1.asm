#led 1111 1111 1111 1111 1111 1110 000 xxx 00
#led F    F    F    F    F    E
#led
 #led
  #      FFFFFE 000x xx00
   #     led_control_3: 3'b000 �� ������
    #    led_control_3: 3'b010                д�� 8 λ LED
     #   
      #  switch
       # FFFFFE 010x xx00
        #switch_control_3: 3'b000 �� ������
#        switch_control_3: 3'b100 �� load 8 bit
 #       switch_control_3: 3'b001 �� load 3 bit testcase
  #      switch_control_3: 3'b101 �� load enter

#        seg
 #       FFFFFE 100x xx00
  #      seg_control_3: 3'b000 �� ������
   #     seg_control_3: 3'b001 �� load number and show as hex
    #    seg_control_3: 3'b010 �� load number and show as decimal


#a 0x00000100
#b 0x00000104

.text

_start:
	add x1,x0,x0 #NOP
	# ���� led ��ַ��0xFFFFF000 -504  + 00001000= 0xFFFFFE08����8λ�з��ţ�
    lui t2, 0x1                 # t2 = 0x00001000�����ڲ��ߵ�ַ
    lui a1,0xfffff
    addi a1,a1, -504
    add a1,a1,t2
    
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
    
    # ���� switch ��ַ��0xFFFFFE40 + 8 = 0xFFFFFE48����8λ�з��ţ�
    lui t2, 0x1                 # t2 = 0x00001000�����ڲ��ߵ�ַ
    lui a4, 0xfffff             # a4 = 0xfffff000
    addi a4, a4, -432           # a4 = 0xfffff000 - 432 = 0xffffee50
    add a4, a4, t2              # a4 = 0xfffffe50������ switch ��ַ��
    #a4: address of switch right 8 bit (input)
    
    # ���� switch ��ַ��0xFFFFFE40 + 8 = 0xFFFFFE50��testcase��
    lui t2, 0x1                 # t2 = 0x00001000�����ڲ��ߵ�ַ
    lui a5, 0xfffff             # a5 = 0xfffff000
    addi a5, a5, -444           # a5 = 0xfffff000 - 440 = 0xffffee44
    add a5, a5, t2              # a5 = 0xfffffe44������ switch ��ַ��
    #a5: address of switch left 3 bits (input testcase number)
    
    # ���� enter_key ��ַ��0xFFFFFE54
    lui a6, 0xfffff             # a6 = 0xfffff000
    addi a6, a6, -428           # a6 = 0xfffff000 - 428 = 0xffffee54
    add a6, a6, t2              # a6 = 0xfffffe54������ switch ��ַ��
    lw s10,(a6)
    lw t1,0(a5)
    sw t1,0(a1)
    sw t1,0(a3)
    beqz s10,_start 		#Ϊ1������ѭ��
    
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
    # �� switch ��ȡ8λ��ֵ 000000FF
    lw t3, 0(a4)               # ��ȡ switch ����8λֵ
    # д�� LED ����8λ
    sw t3, 0(a1)                # д�� LED ����8λ
    j end
    
    case_1: #lb a FFFFFFFF
    lb t3, 0(a4)
    li s0, 0x00000100  #save to a
    sw t3, (s0)	#MEM
    sw t3, (a2)	#SEG
    j end
    
    case_2: #lb 2 000000FF
    lbu t3, 0(a4)
    li s1, 0x00000104 #save to b
    sw t3, (s1)	#MEM
    sw t3, (a2)	#seg
    j end
    
    case_3: #beq should be 00000000 because FFFFFFFF != 000000FF
    lw t1,0(s0) #a FFFFFFFF
    lw t2,0(s1) #b 000000FF
    beq t1,t2,eq 
    li t3,0
    j led_3
    eq:
    li t3, 0x000000FF
    led_3:
    sw t3,(a1) #light left 8 bit
    j end
    
    case_4: #blt should be 11111111 because FFFFFFF < 000000FF
    lw t1,0(s0)
    lw t2,0(s1)
    blt t1,t2,lt
    li t3,0
    j led_4
    lt:
    li t3,0x000000FF
    led_4:
    sw t3,0(a1)
    j end
    
    case_5: #bltu should be 00000000 because FFFFFFFF > 000000FF if unsigned
    lw t1,0(s0)
    lw t2,0(s1)
    bltu t1,t2,ltu
    li t3,0
    j led_5
    ltu:
    li t3,0x000000FF
    led_5:
    sw t3,0(a1)
    j end
    
    case_6: #slt should be 00000001 because FFFFFFFF < 000000FF
    lw t1,0(s0)#slt should be 00000001
    lw t2,0(s1)
    slt t3,t1,t2
    sw t3,0(a1)
    j end
    
    case_7: #sltu should be 00000000 because FFFFFFFF > 000000FF if unsigned
    lw t1,0(s0)
    lw t2,0(s1)
    sltu t3,t1,t2
    sw t3,0(a1)
    j end
    
end: 				# Ϊ0������ѭ���ص���ͷ
  # ���� enter_key ��ַ��0xFFFFFE54
    lui t2, 0x1                 # t2 = 0x00001000�����ڲ��ߵ�ַ
    lui t4, 0xfffff             # t4 = 0xfffff000
    addi t4, t4, -428           # t4 = 0xfffff000 - 428 = 0xffffee54
    add t4, t4, t2              # t4 = 0xfffffe48������ switch ��ַ��
    lw s11,(t4)
    beqz s11,_start 		#Ϊ1������ѭ��
    bne  s11,zero,end
