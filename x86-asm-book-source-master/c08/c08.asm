         ;代码清单8-2
         ;文件名：c08.asm
         ;文件说明：用户程序 
         ;创建日期：2011-5-5 18:17
         
;===============================================================================
;定义用户程序头部段
SECTION header vstart=0                     ;vstart=0表示段中的标号表示的地址从段的开头且从0开始计算，而不是程序的开头           
    ;[0x00]程序总长度
    program_length  dd program_end         
    ;用户程序入口点
    code_entry      dw start                ;[0x04]偏移地址
                    dd section.code_1.start ;[0x06]段地址，section.段名称.start表示段的汇编地址（即段相当于程序开头的偏移量）。
                                            ;段地址总共是20位，所以需要用32位保存
    ;[0x0a]段重定位表项个数
    realloc_tbl_len dw (header_end-code_1_segment)/4
    ;段重定位表           
    code_1_segment  dd section.code_1.start ;[0x0c]
    code_2_segment  dd section.code_2.start ;[0x10]
    data_1_segment  dd section.data_1.start ;[0x14]
    data_2_segment  dd section.data_2.start ;[0x18]
    stack_segment   dd section.stack.start  ;[0x1c]
    
    header_end:                
    
;===============================================================================
SECTION code_1 align=16 vstart=0        ;定义代码段1（align=16表示段的汇编地址对齐方式为16字节对齐，即段的起始汇编地址必须是16的倍数） 
put_string:                             ;显示以0结尾的字符串（否则无法终止）
                                        ;需要两个参数DS和BX，分别是字符串所在的段地址和偏移地址
        mov cl,[bx]                     ;将bx处的单个字符取出放到cl
        or cl,cl                        ;判断cl是否为0
        jz .exit                        ;若cl为0，返回主程序 
        call put_char                   ;否则打印该字符
        inc bx                          ;下一个字符 
        jmp put_string

.exit:
        ret                             ;当所有字符打印完毕，返回用户主程序

;-------------------------------------------------------------------------------
put_char:                                ;显示一个字符
                                         ;输入：cl=字符ascii
        push ax
        push bx
        push cx
        push dx
        push ds
        push es

        ;取当前光标位置高8位到ah
        mov dx,0x3d4                    ;得到索引寄存器端口号
        mov al,0x0e                     ;光标位置高八位寄存器索引
        out dx,al                       ;将索引(al)写到索引寄存器端口(dx)
        mov dx,0x3d5                    ;得到数据端口号0x3d5
        in al,dx                        ;读出数据端口的内容送到al
        mov ah,al                       ;将al内容移到ah
        ;取当前光标位置低8位到al
        mov dx,0x3d4
        mov al,0x0f                     ;光标位置低八位寄存器索引
        out dx,al
        mov dx,0x3d5                    ;从数据端口0x3d5读出1字节数据并送到al中
        in al,dx                        
        mov bx,ax                       ;将ax中的光标位置送到bx中
        ;判断当前字符是否为回车符
        cmp cl,0x0d                     
        jnz .put_0a                     ;若不是回车符，则跳转 
        mov ax,bx                       ;此句略显多余，但去掉后还得改书，麻烦 
        mov bl,80                       
        div bl                          ;将光标位置除以80，得到当前行的行号(ax)
        mul bl                          ;再乘以80，得到当前行行首的光标数值(ax)
        mov bx,ax                       ;将光标行首数值送到bx
        jmp .set_cursor                 ;设置光标在屏幕上的位置
        ;判断当前字符是否为换行符
 .put_0a:
        cmp cl,0x0a                     
        jnz .put_other                  ;若不是换行符，则跳转
        add bx,80                       ;将bx内容（此时因为已经进行了回车处理，光标位于当前行行首）加80，即得到下一行开头的光标位置
        jmp .roll_screen                ;判断是否需要滚屏
        ;显示可打印字符
 .put_other:                            
        mov ax,0xb800                   ;显存段位置0xb800
        mov es,ax                       ;令es指向显存段地址
        shl bx,1                        ;将光标位置乘以2得到该字符在显存中的偏移地址。因为光标指示的是字符位置，一个字符在显存中对应两个字节。
        mov [es:bx],cl                  ;将字符送到显存对应位置（因为显存中本来就都是黑底白字的空白字符，只要不覆盖掉原来的就不需要重写黑底白字的属性）

        ;将光标位置推进一个字符
        shr bx,1                        ;光标位置除以2，恢复
        add bx,1                        ;推进到下一个位置
        ;滚屏操作：将屏幕上所有行的内容整体往上提一行，最后用黑底白字的空白字符填充第25行（最后一行）
 .roll_screen:
        cmp bx,2000                     ;判断光标是否超出当前屏幕
        jl .set_cursor                  ;若没有，跳转设置光标
        ;将第2~25行的内容复制到1~24行
        mov ax,0xb800                   
        mov ds,ax
        mov es,ax
        cld
        mov si,0xa0                     ;源地址为ds:si（第2行第1列开始）
        mov di,0x00                     ;目的地址为ds:di（第1行第1列开始）
        mov cx,1920                     ;要传送的字数为24×80=1920
        rep movsw
        mov bx,3840                     ;第25行第1列的偏移地址为3840byte
        mov cx,80
 .cls:
        mov word[es:bx],0x0720          ;写入黑底白字的空白字符
        add bx,2
        loop .cls

        mov bx,1920                     ;此时光标位置为第25行第1列
        ;重置光标
 .set_cursor:
        ;通过索引端口和数据端口分别写入光标位置的高8位和低8位到两个寄存器
        mov dx,0x3d4
        mov al,0x0e
        out dx,al
        mov dx,0x3d5
        mov al,bh
        out dx,al
        mov dx,0x3d4
        mov al,0x0f
        out dx,al
        mov dx,0x3d5
        mov al,bl
        out dx,al

        pop es
        pop ds
        pop dx
        pop cx
        pop bx
        pop ax

        ret             ;返回到调用者put_string过程

