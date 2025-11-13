MBALIGN equ 1<<0
MEMINFO equ 1<<1
MBFLAGS equ MBALIGN|MEMINFO
MAGIC equ 0x1BADB002
CHECKSUM equ -(MAGIC + MBFLAGS)


section .multiboot
align 4
    dd MAGIC
    dd MBFLAGS
    dd CHECKSUM


section .bss
align 16
stack_bottom:
resb 16384
stack_top:



; used for segmentation, grub gives us a 32 bit one but we need to switch to a long mode gdt
section .rodata
gdt64:
    dq 0                                         ; Null descriptor
.code: equ $ - gdt64
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53) ; code segment
.pointer:
    dw $ - gdt64 - 1
    dq gdt64


PML4T_ADDR equ 0x1000
SIZEOF_PAGE_TABLE equ 4096
PML4T_ADDR equ 0x1000
PDPT_ADDR equ 0x2000
PDT_ADDR equ 0x3000
PT_ADDR equ 0x4000
PT_ADDR_MASK equ 0xffffffffff000
PT_PRESENT equ 1                 ; marks the entry as in use
PT_READABLE equ 2                ; marks the entry as r/w
ENTRIES_PER_PT equ 512
SIZEOF_PT_ENTRY equ 8
PAGE_SIZE equ 0x1000
CR4_PAE_ENABLE equ 1 << 5
EFER_MSR equ 0xC0000080
EFER_LM_ENABLE equ 1 << 8
CR0_PM_ENABLE equ 1 << 0
CR0_PG_ENABLE equ 1 << 31


section .text
bits 32

extern kernel_main

clear_page_table:
        mov edi, PML4T_ADDR
        mov cr3, edi       ;cr3 lets the CPU know where the page tables are
        xor eax, eax
        mov ecx, SIZEOF_PAGE_TABLE
        rep stosd          ;writes 4 * SIZEOF_PAGE_TABLE bytes, which is enough space
                           ;for the 4 page tables
        mov edi, cr3       ;reset di back to the beginning of the page table
        ret 


link_page_table_entries:

        ;edi was previously set to PML4T_ADDR
        mov DWORD [edi], PDPT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

        mov edi, PDPT_ADDR
        mov DWORD [edi], PDT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

        mov edi, PDT_ADDR
        mov DWORD [edi], PT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE
        ret 

fill_page_table:
        mov edi, PT_ADDR ; address of page table
        mov ebx, PT_PRESENT | PT_READABLE ; flags of page table entry 
        mov ecx, ENTRIES_PER_PT      ; 1 full page table addresses 2MiB

.SetEntry:
        mov DWORD [edi], ebx ; Write page table entry 
        add ebx, PAGE_SIZE ; next physical address 
        add edi, SIZEOF_PT_ENTRY ; address of next page table entry 
        loop .SetEntry               ;decreaes ecx and set the next entry if the counter is not 0.
        ret

; enable physical address extensions, allows us to access physical address range larger than 4gb
enable_pae:
        mov eax, cr4
        or eax, CR4_PAE_ENABLE
        mov cr4, eax
        ret

; enable long mode 
set_lm_bit:
        mov ecx, EFER_MSR
        rdmsr
        or eax, EFER_LM_ENABLE
        wrmsr
        ret



; double check that protected mode is still enabled so we can jump to long mode
; we also enable paging here         
enable_paging:
        mov eax, cr0
        or eax, CR0_PG_ENABLE | CR0_PM_ENABLE   ; ensuring that PM is set will allow for jumping
                                                ; from real mode to compatibility mode directly
        mov cr0, eax
        ret


global _start:function (_start.end - _start)
_start:

        mov  esp, stack_top
        call clear_page_table
        call link_page_table_entries
        call fill_page_table
        call enable_pae
        call set_lm_bit
        call enable_paging                 
        lgdt [gdt64.pointer]
        jmp gdt64.code:long_mode_start
.end:


bits 64
long_mode_start:
        mov rsp, stack_top
        and rsp, -16
        
        call kernel_main

        mov rax, 0x2f592f412f4b2f4f  ; "OKAY"
        mov qword [0xb8000], rax
        hlt


