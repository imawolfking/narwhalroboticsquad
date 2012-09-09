/*
 * flash.c
 *
 *  Created on: Sep 8, 2012
 *      Author: GrubyGrub
 */

#include "flash.h"
#include "stm32f4xx.h"
#include "stm32f4xx_flash.h"

// given an address, return the sector
uint32_t GetSector(uint32_t Address)
{
  uint32_t sector = 0;

  if((Address < ADDR_FLASH_SECTOR_1) && (Address >= ADDR_FLASH_SECTOR_0))
  {
    sector = FLASH_Sector_0;
  }
  else if((Address < ADDR_FLASH_SECTOR_2) && (Address >= ADDR_FLASH_SECTOR_1))
  {
    sector = FLASH_Sector_1;
  }
  else if((Address < ADDR_FLASH_SECTOR_3) && (Address >= ADDR_FLASH_SECTOR_2))
  {
    sector = FLASH_Sector_2;
  }
  else if((Address < ADDR_FLASH_SECTOR_4) && (Address >= ADDR_FLASH_SECTOR_3))
  {
    sector = FLASH_Sector_3;
  }
  else if((Address < ADDR_FLASH_SECTOR_5) && (Address >= ADDR_FLASH_SECTOR_4))
  {
    sector = FLASH_Sector_4;
  }
  else if((Address < ADDR_FLASH_SECTOR_6) && (Address >= ADDR_FLASH_SECTOR_5))
  {
    sector = FLASH_Sector_5;
  }
  else if((Address < ADDR_FLASH_SECTOR_7) && (Address >= ADDR_FLASH_SECTOR_6))
  {
    sector = FLASH_Sector_6;
  }
  else if((Address < ADDR_FLASH_SECTOR_8) && (Address >= ADDR_FLASH_SECTOR_7))
  {
    sector = FLASH_Sector_7;
  }
  else if((Address < ADDR_FLASH_SECTOR_9) && (Address >= ADDR_FLASH_SECTOR_8))
  {
    sector = FLASH_Sector_8;
  }
  else if((Address < ADDR_FLASH_SECTOR_10) && (Address >= ADDR_FLASH_SECTOR_9))
  {
    sector = FLASH_Sector_9;
  }
  else if((Address < ADDR_FLASH_SECTOR_11) && (Address >= ADDR_FLASH_SECTOR_10))
  {
    sector = FLASH_Sector_10;
  }
  else/*(Address < FLASH_END_ADDR) && (Address >= ADDR_FLASH_SECTOR_11))*/
  {
    sector = FLASH_Sector_11;
  }

  return sector;
}

int flashAddress(uint32_t startAddr, uint32_t *data, unsigned int len){
    FLASH_Status status;
    unsigned int retries;
    int ret;
    unsigned int i;

    if(startAddr == 0){
        startAddr = FLASH_START_ADDR;
    }

    FLASH_Unlock();

    // clear pending flags
    FLASH_ClearFlag(FLASH_FLAG_EOP | FLASH_FLAG_OPERR | FLASH_FLAG_WRPERR | FLASH_FLAG_PGAERR | FLASH_FLAG_PGPERR|FLASH_FLAG_PGSERR);

    ret = 1;

    for(i = GetSector(startAddr); i <= GetSector(startAddr+len); i+=8){
        retries = 0;
        do{
            // write by word, device voltage range [2.7, 3.6]
            status = FLASH_EraseSector(i, VoltageRange_3);
        }while(status != FLASH_COMPLETE && retries < FLASH_RETRIES);

        if(retries == FLASH_RETRIES){
            ret = 0;
            break;
        }
    }

    if(ret){
        for(i = 0; i < len; i ++){
            retries = 0;
            do{
                status = FLASH_ProgramWord(startAddr + i*4, *(data + i));
                retries++;
            }while(status != FLASH_COMPLETE && retries < FLASH_RETRIES);

            if(retries == FLASH_RETRIES){
                ret = 0;
                break;
            }
        }
    }

    FLASH_Lock();
    return ret;
}

uint32_t flashStartAddr(void){
    return FLASH_START_ADDR;
}

uint32_t flashSerno(uint8_t n){
    return *((uint32_t *)(0xDEADBEEF) + n);
}
