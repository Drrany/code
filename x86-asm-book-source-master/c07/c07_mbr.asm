        ;�����嵥7-1
        ;�ļ�����c07_mbr.asm
        ;�ļ�˵����Ӳ����������������
        ;�������ڣ�2011-4-13 18:02
        
        jmp near start
        ;�õ����Ű�һ���ַ�Χ�������ڱ���׶Σ��������������ǲ𿪣����γ�һ�����������ֽ�
message db '1+2+3+...+100='
    
start:
        mov ax,0x7c0           ;�������ݶεĶλ���ַ 
        mov ds,ax

        mov ax,0xb800          ;���ø��Ӷλ�ַ����ʾ������
        mov es,ax

        ;������ʾ�ַ��� 
        mov si,message         ;si����ַ����ڴ��ַ
        mov di,0               ;di�����ʾ����������
        mov cx,start-message   ;cx�����ַ�������
    @g:
        mov al,[si]            ;���ַ�����ֵ��al�Ĵ���
        mov [es:di],al         ;ͨ��al�Ĵ�����ŵ���ʾ������
        inc di                 ;������ʾ��������������һ���ֽ�Ҫ������ʾ����
        mov byte [es:di],0x07  ;��ʾ����
        inc di                 ;������ʾ����������
        inc si                 ;ָ����һ���ַ������ַ�
        loop @g                ;cx��Ϊ0ʱһֱѭ����ȥ

        ;���¼���1��100�ĺ� 
        xor ax,ax              ;����ax�Ĵ��������ڱ���������ĺ�
        mov cx,1               ;cx�Ĵ�������ѭ������
    @f:
        add ax,cx              ;�ۼӽ�����浽ax��
        inc cx                 ;����cx
        cmp cx,100             ;��100���бȽ�
        jle @f                 ;С��100ʱ����ִ��ѭ��

        ;���¼����ۼӺ͵�ÿ����λ 
        xor cx,cx              ;���ö�ջ�εĶλ���ַ
        mov ss,cx              ;��ջ�εĶε�ַΪ0
        mov sp,cx              ;spָ��ҲΪ0

        mov bx,10              ;bx�������
        xor cx,cx              ;cx������������������������й��ж�������
    @d:
        inc cx                 ;����cx�Ĵ�����Ҳ���Ǳ���������λ��
        xor dx,dx              ;����bx�Ĵ��������ڱ�������
        div bx                 ;����bx
        or dl,0x30             ;������0x30�򣬵õ�ASCII��
        push dx                ;��������浽��ջ�С�8086������ѹ���ջ�����ݱ�������
        cmp ax,0               ;
        jne @d

        ;������ʾ������λ����ʱcx�Ĵ����е�ֵΪ�������õ���������λ��������Ϊѭ����ֹ������
    @a:
        pop dx                 ;���ν�ǰ�汣���ڶ�ջ�еĽ��ȡ����
        mov [es:di],dl         ;���뵽��ʾ��������
        inc di                 ;������ʾ������ָ�룬���ڱ�����ʾ����
        mov byte [es:di],0x07  ;������ʾ����
        inc di                 ;������ʾ������ָ��
        loop @a                ;cx��Ϊ0ʱ����ѭ��
    
        jmp near $ 
    

times 510-($-$$) db 0
                 db 0x55,0xaa