<center>

# Lab2-report

蒲彦丞-2200012956

</center>

<font color=red> 
Attention: I completed some some challenges, you can see details in <mark>challenge</mark> part. 
</font>

## Part 1

### Exercise 1:

#### boot_alloc()
`n=0` 时直接返回; 否则, 将更新前的 `nextfree` 存为返回值,然后将 `nextfree` 增加 `alloc` 的空间,注意确保对齐.当内存溢出时panic. 

#### mem_init()
调用 `boot_alloc()` 申请空间并初始化为0.

#### page_init() & page_free()
按要求仿照原代码设置即可

#### page_alloc()
从 `page_free_list` 中取出一个空闲的物理页面. 如果 `alloc_flags` 中包含 `ALLOC_ZERO`, 则需要将该页面填充为 0.最后返回该页面的指针.

## Part 2

### Exercise 2:
略.

### Exercise 3:

#### Q1
由于 `value` 是指针类型,  `x` would have type `uintptr_t`.

### Exercise 4:

#### pgdir_walk()
注意页目录项不存在页表 (`!(*pde & PTE_P)`) 与 不允许创建新页表 (`!create`) 最后返回指向页表项的指针.

#### boot_map_region()
Simply mapping `[va, va+size)` of virtual address space to physical `[pa, pa+size)` in the page table rooted at pgdir.

#### page_lookup()
如果没有页表项, 或者页表项无效, 则返回 `NULL`. 如果 `pte_store` 不为 `NULL`，则将PTE地址存储到 `pte_store`

#### page_remove()
如果 `va` 处有物理页面, 取消此处对物理页面的映射; 否则不执行任何操作.

#### page_insert()
将物理页 `pp` 映射到虚拟地址 `va` , 删除已映射的页， 增加物理页引用计数并更新页表项.

值得注意的是应该避免重复增加引用计数: 当重新插入相同的物理页 `pp` 时, 可能会出现引用计数增加两次的问题. 为避免这种情况，应该在删除旧映射之后再增加引用计数.  故 `pp->pp_ref++` 应该在 `page_remove` 调用之后. 这个小问题不会影响评分, 因此我最开始并没有注意到, 但是GPT 给我指出来了().

## Part 3

### Exercise 5

#### mem_init()
略.

#### Q2
| Entry | Base Virtual Address |