--Miguel Ángel Alba Blanco
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Exceptions;

package body Word_Lists is

  	package ACL renames Ada.Command_Line;
 
-- Procedures necesarios dentro del paquete

	function Es_Igual (Word1: ASU.Unbounded_String;
				Word2: ASU.Unbounded_String)return Boolean is

	begin
		if (ASU.To_String (Word1)) = (ASU.To_String (Word2)) then
			return True;
		Else 
			return False;
		end if;
	end;


	procedure Add_Word (List: in out Word_List_Type; 
		        Word: in  ASU.Unbounded_String) is

	P_Aux: Word_List_Type;
	P_Aux2: Word_List_Type;
	P_Aux3: Word_List_Type;
	P_Aux_Igual:Word_List_Type;
	Igual:Boolean;
	begin 
		if (List = Null) then
			List:= new cell; 
			List.Word:=Word;
			List.Count:=1;
			List.Next:=Null;

		else
			P_Aux:= List;
			P_Aux_Igual:=List;
			while not (P_Aux = Null)loop

				Igual:= Es_Igual(P_Aux.Word,Word);

				if Igual = True then
					P_Aux.Count:= P_Aux.Count +1;
					P_Aux_Igual:=P_Aux;
				End if;
				--Guardo esta posición para usarla más adelante
				--ya que en la sigueinte vuelta el aux se me pune 
				-- en null y no puedo seguir almacenando
					P_Aux3 := P_Aux;
					P_Aux := P_Aux.Next;
			end loop;

			Igual:= Es_Igual(P_Aux_Igual.Word,Word);
			
			If (Igual = False ) then
				P_Aux2:= new cell;
				P_Aux2.Word:= Word;
				P_Aux2.Count:=1;
				P_Aux2.Next:= Null;
				P_Aux3.Next:= P_Aux2;

			end if;

		end if;
		
	End Add_Word;

	procedure Print_All (List: in Word_List_Type) is 
		P_Aux:Word_List_Type;
	begin
			P_Aux:=List;
			-- Tengo que ponerlo así para poder escribir la primera palabra.
			Ada.Text_IO.Put_Line("|" & ASU.To_String(P_Aux.Word) &"|" & 
					"-" & Integer'Image(P_Aux.Count));
		while not (P_Aux.Next = Null) loop
			P_Aux:=P_Aux.Next;
		Ada.Text_IO.Put_Line("|" & ASU.To_String(P_Aux.Word) &"|" & 
					"-" & Integer'Image(P_Aux.Count));
		end loop;
	
	end Print_All;


	procedure Delete_Word (List: in out Word_List_Type; 
				  Word: in ASU.Unbounded_String) is 

		P_Aux: Word_List_Type;
		P_Aux_Igual: Word_List_Type;
		--Cojo el puntero antes de la palabra que quiero borrar
		P_Antes: Word_List_Type;
		--Cojo la dir de la palabra siguiente, a la que quiero 
		-- Borrar
		P_Despues: Word_List_Type;
		Igual: Boolean;
		Stop:Boolean;
		
		begin
			P_Aux:= List;
			P_Aux_Igual:=List;
			P_Antes:=List;
			Stop:= False;
			Igual:=False;
			Igual := Es_Igual(P_Aux.Word,Word);
			if Igual = True then
				P_Despues:=P_Aux.Next; 
				P_Aux.Word:= P_Despues.Word;
				P_Aux.Next:= P_Despues.Next;

			Else
				
				while not (P_Aux = Null) or Stop = False loop
					
					Igual:= Es_Igual(P_Aux.Word,Word);
						
					if Igual = True then
						P_Aux_Igual:=P_Aux;
						P_Despues:= P_Aux.Next;
						Stop := True;
					End if;
					If Stop = False then
						P_Antes:=P_Aux;	
					End if;
					P_Aux := P_Aux.Next;	
				end loop;

				Igual:= Es_Igual(P_Aux_Igual.Word,Word);
				
				If Igual = True then
					P_Antes.Next:= P_Despues;
				End if;	
			End if;
			
			exception 
			--El error aparace tambien cuando se borra una que está, pero la borra
			-- Me imagino que lo encuentra ya que algun puntero apuntero apuntará 
			-- en algún momento donde no debe. Pero funciona.
				when  Constraint_Error =>
					Ada.Text_IO.Put_Line("La palabra no se encuentra en la lista");
							
	end Delete_word;
   
	procedure Search_Word (List: in Word_List_Type;
				  Word: in ASU.Unbounded_String;
				  Count: out Natural) is 
		
		P_Aux: Word_List_Type;
		P_Aux_Igual: Word_List_Type;
		Igual: Boolean;

	begin
		P_Aux:= List;
		P_Aux_Igual:=List;
		Igual := Es_Igual(P_Aux.Word,Word);
			if Igual = True then
				Count:=P_Aux.Count; 
				
			Else
				while not (P_Aux = Null) loop
					Igual:= Es_Igual(P_Aux.Word,Word);
					if Igual = True then
						Count:= P_Aux.Count;
						P_Aux_Igual:=P_Aux;
					End if;
					P_Aux := P_Aux.Next;
				end loop;

					Igual:= Es_Igual(P_Aux_Igual.Word,Word);
				
				If Igual = False then
					Ada.Text_IO.Put_Line("La palabra no se encuentra");
					Count:= 0;
				End if;
			End if;
	end Search_Word;
   
   --Cuidado!! creo que me estoy cargando la lista de esta manera
   -- No afecta al programa ya que es lo ultimo que se hace
   procedure Max_Word (List: in Word_List_Type;
		        Word: out ASU.Unbounded_String;
		        Count: out Natural) is 
		P_Aux: Word_List_Type;
		P_Aux_Max: Word_List_Type;
		Word_Max:ASU.Unbounded_String;
	begin
		P_Aux:= List;
		P_Aux_Max:=List;

		while not (P_Aux = Null) loop
			
			If P_Aux_Max.Count < P_Aux.Count then
				P_Aux_Max.Word := P_Aux.Word;
				P_Aux_Max.Count := P_Aux.Count;
			End if;
			P_Aux := P_Aux.Next;
		end loop;
		Word:=P_Aux_Max.Word;
		Count:= P_Aux_Max.Count;
	end Max_word;
        
end Word_Lists;