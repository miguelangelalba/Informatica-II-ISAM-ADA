--Miguel Ángel Alba Blanco
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Maps_G;
with To_String_Time;
with Ada.Calendar;
with Maps_Protector_G;


package Chat_Handlers is

	package ASU renames Ada.Strings.Unbounded;
   package LLU renames Lower_Layer_UDP;
   package TST renames To_String_Time;
   type Seq_N_T is mod Integer'Last;

   Nick:ASU.Unbounded_String;
   

	package NP_Neighbors is new Maps_G(Key_Type => LLU.End_Point_Type,
                     Value_Type => Ada.Calendar.Time,
                     Null_Key => null,
                     Null_Value =>Ada.Calendar.Clock,
                     Max_Length => 10,
                     "=" => LLU."=",
                     Key_To_String => LLU.Image,
                     Value_To_String => TST.Image_3 );

	package NP_Latest_Msgs is new Maps_G(Key_Type => LLU.End_Point_Type,
                     Value_Type => Seq_N_T,
                     Null_Key => null,
                     Null_Value =>0,
                     Max_Length => 50,
                     "=" => LLU."=",
                     Key_To_String => LLU.Image,
                     Value_To_String => Seq_N_T'Image );

   
	
   package Neighbors is new Maps_Protector_G (NP_Neighbors);
	package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);
	
   Map_Neighbors: Neighbors.Prot_Map;
   Map_Latest_Msgs: Latest_Msgs.Prot_Map;


   procedure Client_Handler (From    : in     LLU.End_Point_Type;
                            To      : in     LLU.End_Point_Type;
                            P_Buffer: access LLU.Buffer_Type);
end Chat_Handlers;
