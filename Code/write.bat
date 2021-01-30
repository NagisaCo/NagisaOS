cd boot
nasm -o mbr.bin mbr.asm
cd ..
dd if=boot\mbr.bin of=hd60M.img bs=512 count=1 conv=notrunc
pause