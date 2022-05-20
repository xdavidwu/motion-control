use io;

export type L3G4200D_impl = struct {
	file: io::file,
};

export type L3G4200D = *L3G4200D_impl;

def REG_CTRL_REG1: u8	= 0x20;
def CTRL_REG1_DR_100HZ: u8	= 0b00 << 6;
def CTRL_REG1_PD: u8	= 1 << 3;
def CTRL_REG1_Zen: u8	= 1 << 2;
def CTRL_REG1_Yen: u8	= 1 << 1;
def CTRL_REG1_Xen: u8	= 1 << 0;

def REG_CTRL_REG2: u8	= 0x21;
def CTRL_REG2_HPCF_0_05HZ_AT_100HZ: u8	= 0b111;

def REG_CTRL_REG4: u8	= 0x23;
def CTRL_REG4_BDU: u8	= 1 << 7;

def REG_CTRL_REG5: u8	= 0x24;
def CTRL_REG5_OUT_HP_ONLY: u8	= 0b01;

def REG_OUT_X_L: u8	= 0x28;
def REG_OUT_Y_L: u8	= 0x2a;
def REG_OUT_Z_L: u8	= 0x2c;

def FS_250DPS_So: f64	= 8.75f64 / 1000.0f64;
