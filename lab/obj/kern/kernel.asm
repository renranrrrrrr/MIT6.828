
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 58 08 ff ff    	lea    -0xf7a8(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 9c 0a 00 00       	call   f0100aff <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7f 2b                	jg     f0100095 <test_backtrace+0x55>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010006a:	83 ec 04             	sub    $0x4,%esp
f010006d:	6a 00                	push   $0x0
f010006f:	6a 00                	push   $0x0
f0100071:	6a 00                	push   $0x0
f0100073:	e8 22 08 00 00       	call   f010089a <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 74 08 ff ff    	lea    -0xf78c(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 74 0a 00 00       	call   f0100aff <cprintf>
}
f010008b:	83 c4 10             	add    $0x10,%esp
f010008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100091:	5b                   	pop    %ebx
f0100092:	5e                   	pop    %esi
f0100093:	5d                   	pop    %ebp
f0100094:	c3                   	ret    
		test_backtrace(x-1);
f0100095:	83 ec 0c             	sub    $0xc,%esp
f0100098:	8d 46 ff             	lea    -0x1(%esi),%eax
f010009b:	50                   	push   %eax
f010009c:	e8 9f ff ff ff       	call   f0100040 <test_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d5                	jmp    f010007b <test_backtrace+0x3b>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 45 16 00 00       	call   f0101714 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3d 05 00 00       	call   f0100611 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 8f 08 ff ff    	lea    -0xf771(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 17 0a 00 00       	call   f0100aff <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 46 08 00 00       	call   f0100947 <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	57                   	push   %edi
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	83 ec 0c             	sub    $0xc,%esp
f010010f:	e8 a8 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100114:	81 c3 f4 11 01 00    	add    $0x111f4,%ebx
f010011a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010011d:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f0100123:	83 38 00             	cmpl   $0x0,(%eax)
f0100126:	74 0f                	je     f0100137 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100128:	83 ec 0c             	sub    $0xc,%esp
f010012b:	6a 00                	push   $0x0
f010012d:	e8 15 08 00 00       	call   f0100947 <monitor>
f0100132:	83 c4 10             	add    $0x10,%esp
f0100135:	eb f1                	jmp    f0100128 <_panic+0x22>
	panicstr = fmt;
f0100137:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    
	va_start(ap, fmt);
f010013b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	8d 83 aa 08 ff ff    	lea    -0xf756(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 ac 09 00 00       	call   f0100aff <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 6b 09 00 00       	call   f0100ac8 <vcprintf>
	cprintf("\n");
f010015d:	8d 83 e6 08 ff ff    	lea    -0xf71a(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 94 09 00 00       	call   f0100aff <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb b8                	jmp    f0100128 <_panic+0x22>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 c2 08 ff ff    	lea    -0xf73e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 67 09 00 00       	call   f0100aff <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 24 09 00 00       	call   f0100ac8 <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 e6 08 ff ff    	lea    -0xf71a(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 4d 09 00 00       	call   f0100aff <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c9:	a8 01                	test   $0x1,%al
f01001cb:	74 0b                	je     f01001d8 <serial_proc_data+0x18>
f01001cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d3:	0f b6 c0             	movzbl %al,%eax
}
f01001d6:	5d                   	pop    %ebp
f01001d7:	c3                   	ret    
		return -1;
f01001d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001dd:	eb f7                	jmp    f01001d6 <serial_proc_data+0x16>

f01001df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	e8 d3 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01001e9:	81 c3 1f 11 01 00    	add    $0x1111f,%ebx
f01001ef:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d6                	call   *%esi
f01001f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f6:	74 2e                	je     f0100226 <cons_intr+0x47>
		if (c == 0)
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	74 f5                	je     f01001f1 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fc:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010020b:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100212:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100218:	75 d7                	jne    f01001f1 <cons_intr+0x12>
			cons.wpos = 0;
f010021a:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f0100221:	00 00 00 
f0100224:	eb cb                	jmp    f01001f1 <cons_intr+0x12>
	}
}
f0100226:	5b                   	pop    %ebx
f0100227:	5e                   	pop    %esi
f0100228:	5d                   	pop    %ebp
f0100229:	c3                   	ret    

f010022a <kbd_proc_data>:
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	56                   	push   %esi
f010022e:	53                   	push   %ebx
f010022f:	e8 88 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100234:	81 c3 d4 10 01 00    	add    $0x110d4,%ebx
f010023a:	ba 64 00 00 00       	mov    $0x64,%edx
f010023f:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100240:	a8 01                	test   $0x1,%al
f0100242:	0f 84 06 01 00 00    	je     f010034e <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100248:	a8 20                	test   $0x20,%al
f010024a:	0f 85 05 01 00 00    	jne    f0100355 <kbd_proc_data+0x12b>
f0100250:	ba 60 00 00 00       	mov    $0x60,%edx
f0100255:	ec                   	in     (%dx),%al
f0100256:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100258:	3c e0                	cmp    $0xe0,%al
f010025a:	0f 84 93 00 00 00    	je     f01002f3 <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f0100260:	84 c0                	test   %al,%al
f0100262:	0f 88 a0 00 00 00    	js     f0100308 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100268:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010026e:	f6 c1 40             	test   $0x40,%cl
f0100271:	74 0e                	je     f0100281 <kbd_proc_data+0x57>
		data |= 0x80;
f0100273:	83 c8 80             	or     $0xffffff80,%eax
f0100276:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100278:	83 e1 bf             	and    $0xffffffbf,%ecx
f010027b:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100281:	0f b6 d2             	movzbl %dl,%edx
f0100284:	0f b6 84 13 18 0a ff 	movzbl -0xf5e8(%ebx,%edx,1),%eax
f010028b:	ff 
f010028c:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100292:	0f b6 8c 13 18 09 ff 	movzbl -0xf6e8(%ebx,%edx,1),%ecx
f0100299:	ff 
f010029a:	31 c8                	xor    %ecx,%eax
f010029c:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a2:	89 c1                	mov    %eax,%ecx
f01002a4:	83 e1 03             	and    $0x3,%ecx
f01002a7:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ae:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002b2:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002b5:	a8 08                	test   $0x8,%al
f01002b7:	74 0d                	je     f01002c6 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002b9:	89 f2                	mov    %esi,%edx
f01002bb:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002be:	83 f9 19             	cmp    $0x19,%ecx
f01002c1:	77 7a                	ja     f010033d <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002c3:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c6:	f7 d0                	not    %eax
f01002c8:	a8 06                	test   $0x6,%al
f01002ca:	75 33                	jne    f01002ff <kbd_proc_data+0xd5>
f01002cc:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002d2:	75 2b                	jne    f01002ff <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01002d4:	83 ec 0c             	sub    $0xc,%esp
f01002d7:	8d 83 dc 08 ff ff    	lea    -0xf724(%ebx),%eax
f01002dd:	50                   	push   %eax
f01002de:	e8 1c 08 00 00       	call   f0100aff <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e8:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ed:	ee                   	out    %al,(%dx)
f01002ee:	83 c4 10             	add    $0x10,%esp
f01002f1:	eb 0c                	jmp    f01002ff <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002f3:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002fa:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002ff:	89 f0                	mov    %esi,%eax
f0100301:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100304:	5b                   	pop    %ebx
f0100305:	5e                   	pop    %esi
f0100306:	5d                   	pop    %ebp
f0100307:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100308:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010030e:	89 ce                	mov    %ecx,%esi
f0100310:	83 e6 40             	and    $0x40,%esi
f0100313:	83 e0 7f             	and    $0x7f,%eax
f0100316:	85 f6                	test   %esi,%esi
f0100318:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031b:	0f b6 d2             	movzbl %dl,%edx
f010031e:	0f b6 84 13 18 0a ff 	movzbl -0xf5e8(%ebx,%edx,1),%eax
f0100325:	ff 
f0100326:	83 c8 40             	or     $0x40,%eax
f0100329:	0f b6 c0             	movzbl %al,%eax
f010032c:	f7 d0                	not    %eax
f010032e:	21 c8                	and    %ecx,%eax
f0100330:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f0100336:	be 00 00 00 00       	mov    $0x0,%esi
f010033b:	eb c2                	jmp    f01002ff <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f010033d:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100340:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100343:	83 fa 1a             	cmp    $0x1a,%edx
f0100346:	0f 42 f1             	cmovb  %ecx,%esi
f0100349:	e9 78 ff ff ff       	jmp    f01002c6 <kbd_proc_data+0x9c>
		return -1;
f010034e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100353:	eb aa                	jmp    f01002ff <kbd_proc_data+0xd5>
		return -1;
f0100355:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035a:	eb a3                	jmp    f01002ff <kbd_proc_data+0xd5>

f010035c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010035c:	55                   	push   %ebp
f010035d:	89 e5                	mov    %esp,%ebp
f010035f:	57                   	push   %edi
f0100360:	56                   	push   %esi
f0100361:	53                   	push   %ebx
f0100362:	83 ec 1c             	sub    $0x1c,%esp
f0100365:	e8 52 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010036a:	81 c3 9e 0f 01 00    	add    $0x10f9e,%ebx
f0100370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100373:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100378:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010037d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100382:	eb 09                	jmp    f010038d <cons_putc+0x31>
f0100384:	89 ca                	mov    %ecx,%edx
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
f0100389:	ec                   	in     (%dx),%al
	     i++)
f010038a:	83 c6 01             	add    $0x1,%esi
f010038d:	89 fa                	mov    %edi,%edx
f010038f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100390:	a8 20                	test   $0x20,%al
f0100392:	75 08                	jne    f010039c <cons_putc+0x40>
f0100394:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010039a:	7e e8                	jle    f0100384 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039f:	89 f8                	mov    %edi,%eax
f01003a1:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a9:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003aa:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003af:	bf 79 03 00 00       	mov    $0x379,%edi
f01003b4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b9:	eb 09                	jmp    f01003c4 <cons_putc+0x68>
f01003bb:	89 ca                	mov    %ecx,%edx
f01003bd:	ec                   	in     (%dx),%al
f01003be:	ec                   	in     (%dx),%al
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	83 c6 01             	add    $0x1,%esi
f01003c4:	89 fa                	mov    %edi,%edx
f01003c6:	ec                   	in     (%dx),%al
f01003c7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003cd:	7f 04                	jg     f01003d3 <cons_putc+0x77>
f01003cf:	84 c0                	test   %al,%al
f01003d1:	79 e8                	jns    f01003bb <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d3:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d8:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003dc:	ee                   	out    %al,(%dx)
f01003dd:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e7:	ee                   	out    %al,(%dx)
f01003e8:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ed:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f1:	89 fa                	mov    %edi,%edx
f01003f3:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003f9:	89 f8                	mov    %edi,%eax
f01003fb:	80 cc 07             	or     $0x7,%ah
f01003fe:	85 d2                	test   %edx,%edx
f0100400:	0f 45 c7             	cmovne %edi,%eax
f0100403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100406:	0f b6 c0             	movzbl %al,%eax
f0100409:	83 f8 09             	cmp    $0x9,%eax
f010040c:	0f 84 b9 00 00 00    	je     f01004cb <cons_putc+0x16f>
f0100412:	83 f8 09             	cmp    $0x9,%eax
f0100415:	7e 74                	jle    f010048b <cons_putc+0x12f>
f0100417:	83 f8 0a             	cmp    $0xa,%eax
f010041a:	0f 84 9e 00 00 00    	je     f01004be <cons_putc+0x162>
f0100420:	83 f8 0d             	cmp    $0xd,%eax
f0100423:	0f 85 d9 00 00 00    	jne    f0100502 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100429:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100430:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100436:	c1 e8 16             	shr    $0x16,%eax
f0100439:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043c:	c1 e0 04             	shl    $0x4,%eax
f010043f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100446:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010044d:	cf 07 
f010044f:	0f 87 d4 00 00 00    	ja     f0100529 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100455:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f010045b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100460:	89 ca                	mov    %ecx,%edx
f0100462:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100463:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f010046a:	8d 71 01             	lea    0x1(%ecx),%esi
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	66 c1 e8 08          	shr    $0x8,%ax
f0100473:	89 f2                	mov    %esi,%edx
f0100475:	ee                   	out    %al,(%dx)
f0100476:	b8 0f 00 00 00       	mov    $0xf,%eax
f010047b:	89 ca                	mov    %ecx,%edx
f010047d:	ee                   	out    %al,(%dx)
f010047e:	89 d8                	mov    %ebx,%eax
f0100480:	89 f2                	mov    %esi,%edx
f0100482:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100483:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100486:	5b                   	pop    %ebx
f0100487:	5e                   	pop    %esi
f0100488:	5f                   	pop    %edi
f0100489:	5d                   	pop    %ebp
f010048a:	c3                   	ret    
	switch (c & 0xff) {
f010048b:	83 f8 08             	cmp    $0x8,%eax
f010048e:	75 72                	jne    f0100502 <cons_putc+0x1a6>
		if (crt_pos > 0) {
f0100490:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100497:	66 85 c0             	test   %ax,%ax
f010049a:	74 b9                	je     f0100455 <cons_putc+0xf9>
			crt_pos--;
f010049c:	83 e8 01             	sub    $0x1,%eax
f010049f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ad:	b2 00                	mov    $0x0,%dl
f01004af:	83 ca 20             	or     $0x20,%edx
f01004b2:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004b8:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004bc:	eb 88                	jmp    f0100446 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01004be:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004c5:	50 
f01004c6:	e9 5e ff ff ff       	jmp    f0100429 <cons_putc+0xcd>
		cons_putc(' ');
f01004cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d0:	e8 87 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004da:	e8 7d fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004df:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e4:	e8 73 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ee:	e8 69 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f8:	e8 5f fe ff ff       	call   f010035c <cons_putc>
f01004fd:	e9 44 ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100502:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100509:	8d 50 01             	lea    0x1(%eax),%edx
f010050c:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100513:	0f b7 c0             	movzwl %ax,%eax
f0100516:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010051c:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100520:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100524:	e9 1d ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100529:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010052f:	83 ec 04             	sub    $0x4,%esp
f0100532:	68 00 0f 00 00       	push   $0xf00
f0100537:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010053d:	52                   	push   %edx
f010053e:	50                   	push   %eax
f010053f:	e8 1d 12 00 00       	call   f0101761 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100544:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010054a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100550:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100556:	83 c4 10             	add    $0x10,%esp
f0100559:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010055e:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100561:	39 d0                	cmp    %edx,%eax
f0100563:	75 f4                	jne    f0100559 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100565:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010056c:	50 
f010056d:	e9 e3 fe ff ff       	jmp    f0100455 <cons_putc+0xf9>

f0100572 <serial_intr>:
{
f0100572:	e8 e7 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f0100577:	05 91 0d 01 00       	add    $0x10d91,%eax
	if (serial_exists)
f010057c:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100583:	75 02                	jne    f0100587 <serial_intr+0x15>
f0100585:	f3 c3                	repz ret 
{
f0100587:	55                   	push   %ebp
f0100588:	89 e5                	mov    %esp,%ebp
f010058a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010058d:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f0100593:	e8 47 fc ff ff       	call   f01001df <cons_intr>
}
f0100598:	c9                   	leave  
f0100599:	c3                   	ret    

f010059a <kbd_intr>:
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	83 ec 08             	sub    $0x8,%esp
f01005a0:	e8 b9 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f01005a5:	05 63 0d 01 00       	add    $0x10d63,%eax
	cons_intr(kbd_proc_data);
f01005aa:	8d 80 22 ef fe ff    	lea    -0x110de(%eax),%eax
f01005b0:	e8 2a fc ff ff       	call   f01001df <cons_intr>
}
f01005b5:	c9                   	leave  
f01005b6:	c3                   	ret    

f01005b7 <cons_getc>:
{
f01005b7:	55                   	push   %ebp
f01005b8:	89 e5                	mov    %esp,%ebp
f01005ba:	53                   	push   %ebx
f01005bb:	83 ec 04             	sub    $0x4,%esp
f01005be:	e8 f9 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005c3:	81 c3 45 0d 01 00    	add    $0x10d45,%ebx
	serial_intr();
f01005c9:	e8 a4 ff ff ff       	call   f0100572 <serial_intr>
	kbd_intr();
f01005ce:	e8 c7 ff ff ff       	call   f010059a <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005d3:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f01005d9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005de:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f01005e4:	74 19                	je     f01005ff <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005e9:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f01005ef:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f01005f6:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005f7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005fd:	74 06                	je     f0100605 <cons_getc+0x4e>
}
f01005ff:	83 c4 04             	add    $0x4,%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5d                   	pop    %ebp
f0100604:	c3                   	ret    
			cons.rpos = 0;
f0100605:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010060c:	00 00 00 
f010060f:	eb ee                	jmp    f01005ff <cons_getc+0x48>

f0100611 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	57                   	push   %edi
f0100615:	56                   	push   %esi
f0100616:	53                   	push   %ebx
f0100617:	83 ec 1c             	sub    $0x1c,%esp
f010061a:	e8 9d fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010061f:	81 c3 e9 0c 01 00    	add    $0x10ce9,%ebx
	was = *cp;
f0100625:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100633:	5a a5 
	if (*cp != 0xA55A) {
f0100635:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100640:	0f 84 bc 00 00 00    	je     f0100702 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100646:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010064d:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100650:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100657:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010065d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100662:	89 fa                	mov    %edi,%edx
f0100664:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100665:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100668:	89 ca                	mov    %ecx,%edx
f010066a:	ec                   	in     (%dx),%al
f010066b:	0f b6 f0             	movzbl %al,%esi
f010066e:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100671:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100676:	89 fa                	mov    %edi,%edx
f0100678:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100679:	89 ca                	mov    %ecx,%edx
f010067b:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010067f:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100685:	0f b6 c0             	movzbl %al,%eax
f0100688:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010068a:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100691:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100696:	89 c8                	mov    %ecx,%eax
f0100698:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010069d:	ee                   	out    %al,(%dx)
f010069e:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006a3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a8:	89 fa                	mov    %edi,%edx
f01006aa:	ee                   	out    %al,(%dx)
f01006ab:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006b0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b5:	ee                   	out    %al,(%dx)
f01006b6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006bb:	89 c8                	mov    %ecx,%eax
f01006bd:	89 f2                	mov    %esi,%edx
f01006bf:	ee                   	out    %al,(%dx)
f01006c0:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c5:	89 fa                	mov    %edi,%edx
f01006c7:	ee                   	out    %al,(%dx)
f01006c8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006cd:	89 c8                	mov    %ecx,%eax
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d5:	89 f2                	mov    %esi,%edx
f01006d7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006dd:	ec                   	in     (%dx),%al
f01006de:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006e0:	3c ff                	cmp    $0xff,%al
f01006e2:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006e9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006ee:	ec                   	in     (%dx),%al
f01006ef:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f4:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f5:	80 f9 ff             	cmp    $0xff,%cl
f01006f8:	74 25                	je     f010071f <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006fd:	5b                   	pop    %ebx
f01006fe:	5e                   	pop    %esi
f01006ff:	5f                   	pop    %edi
f0100700:	5d                   	pop    %ebp
f0100701:	c3                   	ret    
		*cp = was;
f0100702:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100709:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100710:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100713:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010071a:	e9 38 ff ff ff       	jmp    f0100657 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f010071f:	83 ec 0c             	sub    $0xc,%esp
f0100722:	8d 83 e8 08 ff ff    	lea    -0xf718(%ebx),%eax
f0100728:	50                   	push   %eax
f0100729:	e8 d1 03 00 00       	call   f0100aff <cprintf>
f010072e:	83 c4 10             	add    $0x10,%esp
}
f0100731:	eb c7                	jmp    f01006fa <cons_init+0xe9>

f0100733 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100739:	8b 45 08             	mov    0x8(%ebp),%eax
f010073c:	e8 1b fc ff ff       	call   f010035c <cons_putc>
}
f0100741:	c9                   	leave  
f0100742:	c3                   	ret    

f0100743 <getchar>:

int
getchar(void)
{
f0100743:	55                   	push   %ebp
f0100744:	89 e5                	mov    %esp,%ebp
f0100746:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100749:	e8 69 fe ff ff       	call   f01005b7 <cons_getc>
f010074e:	85 c0                	test   %eax,%eax
f0100750:	74 f7                	je     f0100749 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100752:	c9                   	leave  
f0100753:	c3                   	ret    

f0100754 <iscons>:

int
iscons(int fdnum)
{
f0100754:	55                   	push   %ebp
f0100755:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100757:	b8 01 00 00 00       	mov    $0x1,%eax
f010075c:	5d                   	pop    %ebp
f010075d:	c3                   	ret    

f010075e <__x86.get_pc_thunk.ax>:
f010075e:	8b 04 24             	mov    (%esp),%eax
f0100761:	c3                   	ret    

f0100762 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100762:	55                   	push   %ebp
f0100763:	89 e5                	mov    %esp,%ebp
f0100765:	56                   	push   %esi
f0100766:	53                   	push   %ebx
f0100767:	e8 50 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010076c:	81 c3 9c 0b 01 00    	add    $0x10b9c,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100772:	83 ec 04             	sub    $0x4,%esp
f0100775:	8d 83 18 0b ff ff    	lea    -0xf4e8(%ebx),%eax
f010077b:	50                   	push   %eax
f010077c:	8d 83 36 0b ff ff    	lea    -0xf4ca(%ebx),%eax
f0100782:	50                   	push   %eax
f0100783:	8d b3 3b 0b ff ff    	lea    -0xf4c5(%ebx),%esi
f0100789:	56                   	push   %esi
f010078a:	e8 70 03 00 00       	call   f0100aff <cprintf>
f010078f:	83 c4 0c             	add    $0xc,%esp
f0100792:	8d 83 f4 0b ff ff    	lea    -0xf40c(%ebx),%eax
f0100798:	50                   	push   %eax
f0100799:	8d 83 44 0b ff ff    	lea    -0xf4bc(%ebx),%eax
f010079f:	50                   	push   %eax
f01007a0:	56                   	push   %esi
f01007a1:	e8 59 03 00 00       	call   f0100aff <cprintf>
f01007a6:	83 c4 0c             	add    $0xc,%esp
f01007a9:	8d 83 4d 0b ff ff    	lea    -0xf4b3(%ebx),%eax
f01007af:	50                   	push   %eax
f01007b0:	8d 83 6b 0b ff ff    	lea    -0xf495(%ebx),%eax
f01007b6:	50                   	push   %eax
f01007b7:	56                   	push   %esi
f01007b8:	e8 42 03 00 00       	call   f0100aff <cprintf>
	return 0;
}
f01007bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007c5:	5b                   	pop    %ebx
f01007c6:	5e                   	pop    %esi
f01007c7:	5d                   	pop    %ebp
f01007c8:	c3                   	ret    

f01007c9 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007c9:	55                   	push   %ebp
f01007ca:	89 e5                	mov    %esp,%ebp
f01007cc:	57                   	push   %edi
f01007cd:	56                   	push   %esi
f01007ce:	53                   	push   %ebx
f01007cf:	83 ec 18             	sub    $0x18,%esp
f01007d2:	e8 e5 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007d7:	81 c3 31 0b 01 00    	add    $0x10b31,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007dd:	8d 83 75 0b ff ff    	lea    -0xf48b(%ebx),%eax
f01007e3:	50                   	push   %eax
f01007e4:	e8 16 03 00 00       	call   f0100aff <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e9:	83 c4 08             	add    $0x8,%esp
f01007ec:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007f2:	8d 83 1c 0c ff ff    	lea    -0xf3e4(%ebx),%eax
f01007f8:	50                   	push   %eax
f01007f9:	e8 01 03 00 00       	call   f0100aff <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007fe:	83 c4 0c             	add    $0xc,%esp
f0100801:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100807:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f010080d:	50                   	push   %eax
f010080e:	57                   	push   %edi
f010080f:	8d 83 44 0c ff ff    	lea    -0xf3bc(%ebx),%eax
f0100815:	50                   	push   %eax
f0100816:	e8 e4 02 00 00       	call   f0100aff <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010081b:	83 c4 0c             	add    $0xc,%esp
f010081e:	c7 c0 49 1b 10 f0    	mov    $0xf0101b49,%eax
f0100824:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010082a:	52                   	push   %edx
f010082b:	50                   	push   %eax
f010082c:	8d 83 68 0c ff ff    	lea    -0xf398(%ebx),%eax
f0100832:	50                   	push   %eax
f0100833:	e8 c7 02 00 00       	call   f0100aff <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100838:	83 c4 0c             	add    $0xc,%esp
f010083b:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f0100841:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100847:	52                   	push   %edx
f0100848:	50                   	push   %eax
f0100849:	8d 83 8c 0c ff ff    	lea    -0xf374(%ebx),%eax
f010084f:	50                   	push   %eax
f0100850:	e8 aa 02 00 00       	call   f0100aff <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100855:	83 c4 0c             	add    $0xc,%esp
f0100858:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f010085e:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100864:	50                   	push   %eax
f0100865:	56                   	push   %esi
f0100866:	8d 83 b0 0c ff ff    	lea    -0xf350(%ebx),%eax
f010086c:	50                   	push   %eax
f010086d:	e8 8d 02 00 00       	call   f0100aff <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100872:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100875:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010087b:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010087d:	c1 fe 0a             	sar    $0xa,%esi
f0100880:	56                   	push   %esi
f0100881:	8d 83 d4 0c ff ff    	lea    -0xf32c(%ebx),%eax
f0100887:	50                   	push   %eax
f0100888:	e8 72 02 00 00       	call   f0100aff <cprintf>
	return 0;
}
f010088d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100892:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100895:	5b                   	pop    %ebx
f0100896:	5e                   	pop    %esi
f0100897:	5f                   	pop    %edi
f0100898:	5d                   	pop    %ebp
f0100899:	c3                   	ret    

f010089a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010089a:	55                   	push   %ebp
f010089b:	89 e5                	mov    %esp,%ebp
f010089d:	57                   	push   %edi
f010089e:	56                   	push   %esi
f010089f:	53                   	push   %ebx
f01008a0:	83 ec 48             	sub    $0x48,%esp
f01008a3:	e8 14 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01008a8:	81 c3 60 0a 01 00    	add    $0x10a60,%ebx
	// Your code here.
	uint32_t *ebp;
	struct Eipdebuginfo info;

	cprintf("Stack backtrace:\n");
f01008ae:	8d 83 8e 0b ff ff    	lea    -0xf472(%ebx),%eax
f01008b4:	50                   	push   %eax
f01008b5:	e8 45 02 00 00       	call   f0100aff <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ba:	89 ee                	mov    %ebp,%esi
	
	ebp = (uint32_t *)read_ebp();

	while(ebp!=0){
f01008bc:	83 c4 10             	add    $0x10,%esp
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01008bf:	8d bb 00 0d ff ff    	lea    -0xf300(%ebx),%edi
			ebp, ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		
		int res = debuginfo_eip(ebp[1], &info);
f01008c5:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008c8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while(ebp!=0){
f01008cb:	eb 14                	jmp    f01008e1 <mon_backtrace+0x47>
			cprintf("%s:%d: %.*s+%u\n",
			 info.eip_file,info.eip_line,
			 info.eip_fn_namelen,info.eip_fn_name,
			 fn_offset);
		}
		else cprintf("Error!\n");
f01008cd:	83 ec 0c             	sub    $0xc,%esp
f01008d0:	8d 83 b0 0b ff ff    	lea    -0xf450(%ebx),%eax
f01008d6:	50                   	push   %eax
f01008d7:	e8 23 02 00 00       	call   f0100aff <cprintf>
f01008dc:	83 c4 10             	add    $0x10,%esp
		ebp = (uint32_t *)*ebp;
f01008df:	8b 36                	mov    (%esi),%esi
	while(ebp!=0){
f01008e1:	85 f6                	test   %esi,%esi
f01008e3:	74 55                	je     f010093a <mon_backtrace+0xa0>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01008e5:	ff 76 18             	pushl  0x18(%esi)
f01008e8:	ff 76 14             	pushl  0x14(%esi)
f01008eb:	ff 76 10             	pushl  0x10(%esi)
f01008ee:	ff 76 0c             	pushl  0xc(%esi)
f01008f1:	ff 76 08             	pushl  0x8(%esi)
f01008f4:	ff 76 04             	pushl  0x4(%esi)
f01008f7:	56                   	push   %esi
f01008f8:	57                   	push   %edi
f01008f9:	e8 01 02 00 00       	call   f0100aff <cprintf>
		int res = debuginfo_eip(ebp[1], &info);
f01008fe:	83 c4 18             	add    $0x18,%esp
f0100901:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100904:	ff 76 04             	pushl  0x4(%esi)
f0100907:	e8 f7 02 00 00       	call   f0100c03 <debuginfo_eip>
		if(res == 0){
f010090c:	83 c4 10             	add    $0x10,%esp
f010090f:	85 c0                	test   %eax,%eax
f0100911:	75 ba                	jne    f01008cd <mon_backtrace+0x33>
			cprintf("%s:%d: %.*s+%u\n",
f0100913:	83 ec 08             	sub    $0x8,%esp
			int fn_offset = *(ebp+1) - info.eip_fn_addr;
f0100916:	8b 46 04             	mov    0x4(%esi),%eax
f0100919:	2b 45 e0             	sub    -0x20(%ebp),%eax
			cprintf("%s:%d: %.*s+%u\n",
f010091c:	50                   	push   %eax
f010091d:	ff 75 d8             	pushl  -0x28(%ebp)
f0100920:	ff 75 dc             	pushl  -0x24(%ebp)
f0100923:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100926:	ff 75 d0             	pushl  -0x30(%ebp)
f0100929:	8d 83 a0 0b ff ff    	lea    -0xf460(%ebx),%eax
f010092f:	50                   	push   %eax
f0100930:	e8 ca 01 00 00       	call   f0100aff <cprintf>
f0100935:	83 c4 20             	add    $0x20,%esp
f0100938:	eb a5                	jmp    f01008df <mon_backtrace+0x45>
	}
	return 0;
}
f010093a:	b8 00 00 00 00       	mov    $0x0,%eax
f010093f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100942:	5b                   	pop    %ebx
f0100943:	5e                   	pop    %esi
f0100944:	5f                   	pop    %edi
f0100945:	5d                   	pop    %ebp
f0100946:	c3                   	ret    

f0100947 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100947:	55                   	push   %ebp
f0100948:	89 e5                	mov    %esp,%ebp
f010094a:	57                   	push   %edi
f010094b:	56                   	push   %esi
f010094c:	53                   	push   %ebx
f010094d:	83 ec 68             	sub    $0x68,%esp
f0100950:	e8 67 f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100955:	81 c3 b3 09 01 00    	add    $0x109b3,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010095b:	8d 83 38 0d ff ff    	lea    -0xf2c8(%ebx),%eax
f0100961:	50                   	push   %eax
f0100962:	e8 98 01 00 00       	call   f0100aff <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100967:	8d 83 5c 0d ff ff    	lea    -0xf2a4(%ebx),%eax
f010096d:	89 04 24             	mov    %eax,(%esp)
f0100970:	e8 8a 01 00 00       	call   f0100aff <cprintf>
f0100975:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100978:	8d bb bc 0b ff ff    	lea    -0xf444(%ebx),%edi
f010097e:	eb 4a                	jmp    f01009ca <monitor+0x83>
f0100980:	83 ec 08             	sub    $0x8,%esp
f0100983:	0f be c0             	movsbl %al,%eax
f0100986:	50                   	push   %eax
f0100987:	57                   	push   %edi
f0100988:	e8 4a 0d 00 00       	call   f01016d7 <strchr>
f010098d:	83 c4 10             	add    $0x10,%esp
f0100990:	85 c0                	test   %eax,%eax
f0100992:	74 08                	je     f010099c <monitor+0x55>
			*buf++ = 0;
f0100994:	c6 06 00             	movb   $0x0,(%esi)
f0100997:	8d 76 01             	lea    0x1(%esi),%esi
f010099a:	eb 79                	jmp    f0100a15 <monitor+0xce>
		if (*buf == 0)
f010099c:	80 3e 00             	cmpb   $0x0,(%esi)
f010099f:	74 7f                	je     f0100a20 <monitor+0xd9>
		if (argc == MAXARGS-1) {
f01009a1:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009a5:	74 0f                	je     f01009b6 <monitor+0x6f>
		argv[argc++] = buf;
f01009a7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009aa:	8d 48 01             	lea    0x1(%eax),%ecx
f01009ad:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009b0:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f01009b4:	eb 44                	jmp    f01009fa <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009b6:	83 ec 08             	sub    $0x8,%esp
f01009b9:	6a 10                	push   $0x10
f01009bb:	8d 83 c1 0b ff ff    	lea    -0xf43f(%ebx),%eax
f01009c1:	50                   	push   %eax
f01009c2:	e8 38 01 00 00       	call   f0100aff <cprintf>
f01009c7:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009ca:	8d 83 b8 0b ff ff    	lea    -0xf448(%ebx),%eax
f01009d0:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01009d3:	83 ec 0c             	sub    $0xc,%esp
f01009d6:	ff 75 a4             	pushl  -0x5c(%ebp)
f01009d9:	e8 c1 0a 00 00       	call   f010149f <readline>
f01009de:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009e0:	83 c4 10             	add    $0x10,%esp
f01009e3:	85 c0                	test   %eax,%eax
f01009e5:	74 ec                	je     f01009d3 <monitor+0x8c>
	argv[argc] = 0;
f01009e7:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009ee:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009f5:	eb 1e                	jmp    f0100a15 <monitor+0xce>
			buf++;
f01009f7:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009fa:	0f b6 06             	movzbl (%esi),%eax
f01009fd:	84 c0                	test   %al,%al
f01009ff:	74 14                	je     f0100a15 <monitor+0xce>
f0100a01:	83 ec 08             	sub    $0x8,%esp
f0100a04:	0f be c0             	movsbl %al,%eax
f0100a07:	50                   	push   %eax
f0100a08:	57                   	push   %edi
f0100a09:	e8 c9 0c 00 00       	call   f01016d7 <strchr>
f0100a0e:	83 c4 10             	add    $0x10,%esp
f0100a11:	85 c0                	test   %eax,%eax
f0100a13:	74 e2                	je     f01009f7 <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a15:	0f b6 06             	movzbl (%esi),%eax
f0100a18:	84 c0                	test   %al,%al
f0100a1a:	0f 85 60 ff ff ff    	jne    f0100980 <monitor+0x39>
	argv[argc] = 0;
f0100a20:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a23:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a2a:	00 
	if (argc == 0)
f0100a2b:	85 c0                	test   %eax,%eax
f0100a2d:	74 9b                	je     f01009ca <monitor+0x83>
f0100a2f:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a35:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%ebp)
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a3c:	83 ec 08             	sub    $0x8,%esp
f0100a3f:	ff 36                	pushl  (%esi)
f0100a41:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a44:	e8 30 0c 00 00       	call   f0101679 <strcmp>
f0100a49:	83 c4 10             	add    $0x10,%esp
f0100a4c:	85 c0                	test   %eax,%eax
f0100a4e:	74 29                	je     f0100a79 <monitor+0x132>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a50:	83 45 a0 01          	addl   $0x1,-0x60(%ebp)
f0100a54:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0100a57:	83 c6 0c             	add    $0xc,%esi
f0100a5a:	83 f8 03             	cmp    $0x3,%eax
f0100a5d:	75 dd                	jne    f0100a3c <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a5f:	83 ec 08             	sub    $0x8,%esp
f0100a62:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a65:	8d 83 de 0b ff ff    	lea    -0xf422(%ebx),%eax
f0100a6b:	50                   	push   %eax
f0100a6c:	e8 8e 00 00 00       	call   f0100aff <cprintf>
f0100a71:	83 c4 10             	add    $0x10,%esp
f0100a74:	e9 51 ff ff ff       	jmp    f01009ca <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100a79:	83 ec 04             	sub    $0x4,%esp
f0100a7c:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0100a7f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a82:	ff 75 08             	pushl  0x8(%ebp)
f0100a85:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a88:	52                   	push   %edx
f0100a89:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a8c:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a93:	83 c4 10             	add    $0x10,%esp
f0100a96:	85 c0                	test   %eax,%eax
f0100a98:	0f 89 2c ff ff ff    	jns    f01009ca <monitor+0x83>
				break;
	}
}
f0100a9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aa1:	5b                   	pop    %ebx
f0100aa2:	5e                   	pop    %esi
f0100aa3:	5f                   	pop    %edi
f0100aa4:	5d                   	pop    %ebp
f0100aa5:	c3                   	ret    

f0100aa6 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100aa6:	55                   	push   %ebp
f0100aa7:	89 e5                	mov    %esp,%ebp
f0100aa9:	53                   	push   %ebx
f0100aaa:	83 ec 10             	sub    $0x10,%esp
f0100aad:	e8 0a f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100ab2:	81 c3 56 08 01 00    	add    $0x10856,%ebx
	cputchar(ch);
f0100ab8:	ff 75 08             	pushl  0x8(%ebp)
f0100abb:	e8 73 fc ff ff       	call   f0100733 <cputchar>
	*cnt++;
}
f0100ac0:	83 c4 10             	add    $0x10,%esp
f0100ac3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ac6:	c9                   	leave  
f0100ac7:	c3                   	ret    

f0100ac8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100ac8:	55                   	push   %ebp
f0100ac9:	89 e5                	mov    %esp,%ebp
f0100acb:	53                   	push   %ebx
f0100acc:	83 ec 14             	sub    $0x14,%esp
f0100acf:	e8 e8 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100ad4:	81 c3 34 08 01 00    	add    $0x10834,%ebx
	int cnt = 0;
f0100ada:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100ae1:	ff 75 0c             	pushl  0xc(%ebp)
f0100ae4:	ff 75 08             	pushl  0x8(%ebp)
f0100ae7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100aea:	50                   	push   %eax
f0100aeb:	8d 83 9e f7 fe ff    	lea    -0x10862(%ebx),%eax
f0100af1:	50                   	push   %eax
f0100af2:	e8 98 04 00 00       	call   f0100f8f <vprintfmt>
	return cnt;
}
f0100af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100afa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100afd:	c9                   	leave  
f0100afe:	c3                   	ret    

f0100aff <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100aff:	55                   	push   %ebp
f0100b00:	89 e5                	mov    %esp,%ebp
f0100b02:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b05:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b08:	50                   	push   %eax
f0100b09:	ff 75 08             	pushl  0x8(%ebp)
f0100b0c:	e8 b7 ff ff ff       	call   f0100ac8 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b11:	c9                   	leave  
f0100b12:	c3                   	ret    

f0100b13 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b13:	55                   	push   %ebp
f0100b14:	89 e5                	mov    %esp,%ebp
f0100b16:	57                   	push   %edi
f0100b17:	56                   	push   %esi
f0100b18:	53                   	push   %ebx
f0100b19:	83 ec 14             	sub    $0x14,%esp
f0100b1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b1f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b22:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b25:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b28:	8b 32                	mov    (%edx),%esi
f0100b2a:	8b 01                	mov    (%ecx),%eax
f0100b2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b2f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b36:	eb 2f                	jmp    f0100b67 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b38:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b3b:	39 c6                	cmp    %eax,%esi
f0100b3d:	7f 49                	jg     f0100b88 <stab_binsearch+0x75>
f0100b3f:	0f b6 0a             	movzbl (%edx),%ecx
f0100b42:	83 ea 0c             	sub    $0xc,%edx
f0100b45:	39 f9                	cmp    %edi,%ecx
f0100b47:	75 ef                	jne    f0100b38 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b49:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b4c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b4f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b53:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b56:	73 35                	jae    f0100b8d <stab_binsearch+0x7a>
			*region_left = m;
f0100b58:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b5b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100b5d:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100b60:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b67:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100b6a:	7f 4e                	jg     f0100bba <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b6f:	01 f0                	add    %esi,%eax
f0100b71:	89 c3                	mov    %eax,%ebx
f0100b73:	c1 eb 1f             	shr    $0x1f,%ebx
f0100b76:	01 c3                	add    %eax,%ebx
f0100b78:	d1 fb                	sar    %ebx
f0100b7a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b7d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b80:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100b84:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b86:	eb b3                	jmp    f0100b3b <stab_binsearch+0x28>
			l = true_m + 1;
f0100b88:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100b8b:	eb da                	jmp    f0100b67 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100b8d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b90:	76 14                	jbe    f0100ba6 <stab_binsearch+0x93>
			*region_right = m - 1;
f0100b92:	83 e8 01             	sub    $0x1,%eax
f0100b95:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b98:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100b9b:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100b9d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100ba4:	eb c1                	jmp    f0100b67 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100ba6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ba9:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100bab:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100baf:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100bb1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bb8:	eb ad                	jmp    f0100b67 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100bba:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100bbe:	74 16                	je     f0100bd6 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100bc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bc3:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100bc5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bc8:	8b 0e                	mov    (%esi),%ecx
f0100bca:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bcd:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100bd0:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100bd4:	eb 12                	jmp    f0100be8 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100bd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bd9:	8b 00                	mov    (%eax),%eax
f0100bdb:	83 e8 01             	sub    $0x1,%eax
f0100bde:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100be1:	89 07                	mov    %eax,(%edi)
f0100be3:	eb 16                	jmp    f0100bfb <stab_binsearch+0xe8>
		     l--)
