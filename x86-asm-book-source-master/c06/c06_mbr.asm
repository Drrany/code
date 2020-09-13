       ;代码清单6-1
       ;文件名：c06_mbr.asm
       ;文件说明：硬盘主引导扇区代码
       ;创建日期：2011-4-12 22:12 

       jmp near start
;声明了非指令的数据，其不可执行，因此需要使用jmp指令跳转
mytext db 'L',0x07,'a',0x07,'b',0x07,'e',0x07,'l',0x07,' ',0x07,'o',0x07,\        ;\是续行符，表示下一行和当前行应该合并为一行
       'f',0x07,'f',0x07,'s',0x07,'e',0x07,'t',0x07,':',0x07
number db 0,0,0,0,0

start:
       mov ax,0x7c0                  ;设置数据段基地址 
       mov ds,ax
       
       mov ax,0xb800                 ;设置附加段基地址 ，即显示缓冲区所在的段地址
       mov es,ax
       
       ;movsb和movsw有两种传送：正向传送和反向传送
       ;正向传送是指传送操作的方向是从内存区域的低地址端到高地址端；反向传送则正好相反。
       ;正向传送时，每传送一个字节（movsb）或者一个字（movsw），SI和DI加1或者加2；反向传送时，每传送一个字节（movsb）或者一个字（movsw）时，SI和DI减去1或者减去2。
       ;cld指令表示将方向标志清零，即指示传送是正向的
       cld
       ;次数由cx指定
       mov si,mytext                    ;movsw指令的源地址由DS:SI指定   
       mov di,0                         ;movsw指令的目的地址由ES:DI指定   
       ;除以2是因为下面使用movsw指令
       mov cx,(number-mytext)/2         ;传送的字节数（movsb）或者字数（movsw）由CX指定
       rep movsw                        ;rep（repeat），意思是CX不为零则重复

       ;得到标号所代表的偏移地址
       mov ax,number
       
       ;计算各个数位
       mov bx,ax                        ;bx作为内存地址索引。在8086处理器上，如果要用寄存器来提供偏移地址，只能使用BX(base address register)、SI、DI、BP，不能使用其他寄存器。
       mov cx,5                         ;循环次数 
       mov si,10                        ;除数 
digit: ;循环体
       xor dx,dx                        ;每次计算前将余数清零
       div si                           ;除以10，结果位于dx中
       mov [bx],dl                      ;保存数位
       inc bx                           ;bx自增1字节
       loop digit                       ;当cx大于0时循环一直执行下去
       ;处理器执行loop时会做两件事：
       ;    将寄存器CX的内容减1；
       ;    如果CX的内容不为零，转移到指定的位置处执行，否则顺序执行后面的指令。

       
       ;显示各个数位
       mov bx,number                  ;偏移地址保存在bx中
       mov si,4                       ;个数保存在si中
show:
       mov al,[bx+si]                 ;取其中一位保存在al中
       add al,0x30                    ;加0x30得到对应的ASCII码
       mov ah,0x04                    ;显示属性是黑底红字
       mov [es:di],ax                 ;存储到显示缓冲区
       add di,2                       ;移动到下一个显示缓冲区，加2是因为ASCII需要两个字节
       dec si                         ;移动到下一个需要显示的数位
       jns show                       ;jns当SF不为1时则跳转，如果si小于0，则SF为1
       
       mov word [es:di],0x0744

       jmp near $                     ;$为当前汇编代码行标记，该指令意为转移到当前指令继续执行

times  510-($-$$) db 0                 ;$$为nasm提供的当前汇编段的起始汇编地址，510是512-2字节(0x55,0xaa共两字节)
       db 0x55,0xaa
