      ;代码清单5-1 
      ;文件名：c05_mbr.asm
      ;文件说明：硬盘主引导扇区代码
      ;创建日期：2011-3-31 21:15 
      
      mov ax,0xb800                 ;es寄存器指向文本模式的显示缓冲区
      mov es,ax                     ;Intel处理器不允许将一个立即数直接传送到ES，所以需要一个通用寄存器中转

      ;以下显示字符串"Label offset:"
      ;字符的显示属性分为两个字节
      ;第一个字节是字符的ASCII码，第二个字节是字符的显示属性
      ;下面的0x07表示字符以黑底白字，无闪烁无加亮的方式显示
      mov byte [es:0x00],'L'  ;如果省略es:，段地址默认在段寄存器DS中
                              ;ES的内容左移4位，然后加上指令中提供的偏移量0x00，得到物理地址
                              ;[]表示寻址，括起来内容是一个地址，先访问这个地址，再进行操作
                              ;byte修饰目的操作数，表示此次传送以字节为单位（word:字）。如果目的操作数或者源操作数是寄存器，可以不指明传送单位，其默认按照寄存器位数传送。
      mov byte [es:0x01],0x07
      mov byte [es:0x02],'a'
      mov byte [es:0x03],0x07
      mov byte [es:0x04],'b'
      mov byte [es:0x05],0x07
      mov byte [es:0x06],'e'
      mov byte [es:0x07],0x07
      mov byte [es:0x08],'l'
      mov byte [es:0x09],0x07
      mov byte [es:0x0a],' '
      mov byte [es:0x0b],0x07
      mov byte [es:0x0c],"o"
      mov byte [es:0x0d],0x07
      mov byte [es:0x0e],'f'
      mov byte [es:0x0f],0x07
      mov byte [es:0x10],'f'
      mov byte [es:0x11],0x07
      mov byte [es:0x12],'s'
      mov byte [es:0x13],0x07
      mov byte [es:0x14],'e'
      mov byte [es:0x15],0x07
      mov byte [es:0x16],'t'
      mov byte [es:0x17],0x07
      mov byte [es:0x18],':'
      mov byte [es:0x19],0x07

      mov ax,number                 ;ax保存被除数的低16位，取得标号number对应的偏移地址，即数据存放位置
      mov bx,10                     ;bx保存除数

      ;设置数据段的基地址（和代码段相同，因为我们把数据声明在了代码段中）
      mov cx,cs
      mov ds,cx

      ;32位除法中，被除数的低16位在ax寄存器中，高16位在dx寄存器中
      ;前面已经将number的地址赋值给ax，下面将dx清零
      ;求个位上的数字
      mov dx,0
      div bx                        ;商在ax中，余数在dx中
      mov [0x7c00+number+0x00],dl   ;保存个位上的数字。因为余数肯定比10小，所以可以直接中dl中取得
                                    ;加0x7c00是因为主引导扇区的代码被加载到该位置
      ;求十位上的数字
      xor dx,dx                     ;dx内容清零，该指令比mov dx,0短，且执行速度快
      div bx
      mov [0x7c00+number+0x01],dl   ;保存十位上的数字

      ;求百位上的数字
      xor dx,dx
      div bx
      mov [0x7c00+number+0x02],dl   ;保存百位上的数字

      ;求千位上的数字
      xor dx,dx
      div bx
      mov [0x7c00+number+0x03],dl   ;保存千位上的数字

      ;求万位上的数字 
      xor dx,dx
      div bx
      mov [0x7c00+number+0x04],dl   ;保存万位上的数字

      ;以下用十进制显示标号的偏移地址
      mov al,[0x7c00+number+0x04]    ;将计算结果送到al寄存器中
      add al,0x30                    ;加上0x30得到这个数字的ASCII码
      mov [es:0x1a],al               ;得到的ASCII码送到指定的位置
      mov byte [es:0x1b],0x04        ;显示属性为黑底红字，无闪烁无加亮
      
      mov al,[0x7c00+number+0x03]
      add al,0x30
      mov [es:0x1c],al
      mov byte [es:0x1d],0x04
      
      mov al,[0x7c00+number+0x02]
      add al,0x30
      mov [es:0x1e],al
      mov byte [es:0x1f],0x04

      mov al,[0x7c00+number+0x01]
      add al,0x30
      mov [es:0x20],al
      mov byte [es:0x21],0x04

      mov al,[0x7c00+number+0x00]
      add al,0x30
      mov [es:0x22],al
      mov byte [es:0x23],0x04
      
      mov byte [es:0x24],'D'
      mov byte [es:0x25],0x07
          
infi: jmp near infi        ;无限循环，避免执行到后面的非指令数据上
                        ;near表示目标位置依然在当前代码段内，后跟的操作数表示目标位置相对于当前指令处的偏移量

number db 0,0,0,0,0     ;DB(Declare Byte)，声明字节数据，跟在它后面的操作数都占一个字节的长度
                        ;DW(Declare Word), DD(Declare Double Word), DQ(Declare Quad)
                        ;DB...这些属于伪指令，没有对应的机器指令，由编译器执行

times 203 db 0             ;伪指令times将它后面的指令重复指定次数，此处会将前面内容和结尾的0xaa55中的203个字节用0填充
      db 0x55,0xaa         ;在结尾添加主引导区的有效标志
                        ;或者可以用dw 0xaa55代替（Intel采用低端字节序）
