      ;�����嵥5-1 
      ;�ļ�����c05_mbr.asm
      ;�ļ�˵����Ӳ����������������
      ;�������ڣ�2011-3-31 21:15 
      
      mov ax,0xb800                 ;es�Ĵ���ָ���ı�ģʽ����ʾ������
      mov es,ax                     ;Intel������������һ��������ֱ�Ӵ��͵�ES��������Ҫһ��ͨ�üĴ�����ת

      ;������ʾ�ַ���"Label offset:"
      ;�ַ�����ʾ���Է�Ϊ�����ֽ�
      ;��һ���ֽ����ַ���ASCII�룬�ڶ����ֽ����ַ�����ʾ����
      ;�����0x07��ʾ�ַ��Ժڵװ��֣�����˸�޼����ķ�ʽ��ʾ
      mov byte [es:0x00],'L'  ;���ʡ��es:���ε�ַĬ���ڶμĴ���DS��
                              ;ES����������4λ��Ȼ�����ָ�����ṩ��ƫ����0x00���õ������ַ
                              ;[]��ʾѰַ��������������һ����ַ���ȷ��������ַ���ٽ��в���
                              ;byte����Ŀ�Ĳ���������ʾ�˴δ������ֽ�Ϊ��λ��word:�֣������Ŀ�Ĳ���������Դ�������ǼĴ��������Բ�ָ�����͵�λ����Ĭ�ϰ��ռĴ���λ�����͡�
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

      mov ax,number                 ;ax���汻�����ĵ�16λ��ȡ�ñ��number��Ӧ��ƫ�Ƶ�ַ�������ݴ��λ��
      mov bx,10                     ;bx�������

      ;�������ݶεĻ���ַ���ʹ������ͬ����Ϊ���ǰ������������˴�����У�
      mov cx,cs
      mov ds,cx

      ;32λ�����У��������ĵ�16λ��ax�Ĵ����У���16λ��dx�Ĵ�����
      ;ǰ���Ѿ���number�ĵ�ַ��ֵ��ax�����潫dx����
      ;���λ�ϵ�����
      mov dx,0
      div bx                        ;����ax�У�������dx��
      mov [0x7c00+number+0x00],dl   ;�����λ�ϵ����֡���Ϊ�����϶���10С�����Կ���ֱ����dl��ȡ��
                                    ;��0x7c00����Ϊ�����������Ĵ��뱻���ص���λ��
      ;��ʮλ�ϵ�����
      xor dx,dx                     ;dx�������㣬��ָ���mov dx,0�̣���ִ���ٶȿ�
      div bx
      mov [0x7c00+number+0x01],dl   ;����ʮλ�ϵ�����

      ;���λ�ϵ�����
      xor dx,dx
      div bx
      mov [0x7c00+number+0x02],dl   ;�����λ�ϵ�����

      ;��ǧλ�ϵ�����
      xor dx,dx
      div bx
      mov [0x7c00+number+0x03],dl   ;����ǧλ�ϵ�����

      ;����λ�ϵ����� 
      xor dx,dx
      div bx
      mov [0x7c00+number+0x04],dl   ;������λ�ϵ�����

      ;������ʮ������ʾ��ŵ�ƫ�Ƶ�ַ
      mov al,[0x7c00+number+0x04]    ;���������͵�al�Ĵ�����
      add al,0x30                    ;����0x30�õ�������ֵ�ASCII��
      mov [es:0x1a],al               ;�õ���ASCII���͵�ָ����λ��
      mov byte [es:0x1b],0x04        ;��ʾ����Ϊ�ڵ׺��֣�����˸�޼���
      
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
          
infi: jmp near infi        ;����ѭ��������ִ�е�����ķ�ָ��������
                        ;near��ʾĿ��λ����Ȼ�ڵ�ǰ������ڣ�����Ĳ�������ʾĿ��λ������ڵ�ǰָ���ƫ����

number db 0,0,0,0,0     ;DB(Declare Byte)�������ֽ����ݣ�����������Ĳ�������ռһ���ֽڵĳ���
                        ;DW(Declare Word), DD(Declare Double Word), DQ(Declare Quad)
                        ;DB...��Щ����αָ�û�ж�Ӧ�Ļ���ָ��ɱ�����ִ��

times 203 db 0             ;αָ��times���������ָ���ظ�ָ���������˴��Ὣǰ�����ݺͽ�β��0xaa55�е�203���ֽ���0���
      db 0x55,0xaa         ;�ڽ�β���������������Ч��־
                        ;���߿�����dw 0xaa55���棨Intel���õͶ��ֽ���
