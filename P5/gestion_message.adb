--Miguel Ángel Alba

with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Calendar;
with Debug;
with Pantalla;
with Chat_Messages;
with Chat_Handlers;

package Gestion_Message is

   package ASU renames Ada.Strings.Unbounded;
   package LLU renames Lower_Layer_UDP;
   package CH renames Chat_Handlers;


package body Gestion_Message is

procedure Msg_Init(Warehouse_Nodo_EP:in CH.Neighbors.Keys_Array_Type;
										EP_H_Creat: in LLU.End_Point_Type;
										EP_H_Rsnd: in LLU.End_Point_Type;
										EP_R_Creat: in LLU.End_Point_Type;
										Nick_Aux:in ASU.Unbounded_String) is
		Buffer:aliased LLU.Buffer_Type(1024);
		P_Buffer: Access LLU.Buffer_Type;
	begin

		Add_Latest_Msgs(EP_H_Creat,Seq_N);
		debug.Put_Line(("Iniciando P_Admision..."),Pantalla.Magenta);
		debug.Put_Line(("Enviando Init"),Pantalla.Amarillo);
		LLU.Reset(Buffer);
      CM.Message_Type'Output(Buffer'Access,CM.Init);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
      CH.Seq_N_T'Output(Buffer'Access,Seq_N);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
      LLU.End_Point_Type'Output(Buffer'Access, EP_R_Creat);
      debug.Put(("EP_R_Creat:" & LLU.Image(EP_R_Creat)),Pantalla.Verde);
      ASU.Unbounded_String'Output(Buffer'Access,Nick_Aux);
      P_Buffer:=Buffer'Access;

      Send_msg(Warehouse_Nodo_EP,P_Buffer);
      LLU.Reset(Buffer);
   end Msg_Init;

end Gestion_Message;