f0100be5:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100be8:	39 c1                	cmp    %eax,%ecx
f0100bea:	7d 0a                	jge    f0100bf6 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100bec:	0f b6 1a             	movzbl (%edx),%ebx
f0100bef:	83 ea 0c             	sub    $0xc,%edx
f0100bf2:	39 fb                	cmp    %edi,%ebx
f0100bf4:	75 ef                	jne    f0100be5 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100bf6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bf9:	89 07                	mov    %eax,(%edi)
	}
}
f0100bfb:	83 c4 14             	add    $0x14,%esp
f0100bfe:	5b                   	pop    %ebx
f0100bff:	5e                   	pop    %esi
f0100c00:	5f                   	pop    %edi
f0100c01:	5d                   	pop    %ebp
f0100c02:	c3                   	ret    

f0100c03 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c03:	55                   	push   %ebp
f0100c04:	89 e5                	mov    %esp,%ebp
f0100c06:	57                   	push   %edi
f0100c07:	56                   	push   %esi
f0100c08:	53                   	push   %ebx
f0100c09:	83 ec 3c             	sub    $0x3c,%esp
f0100c0c:	e8 ab f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100c11:	81 c3 f7 06 01 00    	add    $0x106f7,%ebx
f0100c17:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100c1a:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c1d:	8d 83 84 0d ff ff    	lea    -0xf27c(%ebx),%eax
f0100c23:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100c25:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100c2c:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100c2f:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100c36:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100c39:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c40:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100c46:	0f 86 37 01 00 00    	jbe    f0100d83 <debuginfo_eip+0x180>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c4c:	c7 c0 29 60 10 f0    	mov    $0xf0106029,%eax
f0100c52:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100c58:	0f 86 04 02 00 00    	jbe    f0100e62 <debuginfo_eip+0x25f>
f0100c5e:	c7 c0 b1 79 10 f0    	mov    $0xf01079b1,%eax
f0100c64:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c68:	0f 85 fb 01 00 00    	jne    f0100e69 <debuginfo_eip+0x266>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c6e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c75:	c7 c0 a8 22 10 f0    	mov    $0xf01022a8,%eax
f0100c7b:	c7 c2 28 60 10 f0    	mov    $0xf0106028,%edx
f0100c81:	29 c2                	sub    %eax,%edx
f0100c83:	c1 fa 02             	sar    $0x2,%edx
f0100c86:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100c8c:	83 ea 01             	sub    $0x1,%edx
f0100c8f:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c92:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c95:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c98:	83 ec 08             	sub    $0x8,%esp
f0100c9b:	57                   	push   %edi
f0100c9c:	6a 64                	push   $0x64
f0100c9e:	e8 70 fe ff ff       	call   f0100b13 <stab_binsearch>
	if (lfile == 0)
