/******************************************************
 * @file      startup_stm32f401cdux.s
 * BLACK PILL LED BLINKING IN ASSEMBLER 52 BYTES LONG
 *******************************************************/

// A FEW DEFINITIONS


#define TOP_OF_STACK              0x20000F00

#define RCC_AHB1_ADDR             0x40023800
#define RCC_AHB1_EN_OFFSET        0x30
#define ENABLE_GPIOC_VALUE        0x04

#define GPIOC_MODER_REG_ADDR      0x40020800
#define GPIOC_PUPDR_REG_OFFSET    0x0C
#define GPIOC_ODR_REG_OFFSET      0x14
#define BIT_13_REGVALUE_SETUP     (1UL << 26)
#define BIT_13_VALUE              (1UL << 13)
/******************************************************************************
*  VECTORS
******************************************************************************/
// ARM ASSEMBLER ATTRIBUTES
.syntax unified
.cpu cortex-m4
/*********************************************************************
*  VECTORS SECTION START
**********************************************************************/
  .section .vector_table

  .word TOP_OF_STACK            // DOESN'T MATTER WE DON'T USE STACK HERE
  .word Reset_Handler           // FOR STM32 IN THUMB MODE 0x08000009


/*********************************************************************
*  VECTORS END
**********************************************************************/

  .thumb_func
  .text
/***********************************************************
* RESET CODE - BLINKING LED PC13
********************************************************************/


Reset_Handler:


/* 1. ENABLE RCC CLOCK FOR GPIOC (0x40023830 ADDRESS) */
/* 2. SET GPIOC BIT 13 TO OUTPUT  IN GPIOC->MODER REGISTER (0x40020800  ADDRESS) */
/* 3. SET GPIOC BIT 13 AS PULL UP IN GPIOC->PUPDR REGISTER (0x4002080C  ADDRESS) */
/* 4. TOGGLE BIT 13 IN GPIOC->ODR REGISTER (0x40020814  ADDRESS)  */
/* 5. A SMALL DELAY LOOP */
/* 6. GO BACK TO TOGGLE BIT 13 IN GPIOC->ODR REGISTER */


                               // R7 = RAM or ROM START ADDRESS 0x20000000 or 0x08000000
//**********************************************************************************************************

/* 1. ENABLE RCC CLOCK FOR GPIOC (0x40023830 ADDRESS) */



  LDR    R0, =RCC_AHB1_ADDR           // R0 = RCC_AHB1_BASE_ADDRES (R7 = 0x00000000)  12 = RCC_AHB1_BASE_ADDRES
  LDR    R1, [R0, #RCC_AHB1_EN_OFFSET]        // R1 = RCC_AHB1_EN VALUE
  ORR.W  R1,  R1, #ENABLE_GPIOC_VALUE         // ENABLE GPIOC
  STR    R1, [R0, #RCC_AHB1_EN_OFFSET]

/* 2. SET GPIOC BIT 13 TO OUTPUT  IN GPIOC->MODER REGISTER (0x40020800  ADDRESS) */
/* 3. SET GPIOC BIT 13 AS PULL UP IN GPIOC->PUPDR REGISTER (0x4002080C  ADDRESS) */
  LDR    R1, =BIT_13_REGVALUE_SETUP           // R1 = 0x04000000
  SUBS   R0, 0x3000                           // 2 BYTEST SHORT INSTEAD "LDR    R0, =GPIOC_MODER_REG_ADDR"
  STR    R1, [R0]                             // INITIAL VALUE GPIOC_MODER_REGISTER = BIT13 SET TO OUTPUT
  STR    R1, [R0, #GPIOC_PUPDR_REG_OFFSET]    // INITIAL VALUE GPIOC_PUPDR_REGISTER = BIT13 PULL_UP

  //LDR    R1, [R0, #GPIOC_ODR_REG_OFFSET]    // UNNEECESSARY

LOOP01:
/* 4. TOGGLE BIT 13 IN GPIOC->ODR REGISTER (0x40020814  ADDRESS)  */
  EOR.W  R1,  R1,BIT_13_VALUE                 // TOGGLE BIT 13
  STR    R1, [R0, #GPIOC_ODR_REG_OFFSET]      // STORE VALUE WITH TOGGLED BIT 13 INTO GPIOC_ODR_REGISTER

  LDR R2, =500000         // SIMPLE DELAY LOOP  R2 = 500000 or 500000/4


LOOP02:

/* 5. A SMALL DELAY LOOP */
  SUBS   R2,#1                                // DECREMENT REGISTER
  BNE    LOOP02                               // REGISTER NOT 0? SO STILL DECREMENT

/* 6. GO BACK TO TOGGLE BIT 13 IN GPIOC->ODR REGISTER */
  BEQ    LOOP01
END_LOOP:                         // DELAY END GO BACK TO BLINKING LOOP
/*****END OF FILE****/

