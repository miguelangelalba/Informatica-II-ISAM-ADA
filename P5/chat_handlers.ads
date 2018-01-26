--Miguel Ángel Alba Blanco
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ordered_Maps_G;
with To_String_Time;
with Ada.Calendar;
with Maps_Protector_G;
with Maps_G;
with Ordered_Maps_Protector_G;

package Chat_Handlers is

	package ASU renames Ada.Strings.Unbounded;
   package LLU renames Lower_Layer_UDP;
   package TST renames To_String_Time;

   

   Type Seq_N_T is mod Integer'Last;
   
	Type Mess_Id_T is record
		EP: LLU.End_Point_Type;
		Seq: Seq_N_T;
	end record;
	
	Type Destination_T is record
		Ep: Llu.End_Point_Type := null;
		Retries : Natural := 0;
	end record;
	
	Type Destinations_T is array (1..10) of Destination_T;

	type Buffer_A_T is access LLU.Buffer_Type;

	type Value_T is record 
		Ep_H_creat : LLU.End_Point_Type;
		Seq_N : Seq_N_T;
		P_Buffer: Buffer_A_T;
	end record;

	-------------------
	--Variable global--
	-------------------

   Nick:ASU.Unbounded_String;
   Max_Retransmisiones:Integer;
   Max_Delay:Integer;

  
	-------------
	--Funciones--
	-------------

	Function Mess_Equal (Mess_Id_1:Mess_Id_T;Mess_Id_2:Mess_Id_T) return Boolean;
	Function Mess_Minor (Mess_Id_1:Mess_Id_T;Mess_Id_2:Mess_Id_T) return Boolean;
   Function Mess_Image(Mess_Id_1:Mess_Id_T) return String;
   Function Destination_Image (Warehouse_Destination:Destinations_T) return String;
   Function Value_T_Image (Value_T_1:Value_T) return String;
   --Function 
   -------------------
	--Instanciaciones--
	-------------------

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

   package NP_Sender_Dests is new Ordered_Maps_G(Key_Type => Mess_Id_T,
   						Value_Type => Destinations_T,
   						"=" => Mess_Equal,
   						"<" => Mess_Minor,
   						Key_To_String => Mess_Image,
   						Value_To_String => Destination_Image);

   
   package NP_Sender_Buffering is new Ordered_Maps_G(Key_Type => Ada.Calendar.Time,
   						Value_Type =>Value_T,
   						"=" => Ada.Calendar."=",
   						"<" => Ada.Calendar."<",
   						Key_To_String =>TST.Image_3,
   						Value_To_String => Value_T_Image);


	package Sender_Dests is new Ordered_Maps_Protector_G (NP_Sender_Dests);
   package Sender_Buffering is new Ordered_Maps_Protector_G (NP_Sender_Buffering);
   Map_Sender_Dests : Sender_Dests.Prot_Map;
   Map_Sender_Buffering : Sender_Buffering.Prot_Map;
   
   procedure Client_Handler (From    : in     LLU.End_Point_Type;
                            To      : in     LLU.End_Point_Type;
                            P_Buffer: access LLU.Buffer_Type);

   procedure Resend_Msg_Timer(Time: Ada.Calendar.Time);

   

end Chat_Handlers;
   