f0100ca3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ca6:	83 c4 10             	add    $0x10,%esp
f0100ca9:	85 c0                	test   %eax,%eax
f0100cab:	0f 84 bf 01 00 00    	je     f0100e70 <debuginfo_eip+0x26d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100cb1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100cb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cb7:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100cba:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100cbd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cc0:	83 ec 08             	sub    $0x8,%esp
f0100cc3:	57                   	push   %edi
f0100cc4:	6a 24                	push   $0x24
f0100cc6:	c7 c0 a8 22 10 f0    	mov    $0xf01022a8,%eax
f0100ccc:	e8 42 fe ff ff       	call   f0100b13 <stab_binsearch>

	if (lfun <= rfun) {
f0100cd1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cd4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100cd7:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100cda:	83 c4 10             	add    $0x10,%esp
f0100cdd:	39 c8                	cmp    %ecx,%eax
f0100cdf:	0f 8f b6 00 00 00    	jg     f0100d9b <debuginfo_eip+0x198>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100ce5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ce8:	c7 c1 a8 22 10 f0    	mov    $0xf01022a8,%ecx
f0100cee:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100cf1:	8b 11                	mov    (%ecx),%edx
f0100cf3:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100cf6:	c7 c2 b1 79 10 f0    	mov    $0xf01079b1,%edx
f0100cfc:	81 ea 29 60 10 f0    	sub    $0xf0106029,%edx
f0100d02:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0100d05:	73 0c                	jae    f0100d13 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d07:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100d0a:	81 c2 29 60 10 f0    	add    $0xf0106029,%edx
f0100d10:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d13:	8b 51 08             	mov    0x8(%ecx),%edx
f0100d16:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100d19:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100d1b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d1e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100d21:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d24:	83 ec 08             	sub    $0x8,%esp
f0100d27:	6a 3a                	push   $0x3a
f0100d29:	ff 76 08             	pushl  0x8(%esi)
f0100d2c:	e8 c7 09 00 00       	call   f01016f8 <strfind>
f0100d31:	2b 46 08             	sub    0x8(%esi),%eax
f0100d34:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d37:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d3a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d3d:	83 c4 08             	add    $0x8,%esp
f0100d40:	57                   	push   %edi
f0100d41:	6a 44                	push   $0x44
f0100d43:	c7 c0 a8 22 10 f0    	mov    $0xf01022a8,%eax
f0100d49:	e8 c5 fd ff ff       	call   f0100b13 <stab_binsearch>
	
	if(lline<=rline){
f0100d4e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100d51:	83 c4 10             	add    $0x10,%esp
f0100d54:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100d57:	0f 8f 1a 01 00 00    	jg     f0100e77 <debuginfo_eip+0x274>
		info->eip_line = stabs[lline].n_desc;
f0100d5d:	89 d0                	mov    %edx,%eax
f0100d5f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100d62:	c1 e2 02             	shl    $0x2,%edx
f0100d65:	c7 c1 a8 22 10 f0    	mov    $0xf01022a8,%ecx
f0100d6b:	0f b7 7c 0a 06       	movzwl 0x6(%edx,%ecx,1),%edi
f0100d70:	89 7e 04             	mov    %edi,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d76:	8d 54 0a 04          	lea    0x4(%edx,%ecx,1),%edx
f0100d7a:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0100d7e:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100d81:	eb 36                	jmp    f0100db9 <debuginfo_eip+0x1b6>
  	        panic("User address");
f0100d83:	83 ec 04             	sub    $0x4,%esp
f0100d86:	8d 83 8e 0d ff ff    	lea    -0xf272(%ebx),%eax
f0100d8c:	50                   	push   %eax
f0100d8d:	6a 7f                	push   $0x7f
f0100d8f:	8d 83 9b 0d ff ff    	lea    -0xf265(%ebx),%eax
f0100d95:	50                   	push   %eax
f0100d96:	e8 6b f3 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100d9b:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100d9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100da1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100da4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100da7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100daa:	e9 75 ff ff ff       	jmp    f0100d24 <debuginfo_eip+0x121>
f0100daf:	83 e8 01             	sub    $0x1,%eax
f0100db2:	83 ea 0c             	sub    $0xc,%edx
f0100db5:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0100db9:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0100dbc:	39 c7                	cmp    %eax,%edi
f0100dbe:	7f 24                	jg     f0100de4 <debuginfo_eip+0x1e1>
	       && stabs[lline].n_type != N_SOL
f0100dc0:	0f b6 0a             	movzbl (%edx),%ecx
f0100dc3:	80 f9 84             	cmp    $0x84,%cl
f0100dc6:	74 46                	je     f0100e0e <debuginfo_eip+0x20b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100dc8:	80 f9 64             	cmp    $0x64,%cl
f0100dcb:	75 e2                	jne    f0100daf <debuginfo_eip+0x1ac>
f0100dcd:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0100dd1:	74 dc                	je     f0100daf <debuginfo_eip+0x1ac>
f0100dd3:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100dd6:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100dda:	74 3b                	je     f0100e17 <debuginfo_eip+0x214>
f0100ddc:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100ddf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100de2:	eb 33                	jmp    f0100e17 <debuginfo_eip+0x214>
f0100de4:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100de7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100dea:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100ded:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100df2:	39 fa                	cmp    %edi,%edx
f0100df4:	0f 8d 89 00 00 00    	jge    f0100e83 <debuginfo_eip+0x280>
		for (lline = lfun + 1;
f0100dfa:	83 c2 01             	add    $0x1,%edx
f0100dfd:	89 d0                	mov    %edx,%eax
f0100dff:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100e02:	c7 c2 a8 22 10 f0    	mov    $0xf01022a8,%edx
f0100e08:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100e0c:	eb 3b                	jmp    f0100e49 <debuginfo_eip+0x246>
f0100e0e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e11:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100e15:	75 26                	jne    f0100e3d <debuginfo_eip+0x23a>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e17:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e1a:	c7 c0 a8 22 10 f0    	mov    $0xf01022a8,%eax
f0100e20:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e23:	c7 c0 b1 79 10 f0    	mov    $0xf01079b1,%eax
f0100e29:	81 e8 29 60 10 f0    	sub    $0xf0106029,%eax
f0100e2f:	39 c2                	cmp    %eax,%edx
f0100e31:	73 b4                	jae    f0100de7 <debuginfo_eip+0x1e4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e33:	81 c2 29 60 10 f0    	add    $0xf0106029,%edx
f0100e39:	89 16                	mov    %edx,(%esi)
f0100e3b:	eb aa                	jmp    f0100de7 <debuginfo_eip+0x1e4>
f0100e3d:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100e40:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e43:	eb d2                	jmp    f0100e17 <debuginfo_eip+0x214>
			info->eip_fn_narg++;
f0100e45:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100e49:	39 c7                	cmp    %eax,%edi
f0100e4b:	7e 31                	jle    f0100e7e <debuginfo_eip+0x27b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e4d:	0f b6 0a             	movzbl (%edx),%ecx
f0100e50:	83 c0 01             	add    $0x1,%eax
f0100e53:	83 c2 0c             	add    $0xc,%edx
f0100e56:	80 f9 a0             	cmp    $0xa0,%cl
f0100e59:	74 ea                	je     f0100e45 <debuginfo_eip+0x242>
	return 0;
f0100e5b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e60:	eb 21                	jmp    f0100e83 <debuginfo_eip+0x280>
		return -1;
f0100e62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e67:	eb 1a                	jmp    f0100e83 <debuginfo_eip+0x280>
f0100e69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e6e:	eb 13                	jmp    f0100e83 <debuginfo_eip+0x280>
		return -1;
f0100e70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e75:	eb 0c                	jmp    f0100e83 <debuginfo_eip+0x280>
	else return -1;
f0100e77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e7c:	eb 05                	jmp    f0100e83 <debuginfo_eip+0x280>
	return 0;
f0100e7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e83:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e86:	5b                   	pop    %ebx
f0100e87:	5e                   	pop    %esi
f0100e88:	5f                   	pop    %edi
f0100e89:	5d                   	pop    %ebp
f0100e8a:	c3                   	ret    

f0100e8b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100e8b:	55                   	push   %ebp
f0100e8c:	89 e5                	mov    %esp,%ebp
f0100e8e:	57                   	push   %edi
f0100e8f:	56                   	push   %esi
f0100e90:	53                   	push   %ebx
f0100e91:	83 ec 2c             	sub    $0x2c,%esp
f0100e94:	e8 02 06 00 00       	call   f010149b <__x86.get_pc_thunk.cx>
f0100e99:	81 c1 6f 04 01 00    	add    $0x1046f,%ecx
f0100e9f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100ea2:	89 c7                	mov    %eax,%edi
f0100ea4:	89 d6                	mov    %edx,%esi
f0100ea6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ea9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100eac:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100eaf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100eb2:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100eb5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100eba:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100ebd:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100ec0:	39 d3                	cmp    %edx,%ebx
f0100ec2:	72 09                	jb     f0100ecd <printnum+0x42>
f0100ec4:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100ec7:	0f 87 83 00 00 00    	ja     f0100f50 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ecd:	83 ec 0c             	sub    $0xc,%esp
f0100ed0:	ff 75 18             	pushl  0x18(%ebp)
f0100ed3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ed6:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100ed9:	53                   	push   %ebx
f0100eda:	ff 75 10             	pushl  0x10(%ebp)
f0100edd:	83 ec 08             	sub    $0x8,%esp
f0100ee0:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ee3:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ee6:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100ee9:	ff 75 d0             	pushl  -0x30(%ebp)
f0100eec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100eef:	e8 1c 0a 00 00       	call   f0101910 <__udivdi3>
f0100ef4:	83 c4 18             	add    $0x18,%esp
f0100ef7:	52                   	push   %edx
f0100ef8:	50                   	push   %eax
f0100ef9:	89 f2                	mov    %esi,%edx
f0100efb:	89 f8                	mov    %edi,%eax
f0100efd:	e8 89 ff ff ff       	call   f0100e8b <printnum>
f0100f02:	83 c4 20             	add    $0x20,%esp
f0100f05:	eb 13                	jmp    f0100f1a <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f07:	83 ec 08             	sub    $0x8,%esp
f0100f0a:	56                   	push   %esi
f0100f0b:	ff 75 18             	pushl  0x18(%ebp)
f0100f0e:	ff d7                	call   *%edi
f0100f10:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f13:	83 eb 01             	sub    $0x1,%ebx
f0100f16:	85 db                	test   %ebx,%ebx
f0100f18:	7f ed                	jg     f0100f07 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f1a:	83 ec 08             	sub    $0x8,%esp
f0100f1d:	56                   	push   %esi
f0100f1e:	83 ec 04             	sub    $0x4,%esp
f0100f21:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f24:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f27:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f2a:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f2d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f30:	89 f3                	mov    %esi,%ebx
f0100f32:	e8 f9 0a 00 00       	call   f0101a30 <__umoddi3>
f0100f37:	83 c4 14             	add    $0x14,%esp
f0100f3a:	0f be 84 06 a9 0d ff 	movsbl -0xf257(%esi,%eax,1),%eax
f0100f41:	ff 
f0100f42:	50                   	push   %eax
f0100f43:	ff d7                	call   *%edi
}
f0100f45:	83 c4 10             	add    $0x10,%esp
f0100f48:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f4b:	5b                   	pop    %ebx
f0100f4c:	5e                   	pop    %esi
f0100f4d:	5f                   	pop    %edi
f0100f4e:	5d                   	pop    %ebp
f0100f4f:	c3                   	ret    
f0100f50:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100f53:	eb be                	jmp    f0100f13 <printnum+0x88>

f0100f55 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f55:	55                   	push   %ebp
f0100f56:	89 e5                	mov    %esp,%ebp
f0100f58:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f5b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f5f:	8b 10                	mov    (%eax),%edx
f0100f61:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f64:	73 0a                	jae    f0100f70 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f66:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f69:	89 08                	mov    %ecx,(%eax)
f0100f6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f6e:	88 02                	mov    %al,(%edx)
}
f0100f70:	5d                   	pop    %ebp
f0100f71:	c3                   	ret    

f0100f72 <printfmt>:
{
f0100f72:	55                   	push   %ebp
f0100f73:	89 e5                	mov    %esp,%ebp
f0100f75:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f78:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f7b:	50                   	push   %eax
f0100f7c:	ff 75 10             	pushl  0x10(%ebp)
f0100f7f:	ff 75 0c             	pushl  0xc(%ebp)
f0100f82:	ff 75 08             	pushl  0x8(%ebp)
f0100f85:	e8 05 00 00 00       	call   f0100f8f <vprintfmt>
}
f0100f8a:	83 c4 10             	add    $0x10,%esp
f0100f8d:	c9                   	leave  
f0100f8e:	c3                   	ret    

f0100f8f <vprintfmt>:
{
f0100f8f:	55                   	push   %ebp
f0100f90:	89 e5                	mov    %esp,%ebp
f0100f92:	57                   	push   %edi
f0100f93:	56                   	push   %esi
f0100f94:	53                   	push   %ebx
f0100f95:	83 ec 2c             	sub    $0x2c,%esp
f0100f98:	e8 1f f2 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100f9d:	81 c3 6b 03 01 00    	add    $0x1036b,%ebx
f0100fa3:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100fa6:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100fa9:	e9 c3 03 00 00       	jmp    f0101371 <.L35+0x48>
		padc = ' ';
f0100fae:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100fb2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100fb9:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0100fc0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100fc7:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fcc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100fcf:	8d 47 01             	lea    0x1(%edi),%eax
f0100fd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100fd5:	0f b6 17             	movzbl (%edi),%edx
f0100fd8:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100fdb:	3c 55                	cmp    $0x55,%al
f0100fdd:	0f 87 16 04 00 00    	ja     f01013f9 <.L22>
f0100fe3:	0f b6 c0             	movzbl %al,%eax
f0100fe6:	89 d9                	mov    %ebx,%ecx
f0100fe8:	03 8c 83 38 0e ff ff 	add    -0xf1c8(%ebx,%eax,4),%ecx
f0100fef:	ff e1                	jmp    *%ecx

f0100ff1 <.L69>:
f0100ff1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100ff4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100ff8:	eb d5                	jmp    f0100fcf <vprintfmt+0x40>

f0100ffa <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0100ffa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0100ffd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101001:	eb cc                	jmp    f0100fcf <vprintfmt+0x40>

f0101003 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0101003:	0f b6 d2             	movzbl %dl,%edx
f0101006:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0101009:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f010100e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101011:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0101015:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0101018:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010101b:	83 f9 09             	cmp    $0x9,%ecx
f010101e:	77 55                	ja     f0101075 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0101020:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0101023:	eb e9                	jmp    f010100e <.L29+0xb>

f0101025 <.L26>:
			precision = va_arg(ap, int);
f0101025:	8b 45 14             	mov    0x14(%ebp),%eax
f0101028:	8b 00                	mov    (%eax),%eax
f010102a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010102d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101030:	8d 40 04             	lea    0x4(%eax),%eax
f0101033:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101036:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0101039:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010103d:	79 90                	jns    f0100fcf <vprintfmt+0x40>
				width = precision, precision = -1;
f010103f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101042:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101045:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f010104c:	eb 81                	jmp    f0100fcf <vprintfmt+0x40>

f010104e <.L27>:
f010104e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101051:	85 c0                	test   %eax,%eax
f0101053:	ba 00 00 00 00       	mov    $0x0,%edx
f0101058:	0f 49 d0             	cmovns %eax,%edx
f010105b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010105e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101061:	e9 69 ff ff ff       	jmp    f0100fcf <vprintfmt+0x40>

f0101066 <.L23>:
f0101066:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0101069:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101070:	e9 5a ff ff ff       	jmp    f0100fcf <vprintfmt+0x40>
f0101075:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101078:	eb bf                	jmp    f0101039 <.L26+0x14>

f010107a <.L33>:
			lflag++;
f010107a:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010107e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0101081:	e9 49 ff ff ff       	jmp    f0100fcf <vprintfmt+0x40>

f0101086 <.L30>:
			putch(va_arg(ap, int), putdat);
f0101086:	8b 45 14             	mov    0x14(%ebp),%eax
f0101089:	8d 78 04             	lea    0x4(%eax),%edi
f010108c:	83 ec 08             	sub    $0x8,%esp
f010108f:	56                   	push   %esi
f0101090:	ff 30                	pushl  (%eax)
f0101092:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101095:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101098:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f010109b:	e9 ce 02 00 00       	jmp    f010136e <.L35+0x45>

f01010a0 <.L32>:
			err = va_arg(ap, int);
f01010a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a3:	8d 78 04             	lea    0x4(%eax),%edi
f01010a6:	8b 00                	mov    (%eax),%eax
f01010a8:	99                   	cltd   
f01010a9:	31 d0                	xor    %edx,%eax
f01010ab:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01010ad:	83 f8 06             	cmp    $0x6,%eax
f01010b0:	7f 27                	jg     f01010d9 <.L32+0x39>
f01010b2:	8b 94 83 3c 1d 00 00 	mov    0x1d3c(%ebx,%eax,4),%edx
f01010b9:	85 d2                	test   %edx,%edx
f01010bb:	74 1c                	je     f01010d9 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f01010bd:	52                   	push   %edx
f01010be:	8d 83 ca 0d ff ff    	lea    -0xf236(%ebx),%eax
f01010c4:	50                   	push   %eax
f01010c5:	56                   	push   %esi
f01010c6:	ff 75 08             	pushl  0x8(%ebp)
f01010c9:	e8 a4 fe ff ff       	call   f0100f72 <printfmt>
f01010ce:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010d1:	89 7d 14             	mov    %edi,0x14(%ebp)
f01010d4:	e9 95 02 00 00       	jmp    f010136e <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f01010d9:	50                   	push   %eax
f01010da:	8d 83 c1 0d ff ff    	lea    -0xf23f(%ebx),%eax
f01010e0:	50                   	push   %eax
f01010e1:	56                   	push   %esi
f01010e2:	ff 75 08             	pushl  0x8(%ebp)
f01010e5:	e8 88 fe ff ff       	call   f0100f72 <printfmt>
f01010ea:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010ed:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01010f0:	e9 79 02 00 00       	jmp    f010136e <.L35+0x45>

f01010f5 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f01010f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f8:	83 c0 04             	add    $0x4,%eax
f01010fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01010fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101101:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0101103:	85 ff                	test   %edi,%edi
f0101105:	8d 83 ba 0d ff ff    	lea    -0xf246(%ebx),%eax
f010110b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010110e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101112:	0f 8e b5 00 00 00    	jle    f01011cd <.L36+0xd8>
f0101118:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010111c:	75 08                	jne    f0101126 <.L36+0x31>
f010111e:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101121:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101124:	eb 6d                	jmp    f0101193 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101126:	83 ec 08             	sub    $0x8,%esp
f0101129:	ff 75 cc             	pushl  -0x34(%ebp)
f010112c:	57                   	push   %edi
f010112d:	e8 82 04 00 00       	call   f01015b4 <strnlen>
f0101132:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101135:	29 c2                	sub    %eax,%edx
f0101137:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010113a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010113d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101141:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101144:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101147:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101149:	eb 10                	jmp    f010115b <.L36+0x66>
					putch(padc, putdat);
f010114b:	83 ec 08             	sub    $0x8,%esp
f010114e:	56                   	push   %esi
f010114f:	ff 75 e0             	pushl  -0x20(%ebp)
f0101152:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101155:	83 ef 01             	sub    $0x1,%edi
f0101158:	83 c4 10             	add    $0x10,%esp
f010115b:	85 ff                	test   %edi,%edi
f010115d:	7f ec                	jg     f010114b <.L36+0x56>
f010115f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101162:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0101165:	85 d2                	test   %edx,%edx
f0101167:	b8 00 00 00 00       	mov    $0x0,%eax
f010116c:	0f 49 c2             	cmovns %edx,%eax
f010116f:	29 c2                	sub    %eax,%edx
f0101171:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101174:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101177:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010117a:	eb 17                	jmp    f0101193 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f010117c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101180:	75 30                	jne    f01011b2 <.L36+0xbd>
					putch(ch, putdat);
f0101182:	83 ec 08             	sub    $0x8,%esp
f0101185:	ff 75 0c             	pushl  0xc(%ebp)
f0101188:	50                   	push   %eax
f0101189:	ff 55 08             	call   *0x8(%ebp)
f010118c:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010118f:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0101193:	83 c7 01             	add    $0x1,%edi
f0101196:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f010119a:	0f be c2             	movsbl %dl,%eax
f010119d:	85 c0                	test   %eax,%eax
f010119f:	74 52                	je     f01011f3 <.L36+0xfe>
f01011a1:	85 f6                	test   %esi,%esi
f01011a3:	78 d7                	js     f010117c <.L36+0x87>
f01011a5:	83 ee 01             	sub    $0x1,%esi
f01011a8:	79 d2                	jns    f010117c <.L36+0x87>
f01011aa:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011ad:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01011b0:	eb 32                	jmp    f01011e4 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f01011b2:	0f be d2             	movsbl %dl,%edx
f01011b5:	83 ea 20             	sub    $0x20,%edx
f01011b8:	83 fa 5e             	cmp    $0x5e,%edx
f01011bb:	76 c5                	jbe    f0101182 <.L36+0x8d>
					putch('?', putdat);
f01011bd:	83 ec 08             	sub    $0x8,%esp
f01011c0:	ff 75 0c             	pushl  0xc(%ebp)
f01011c3:	6a 3f                	push   $0x3f
f01011c5:	ff 55 08             	call   *0x8(%ebp)
f01011c8:	83 c4 10             	add    $0x10,%esp
f01011cb:	eb c2                	jmp    f010118f <.L36+0x9a>
f01011cd:	89 75 0c             	mov    %esi,0xc(%ebp)
f01011d0:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01011d3:	eb be                	jmp    f0101193 <.L36+0x9e>
				putch(' ', putdat);
f01011d5:	83 ec 08             	sub    $0x8,%esp
f01011d8:	56                   	push   %esi
f01011d9:	6a 20                	push   $0x20
f01011db:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f01011de:	83 ef 01             	sub    $0x1,%edi
f01011e1:	83 c4 10             	add    $0x10,%esp
f01011e4:	85 ff                	test   %edi,%edi
f01011e6:	7f ed                	jg     f01011d5 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f01011e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01011eb:	89 45 14             	mov    %eax,0x14(%ebp)
f01011ee:	e9 7b 01 00 00       	jmp    f010136e <.L35+0x45>
f01011f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01011f6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011f9:	eb e9                	jmp    f01011e4 <.L36+0xef>

f01011fb <.L31>:
f01011fb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01011fe:	83 f9 01             	cmp    $0x1,%ecx
f0101201:	7e 40                	jle    f0101243 <.L31+0x48>
		return va_arg(*ap, long long);
f0101203:	8b 45 14             	mov    0x14(%ebp),%eax
f0101206:	8b 50 04             	mov    0x4(%eax),%edx
f0101209:	8b 00                	mov    (%eax),%eax
f010120b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010120e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101211:	8b 45 14             	mov    0x14(%ebp),%eax
f0101214:	8d 40 08             	lea    0x8(%eax),%eax
f0101217:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010121a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010121e:	79 55                	jns    f0101275 <.L31+0x7a>
				putch('-', putdat);
f0101220:	83 ec 08             	sub    $0x8,%esp
f0101223:	56                   	push   %esi
f0101224:	6a 2d                	push   $0x2d
f0101226:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101229:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010122c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010122f:	f7 da                	neg    %edx
f0101231:	83 d1 00             	adc    $0x0,%ecx
f0101234:	f7 d9                	neg    %ecx
f0101236:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101239:	b8 0a 00 00 00       	mov    $0xa,%eax
f010123e:	e9 10 01 00 00       	jmp    f0101353 <.L35+0x2a>
	else if (lflag)
f0101243:	85 c9                	test   %ecx,%ecx
f0101245:	75 17                	jne    f010125e <.L31+0x63>
		return va_arg(*ap, int);
f0101247:	8b 45 14             	mov    0x14(%ebp),%eax
f010124a:	8b 00                	mov    (%eax),%eax
f010124c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010124f:	99                   	cltd   
f0101250:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101253:	8b 45 14             	mov    0x14(%ebp),%eax
f0101256:	8d 40 04             	lea    0x4(%eax),%eax
f0101259:	89 45 14             	mov    %eax,0x14(%ebp)
f010125c:	eb bc                	jmp    f010121a <.L31+0x1f>
		return va_arg(*ap, long);
f010125e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101261:	8b 00                	mov    (%eax),%eax
f0101263:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101266:	99                   	cltd   
f0101267:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010126a:	8b 45 14             	mov    0x14(%ebp),%eax
f010126d:	8d 40 04             	lea    0x4(%eax),%eax
f0101270:	89 45 14             	mov    %eax,0x14(%ebp)
f0101273:	eb a5                	jmp    f010121a <.L31+0x1f>
			num = getint(&ap, lflag);
f0101275:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101278:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010127b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101280:	e9 ce 00 00 00       	jmp    f0101353 <.L35+0x2a>

f0101285 <.L37>:
f0101285:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101288:	83 f9 01             	cmp    $0x1,%ecx
f010128b:	7e 18                	jle    f01012a5 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f010128d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101290:	8b 10                	mov    (%eax),%edx
f0101292:	8b 48 04             	mov    0x4(%eax),%ecx
f0101295:	8d 40 08             	lea    0x8(%eax),%eax
f0101298:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010129b:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012a0:	e9 ae 00 00 00       	jmp    f0101353 <.L35+0x2a>
	else if (lflag)
f01012a5:	85 c9                	test   %ecx,%ecx
f01012a7:	75 1a                	jne    f01012c3 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f01012a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ac:	8b 10                	mov    (%eax),%edx
f01012ae:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012b3:	8d 40 04             	lea    0x4(%eax),%eax
f01012b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012b9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012be:	e9 90 00 00 00       	jmp    f0101353 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01012c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01012c6:	8b 10                	mov    (%eax),%edx
f01012c8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012cd:	8d 40 04             	lea    0x4(%eax),%eax
f01012d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012d3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012d8:	eb 79                	jmp    f0101353 <.L35+0x2a>

f01012da <.L34>:
f01012da:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01012dd:	83 f9 01             	cmp    $0x1,%ecx
f01012e0:	7e 15                	jle    f01012f7 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f01012e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e5:	8b 10                	mov    (%eax),%edx
f01012e7:	8b 48 04             	mov    0x4(%eax),%ecx
f01012ea:	8d 40 08             	lea    0x8(%eax),%eax
f01012ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012f0:	b8 08 00 00 00       	mov    $0x8,%eax
f01012f5:	eb 5c                	jmp    f0101353 <.L35+0x2a>
	else if (lflag)
f01012f7:	85 c9                	test   %ecx,%ecx
f01012f9:	75 17                	jne    f0101312 <.L34+0x38>
		return va_arg(*ap, unsigned int);
f01012fb:	8b 45 14             	mov    0x14(%ebp),%eax
f01012fe:	8b 10                	mov    (%eax),%edx
f0101300:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101305:	8d 40 04             	lea    0x4(%eax),%eax
f0101308:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010130b:	b8 08 00 00 00       	mov    $0x8,%eax
f0101310:	eb 41                	jmp    f0101353 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0101312:	8b 45 14             	mov    0x14(%ebp),%eax
f0101315:	8b 10                	mov    (%eax),%edx
f0101317:	b9 00 00 00 00       	mov    $0x0,%ecx
f010131c:	8d 40 04             	lea    0x4(%eax),%eax
f010131f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101322:	b8 08 00 00 00       	mov    $0x8,%eax
f0101327:	eb 2a                	jmp    f0101353 <.L35+0x2a>

f0101329 <.L35>:
			putch('0', putdat);
f0101329:	83 ec 08             	sub    $0x8,%esp
f010132c:	56                   	push   %esi
f010132d:	6a 30                	push   $0x30
f010132f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101332:	83 c4 08             	add    $0x8,%esp
f0101335:	56                   	push   %esi
f0101336:	6a 78                	push   $0x78
f0101338:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f010133b:	8b 45 14             	mov    0x14(%ebp),%eax
f010133e:	8b 10                	mov    (%eax),%edx
f0101340:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0101345:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101348:	8d 40 04             	lea    0x4(%eax),%eax
f010134b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010134e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101353:	83 ec 0c             	sub    $0xc,%esp
f0101356:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010135a:	57                   	push   %edi
f010135b:	ff 75 e0             	pushl  -0x20(%ebp)
f010135e:	50                   	push   %eax
f010135f:	51                   	push   %ecx
f0101360:	52                   	push   %edx
f0101361:	89 f2                	mov    %esi,%edx
f0101363:	8b 45 08             	mov    0x8(%ebp),%eax
f0101366:	e8 20 fb ff ff       	call   f0100e8b <printnum>
			break;
f010136b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010136e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101371:	83 c7 01             	add    $0x1,%edi
f0101374:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101378:	83 f8 25             	cmp    $0x25,%eax
f010137b:	0f 84 2d fc ff ff    	je     f0100fae <vprintfmt+0x1f>
			if (ch == '\0')
f0101381:	85 c0                	test   %eax,%eax
f0101383:	0f 84 91 00 00 00    	je     f010141a <.L22+0x21>
			putch(ch, putdat);
f0101389:	83 ec 08             	sub    $0x8,%esp
f010138c:	56                   	push   %esi
f010138d:	50                   	push   %eax
f010138e:	ff 55 08             	call   *0x8(%ebp)
f0101391:	83 c4 10             	add    $0x10,%esp
f0101394:	eb db                	jmp    f0101371 <.L35+0x48>

f0101396 <.L38>:
f0101396:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101399:	83 f9 01             	cmp    $0x1,%ecx
f010139c:	7e 15                	jle    f01013b3 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f010139e:	8b 45 14             	mov    0x14(%ebp),%eax
f01013a1:	8b 10                	mov    (%eax),%edx
f01013a3:	8b 48 04             	mov    0x4(%eax),%ecx
f01013a6:	8d 40 08             	lea    0x8(%eax),%eax
f01013a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013ac:	b8 10 00 00 00       	mov    $0x10,%eax
f01013b1:	eb a0                	jmp    f0101353 <.L35+0x2a>
	else if (lflag)
f01013b3:	85 c9                	test   %ecx,%ecx
f01013b5:	75 17                	jne    f01013ce <.L38+0x38>
		return va_arg(*ap, unsigned int);
f01013b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01013ba:	8b 10                	mov    (%eax),%edx
f01013bc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013c1:	8d 40 04             	lea    0x4(%eax),%eax
f01013c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013c7:	b8 10 00 00 00       	mov    $0x10,%eax
f01013cc:	eb 85                	jmp    f0101353 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01013ce:	8b 45 14             	mov    0x14(%ebp),%eax
f01013d1:	8b 10                	mov    (%eax),%edx
f01013d3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013d8:	8d 40 04             	lea    0x4(%eax),%eax
f01013db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013de:	b8 10 00 00 00       	mov    $0x10,%eax
f01013e3:	e9 6b ff ff ff       	jmp    f0101353 <.L35+0x2a>

f01013e8 <.L25>:
			putch(ch, putdat);
f01013e8:	83 ec 08             	sub    $0x8,%esp
f01013eb:	56                   	push   %esi
f01013ec:	6a 25                	push   $0x25
f01013ee:	ff 55 08             	call   *0x8(%ebp)
			break;
f01013f1:	83 c4 10             	add    $0x10,%esp
f01013f4:	e9 75 ff ff ff       	jmp    f010136e <.L35+0x45>

f01013f9 <.L22>:
			putch('%', putdat);
f01013f9:	83 ec 08             	sub    $0x8,%esp
f01013fc:	56                   	push   %esi
f01013fd:	6a 25                	push   $0x25
f01013ff:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101402:	83 c4 10             	add    $0x10,%esp
f0101405:	89 f8                	mov    %edi,%eax
f0101407:	eb 03                	jmp    f010140c <.L22+0x13>
f0101409:	83 e8 01             	sub    $0x1,%eax
f010140c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101410:	75 f7                	jne    f0101409 <.L22+0x10>
f0101412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101415:	e9 54 ff ff ff       	jmp    f010136e <.L35+0x45>
}
f010141a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010141d:	5b                   	pop    %ebx
f010141e:	5e                   	pop    %esi
f010141f:	5f                   	pop    %edi
f0101420:	5d                   	pop    %ebp
f0101421:	c3                   	ret    

f0101422 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101422:	55                   	push   %ebp
f0101423:	89 e5                	mov    %esp,%ebp
f0101425:	53                   	push   %ebx
f0101426:	83 ec 14             	sub    $0x14,%esp
f0101429:	e8 8e ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010142e:	81 c3 da fe 00 00    	add    $0xfeda,%ebx
f0101434:	8b 45 08             	mov    0x8(%ebp),%eax
f0101437:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010143a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010143d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101441:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101444:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010144b:	85 c0                	test   %eax,%eax
f010144d:	74 2b                	je     f010147a <vsnprintf+0x58>
f010144f:	85 d2                	test   %edx,%edx
f0101451:	7e 27                	jle    f010147a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101453:	ff 75 14             	pushl  0x14(%ebp)
f0101456:	ff 75 10             	pushl  0x10(%ebp)
f0101459:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010145c:	50                   	push   %eax
f010145d:	8d 83 4d fc fe ff    	lea    -0x103b3(%ebx),%eax
f0101463:	50                   	push   %eax
f0101464:	e8 26 fb ff ff       	call   f0100f8f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101469:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010146c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010146f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101472:	83 c4 10             	add    $0x10,%esp
}
f0101475:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101478:	c9                   	leave  
f0101479:	c3                   	ret    
		return -E_INVAL;
