@echo off
cd "C:\Users\Co\Documents\Work\NagisaOS\Code\boot"
nasm -I include\ -o mbr.bin mbr.S
nasm -I include\ -o loader.bin loader.S
cd ..
dd if=boot\mbr.bin of=hd60M.img bs=512 count=1 seek=0 conv=notrunc
dd if=boot\loader.bin of=hd60M.img bs=512 count=4 seek=2 conv=notrunc
pause