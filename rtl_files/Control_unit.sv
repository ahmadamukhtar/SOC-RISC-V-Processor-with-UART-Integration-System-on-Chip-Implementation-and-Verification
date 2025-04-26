module control_unit(
    input logic [2:0] func_3,  // Function field to distinguish instructions within the opcode
    input logic [4:0] opcode,  // Main instruction opcode
    input logic func_7,        // Additional function field (for some instructions like shifts, etc.)
    input logic BrEq,          // Branch equals signal
    input logic BrLt,          // Branch less than signal
    output logic PCSel,        // Program counter select signal
    output logic [2:0] ImmSel, // Immediate selection signal
    output logic BrUn,         // Branch unsigned signal
    output logic ASel,         // ALU A input select
    output logic BSel,         // ALU B input select
    output logic [3:0] ALUSel, // ALU operation select signal
    output logic MemRW,        // Memory read/write signal
    output logic RegWEn,       // Register write enable signal
    output logic [1:0]WBSel,  // Write back select signal
    output logic signal
);

always_comb begin
    case(opcode)
        5'b00000: begin  // Load instructions
            case(func_3)
                3'b000: begin  // LB - Load byte  //imm_sel_is now 12bit  load case
                  PCSel = 0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 1; ALUSel =0; MemRW = 0; RegWEn = 1; WBSel = 0;signal=0;
                end
                3'b001: begin  // LH - Load halfword
                      PCSel = 0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 1; ALUSel =0; MemRW = 0; RegWEn = 1; WBSel = 0;signal=0;
                end
                3'b010: begin  // LW - Load word
                     PCSel = 0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 1; ALUSel =0; MemRW = 0; RegWEn = 1; WBSel = 0;signal=0;
                end
                3'b100: begin  // LBU - Load byte unsigned
                     PCSel = 0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 1; ALUSel =0; MemRW = 0; RegWEn = 1; WBSel = 0;signal=0;
                end
                3'b101: begin  // LHU - Load halfword unsigned
                    PCSel = 0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 1; ALUSel =0; MemRW = 0; RegWEn = 1; WBSel = 0;signal=0;
                end
                default: begin  PCSel = 0; ImmSel =0; BrUn = 0; signal=0;ASel = 0; BSel = 0; ALUSel =0; MemRW = 0; RegWEn = 0; WBSel = 0;
                end
            endcase
        end
        
        5'b00100: begin  // Immediate arithmetic instructions
            case(func_3)
                3'b000: begin  // ADDI - Add immediate
                    PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel =1; ALUSel =0; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                end
                3'b001: begin  // SLLI - Shift left logical immediate
                     PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel =1; ALUSel =5; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                end
                3'b010: begin  // SLTI - Set less than immediate
                    PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel =1; ALUSel =8; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                end
                3'b011: begin  // SLTIU - Set less than immediate unsigned
                     PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel =1; ALUSel =9; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                end
                3'b100: begin  // XORI - Exclusive OR immediate
                     PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel =1; ALUSel =4; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                end
                3'b101: begin  // SRLI/SRAI - Shift right logical/arithmetic immediate
                    if(func_7) begin  // SRAI - Arithmetic shift right
                         PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel =1; ALUSel =7; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                    end else begin  // SRLI - Logical shift right
                         PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel =1; ALUSel =6; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                    end
                end
                3'b110: begin  // ORI - OR immediate
                    PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel =1; ALUSel =3; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                end
                3'b111: begin  // ANDI - AND immediate
                    PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel =1; ALUSel =2; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                end
                  default: begin  PCSel = 0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 0; ALUSel =0; MemRW = 0; RegWEn = 0; WBSel = 0;  end
            endcase
        end
        
        5'b00101: begin  // AUIPC - Add upper immediate to PC  //imm type is of uper lead 20 bit 
                  PCSel = 0; ImmSel = 1; BrUn = 0; ASel = 1; BSel = 1; ALUSel =10; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
        end
        
        5'b01101: begin  // LUI - Load upper immediate  //imm type is of uper lead 20 bit  // alu sel is new type which just 12 bit sll shift the second oprand
        PCSel = 0; ImmSel = 1; BrUn = 0; ASel = 0; BSel = 1; ALUSel = 11; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
        end
        
        5'b01000: begin  // Store instructions
            case(func_3)
                3'b000: begin  // SB - Store byte  //imm_gen_store_type
                    PCSel = 0; ImmSel =2; BrUn = 0; ASel = 0; BSel = 1; ALUSel = 0; MemRW = 1; RegWEn = 0; WBSel = 0; signal=1;
                end
                3'b001: begin  // SH - Store halfword
                      PCSel = 0; ImmSel =2; BrUn = 0; ASel = 0; BSel = 1; ALUSel = 0; MemRW = 1; RegWEn = 0; WBSel = 0;signal=1;
                end
                3'b010: begin  // SW - Store word
                     PCSel = 0; ImmSel =2; BrUn = 0; ASel = 0; BSel = 1; ALUSel = 0; MemRW = 1; RegWEn = 0; WBSel = 0;signal=1;
                end
                default: begin  PCSel = 0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 0; ALUSel =0; MemRW = 0; RegWEn = 0; WBSel = 0; signal=0;end
            endcase
        end
        
        5'b01100: begin  // Register-register arithmetic instructions
            case(func_3)
                3'b000: begin  // ADD/SUB - Addition or subtraction
                    if(func_7) begin  // SUB - Subtraction
                        PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel = 0; ALUSel =1; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                    end else begin  // ADD - Addition
                        PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel = 0; ALUSel =0; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                    end
                end
                3'b001: begin  // SLL - Shift left logical
                    PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel = 0; ALUSel =5; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                end
                3'b010: begin  // SLT - Set less than
                    PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel = 0; ALUSel =8; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                end
                3'b011: begin  // SLTU - Set less than unsigned
                        PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel = 0; ALUSel =9; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                    end                
                3'b100: begin  // XOR - Exclusive OR
                   PCSel = 0; ImmSel = 0; BrUn = 0; ASel =0; BSel = 0; ALUSel =4; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                end
                3'b101: begin  // SRL/SRA - Shift right logical/arithmetic
                   if(func_7) begin    //SRA
                        PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel = 0; ALUSel =7; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                    end else begin    //SRL
                        PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel = 0; ALUSel =6; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                    end
                end
                3'b110: begin  // OR - OR operation
                    PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel = 0; ALUSel =3; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                end
                3'b111: begin  // AND - AND operation
                   PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel = 0; ALUSel =2; MemRW = 0; RegWEn = 1; WBSel = 1;signal=0;
                end
                 default: begin  PCSel = 0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 0; ALUSel =0; MemRW = 0; RegWEn = 0; WBSel = 0; end
            endcase
        end
        
        5'b11000: begin  // Branch instructions   //imm_sel is of brach type 
            case(func_3)
                3'b000: begin  // BEQ - Branch if equal
                if(BrEq)  begin  PCSel =1; ImmSel =3; BrUn = 0; ASel = 1; BSel = 1; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel =1; signal=0;  end          begin signal=0; PCSel =0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 0; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel =0; signal=0;  end       
                end
                3'b001: begin  // BNE - Branch if not equal
               if(!BrEq)  begin  PCSel =1; ImmSel =3; BrUn = 0; ASel = 1; BSel = 1; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel =1; signal=0;  end   else  begin signal=0;  PCSel =0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 0; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel =0;   end
                end
                3'b100: begin  // BLT - Branch if less than
                   if( BrLt)  begin  PCSel =1; ImmSel =3; BrUn = 0; ASel = 1; BSel = 1; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel =1;  signal=0; end   begin signal=0; PCSel =0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 0; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel =0;   end
                end
                3'b101: begin  // BGE - Branch if greater than or equal
               if(!BrLt||BrEq)  begin  PCSel =1; ImmSel =3; BrUn = 0; ASel = 1; BSel = 1; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel =1; signal=0;  end   begin signal=0; PCSel =0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 0; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel =0;   end
                end
                3'b110: begin  // BLTU - Branch if less than unsigned
               if( BrLt)  begin  PCSel =1; ImmSel =3; BrUn =1; ASel = 1; BSel = 1; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel =1;   end   begin  signal=0; PCSel =0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 0; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel =0;   end
                end
                3'b111: begin  // BGEU - Branch if greater than or equal unsigned
                if(!BrLt||BrEq)  begin  PCSel =1; ImmSel =3; BrUn = 1; ASel = 1; BSel = 1; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel =1;   end   begin  signal=0; PCSel =0; ImmSel =0; BrUn = 0; ASel = 0; BSel = 0; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel =0;   end
                end
                default: begin  PCSel =0; ImmSel =0; BrUn = 0; ASel = 0;signal=0; BSel = 0; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel =0;   end 
            endcase
        end
        5'b11001: begin  // JALR - Jump and link register//immSEL is itype so it is imm=0
            case(func_3)
                3'b000: begin
               PCSel = 1; ImmSel =0; BrUn = 0; ASel = 0; BSel = 1; ALUSel =0; MemRW = 0; RegWEn = 1; WBSel =2;signal=0;
                end
            endcase
        end
        
        5'b11011: begin  // JAL - Jump and link  //imm_sel is J type 
            PCSel = 1; ImmSel =4; BrUn = 0; ASel = 1; BSel = 1; ALUSel = 0; MemRW = 0; RegWEn = 1; WBSel =2;signal=0;
        end
        
        default: begin  // Default case
            PCSel = 0; ImmSel = 0; BrUn = 0; ASel = 0; BSel = 0; ALUSel = 0; MemRW = 0; RegWEn = 0; WBSel = 0;signal=0;
        end
    endcase
end
endmodule