;-------------------------------------------------------------------------------
  start:
        ;初始执行时，CS指向用户入口程序的段地址，DS和ES指向用户程序起始物理地址(header)，SS指向加载器的堆栈
        ;下面的程序初始化各个段寄存器，段寄存器初始化的顺序很重要，如果先初始化数据段DS和附加段ES，那么头部段header的数据将无法访问
        mov ax,[stack_segment]           ;从头部取得用户程序自己的堆栈段的段地址
        mov ss,ax                        ;将堆栈地址传送给SS
        mov sp,stack_end                 ;令堆栈指针寄存器SP指向堆栈空间的结尾
        
        mov ax,[data_1_segment]          ;从头部取得用户程序自己的数据段的段地址
        mov ds,ax                        ;将数据段地址传送给DS

        mov bx,msg0                     
        call put_string                  ;显示第一段信息 

        push word [es:code_2_segment]    ;在堆栈中压入代码段code_2的段地址
        mov ax,begin                     ;得到偏移地址，8086不能在堆栈中压入立即数，只能通过寄存器间接处理
        push ax                          ;压入偏移地址，即begin的汇编地址
        
        retf                             ;转移到代码段2执行
         
  continue:
        mov ax,[es:data_2_segment]       ;段寄存器DS切换到数据段2 
        mov ds,ax
        
        mov bx,msg1
        call put_string                  ;显示第二段信息 

        jmp $                            ;用户程序执行结束，进入无限循环

;===============================================================================
SECTION code_2 align=16 vstart=0          ;定义代码段2（16字节对齐）

  begin:
        push word [es:code_1_segment]
        mov ax,continue
        push ax                          ;可以直接push continue,80386+
        
        retf                             ;转移到代码段1接着执行 
         
;===============================================================================
SECTION data_1 align=16 vstart=0

   msg0 db '  This is NASM - the famous Netwide Assembler. '
        db 'Back at SourceForge and in intensive development! '
        db 'Get the current versions from http://www.nasm.us/.'
        db 0x0d,0x0a,0x0d,0x0a
        db '  Example code for calculate 1+2+...+1000:',0x0d,0x0a,0x0d,0x0a
        db '     xor dx,dx',0x0d,0x0a
        db '     xor ax,ax',0x0d,0x0a
        db '     xor cx,cx',0x0d,0x0a
        db '  @@:',0x0d,0x0a
        db '     inc cx',0x0d,0x0a
        db '     add ax,cx',0x0d,0x0a
        db '     adc dx,0',0x0d,0x0a
        db '     inc cx',0x0d,0x0a
        db '     cmp cx,1000',0x0d,0x0a
        db '     jle @@',0x0d,0x0a
        db '     ... ...(Some other codes)',0x0d,0x0a,0x0d,0x0a
        db 0

;===============================================================================
SECTION data_2 align=16 vstart=0

msg1    db '  The above contents is written by LeeChung. '
        db '2011-05-06'
        db 0

;===============================================================================
SECTION stack align=16 vstart=0
           
        resb 256                ;保留256字节的堆栈空间
                                ;resb(resw, resd)：从当前位置开始，保留指定数量的字节，但不初始化它们的值。
stack_end:  

;===============================================================================
SECTION trail align=16
program_end: