# 编写MBR主引导记录
## 一、BIOS
### 1. 实模式下的1MB内存布局
![实模式下的内存布局](pic/2.1_1.jpg)
### 2. 加电启动
当前指令位置：f000:fff0 ( *0xffff0* BIOS入口地址)  
当前指令: jmpf f000:e05b  ( *0xfe05b* BIOS代码开始处)
![t0状态](pic/2.1_2.jpg)

## 二、MBR
> MBR大小必须是512字节，为了保证0x55与0xaa在该扇区最后两个字节处（小端字节序：AA（高位）+55（低位）=0xaa55）
```asm
section mbr vstart=0x7c00
;vstart:标明段内程序开始点
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov sp,0x7c00
;int 10h,ah=06h:清屏
    mov ax,0x600
    mov bx,0x700
    mov cx,0
    mov dx,0x184f
    int 0x10
;int 10h，ah=03h获取光标位置
    mov ah,3
    mov bh,0
    int 0x10
    
```