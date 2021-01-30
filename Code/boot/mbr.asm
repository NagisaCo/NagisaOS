%include "boot.inc"
SECTION MBR vstart=0x7c00         
	mov ax,cs      
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov sp,0x7c00
	mov ax,0xb800
	mov gs,ax

clr:
	mov     ax, 0600h
	mov     bx, 0700h
	mov     cx, 0
	mov     dx, 184fh
	int     10h

	;输出字符串:MBR
    mov byte [gs:0x334], 'M'
    mov byte [gs:0x335], 7

    mov byte [gs:0x336], 'B'
    mov byte [gs:0x337], 7

    mov byte [gs:0x338], 'R'
    mov byte [gs:0x339], 7
	
	mov byte [gs:0x33a], ' '
    mov byte [gs:0x33b], 7
	mov byte [gs:0x33c], 'L'
    mov byte [gs:0x33d], 7
	mov byte [gs:0x33e], 'o'
    mov byte [gs:0x33f], 7
	mov byte [gs:0x340], 'a'
    mov byte [gs:0x341], 7
	mov byte [gs:0x342], 'd'
    mov byte [gs:0x343], 7
	mov byte [gs:0x344], 'i'
    mov byte [gs:0x345], 7
	mov byte [gs:0x346], 'n'
    mov byte [gs:0x347], 7
	mov byte [gs:0x348], 'g'
    mov byte [gs:0x349], 7
	mov byte [gs:0x34a], '.'
    mov byte [gs:0x34b], 7
	mov byte [gs:0x34c], '.'
    mov byte [gs:0x34d], 7
	mov byte [gs:0x34e], '.'
    mov byte [gs:0x34f], 7
	mov byte [gs:0x350], ' '
    mov byte [gs:0x351], 7
	
	mov eax,LOADER_START_SECTOR	 ; 起始扇区lba地址
	mov bx,LOADER_BASE_ADDR       ; 写入的地址
	mov cx,1			 ; 待读入的扇区数
	call rd_disk_m_16		 ; 以下读取程序的起始部分（一个扇区）
  
	jmp LOADER_BASE_ADDR
       
;-------------------------------------------------------------------------------
;功能:读取硬盘n个扇区
rd_disk_m_16:	   
;-------------------------------------------------------------------------------
				       ; eax=LBA扇区号
				       ; ebx=将数据写入的内存地址
				       ; ecx=读入的扇区数
	mov esi,eax	  ;备份eax
	mov di,cx		  ;备份cx
;读写硬盘:
;第1步：设置要读取的扇区数
	mov dx,0x1f2
	mov al,cl
	out dx,al            ;读取的扇区数

	mov eax,esi	   ;恢复ax

;第2步：将LBA地址存入0x1f3 ~ 0x1f6

      ;LBA地址7~0位写入端口0x1f3
	mov dx,0x1f3                       
	out dx,al                          

      ;LBA地址15~8位写入端口0x1f4
	mov cl,8
	shr eax,cl
	mov dx,0x1f4
	out dx,al

      ;LBA地址23~16位写入端口0x1f5
	shr eax,cl
	mov dx,0x1f5
	out dx,al

	shr eax,cl
	and al,0x0f	   ;lba第24~27位
	or al,0xe0	   ; 设置7～4位为1110,表示lba模式
	mov dx,0x1f6
	out dx,al

;第3步：向0x1f7端口写入读命令，0x20 
	mov dx,0x1f7
	mov al,0x20                        
	out dx,al

;第4步：检测硬盘状态
.not_ready:
      ;同一端口，写时表示写入命令字，读时表示读入硬盘状态
	nop
	in al,dx
	and al,0x88	   ;第4位为1表示硬盘控制器已准备好数据传输，第7位为1表示硬盘忙
	cmp al,0x08
	jnz .not_ready	   ;若未准备好，继续等。

;第5步：从0x1f0端口读数据
	mov ax, di
	mov dx, 256
	mul dx
	mov cx, ax	   ; di为要读取的扇区数，一个扇区有512字节，每次读入一个字，
			   ; 共需di*512/2次，所以di*256
	mov dx, 0x1f0
  .go_on_read:
	in ax,dx
	mov [bx],ax
	add bx,2		  
	loop .go_on_read
	ret

	times 510-($-$$) db 0
	db 0x55,0xaa