f010147a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010147f:	eb f4                	jmp    f0101475 <vsnprintf+0x53>

f0101481 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101481:	55                   	push   %ebp
f0101482:	89 e5                	mov    %esp,%ebp
f0101484:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101487:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010148a:	50                   	push   %eax
f010148b:	ff 75 10             	pushl  0x10(%ebp)
f010148e:	ff 75 0c             	pushl  0xc(%ebp)
f0101491:	ff 75 08             	pushl  0x8(%ebp)
f0101494:	e8 89 ff ff ff       	call   f0101422 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101499:	c9                   	leave  
f010149a:	c3                   	ret    

f010149b <__x86.get_pc_thunk.cx>:
f010149b:	8b 0c 24             	mov    (%esp),%ecx
f010149e:	c3                   	ret    

f010149f <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010149f:	55                   	push   %ebp
f01014a0:	89 e5                	mov    %esp,%ebp
f01014a2:	57                   	push   %edi
f01014a3:	56                   	push   %esi
f01014a4:	53                   	push   %ebx
f01014a5:	83 ec 1c             	sub    $0x1c,%esp
f01014a8:	e8 0f ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01014ad:	81 c3 5b fe 00 00    	add    $0xfe5b,%ebx
f01014b3:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014b6:	85 c0                	test   %eax,%eax
f01014b8:	74 13                	je     f01014cd <readline+0x2e>
		cprintf("%s", prompt);
