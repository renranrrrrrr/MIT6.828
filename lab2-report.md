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

#### A1
由于 `value` 是指针类型,  `x` would have type `uintptr_t`.

### Exercise 4:

#### pgdir_walk()


