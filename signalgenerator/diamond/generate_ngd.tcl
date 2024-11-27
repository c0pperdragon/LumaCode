#!/usr/local/bin/wish

proc GetPlatform {} {
	global tcl_platform

	set cpu  $tcl_platform(machine)

	switch $cpu {
		intel -
		i*86* {
			set cpu ix86
		}
		x86_64 {
			if {$tcl_platform(wordSize) == 4} {
				set cpu ix86
			}
		}
	}

	switch $tcl_platform(platform) {
		windows {
			if {$cpu == "amd64"} {
				# Do not check wordSize, win32-x64 is an IL32P64 platform.
				set cpu x86_64
			}
			if {$cpu == "x86_64"} {
				return "nt64"
			} else {
				return "nt"
			}
		}
		unix {
			if {$tcl_platform(os) == "Linux"}  {
				if {$cpu == "x86_64"} {
					return "lin64"
				} else {
					return "lin"
				}
			} else  {
				return "sol"
			}
		}
	}
	return "nt"
}

set platformpath [GetPlatform]
set Para(sbp_path) [file dirname [info script]]
set Para(install_dir) $env(TOOLRTF)
set Para(FPGAPath) "[file join $Para(install_dir) ispfpga bin $platformpath]"
set Para(bin_dir) "[file join $Para(install_dir) bin $platformpath]"

set Para(ModuleName) "TITLES"
set Para(Module) "ROM"
set Para(libname) machxo2
set Para(arch_name) xo2c00
set Para(PartType) "LCMXO2-1200HC"

set Para(tech_syn) machxo2
set Para(tech_cae) machxo2
set Para(Package) "QFN32"
set Para(SpeedGrade) "5"
set Para(FMax) "100"
set fdcfile "$Para(sbp_path)/$Para(ModuleName).fdc"

#edif2ngd
set edif2ngd "$Para(FPGAPath)/edif2ngd"
set Para(result) [catch {eval exec $edif2ngd -l $Para(libname) -d $Para(PartType) -nopropwarn $Para(ModuleName).edn $Para(ModuleName).ngo} msg]
#puts $msg

#ngdbuild
set ngdbuild "$Para(FPGAPath)/ngdbuild"
set Para(result) [catch {eval exec $ngdbuild -addiobuf -dt -a $Para(arch_name) $Para(ModuleName).ngo $Para(ModuleName).ngd} msg]
#puts $msg