f01014ba:	83 ec 08             	sub    $0x8,%esp
f01014bd:	50                   	push   %eax
f01014be:	8d 83 ca 0d ff ff    	lea    -0xf236(%ebx),%eax
f01014c4:	50                   	push   %eax
f01014c5:	e8 35 f6 ff ff       	call   f0100aff <cprintf>
f01014ca:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01014cd:	83 ec 0c             	sub    $0xc,%esp
f01014d0:	6a 00                	push   $0x0
f01014d2:	e8 7d f2 ff ff       	call   f0100754 <iscons>
f01014d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014da:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01014dd:	bf 00 00 00 00       	mov    $0x0,%edi
f01014e2:	eb 46                	jmp    f010152a <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01014e4:	83 ec 08             	sub    $0x8,%esp
f01014e7:	50                   	push   %eax
f01014e8:	8d 83 90 0f ff ff    	lea    -0xf070(%ebx),%eax
f01014ee:	50                   	push   %eax
f01014ef:	e8 0b f6 ff ff       	call   f0100aff <cprintf>
			return NULL;
f01014f4:	83 c4 10             	add    $0x10,%esp
f01014f7:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01014fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014ff:	5b                   	pop    %ebx
f0101500:	5e                   	pop    %esi
f0101501:	5f                   	pop    %edi
f0101502:	5d                   	pop    %ebp
f0101503:	c3                   	ret    
			if (echoing)
