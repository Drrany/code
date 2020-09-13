         ;�����嵥8-2
         ;�ļ�����c08.asm
         ;�ļ�˵�����û����� 
         ;�������ڣ�2011-5-5 18:17
         
;===============================================================================
;�����û�����ͷ����
SECTION header vstart=0                     ;vstart=0��ʾ���еı�ű�ʾ�ĵ�ַ�ӶεĿ�ͷ�Ҵ�0��ʼ���㣬�����ǳ���Ŀ�ͷ           
    ;[0x00]�����ܳ���
    program_length  dd program_end         
    ;�û�������ڵ�
    code_entry      dw start                ;[0x04]ƫ�Ƶ�ַ
                    dd section.code_1.start ;[0x06]�ε�ַ��section.������.start��ʾ�εĻ���ַ�������൱�ڳ���ͷ��ƫ��������
                                            ;�ε�ַ�ܹ���20λ��������Ҫ��32λ����
    ;[0x0a]���ض�λ�������
    realloc_tbl_len dw (header_end-code_1_segment)/4
    ;���ض�λ��           
    code_1_segment  dd section.code_1.start ;[0x0c]
    code_2_segment  dd section.code_2.start ;[0x10]
    data_1_segment  dd section.data_1.start ;[0x14]
    data_2_segment  dd section.data_2.start ;[0x18]
    stack_segment   dd section.stack.start  ;[0x1c]
    
    header_end:                
    
;===============================================================================
SECTION code_1 align=16 vstart=0        ;��������1��align=16��ʾ�εĻ���ַ���뷽ʽΪ16�ֽڶ��룬���ε���ʼ����ַ������16�ı����� 
put_string:                             ;��ʾ��0��β���ַ����������޷���ֹ��
                                        ;��Ҫ��������DS��BX���ֱ����ַ������ڵĶε�ַ��ƫ�Ƶ�ַ
        mov cl,[bx]                     ;��bx���ĵ����ַ�ȡ���ŵ�cl
        or cl,cl                        ;�ж�cl�Ƿ�Ϊ0
        jz .exit                        ;��clΪ0������������ 
        call put_char                   ;�����ӡ���ַ�
        inc bx                          ;��һ���ַ� 
        jmp put_string

.exit:
        ret                             ;�������ַ���ӡ��ϣ������û�������

;-------------------------------------------------------------------------------
put_char:                                ;��ʾһ���ַ�
                                         ;���룺cl=�ַ�ascii
        push ax
        push bx
        push cx
        push dx
        push ds
        push es

        ;ȡ��ǰ���λ�ø�8λ��ah
        mov dx,0x3d4                    ;�õ������Ĵ����˿ں�
        mov al,0x0e                     ;���λ�ø߰�λ�Ĵ�������
        out dx,al                       ;������(al)д�������Ĵ����˿�(dx)
        mov dx,0x3d5                    ;�õ����ݶ˿ں�0x3d5
        in al,dx                        ;�������ݶ˿ڵ������͵�al
        mov ah,al                       ;��al�����Ƶ�ah
        ;ȡ��ǰ���λ�õ�8λ��al
        mov dx,0x3d4
        mov al,0x0f                     ;���λ�õͰ�λ�Ĵ�������
        out dx,al
        mov dx,0x3d5                    ;�����ݶ˿�0x3d5����1�ֽ����ݲ��͵�al��
        in al,dx                        
        mov bx,ax                       ;��ax�еĹ��λ���͵�bx��
        ;�жϵ�ǰ�ַ��Ƿ�Ϊ�س���
        cmp cl,0x0d                     
        jnz .put_0a                     ;�����ǻس���������ת 
        mov ax,bx                       ;�˾����Զ��࣬��ȥ���󻹵ø��飬�鷳 
        mov bl,80                       
        div bl                          ;�����λ�ó���80���õ���ǰ�е��к�(ax)
        mul bl                          ;�ٳ���80���õ���ǰ�����׵Ĺ����ֵ(ax)
        mov bx,ax                       ;�����������ֵ�͵�bx
        jmp .set_cursor                 ;���ù������Ļ�ϵ�λ��
        ;�жϵ�ǰ�ַ��Ƿ�Ϊ���з�
 .put_0a:
        cmp cl,0x0a                     
        jnz .put_other                  ;�����ǻ��з�������ת
        add bx,80                       ;��bx���ݣ���ʱ��Ϊ�Ѿ������˻س��������λ�ڵ�ǰ�����ף���80�����õ���һ�п�ͷ�Ĺ��λ��
        jmp .roll_screen                ;�ж��Ƿ���Ҫ����
        ;��ʾ�ɴ�ӡ�ַ�
 .put_other:                            
        mov ax,0xb800                   ;�Դ��λ��0xb800
        mov es,ax                       ;��esָ���Դ�ε�ַ
        shl bx,1                        ;�����λ�ó���2�õ����ַ����Դ��е�ƫ�Ƶ�ַ����Ϊ���ָʾ�����ַ�λ�ã�һ���ַ����Դ��ж�Ӧ�����ֽڡ�
        mov [es:bx],cl                  ;���ַ��͵��Դ��Ӧλ�ã���Ϊ�Դ��б����Ͷ��Ǻڵװ��ֵĿհ��ַ���ֻҪ�����ǵ�ԭ���ľͲ���Ҫ��д�ڵװ��ֵ����ԣ�

        ;�����λ���ƽ�һ���ַ�
        shr bx,1                        ;���λ�ó���2���ָ�
        add bx,1                        ;�ƽ�����һ��λ��
        ;��������������Ļ�������е���������������һ�У�����úڵװ��ֵĿհ��ַ�����25�У����һ�У�
 .roll_screen:
        cmp bx,2000                     ;�жϹ���Ƿ񳬳���ǰ��Ļ
        jl .set_cursor                  ;��û�У���ת���ù��
        ;����2~25�е����ݸ��Ƶ�1~24��
        mov ax,0xb800                   
        mov ds,ax
        mov es,ax
        cld
        mov si,0xa0                     ;Դ��ַΪds:si����2�е�1�п�ʼ��
        mov di,0x00                     ;Ŀ�ĵ�ַΪds:di����1�е�1�п�ʼ��
        mov cx,1920                     ;Ҫ���͵�����Ϊ24��80=1920
        rep movsw
        mov bx,3840                     ;��25�е�1�е�ƫ�Ƶ�ַΪ3840byte
        mov cx,80
 .cls:
        mov word[es:bx],0x0720          ;д��ڵװ��ֵĿհ��ַ�
        add bx,2
        loop .cls

        mov bx,1920                     ;��ʱ���λ��Ϊ��25�е�1��
        ;���ù��
 .set_cursor:
        ;ͨ�������˿ں����ݶ˿ڷֱ�д����λ�õĸ�8λ�͵�8λ�������Ĵ���
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

        ret             ;���ص�������put_string����

