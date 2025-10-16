.PHONY: input_rom input_rom_reader middle_ram middle_ram_controller box_filter

input_rom: input_rom.v test/tb_input_rom.v
	iverilog input_rom.v test/tb_input_rom.v

input_rom_reader: input_rom.v input_rom_reader.v test/tb_input_rom_reader.v
	iverilog input_rom.v input_rom_reader.v test/tb_input_rom_reader.v

middle_ram: middle_ram.v test/tb_middle_ram.v
	iverilog middle_ram.v test/tb_middle_ram.v

middle_ram_controller: middle_ram.v middle_ram_controller.v test/tb_middle_ram_controller.v
	iverilog middle_ram.v middle_ram_controller.v test/tb_middle_ram_controller.v

box_filter: input_rom.v input_rom_reader.v middle_ram.v middle_ram_controller.v box_filter.v test/tb_box_filter.v
	iverilog input_rom.v input_rom_reader.v middle_ram.v middle_ram_controller.v box_filter.v test/tb_box_filter.v
