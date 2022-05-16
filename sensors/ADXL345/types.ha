use io;

export type ADXL345_impl = struct {
	file: io::file,
};

export type ADXL345 = *ADXL345_impl;

def REG_POWER_CTL: u8	= 0x2d;
def POWER_CTL_MEASURE: u8	= 1 << 3;

def REG_DATA_FORMAT: u8	= 0x31;
def DATA_FORMAT_FULL_RES: u8	= 1 << 3;

def SCALE_FACTOR_FULL_RES: f64	= 1.0f64 / 256f64;

def REG_DATAX0: u8	= 0x32;
def REG_DATAY0: u8	= 0x34;
def REG_DATAZ0: u8	= 0x36;