f0101504:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101508:	75 05                	jne    f010150f <readline+0x70>
			i--;
f010150a:	83 ef 01             	sub    $0x1,%edi
f010150d:	eb 1b                	jmp    f010152a <readline+0x8b>
				cputchar('\b');
f010150f:	83 ec 0c             	sub    $0xc,%esp
f0101512:	6a 08                	push   $0x8
f0101514:	e8 1a f2 ff ff       	call   f0100733 <cputchar>
f0101519:	83 c4 10             	add    $0x10,%esp
f010151c:	eb ec                	jmp    f010150a <readline+0x6b>
			buf[i++] = c;
f010151e:	89 f0                	mov    %esi,%eax
f0101520:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f0101527:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f010152a:	e8 14 f2 ff ff       	call   f0100743 <getchar>
f010152f:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101531:	85 c0                	test   %eax,%eax
f0101533:	78 af                	js     f01014e4 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101535:	83 f8 08             	cmp    $0x8,%eax
f0101538:	0f 94 c2             	sete   %dl
f010153b:	83 f8 7f             	cmp    $0x7f,%eax
f010153e:	0f 94 c0             	sete   %al
f0101541:	08 c2                	or     %al,%dl
f0101543:	74 04                	je     f0101549 <readline+0xaa>
f0101545:	85 ff                	test   %edi,%edi
f0101547:	7f bb                	jg     f0101504 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101549:	83 fe 1f             	cmp    $0x1f,%esi
f010154c:	7e 1c                	jle    f010156a <readline+0xcb>
f010154e:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101554:	7f 14                	jg     f010156a <readline+0xcb>
			if (echoing)
f0101556:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010155a:	74 c2                	je     f010151e <readline+0x7f>
				cputchar(c);
f010155c:	83 ec 0c             	sub    $0xc,%esp
f010155f:	56                   	push   %esi
f0101560:	e8 ce f1 ff ff       	call   f0100733 <cputchar>
f0101565:	83 c4 10             	add    $0x10,%esp
f0101568:	eb b4                	jmp    f010151e <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f010156a:	83 fe 0a             	cmp    $0xa,%esi
f010156d:	74 05                	je     f0101574 <readline+0xd5>
f010156f:	83 fe 0d             	cmp    $0xd,%esi
f0101572:	75 b6                	jne    f010152a <readline+0x8b>
			if (echoing)
f0101574:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101578:	75 13                	jne    f010158d <readline+0xee>
			buf[i] = 0;
f010157a:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f0101581:	00 
			return buf;
f0101582:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0101588:	e9 6f ff ff ff       	jmp    f01014fc <readline+0x5d>
				cputchar('\n');
f010158d:	83 ec 0c             	sub    $0xc,%esp
f0101590:	6a 0a                	push   $0xa
f0101592:	e8 9c f1 ff ff       	call   f0100733 <cputchar>
f0101597:	83 c4 10             	add    $0x10,%esp
f010159a:	eb de                	jmp    f010157a <readline+0xdb>

f010159c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010159c:	55                   	push   %ebp
f010159d:	89 e5                	mov    %esp,%ebp
f010159f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01015a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01015a7:	eb 03                	jmp    f01015ac <strlen+0x10>
		n++;
f01015a9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01015ac:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01015b0:	75 f7                	jne    f01015a9 <strlen+0xd>
	return n;
}
f01015b2:	5d                   	pop    %ebp
f01015b3:	c3                   	ret    

f01015b4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01015b4:	55                   	push   %ebp
f01015b5:	89 e5                	mov    %esp,%ebp
f01015b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01015c2:	eb 03                	jmp    f01015c7 <strnlen+0x13>
		n++;
f01015c4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015c7:	39 d0                	cmp    %edx,%eax
f01015c9:	74 06                	je     f01015d1 <strnlen+0x1d>
f01015cb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01015cf:	75 f3                	jne    f01015c4 <strnlen+0x10>
	return n;
}
f01015d1:	5d                   	pop    %ebp
f01015d2:	c3                   	ret    

f01015d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01015d3:	55                   	push   %ebp
f01015d4:	89 e5                	mov    %esp,%ebp
f01015d6:	53                   	push   %ebx
f01015d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01015da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01015dd:	89 c2                	mov    %eax,%edx
f01015df:	83 c1 01             	add    $0x1,%ecx
f01015e2:	83 c2 01             	add    $0x1,%edx
f01015e5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01015e9:	88 5a ff             	mov    %bl,-0x1(%edx)
f01015ec:	84 db                	test   %bl,%bl
f01015ee:	75 ef                	jne    f01015df <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01015f0:	5b                   	pop    %ebx
f01015f1:	5d                   	pop    %ebp
f01015f2:	c3                   	ret    

f01015f3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01015f3:	55                   	push   %ebp
f01015f4:	89 e5                	mov    %esp,%ebp
f01015f6:	53                   	push   %ebx
f01015f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01015fa:	53                   	push   %ebx
f01015fb:	e8 9c ff ff ff       	call   f010159c <strlen>
f0101600:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101603:	ff 75 0c             	pushl  0xc(%ebp)
f0101606:	01 d8                	add    %ebx,%eax
f0101608:	50                   	push   %eax
f0101609:	e8 c5 ff ff ff       	call   f01015d3 <strcpy>
	return dst;
}
f010160e:	89 d8                	mov    %ebx,%eax
f0101610:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101613:	c9                   	leave  
f0101614:	c3                   	ret    

f0101615 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101615:	55                   	push   %ebp
f0101616:	89 e5                	mov    %esp,%ebp
f0101618:	56                   	push   %esi
f0101619:	53                   	push   %ebx
f010161a:	8b 75 08             	mov    0x8(%ebp),%esi
f010161d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101620:	89 f3                	mov    %esi,%ebx
f0101622:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101625:	89 f2                	mov    %esi,%edx
f0101627:	eb 0f                	jmp    f0101638 <strncpy+0x23>
		*dst++ = *src;
f0101629:	83 c2 01             	add    $0x1,%edx
f010162c:	0f b6 01             	movzbl (%ecx),%eax
f010162f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101632:	80 39 01             	cmpb   $0x1,(%ecx)
f0101635:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0101638:	39 da                	cmp    %ebx,%edx
f010163a:	75 ed                	jne    f0101629 <strncpy+0x14>
	}
	return ret;
}
f010163c:	89 f0                	mov    %esi,%eax
f010163e:	5b                   	pop    %ebx
f010163f:	5e                   	pop    %esi
f0101640:	5d                   	pop    %ebp
f0101641:	c3                   	ret    

