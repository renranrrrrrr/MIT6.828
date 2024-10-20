// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display backtrace information", mon_backtrace },
	{ "showmapping", "Display the physical page mappings and corresponding permission bits that apply to the pages at virtual addresses", mon_showmappings},
	{ "setpermission", "Set the permission bits of a given mapping", mon_setpermissions },
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	uint32_t *ebp;
	struct Eipdebuginfo info;

	cprintf("Stack backtrace:\n");
	
	ebp = (uint32_t *)read_ebp();

	while(ebp!=0){
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
			ebp, ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		
		int res = debuginfo_eip(ebp[1], &info);
		if(res == 0){
			int fn_offset = *(ebp+1) - info.eip_fn_addr;
			cprintf("%s:%d: %.*s+%u\n",
			 info.eip_file,info.eip_line,
			 info.eip_fn_namelen,info.eip_fn_name,
			 fn_offset);
		}
		else cprintf("Error!\n");
		ebp = (uint32_t *)*ebp;
	}
	return 0;
}

bool check(const char* buf){
	buf += 2;

	while(*buf){
        if(*buf < '0' || (*buf >'9' && *buf <'A') ||
		   (*buf > 'F' && *buf <'a') || *buf >'f' ){
            return false;
        }
		++buf;
    }

	return true; 
}

uint32_t trans(const char* buf){
    uint32_t result = 0;
    
	if(*buf == '0' && (*(buf+1)) == 'x')
		buf += 2;

    while(*buf){
        uint32_t val = 0;
        
        if(*buf >= '0' && *buf <='9'){
            val = *buf - '0';
        }
		else if(*buf >= 'a' && *buf <= 'f'){
            val = *buf - 'a' + 10;
        }
		else if(*buf >= 'A' && *buf <= 'F'){
            val = *buf - 'A' + 10;
        }
        result = result * 16 + val;
        ++buf;
    }

    return result;
}

int 
mon_showmappings(int argc,char** argv,struct Trapframe* tf){
	
	if(argc !=3){
		cprintf("\nPlease pass arguments in correct formats, for example:\n");
		cprintf("	showmappings begin_addr end_addr\n");
		return 0;
	}

	if(argv[1] > argv[2]){
		cprintf("\nPlease make sure that begin_addr is no greater than end_addr.\n");
		return 0;
	}

	if(!check(argv[1]) || !check(argv[2])){
		cprintf("\nInvalid address, please check your input.\n");
		return 0;
	}

	uint32_t vstart, vend;
    pte_t *pte;

    vstart = trans(argv[1]);
	vend = trans(argv[2]);
	
    vstart = ROUNDDOWN(vstart, PGSIZE);
    vend = ROUNDDOWN(vend, PGSIZE);

    for(; vstart <= vend; vstart += PGSIZE){
        pte = pgdir_walk(kern_pgdir, (void *)vstart, 0);
        
		if(pte && (*pte & PTE_P)){
            cprintf("VA: 0x%08x, PA: 0x%08x, PTE_P: %x, PTE_W: %x, PTE_U: %x\n",
                vstart, PTE_ADDR(*pte), *pte&PTE_P, *pte & PTE_W, *pte & PTE_U);
        }
		else cprintf("Page 0x%08x, there's no such mapping\n", vstart);
    }

    return 0;
}

int 
mon_setpermissions(int argc, char **argv, struct Trapframe *tf){

    if(argc != 3){
        cprintf("\nPlease pass arguments in correct formats, for example:\n");
		cprintf("	setperm virtual_address permission\n");
    	return 0;
	}

	if(!check(argv[1])){
		cprintf("\nInvalid address, please check your input.\n");
		return 0;
	}

    uint16_t perm = (uint16_t)trans(argv[2]);
	if(perm > 0xFFF){
		cprintf("\nInvalid permission, please check your input.\n");
		return 0;
	}

    uint32_t va = trans(argv[1]);
	pte_t *pte = pgdir_walk(kern_pgdir, (void*)va, 0);
    
	if(pte && (*pte & PTE_P)){
		cprintf("You're going to set permission at:\n");
		cprintf("VA: 0x%08x, PA: 0x%08x, PTE_P: %x, PTE_W: %x, PTE_U: %x\n",
                va, PTE_ADDR(*pte), *pte&PTE_P, *pte & PTE_W, *pte & PTE_U);
        *pte = (*pte & 0xFFFFF000) | perm | PTE_P;
		cprintf("You've successfully set permission.\n");
		cprintf("VA: 0x%08x, PA: 0x%08x, PTE_P: %x, PTE_W: %x, PTE_U: %x\n",
                va, PTE_ADDR(*pte), *pte&PTE_P, *pte & PTE_W, *pte & PTE_U);

    }
	else cprintf("Page 0x%08x, there's no such mapping\n", va);
    
	return 0;    
}

/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
