--Miguel Ángel Alba

with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Calendar;

package Gestion_Message is

   package ASU renames Ada.Strings.Unbounded;
   package LLU renames Lower_Layer_UDP;

   procedure Msg_Init(Warehouse_Nodo_EP:in CH.Neighbors.Keys_Array_Type;
										EP_H_Creat: in LLU.End_Point_Type;
										EP_H_Rsnd: in LLU.End_Point_Type;
										EP_R_Creat: in LLU.End_Point_Type;
										Nick_Aux:in ASU.Unbounded_String);




end Gestion_Message;