f0101642 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101642:	55                   	push   %ebp
f0101643:	89 e5                	mov    %esp,%ebp
f0101645:	56                   	push   %esi
f0101646:	53                   	push   %ebx
f0101647:	8b 75 08             	mov    0x8(%ebp),%esi
f010164a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010164d:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101650:	89 f0                	mov    %esi,%eax
f0101652:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101656:	85 c9                	test   %ecx,%ecx
f0101658:	75 0b                	jne    f0101665 <strlcpy+0x23>
f010165a:	eb 17                	jmp    f0101673 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010165c:	83 c2 01             	add    $0x1,%edx
f010165f:	83 c0 01             	add    $0x1,%eax
f0101662:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0101665:	39 d8                	cmp    %ebx,%eax
f0101667:	74 07                	je     f0101670 <strlcpy+0x2e>
f0101669:	0f b6 0a             	movzbl (%edx),%ecx
f010166c:	84 c9                	test   %cl,%cl
f010166e:	75 ec                	jne    f010165c <strlcpy+0x1a>
		*dst = '\0';
f0101670:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101673:	29 f0                	sub    %esi,%eax
}
f0101675:	5b                   	pop    %ebx
f0101676:	5e                   	pop    %esi
f0101677:	5d                   	pop    %ebp
f0101678:	c3                   	ret    

f0101679 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101679:	55                   	push   %ebp
f010167a:	89 e5                	mov    %esp,%ebp
f010167c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010167f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101682:	eb 06                	jmp    f010168a <strcmp+0x11>
		p++, q++;
f0101684:	83 c1 01             	add    $0x1,%ecx
f0101687:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010168a:	0f b6 01             	movzbl (%ecx),%eax
f010168d:	84 c0                	test   %al,%al
f010168f:	74 04                	je     f0101695 <strcmp+0x1c>
f0101691:	3a 02                	cmp    (%edx),%al
f0101693:	74 ef                	je     f0101684 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101695:	0f b6 c0             	movzbl %al,%eax
f0101698:	0f b6 12             	movzbl (%edx),%edx
f010169b:	29 d0                	sub    %edx,%eax
}
f010169d:	5d                   	pop    %ebp
f010169e:	c3                   	ret    

f010169f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010169f:	55                   	push   %ebp
f01016a0:	89 e5                	mov    %esp,%ebp
f01016a2:	53                   	push   %ebx
f01016a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01016a6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016a9:	89 c3                	mov    %eax,%ebx
f01016ab:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01016ae:	eb 06                	jmp    f01016b6 <strncmp+0x17>
		n--, p++, q++;
f01016b0:	83 c0 01             	add    $0x1,%eax
f01016b3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01016b6:	39 d8                	cmp    %ebx,%eax
f01016b8:	74 16                	je     f01016d0 <strncmp+0x31>
f01016ba:	0f b6 08             	movzbl (%eax),%ecx
f01016bd:	84 c9                	test   %cl,%cl
f01016bf:	74 04                	je     f01016c5 <strncmp+0x26>
f01016c1:	3a 0a                	cmp    (%edx),%cl
f01016c3:	74 eb                	je     f01016b0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01016c5:	0f b6 00             	movzbl (%eax),%eax
f01016c8:	0f b6 12             	movzbl (%edx),%edx
f01016cb:	29 d0                	sub    %edx,%eax
}
f01016cd:	5b                   	pop    %ebx
f01016ce:	5d                   	pop    %ebp
f01016cf:	c3                   	ret    
		return 0;
f01016d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01016d5:	eb f6                	jmp    f01016cd <strncmp+0x2e>

f01016d7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01016d7:	55                   	push   %ebp
f01016d8:	89 e5                	mov    %esp,%ebp
f01016da:	8b 45 08             	mov    0x8(%ebp),%eax
f01016dd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016e1:	0f b6 10             	movzbl (%eax),%edx
f01016e4:	84 d2                	test   %dl,%dl
f01016e6:	74 09                	je     f01016f1 <strchr+0x1a>
		if (*s == c)
f01016e8:	38 ca                	cmp    %cl,%dl
f01016ea:	74 0a                	je     f01016f6 <strchr+0x1f>
	for (; *s; s++)
f01016ec:	83 c0 01             	add    $0x1,%eax
f01016ef:	eb f0                	jmp    f01016e1 <strchr+0xa>
			return (char *) s;
	return 0;
f01016f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016f6:	5d                   	pop    %ebp
f01016f7:	c3                   	ret    

f01016f8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01016f8:	55                   	push   %ebp
f01016f9:	89 e5                	mov    %esp,%ebp
f01016fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01016fe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101702:	eb 03                	jmp    f0101707 <strfind+0xf>
f0101704:	83 c0 01             	add    $0x1,%eax
f0101707:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010170a:	38 ca                	cmp    %cl,%dl
f010170c:	74 04                	je     f0101712 <strfind+0x1a>
f010170e:	84 d2                	test   %dl,%dl
f0101710:	75 f2                	jne    f0101704 <strfind+0xc>
			break;
	return (char *) s;
}
f0101712:	5d                   	pop    %ebp
f0101713:	c3                   	ret    

f0101714 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101714:	55                   	push   %ebp
f0101715:	89 e5                	mov    %esp,%ebp
f0101717:	57                   	push   %edi
f0101718:	56                   	push   %esi
f0101719:	53                   	push   %ebx
f010171a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010171d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101720:	85 c9                	test   %ecx,%ecx
f0101722:	74 13                	je     f0101737 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101724:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010172a:	75 05                	jne    f0101731 <memset+0x1d>
f010172c:	f6 c1 03             	test   $0x3,%cl
f010172f:	74 0d                	je     f010173e <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101731:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101734:	fc                   	cld    
f0101735:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101737:	89 f8                	mov    %edi,%eax
f0101739:	5b                   	pop    %ebx
f010173a:	5e                   	pop    %esi
f010173b:	5f                   	pop    %edi
f010173c:	5d                   	pop    %ebp
f010173d:	c3                   	ret    
		c &= 0xFF;
f010173e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101742:	89 d3                	mov    %edx,%ebx
f0101744:	c1 e3 08             	shl    $0x8,%ebx
f0101747:	89 d0                	mov    %edx,%eax
f0101749:	c1 e0 18             	shl    $0x18,%eax
f010174c:	89 d6                	mov    %edx,%esi
f010174e:	c1 e6 10             	shl    $0x10,%esi
f0101751:	09 f0                	or     %esi,%eax
f0101753:	09 c2                	or     %eax,%edx
f0101755:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0101757:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010175a:	89 d0                	mov    %edx,%eax
f010175c:	fc                   	cld    
f010175d:	f3 ab                	rep stos %eax,%es:(%edi)
f010175f:	eb d6                	jmp    f0101737 <memset+0x23>

f0101761 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101761:	55                   	push   %ebp
f0101762:	89 e5                	mov    %esp,%ebp
f0101764:	57                   	push   %edi
f0101765:	56                   	push   %esi
f0101766:	8b 45 08             	mov    0x8(%ebp),%eax
f0101769:	8b 75 0c             	mov    0xc(%ebp),%esi
f010176c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010176f:	39 c6                	cmp    %eax,%esi
f0101771:	73 35                	jae    f01017a8 <memmove+0x47>
f0101773:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101776:	39 c2                	cmp    %eax,%edx
f0101778:	76 2e                	jbe    f01017a8 <memmove+0x47>
		s += n;
		d += n;
f010177a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010177d:	89 d6                	mov    %edx,%esi
f010177f:	09 fe                	or     %edi,%esi
f0101781:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101787:	74 0c                	je     f0101795 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101789:	83 ef 01             	sub    $0x1,%edi
f010178c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010178f:	fd                   	std    
f0101790:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101792:	fc                   	cld    
f0101793:	eb 21                	jmp    f01017b6 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101795:	f6 c1 03             	test   $0x3,%cl
f0101798:	75 ef                	jne    f0101789 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010179a:	83 ef 04             	sub    $0x4,%edi
f010179d:	8d 72 fc             	lea    -0x4(%edx),%esi
f01017a0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01017a3:	fd                   	std    
f01017a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017a6:	eb ea                	jmp    f0101792 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017a8:	89 f2                	mov    %esi,%edx
f01017aa:	09 c2                	or     %eax,%edx
f01017ac:	f6 c2 03             	test   $0x3,%dl
f01017af:	74 09                	je     f01017ba <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01017b1:	89 c7                	mov    %eax,%edi
f01017b3:	fc                   	cld    
f01017b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01017b6:	5e                   	pop    %esi
f01017b7:	5f                   	pop    %edi
f01017b8:	5d                   	pop    %ebp
f01017b9:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017ba:	f6 c1 03             	test   $0x3,%cl
f01017bd:	75 f2                	jne    f01017b1 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01017bf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01017c2:	89 c7                	mov    %eax,%edi
f01017c4:	fc                   	cld    
f01017c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017c7:	eb ed                	jmp    f01017b6 <memmove+0x55>

f01017c9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01017c9:	55                   	push   %ebp
f01017ca:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01017cc:	ff 75 10             	pushl  0x10(%ebp)
f01017cf:	ff 75 0c             	pushl  0xc(%ebp)
f01017d2:	ff 75 08             	pushl  0x8(%ebp)
f01017d5:	e8 87 ff ff ff       	call   f0101761 <memmove>
}
f01017da:	c9                   	leave  
f01017db:	c3                   	ret    

f01017dc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01017dc:	55                   	push   %ebp
f01017dd:	89 e5                	mov    %esp,%ebp
f01017df:	56                   	push   %esi
f01017e0:	53                   	push   %ebx
f01017e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01017e4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01017e7:	89 c6                	mov    %eax,%esi
f01017e9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01017ec:	39 f0                	cmp    %esi,%eax
f01017ee:	74 1c                	je     f010180c <memcmp+0x30>
		if (*s1 != *s2)
f01017f0:	0f b6 08             	movzbl (%eax),%ecx
f01017f3:	0f b6 1a             	movzbl (%edx),%ebx
f01017f6:	38 d9                	cmp    %bl,%cl
f01017f8:	75 08                	jne    f0101802 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01017fa:	83 c0 01             	add    $0x1,%eax
f01017fd:	83 c2 01             	add    $0x1,%edx
f0101800:	eb ea                	jmp    f01017ec <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0101802:	0f b6 c1             	movzbl %cl,%eax
f0101805:	0f b6 db             	movzbl %bl,%ebx
f0101808:	29 d8                	sub    %ebx,%eax
f010180a:	eb 05                	jmp    f0101811 <memcmp+0x35>
	}

	return 0;
f010180c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101811:	5b                   	pop    %ebx
f0101812:	5e                   	pop    %esi
f0101813:	5d                   	pop    %ebp
f0101814:	c3                   	ret    

f0101815 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101815:	55                   	push   %ebp
f0101816:	89 e5                	mov    %esp,%ebp
f0101818:	8b 45 08             	mov    0x8(%ebp),%eax
f010181b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010181e:	89 c2                	mov    %eax,%edx
f0101820:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101823:	39 d0                	cmp    %edx,%eax
f0101825:	73 09                	jae    f0101830 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101827:	38 08                	cmp    %cl,(%eax)
f0101829:	74 05                	je     f0101830 <memfind+0x1b>
	for (; s < ends; s++)
f010182b:	83 c0 01             	add    $0x1,%eax
f010182e:	eb f3                	jmp    f0101823 <memfind+0xe>
			break;
	return (void *) s;
}
f0101830:	5d                   	pop    %ebp
f0101831:	c3                   	ret    

f0101832 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101832:	55                   	push   %ebp
f0101833:	89 e5                	mov    %esp,%ebp
f0101835:	57                   	push   %edi
f0101836:	56                   	push   %esi
f0101837:	53                   	push   %ebx
f0101838:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010183b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010183e:	eb 03                	jmp    f0101843 <strtol+0x11>
		s++;
f0101840:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101843:	0f b6 01             	movzbl (%ecx),%eax
f0101846:	3c 20                	cmp    $0x20,%al
f0101848:	74 f6                	je     f0101840 <strtol+0xe>
f010184a:	3c 09                	cmp    $0x9,%al
f010184c:	74 f2                	je     f0101840 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010184e:	3c 2b                	cmp    $0x2b,%al
f0101850:	74 2e                	je     f0101880 <strtol+0x4e>
	int neg = 0;
f0101852:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101857:	3c 2d                	cmp    $0x2d,%al
f0101859:	74 2f                	je     f010188a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010185b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101861:	75 05                	jne    f0101868 <strtol+0x36>
f0101863:	80 39 30             	cmpb   $0x30,(%ecx)
f0101866:	74 2c                	je     f0101894 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101868:	85 db                	test   %ebx,%ebx
f010186a:	75 0a                	jne    f0101876 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010186c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0101871:	80 39 30             	cmpb   $0x30,(%ecx)
f0101874:	74 28                	je     f010189e <strtol+0x6c>
		base = 10;
f0101876:	b8 00 00 00 00       	mov    $0x0,%eax
f010187b:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010187e:	eb 50                	jmp    f01018d0 <strtol+0x9e>
		s++;
f0101880:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101883:	bf 00 00 00 00       	mov    $0x0,%edi
f0101888:	eb d1                	jmp    f010185b <strtol+0x29>
		s++, neg = 1;
f010188a:	83 c1 01             	add    $0x1,%ecx
f010188d:	bf 01 00 00 00       	mov    $0x1,%edi
f0101892:	eb c7                	jmp    f010185b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101894:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101898:	74 0e                	je     f01018a8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f010189a:	85 db                	test   %ebx,%ebx
f010189c:	75 d8                	jne    f0101876 <strtol+0x44>
		s++, base = 8;
f010189e:	83 c1 01             	add    $0x1,%ecx
f01018a1:	bb 08 00 00 00       	mov    $0x8,%ebx
f01018a6:	eb ce                	jmp    f0101876 <strtol+0x44>
		s += 2, base = 16;
f01018a8:	83 c1 02             	add    $0x2,%ecx
f01018ab:	bb 10 00 00 00       	mov    $0x10,%ebx
f01018b0:	eb c4                	jmp    f0101876 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01018b2:	8d 72 9f             	lea    -0x61(%edx),%esi
f01018b5:	89 f3                	mov    %esi,%ebx
f01018b7:	80 fb 19             	cmp    $0x19,%bl
f01018ba:	77 29                	ja     f01018e5 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01018bc:	0f be d2             	movsbl %dl,%edx
f01018bf:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01018c2:	3b 55 10             	cmp    0x10(%ebp),%edx
f01018c5:	7d 30                	jge    f01018f7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01018c7:	83 c1 01             	add    $0x1,%ecx
f01018ca:	0f af 45 10          	imul   0x10(%ebp),%eax
f01018ce:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01018d0:	0f b6 11             	movzbl (%ecx),%edx
f01018d3:	8d 72 d0             	lea    -0x30(%edx),%esi
f01018d6:	89 f3                	mov    %esi,%ebx
f01018d8:	80 fb 09             	cmp    $0x9,%bl
f01018db:	77 d5                	ja     f01018b2 <strtol+0x80>
			dig = *s - '0';
