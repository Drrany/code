      ;代码清单8-1
      ;文件名：c08_mbr.asm
      ;文件说明：硬盘主引导扇区代码（加载程序） 
      ;创建日期：2011-5-5 18:17
      
      app_lba_start equ 100           ;声明常数（用户程序起始逻辑扇区号）
                                      ;常数的声明不会占用汇编地址
                              
SECTION mbr align=16 vstart=0x7c00                                     

      ;设置堆栈段和栈指针 
      mov ax,0      
      mov ss,ax
      mov sp,ax

      mov ax,[cs:phy_base]            ;得到用于加载用户程序的物理地址。cs的内容为0x0000
      mov dx,[cs:phy_base+0x02]       ;由于地址是20位的，所以需要两个寄存器。ax存储低16位，dx存储高16位
      mov bx,16        
      div bx                          ;dx:ax除以16得到对应的段地址
      mov ds,ax                       
      mov es,ax                       ;令DS和ES指向该段以进行操作

      ;以下从硬盘读取用户程序 
      xor di,di                       ;di清零，用户程序起始逻辑扇区号高12位存储在di中（100的高12位是0）
      mov si,app_lba_start            ;用户程序起始逻辑扇区号的低16位存储在si中。
      xor bx,bx                       ;bx清零，指定存放数据的内存地址DS:bx(0x0000)处 
      call read_hard_disk_0           ;先计算出被调用过程的绝对偏移地址，然后将IP的现行值压栈，用计算出的值替代IP的内容

      ;以下判断整个程序有多大
      mov dx,[2]                      ;将程序大小对应数值的高16位传送到dx，低16位传送到ax
      mov ax,[0]
      mov bx,512                      ;512字节每扇区
      div bx
      cmp dx,0
      jnz @1                          ;如果除尽了，跳转到@1；若未除尽，扇区数-1，因为已经预读了一个扇区 
      dec ax                          
@1:
      cmp ax,0                        ;如果只有一个扇区，则直接跳转到direct，不再读取扇区
      jz direct
      
      ;读取剩余的扇区
      push ds                         ;以下要用到并改变DS寄存器 

      mov cx,ax                       ;循环次数（剩余扇区数）
@2:
      mov ax,ds
      add ax,0x20                     ;得到下一个以512字节为边界的段地址
      mov ds,ax  
                        
      xor bx,bx                       ;每次读时，偏移地址始终为0x0000 
      inc si                          ;指向下一个逻辑扇区 
      call read_hard_disk_0
      loop @2                         ;循环读，直到读完整个功能程序 

      pop ds                          ;恢复数据段基址到用户程序头部段 

      ;重定位用户程序入口点的代码段 
direct:
      mov dx,[0x08]                   ;将偏移地址0x06处存放的入口代码段的汇编地址，高字和低字分别传送给dx和ax
      mov ax,[0x06]
      call calc_segment_base          ;计算该代码段在内存中的段地址
      mov [0x06],ax                   ;回填修正后的入口点代码段基址，高16位不用管

      ;开始处理段重定位表
      mov cx,[0x0a]                   ;需要重定位的项目数量
      mov bx,0x0c                     ;重定位表首地址
      
realloc:
      mov dx,[bx+0x02]                ;32位段地址的高16位 
      mov ax,[bx]                     ;32位段地址的低16位
      call calc_segment_base          ;计算相应的逻辑段地址
      mov [bx],ax                     ;回填段的基址
      add bx,4                        ;指向下一个重定位项（每项占4个字节） 
      loop realloc 

      jmp far [0x04]                  ;转移到用户程序（ds已经指向了数据段0x1000处）
                                      ;jmp问ds:0x04的内容，取出两个字，分别传送到cs和ip中（[0x06]->cs,[0x04]->ip）
                                      ;然后处理器转移到指定的位置处开始执行

;-------------------------------------------------------------------------------
read_hard_disk_0:                   ;从硬盘读取一个逻辑扇区
                                    ;输入：DI:SI=起始逻辑扇区号
                                    ;     DS:BX=目标缓冲区地址
      push ax                       ;将过程中会使用(破坏)的寄存器压栈保存
      push bx
      push cx
      push dx

      mov dx,0x1f2
      mov al,1
      out dx,al                       ;读取的扇区数为1

      inc dx                          ;0x1f3
      mov ax,si
      out dx,al                       ;LBA地址7~0

      inc dx                          ;0x1f4
      mov al,ah
      out dx,al                       ;LBA地址15~8

      inc dx                          ;0x1f5
      mov ax,di
      out dx,al                       ;LBA地址23~16

      inc dx                          ;0x1f6
      mov al,0xe0                     ;LBA28模式，主盘
      or al,ah                        ;LBA地址27~24
      out dx,al

      inc dx                          ;0x1f7
      mov al,0x20                     ;读命令
      out dx,al

.waits:
      in al,dx
      and al,0x88
      cmp al,0x08
      jnz .waits                      ;不忙，且硬盘已准备好数据传输 

      mov cx,256                      ;总共要读取的**字**数
      mov dx,0x1f0
.readw:
      in ax,dx
      mov [bx],ax
      add bx,2
      loop .readw

      pop dx
      pop cx
      pop bx
      pop ax

      ret                           ;从堆栈中弹出一个字到指令指针寄存器中
                                    ;retf：分别从堆栈弹出两个字到IP和CS中
;-------------------------------------------------------------------------------
calc_segment_base:                  ;计算和确定每个段的段地址
                                    ;输入：DX:AX=32位汇编地址（每个段的汇编地址都是其相对于整个程序开头的偏移量）
                                    ;返回：AX=16位段基地址
      push dx                          
      
      add ax,[cs:phy_base]          ;将用户程序在内存中物理起始地址的低16位和ax中段地址的低16位相加
      adc dx,[cs:phy_base+0x02]     ;将用户程序在内存中物理起始地址的高16位和dx中段地址的高16位相加
                                    ;adc是带进位加法，会加上CF标志位的值
                                    ;此时dx:ax就是入口代码段的起始物理地址，现在要将其右移4位得到逻辑段地址
      shr ax,4                         ;ax向右移动4位，空出高4位来
      ror dx,4                         ;ror是循环右移指令，通过这个指令把dx的低4位移动到了高4位上
      and dx,0xf000                    ;将dx的低12位清零
      or ax,dx                         ;ax和dx相与得到20位地址，保存在ax寄存器中
      
      pop dx
      
      ret

;-------------------------------------------------------------------------------
      phy_base dd 0x10000             ;用户程序被加载的20位物理起始地址。即1000H:0000H
      
times 510-($-$$) db 0
            db 0x55,0xaa