;-------------------------------------------------------------------------------
  start:
        ;��ʼִ��ʱ��CSָ���û���ڳ���Ķε�ַ��DS��ESָ���û�������ʼ�����ַ(header)��SSָ��������Ķ�ջ
        ;����ĳ����ʼ�������μĴ������μĴ�����ʼ����˳�����Ҫ������ȳ�ʼ�����ݶ�DS�͸��Ӷ�ES����ôͷ����header�����ݽ��޷�����
        mov ax,[stack_segment]           ;��ͷ��ȡ���û������Լ��Ķ�ջ�εĶε�ַ
        mov ss,ax                        ;����ջ��ַ���͸�SS
        mov sp,stack_end                 ;���ջָ��Ĵ���SPָ���ջ�ռ�Ľ�β
        
        mov ax,[data_1_segment]          ;��ͷ��ȡ���û������Լ������ݶεĶε�ַ
        mov ds,ax                        ;�����ݶε�ַ���͸�DS

        mov bx,msg0                     
        call put_string                  ;��ʾ��һ����Ϣ 

        push word [es:code_2_segment]    ;�ڶ�ջ��ѹ������code_2�Ķε�ַ
        mov ax,begin                     ;�õ�ƫ�Ƶ�ַ��8086�����ڶ�ջ��ѹ����������ֻ��ͨ���Ĵ�����Ӵ���
        push ax                          ;ѹ��ƫ�Ƶ�ַ����begin�Ļ���ַ
        
        retf                             ;ת�Ƶ������2ִ��
         
  continue:
        mov ax,[es:data_2_segment]       ;�μĴ���DS�л������ݶ�2 
        mov ds,ax
        
        mov bx,msg1
        call put_string                  ;��ʾ�ڶ�����Ϣ 

        jmp $                            ;�û�����ִ�н�������������ѭ��

;===============================================================================
SECTION code_2 align=16 vstart=0          ;��������2��16�ֽڶ��룩

  begin:
        push word [es:code_1_segment]
        mov ax,continue
        push ax                          ;����ֱ��push continue,80386+
        
        retf                             ;ת�Ƶ������1����ִ�� 
         
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
           
        resb 256                ;����256�ֽڵĶ�ջ�ռ�
                                ;resb(resw, resd)���ӵ�ǰλ�ÿ�ʼ������ָ���������ֽڣ�������ʼ�����ǵ�ֵ��
stack_end:  

;===============================================================================
SECTION trail align=16
program_end: