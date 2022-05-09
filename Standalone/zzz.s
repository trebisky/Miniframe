|
| Assembly language startup file
|
	.data
	.set	NBPG,4096
	.set	KSIZE,128
	.set	MAPBASE,0x400000
	.set	VBASE,0

	.globl	_umap
	.globl	_kmap
	.globl	_u
	.globl	_vk

	.set	_kmap,MAPBASE
	.set	_umap,MAPBASE + KSIZE * 2

	.set	_vk,VBASE
	.set	_u,_vk + KSIZE * NBPG
