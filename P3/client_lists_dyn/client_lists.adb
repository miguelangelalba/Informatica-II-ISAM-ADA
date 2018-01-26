--Miguel Ángel Alba Blanco
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Text_IO;
with Chat_Messages;
with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Unchecked_Deallocation;
with Ada.Calendar;

package body Client_Lists is

	package CM renames Chat_Messages;
	package ACL renames Ada.Command_Line;
	package CL renames Client_Lists;

	function Es_Igual_Nick (Parametro1:ASU.Unbounded_String;
				Parametro2:ASU.Unbounded_String)return Boolean is
	begin
		if ASU.To_String(Parametro1) = ASU.To_String(Parametro2) then
			return True;
		Else 
			return False;
		end if;
	end Es_Igual_Nick;

	function Es_Igual_EP (Parametro1: LLU.End_Point_Type;
				Parametro2: LLU.End_Point_Type)return Boolean is
	begin
		if LLU.Image(Parametro1) = LLU.Image(Parametro2) then
			return True;
		Else 
			return False;
		end if;
	end Es_Igual_EP;

	function Unir2_Cadenas (Cadena1:ASU.Unbounded_String;
			Cadena2:ASU.Unbounded_String) return String is
	begin
		return (ASU.To_String(Cadena1) & ASU.To_String(Cadena2));
	End Unir2_Cadenas;

	function Unir3_Cadenas(Cadena1:ASU.Unbounded_String;
			Cadena2:ASU.Unbounded_String;
			Cadena3:ASU.Unbounded_String) return String is
	begin
		return (ASU.To_String (Cadena1) & ":" & ASU.To_String(Cadena2)
		 & " " & ASU.To_String(Cadena3) & ASCII.LF);
	end Unir3_Cadenas;

	procedure Quitar_Espacios (Word_Aux: in ASU.Unbounded_String;
				Word: out ASU.Unbounded_String) is
	begin
		If ASU.To_String(Word_Aux) /= "" then
			Word:= Word_Aux;
		End if;

	end Quitar_Espacios;

	procedure Trocear_Ep(Line: in out ASU.Unbounded_String;
					Dir_Ip: out ASU.Unbounded_String;
					Puerto: out ASU.Unbounded_String) is

		Position: Integer;
		Word:ASU.Unbounded_String;
		Word_Aux:ASU.Unbounded_String;
		Contador:Integer;
	begin	
		Contador:=0;
		loop
			Position:=ASU.Index(Line," ");

			exit when Position= 0;
			Word_Aux:= ASU.Head(Line,Position-1);
			Quitar_Espacios(Word_Aux,Word);
			Word:=Word;
			If Contador = 2 then
				Dir_Ip:=ASU.Head(Word,Position-2);
			end if;
			If Contador = 3 then	
				Puerto:=ASU.Tail(Line,ASU.Length(Line)-Position-1);
			end if;
			Contador:= Contador+1;
			--Esto es para ir acortando la línea y que 
			-- no entre en bucle
			Line:=ASU.Tail(Line,ASU.Length(Line)-Position);
		end loop;

	end Trocear_Ep;

	procedure Search_Oldest(List: in Client_List_Type;
			Nick_Oldest:out ASU.Unbounded_String;
			Ep_Oldest: out LLU.End_Point_Type ) is
		use type Ada.Calendar.Time;
	procedure Free is new 
		Ada.Unchecked_Deallocation
		(Cell,Cell_A);
	P_List: Cell_A;
	P_List_Aux: Cell_A;
	
	begin

		P_List:=List.P_First;
		P_List_Aux:= New cell;
		P_List_Aux.Time:= P_List.Time;
		
		while not (P_List = Null) loop
		
			If (P_List_Aux.Time) >= (P_List.Time) then
				P_List_Aux.Time := P_List.Time;
				P_List_Aux.Nick := P_List.Nick;
				P_List_Aux.Client_EP := P_List.Client_EP;

			end If;
			P_List := P_List.Next;
		End loop;
		Nick_Oldest:= P_List_Aux.Nick;
		Ep_Oldest:= P_List_Aux.Client_EP;
		Free(P_List_Aux);

	end Search_Oldest;

	procedure Search_EP (List: in out Cell_A;
			EP: in LLU.End_Point_Type;
			Position_EP: out Cell_A; Found: out Boolean) is

		P_Aux: Cell_A;
		P_Aux_Igual: Cell_A;
		Igual: Boolean;
	begin
	--Modificado
		Found:=False;
		P_Aux:= List;
		P_Aux_Igual:=List;
		Igual := Es_Igual_EP(P_Aux.Client_EP,EP);
		if Igual = True then
			Position_EP:=list;
			Found:= True; 
		Else
			while not (P_Aux = Null) loop
				Igual:= Es_Igual_EP(P_Aux.Client_EP,EP);
				if Igual = True then
					Position_EP:=P_Aux;
					Found:= True;
				End if;
				P_Aux := P_Aux.Next;
			end loop;
		End if;
	end Search_EP;

	procedure Search_Nick (List: in out Cell_A; 
			Nick: in ASU.Unbounded_String;
			Position_Nick: out Cell_A;
			P_Anterior_Nick: out Cell_A;
			Found: out Boolean) is

		P_Aux: Cell_A;
		P_Aux_Igual: Cell_A;
		Igual: Boolean;
	begin
	--Modificado
		Found:= False;
		P_Aux:= List;
		P_Aux_Igual:=List;
		Igual := Es_Igual_Nick(P_Aux.Nick,Nick);
		if Igual = True then
			Found:= True;
			P_Anterior_Nick:=P_Aux;
			Position_Nick:=P_Aux;
		Else
			while not (P_Aux = Null) loop
				Igual:= Es_Igual_Nick(P_Aux.Nick,Nick);
				if Igual = True then
					Found:= True;
					Position_Nick:=P_Aux;
					exit;
				End if;
				P_Anterior_Nick:=P_Aux;
				P_Aux := P_Aux.Next;
			end loop;
		End if;

	end Search_Nick;

	procedure Add_Client (List: in out Client_List_Type; 
			 EP: in LLU.End_Point_Type; 
			 Nick: in ASU.Unbounded_String) is

		Client_List: Cell_A;
		Position_Nick:Cell_A;
		P_Anterior_Nick:Cell_A;
		Found_Nick: Boolean;
		
	begin
		if (List.P_First = Null) then
			Client_List := new Cell;
			Client_List.Client_EP := EP;
			Client_List.Nick := Nick;
			Client_List.Time := Ada.Calendar.Clock;
			Client_List.Next := Null;
			List.P_First := Client_List;
			List.Total := 1;
		Else

			Search_Nick(List.P_First,Nick,Position_Nick,P_Anterior_Nick,Found_Nick);
			
			If Found_Nick = True then
				raise Client_List_Error;
			end If;	
			
			Client_List := new Cell;
			Client_List.Client_EP := EP;
			Client_List.Nick := Nick;
			Client_List.Time := Ada.Calendar.Clock;
			Client_List.Next := List.P_First;
			List.P_First := Client_List;
			List.Total := List.Total + 1;
			
		End if;
		Ada.Text_IO.Put_Line ("INIT received from " &
			 ASU.To_String(Nick) & ": ACCEPTED");
	end Add_Client;

	procedure Delete_Client (List: in out Client_List_Type;
            Nick: in ASU.Unbounded_String) is
	
	procedure Free is new 
		Ada.Unchecked_Deallocation
		(Cell,Cell_A);
   	P_List:Cell_A;
   	Position_Nick:Cell_A;
	   P_Anterior_Nick:Cell_A;
	   Found:Boolean;
   
   begin
   
   	P_List:=List.P_First;
   	Search_Nick(P_List,Nick,Position_Nick,P_Anterior_Nick,Found);
   	If Found = True then

   		If P_Anterior_Nick = Position_Nick then
   			If Position_Nick.Next = null then
   				P_Anterior_Nick.Next:=Null;
   				List.Total:= List.Total -1;
   				Free(Position_Nick);
   				List.P_First:= Null;
   			Else
	   			List.P_First := Position_Nick.Next;
	   			List.Total:=List.Total-1;
	   			Free(Position_Nick);
	   		end if;
   			
   		Else
   			if Position_Nick.Next = null then
   				P_Anterior_Nick.Next:=Null;
   				List.Total:= List.Total -1;
   				Free(Position_Nick);
   			Else
   				P_Anterior_Nick.Next:=Position_Nick.Next;
   				List.Total:= List.Total -1;
   				Free(Position_Nick);
   			end if;
   		end if;
   	Else
   		raise Client_List_Error;
   	end if;

   Exception
		when Client_List_Error =>
			Ada.Text_IO.Put_Line(ASU.To_String(Nick) &
				 " No se encuentra en la lista");

	end Delete_Client;

	function Search_Client (List: in Client_List_Type;
            EP: in LLU.End_Point_Type)
            return ASU.Unbounded_String is
   	Position_EP:Cell_A;
		Found:Boolean;
		P_List: Cell_A;
	begin	
		
		P_List:= List.P_First;
		Search_EP(P_List,Ep,Position_EP,Found);
		If Found = False then
			raise Client_List_Error;
		End if;
		Return Position_EP.Nick;
		
   end Search_Client;

   procedure Send_To_All (List: in Client_List_Type;
             P_Buffer: access LLU.Buffer_Type;
             EP_Not_Send: in LLU.End_Point_Type) is
   	I:Natural;
		P_List:Cell_A;
		count:Integer;
	begin	
		P_List:= List.P_First;
		I:=0;
		Count:=0;
		If List.Total = 0  then	
			raise Client_List_Error;
		end if;
		if Es_Igual_EP(P_List.Client_EP,EP_Not_Send) then 
			null;
		Else
			Count:= Count +1;
			LLU.Send(P_List.Client_EP,P_Buffer);
		End if;

		 while not (P_List.Next = Null) loop
			P_List:=P_List.Next;
			
			if Es_Igual_EP(P_List.Client_EP,EP_Not_Send) then 
				null;
			Else
				Count:= Count +1;
				LLU.Send(P_List.Client_EP,P_Buffer);
			end if;
			If Count = 0 then    	
				raise Client_List_Error;
			end if;
		end loop;
	Exception
		when  Client_List_Error =>
			null;
   End Send_To_All;

   function List_Image (List: in Client_List_Type) return String is

   	P_Aux:Cell_A;
		Line:ASU.Unbounded_String;
		Clientes:Asu.Unbounded_String;
		Dir_Ip:ASU.Unbounded_String;
		Puerto:ASU.Unbounded_String;
		Resultado:ASU.Unbounded_String;
		Unidas:ASU.Unbounded_String;
   begin
   	P_Aux:=List.P_First;
		Line:=ASU.To_Unbounded_String(LLU.Image(P_Aux.Client_EP));

		Trocear_Ep(Line,Dir_Ip,Puerto);
		
		Resultado:=ASU.To_Unbounded_String(Unir3_Cadenas(Dir_Ip,Puerto,P_Aux.Nick));
		while not (P_Aux.Next = Null) loop
			P_Aux:=P_Aux.Next;	
			Line:=ASU.To_Unbounded_String(LLU.Image(P_Aux.Client_EP));
			Trocear_Ep(Line,Dir_Ip,Puerto);
			Unidas:=ASU.To_Unbounded_String(Unir3_Cadenas(Dir_Ip,Puerto,P_Aux.Nick));
			Resultado:=ASU.To_Unbounded_String(Unir2_Cadenas(Resultado,Unidas));
		end loop;

		return ASU.To_String (Resultado);  
   end List_Image;

   procedure Update_Client (List: in out Client_List_Type;
                            EP: in LLU.End_Point_Type) is

   	Position_EP:Cell_A;
		--Esto es solamente necesario para llamar al procedure
		--En este punto nunca debería de salir False
		Found:Boolean;
	begin
   	Search_EP(List.P_First,EP,Position_EP,Found);
   	Position_EP.Time := Ada.Calendar.Clock;

   end Update_Client;

   procedure Remove_Oldest (List: in out Client_List_Type;
   				EP: out LLU.End_Point_Type;
   				Nick: out ASU.Unbounded_String) is

   	Ep_Oldest:LLU.End_Point_Type;
   	Nick_Oldest:ASU.Unbounded_String;
   begin

   	Search_Oldest(List,Nick_Oldest,Ep_Oldest);

   	EP:= Ep_Oldest;
   	Nick:=Nick_Oldest;

		Delete_Client(List,Nick_Oldest);

   end Remove_Oldest;

   function Count (List: in Client_List_Type) return Natural is

   begin
   	If List.P_First = Null then
   		return 0;
   	Else
   		return List.Total;
   	end if;
   	
   end Count;

end Client_Lists;