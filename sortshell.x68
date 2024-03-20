*-----------------------------------------------------------
* Program Number: IDK Dawg
* Written by    : Ben Cohen
* Date Created  : Sept 13, 2023
* Description   : Sorting a raw data file with shell sort
*
*-----------------------------------------------------------



START   ORG     $1000

*store words in High and Low?
*Size Bytes = d0
*d1 = interval in words
*d7 = interval in bytes
*
*lower index value = d2 (index value)
*higher index value = d3 (index value)
*
*saved lower data = d4
*
*addresses
*a0 = start of iteration
*a1 = max address
*


        lea     DataToSort,a0                   ;load the address of the data into a0
        move.l  #(SortedData-DataToSort), d0    ;set size in bytes to d0
        lsr.b   #$01,d0                         ;get size in words to d0
        lea     sortedData, a1                  ;start of sorted data
        
        
MoveByteData:
        
        move.w  (a0)+,(a1)+     ;move a0 to a1 and post inc both
        
        subi.l  #01,d0          ;decrement d0
        BNE     MoveByteData    ;If not zero run loop again    
                
PrepareRegistersForSort:
        
        
        move.l #(SortedData-DataToSort), d0
        move.l  d0,d1                           ;move size to interval value register
        lsr.b   #$02,d1                         ;Divide size by 2 to get size in words, then another 2 for true interval in words
        move.l  d1, d7                          ;Move inteval in words to iterating interval holder d7
        
        lsl.b   #$01, d7                        ;Always positive
        
        BNE     SetInterval
       

DecrementInterval:        

        lsr.b   #$01,d1                         ;Divide word interval by 2
        move.l  d1,d7                           ;move word interval to byte interval
        lsl.b   #$01,d7                         ;d7 shift left to get byte interval (Always even)
        
        BEQ     CheckIfListSorted               ;gap size = 0 => Branch outa here the list should be sorted       
        
               
SetInterval:

        lea sortedData, a0                      ;needed for next interval             
        
        clr.l   d2
        BEQ     SetLowerIndexVal
        
SetLowerIndexIncrement:
        add.l   #02,d2        
        
SetLowerIndexVal:
        
        move.l  a0,a2
        add.l   d7,a2
        cmp.l   a2,a1                           ;max increment minus current increment
        BLE     DecrementInterval
              
        move.w  (a0),d4                         ;save lower interval data to d4       
        clr.l   d3

SetHigherIndexVal:
        
        cmp.w   (a0,d7),d4                      ;Compare lower address minus higher address  L - H = -x if lower is less than high
        BGE     Swap                            ;lower index value is greater so swap
        
        add.l   #02,a0                          ;increment a0
        BNE     SetLowerIndexIncrement


Swap:        
        ;value is higher
        move.w  (a0,d7),(a0)                    ;move higher address data into lower address data 
        move.w  d4,(a0,d7)                      ;move saved lower address data into higher address data
        
        add.l   #02,a0                          ;increment a0
        BNE     SetLowerIndexIncrement        
  
    
    
*Insertion Sort check in case worst case scenario

*a0 = iterator
*a1 = end of data
*d0 = total size of array 
*d1 = decrement variable 
*d2 = gap size (always 2)
*d3 >= 1 if a swap occurs (run iteration again)
*d4 = saved lower value
*d7 for zero checking and making sure things branches correctly    
    
    
CheckIfListSorted:      

        clr.l   d1
        clr.l   d2       
        clr.l   d4
        clr.l   d7
        
        move.l  d0,d1
        move.l  #2,d2
        
        lea SortedData,a0
        
        sub.l   #2,a1                           ;max size - 1
        
        
RestartIteration:

        lea     SortedData,a0
        clr.l   d3
        
FinalSortIteration:        
        
        cmp.l   a0,a1                           ;If max - 1 is less than or equal to current, go to AreWeDone
        BLE     AreWeDone
        
        move.w  (a0),d4                         ;Save lower value to register
        cmp.w   (a0,d2),d4                      ;Lower Minus Upper if Greater than, swap needed
        BGT FinalSwap
        
        add.l   #02,a0
        cmp.l   #0,d7
        BEQ     FinalSortIteration
        
        
FinalSwap:
        
        add.l   #1,d3                           ;swap occurred, so increase d3 so another iteration will run after current
        move.w  (a0,d2),(a0)
        move.w  d4,(a0,d2)
        add.l   #02,a0
        cmp.l   #0,d7
        BEQ     FinalSortIteration  
        
AreWeDone:
        cmp.l   #0,d3
        BNE     RestartIteration

        
ListSorted: *Huzzah!       

        

       
        move.b  $9,d0
        TRAP #15
        
        STOP #$2000
     

DataToSort      INCBIN "asmdata.bin"


SortedData      ds.b  (SortedData-DataToSort)
        END     START












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