f01018dd:	0f be d2             	movsbl %dl,%edx
f01018e0:	83 ea 30             	sub    $0x30,%edx
f01018e3:	eb dd                	jmp    f01018c2 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f01018e5:	8d 72 bf             	lea    -0x41(%edx),%esi
f01018e8:	89 f3                	mov    %esi,%ebx
f01018ea:	80 fb 19             	cmp    $0x19,%bl
f01018ed:	77 08                	ja     f01018f7 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01018ef:	0f be d2             	movsbl %dl,%edx
f01018f2:	83 ea 37             	sub    $0x37,%edx
f01018f5:	eb cb                	jmp    f01018c2 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f01018f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01018fb:	74 05                	je     f0101902 <strtol+0xd0>
		*endptr = (char *) s;
f01018fd:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101900:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0101902:	89 c2                	mov    %eax,%edx
f0101904:	f7 da                	neg    %edx
f0101906:	85 ff                	test   %edi,%edi
f0101908:	0f 45 c2             	cmovne %edx,%eax
}
f010190b:	5b                   	pop    %ebx
f010190c:	5e                   	pop    %esi
f010190d:	5f                   	pop    %edi
f010190e:	5d                   	pop    %ebp
f010190f:	c3                   	ret    

f0101910 <__udivdi3>:
f0101910:	55                   	push   %ebp
f0101911:	57                   	push   %edi
f0101912:	56                   	push   %esi
f0101913:	53                   	push   %ebx
f0101914:	83 ec 1c             	sub    $0x1c,%esp
f0101917:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010191b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010191f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101923:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101927:	85 d2                	test   %edx,%edx
f0101929:	75 35                	jne    f0101960 <__udivdi3+0x50>
f010192b:	39 f3                	cmp    %esi,%ebx
f010192d:	0f 87 bd 00 00 00    	ja     f01019f0 <__udivdi3+0xe0>
f0101933:	85 db                	test   %ebx,%ebx
f0101935:	89 d9                	mov    %ebx,%ecx
f0101937:	75 0b                	jne    f0101944 <__udivdi3+0x34>
f0101939:	b8 01 00 00 00       	mov    $0x1,%eax
f010193e:	31 d2                	xor    %edx,%edx
f0101940:	f7 f3                	div    %ebx
f0101942:	89 c1                	mov    %eax,%ecx
f0101944:	31 d2                	xor    %edx,%edx
f0101946:	89 f0                	mov    %esi,%eax
f0101948:	f7 f1                	div    %ecx
f010194a:	89 c6                	mov    %eax,%esi
f010194c:	89 e8                	mov    %ebp,%eax
f010194e:	89 f7                	mov    %esi,%edi
f0101950:	f7 f1                	div    %ecx
f0101952:	89 fa                	mov    %edi,%edx
f0101954:	83 c4 1c             	add    $0x1c,%esp
f0101957:	5b                   	pop    %ebx
f0101958:	5e                   	pop    %esi
f0101959:	5f                   	pop    %edi
f010195a:	5d                   	pop    %ebp
f010195b:	c3                   	ret    
f010195c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101960:	39 f2                	cmp    %esi,%edx
f0101962:	77 7c                	ja     f01019e0 <__udivdi3+0xd0>
f0101964:	0f bd fa             	bsr    %edx,%edi
f0101967:	83 f7 1f             	xor    $0x1f,%edi
f010196a:	0f 84 98 00 00 00    	je     f0101a08 <__udivdi3+0xf8>
f0101970:	89 f9                	mov    %edi,%ecx
f0101972:	b8 20 00 00 00       	mov    $0x20,%eax
f0101977:	29 f8                	sub    %edi,%eax
f0101979:	d3 e2                	shl    %cl,%edx
f010197b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010197f:	89 c1                	mov    %eax,%ecx
f0101981:	89 da                	mov    %ebx,%edx
f0101983:	d3 ea                	shr    %cl,%edx
f0101985:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101989:	09 d1                	or     %edx,%ecx
f010198b:	89 f2                	mov    %esi,%edx
f010198d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101991:	89 f9                	mov    %edi,%ecx
f0101993:	d3 e3                	shl    %cl,%ebx
f0101995:	89 c1                	mov    %eax,%ecx
f0101997:	d3 ea                	shr    %cl,%edx
f0101999:	89 f9                	mov    %edi,%ecx
f010199b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010199f:	d3 e6                	shl    %cl,%esi
f01019a1:	89 eb                	mov    %ebp,%ebx
f01019a3:	89 c1                	mov    %eax,%ecx
f01019a5:	d3 eb                	shr    %cl,%ebx
f01019a7:	09 de                	or     %ebx,%esi
f01019a9:	89 f0                	mov    %esi,%eax
f01019ab:	f7 74 24 08          	divl   0x8(%esp)
f01019af:	89 d6                	mov    %edx,%esi
f01019b1:	89 c3                	mov    %eax,%ebx
f01019b3:	f7 64 24 0c          	mull   0xc(%esp)
f01019b7:	39 d6                	cmp    %edx,%esi
f01019b9:	72 0c                	jb     f01019c7 <__udivdi3+0xb7>
f01019bb:	89 f9                	mov    %edi,%ecx
f01019bd:	d3 e5                	shl    %cl,%ebp
f01019bf:	39 c5                	cmp    %eax,%ebp
f01019c1:	73 5d                	jae    f0101a20 <__udivdi3+0x110>
f01019c3:	39 d6                	cmp    %edx,%esi
f01019c5:	75 59                	jne    f0101a20 <__udivdi3+0x110>
f01019c7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01019ca:	31 ff                	xor    %edi,%edi
f01019cc:	89 fa                	mov    %edi,%edx
f01019ce:	83 c4 1c             	add    $0x1c,%esp
f01019d1:	5b                   	pop    %ebx
f01019d2:	5e                   	pop    %esi
f01019d3:	5f                   	pop    %edi
f01019d4:	5d                   	pop    %ebp
f01019d5:	c3                   	ret    
f01019d6:	8d 76 00             	lea    0x0(%esi),%esi
f01019d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01019e0:	31 ff                	xor    %edi,%edi
f01019e2:	31 c0                	xor    %eax,%eax
f01019e4:	89 fa                	mov    %edi,%edx
f01019e6:	83 c4 1c             	add    $0x1c,%esp
f01019e9:	5b                   	pop    %ebx
f01019ea:	5e                   	pop    %esi
f01019eb:	5f                   	pop    %edi
f01019ec:	5d                   	pop    %ebp
f01019ed:	c3                   	ret    
f01019ee:	66 90                	xchg   %ax,%ax
f01019f0:	31 ff                	xor    %edi,%edi
f01019f2:	89 e8                	mov    %ebp,%eax
f01019f4:	89 f2                	mov    %esi,%edx
f01019f6:	f7 f3                	div    %ebx
f01019f8:	89 fa                	mov    %edi,%edx
f01019fa:	83 c4 1c             	add    $0x1c,%esp
f01019fd:	5b                   	pop    %ebx
f01019fe:	5e                   	pop    %esi
f01019ff:	5f                   	pop    %edi
f0101a00:	5d                   	pop    %ebp
f0101a01:	c3                   	ret    
f0101a02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a08:	39 f2                	cmp    %esi,%edx
f0101a0a:	72 06                	jb     f0101a12 <__udivdi3+0x102>
f0101a0c:	31 c0                	xor    %eax,%eax
f0101a0e:	39 eb                	cmp    %ebp,%ebx
f0101a10:	77 d2                	ja     f01019e4 <__udivdi3+0xd4>
f0101a12:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a17:	eb cb                	jmp    f01019e4 <__udivdi3+0xd4>
f0101a19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a20:	89 d8                	mov    %ebx,%eax
f0101a22:	31 ff                	xor    %edi,%edi
f0101a24:	eb be                	jmp    f01019e4 <__udivdi3+0xd4>
f0101a26:	66 90                	xchg   %ax,%ax
f0101a28:	66 90                	xchg   %ax,%ax
f0101a2a:	66 90                	xchg   %ax,%ax
f0101a2c:	66 90                	xchg   %ax,%ax
f0101a2e:	66 90                	xchg   %ax,%ax

f0101a30 <__umoddi3>:
f0101a30:	55                   	push   %ebp
f0101a31:	57                   	push   %edi
f0101a32:	56                   	push   %esi
f0101a33:	53                   	push   %ebx
f0101a34:	83 ec 1c             	sub    $0x1c,%esp
f0101a37:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101a3b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101a3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a43:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101a47:	85 ed                	test   %ebp,%ebp
f0101a49:	89 f0                	mov    %esi,%eax
f0101a4b:	89 da                	mov    %ebx,%edx
f0101a4d:	75 19                	jne    f0101a68 <__umoddi3+0x38>
f0101a4f:	39 df                	cmp    %ebx,%edi
f0101a51:	0f 86 b1 00 00 00    	jbe    f0101b08 <__umoddi3+0xd8>
f0101a57:	f7 f7                	div    %edi
f0101a59:	89 d0                	mov    %edx,%eax
f0101a5b:	31 d2                	xor    %edx,%edx
f0101a5d:	83 c4 1c             	add    $0x1c,%esp
f0101a60:	5b                   	pop    %ebx
f0101a61:	5e                   	pop    %esi
f0101a62:	5f                   	pop    %edi
f0101a63:	5d                   	pop    %ebp
f0101a64:	c3                   	ret    
f0101a65:	8d 76 00             	lea    0x0(%esi),%esi
f0101a68:	39 dd                	cmp    %ebx,%ebp
f0101a6a:	77 f1                	ja     f0101a5d <__umoddi3+0x2d>
f0101a6c:	0f bd cd             	bsr    %ebp,%ecx
f0101a6f:	83 f1 1f             	xor    $0x1f,%ecx
f0101a72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101a76:	0f 84 b4 00 00 00    	je     f0101b30 <__umoddi3+0x100>
f0101a7c:	b8 20 00 00 00       	mov    $0x20,%eax
f0101a81:	89 c2                	mov    %eax,%edx
f0101a83:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101a87:	29 c2                	sub    %eax,%edx
f0101a89:	89 c1                	mov    %eax,%ecx
f0101a8b:	89 f8                	mov    %edi,%eax
f0101a8d:	d3 e5                	shl    %cl,%ebp
f0101a8f:	89 d1                	mov    %edx,%ecx
f0101a91:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a95:	d3 e8                	shr    %cl,%eax
f0101a97:	09 c5                	or     %eax,%ebp
f0101a99:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101a9d:	89 c1                	mov    %eax,%ecx
f0101a9f:	d3 e7                	shl    %cl,%edi
f0101aa1:	89 d1                	mov    %edx,%ecx
f0101aa3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101aa7:	89 df                	mov    %ebx,%edi
f0101aa9:	d3 ef                	shr    %cl,%edi
f0101aab:	89 c1                	mov    %eax,%ecx
f0101aad:	89 f0                	mov    %esi,%eax
f0101aaf:	d3 e3                	shl    %cl,%ebx
f0101ab1:	89 d1                	mov    %edx,%ecx
f0101ab3:	89 fa                	mov    %edi,%edx
f0101ab5:	d3 e8                	shr    %cl,%eax
f0101ab7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101abc:	09 d8                	or     %ebx,%eax
f0101abe:	f7 f5                	div    %ebp
f0101ac0:	d3 e6                	shl    %cl,%esi
f0101ac2:	89 d1                	mov    %edx,%ecx
f0101ac4:	f7 64 24 08          	mull   0x8(%esp)
f0101ac8:	39 d1                	cmp    %edx,%ecx
f0101aca:	89 c3                	mov    %eax,%ebx
f0101acc:	89 d7                	mov    %edx,%edi
f0101ace:	72 06                	jb     f0101ad6 <__umoddi3+0xa6>
f0101ad0:	75 0e                	jne    f0101ae0 <__umoddi3+0xb0>
f0101ad2:	39 c6                	cmp    %eax,%esi
f0101ad4:	73 0a                	jae    f0101ae0 <__umoddi3+0xb0>
f0101ad6:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101ada:	19 ea                	sbb    %ebp,%edx
f0101adc:	89 d7                	mov    %edx,%edi
f0101ade:	89 c3                	mov    %eax,%ebx
f0101ae0:	89 ca                	mov    %ecx,%edx
f0101ae2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101ae7:	29 de                	sub    %ebx,%esi
f0101ae9:	19 fa                	sbb    %edi,%edx
f0101aeb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0101aef:	89 d0                	mov    %edx,%eax
f0101af1:	d3 e0                	shl    %cl,%eax
f0101af3:	89 d9                	mov    %ebx,%ecx
f0101af5:	d3 ee                	shr    %cl,%esi
f0101af7:	d3 ea                	shr    %cl,%edx
f0101af9:	09 f0                	or     %esi,%eax
f0101afb:	83 c4 1c             	add    $0x1c,%esp
f0101afe:	5b                   	pop    %ebx
f0101aff:	5e                   	pop    %esi
f0101b00:	5f                   	pop    %edi
f0101b01:	5d                   	pop    %ebp
f0101b02:	c3                   	ret    
f0101b03:	90                   	nop
f0101b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b08:	85 ff                	test   %edi,%edi
f0101b0a:	89 f9                	mov    %edi,%ecx
f0101b0c:	75 0b                	jne    f0101b19 <__umoddi3+0xe9>
f0101b0e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b13:	31 d2                	xor    %edx,%edx
f0101b15:	f7 f7                	div    %edi
f0101b17:	89 c1                	mov    %eax,%ecx
f0101b19:	89 d8                	mov    %ebx,%eax
f0101b1b:	31 d2                	xor    %edx,%edx
f0101b1d:	f7 f1                	div    %ecx
f0101b1f:	89 f0                	mov    %esi,%eax
f0101b21:	f7 f1                	div    %ecx
f0101b23:	e9 31 ff ff ff       	jmp    f0101a59 <__umoddi3+0x29>
f0101b28:	90                   	nop
f0101b29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b30:	39 dd                	cmp    %ebx,%ebp
f0101b32:	72 08                	jb     f0101b3c <__umoddi3+0x10c>
f0101b34:	39 f7                	cmp    %esi,%edi
f0101b36:	0f 87 21 ff ff ff    	ja     f0101a5d <__umoddi3+0x2d>
f0101b3c:	89 da                	mov    %ebx,%edx
f0101b3e:	89 f0                	mov    %esi,%eax
f0101b40:	29 f8                	sub    %edi,%eax
f0101b42:	19 ea                	sbb    %ebp,%edx
f0101b44:	e9 14 ff ff ff       	jmp    f0101a5d <__umoddi3+0x2d>
