--Miguel Ángel Alba Blanco
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with Word_Lists;

procedure Words is
   package ACL renames Ada.Command_Line;
   package ASU renames Ada.Strings.Unbounded;
   
   Usage_Error: exception;
	
	
--Declaración de Procedures

--En quitar espacios, además añado la palabra
	procedure quitar_espacios(Word_Aux:in ASU.Unbounded_String ; 
					Word: out ASU.Unbounded_String;
					List: in Out Word_Lists.Word_List_Type) is
		
	begin 
	
		if ASU.To_String(Word_Aux)= "" or 
			ASU.To_String(Word_Aux)= "   " then 
			-- Las palabras que tienen tabulador las coge. 
			--eso aún no está arreglado.
			Word:=ASU.To_Unbounded_String("No añadir espacio");
		else
			Word:= Word_Aux;
			Word_Lists.Add_Word(List,Word);			
		end if;

	end quitar_espacios;
   
   procedure space_words(Line: in out ASU.Unbounded_String;
						List: in out Word_Lists.Word_List_Type) is
		Position:integer;
		Word:ASU.Unbounded_String;
		Word_Aux:ASU.Unbounded_String;
		Line_Aux:ASU.Unbounded_String;
		
	begin
		
	  loop
			Position:=ASU.Index(Line," ");

			If Position= 0 then 
				Word_Aux:= Line;
				quitar_espacios(Word_Aux,Word,List);
				Word:=Word;
				
			End if;
	
			Exit when Position=0;

			Word_Aux:=Asu.Head(Line,Position-1);
			quitar_espacios(Word_Aux,Word,List);
			Word:=Word;
			Line:=ASU.Tail(Line,ASU.Length(Line)-Position);
				
		end loop;
	end space_words;

	procedure Search_Word(List: in Word_Lists.Word_List_Type;
				Word:in ASU.Unbounded_String; Count: out Natural) is
		
	begin

		Word_Lists.Search_Word(List,Word,Count);	

	End Search_Word;	

	Procedure Delete_Word(List: in out Word_Lists.Word_List_Type; 
					Word: in ASU.Unbounded_String) is
	begin
		
		Word_Lists.Delete_Word(List,word);
		
	end Delete_Word;

	procedure Max_Word (List: in Word_Lists.Word_List_Type) is

		Word: ASU.Unbounded_String;
		Count: Natural;
		Number:ASU.Unbounded_String;
	begin
		Word_Lists.Max_Word(List,Word,Count);
		Ada.Text_IO.Put_Line("The most frequent word: " & "|" &
			ASU.To_String(Word) & "|" &" -" & Integer'Image(Count));
	End Max_Word;

	Procedure Read (Name: in ASU.Unbounded_String; 
				 List: Out Word_Lists.Word_List_Type) is
		File_Name: ASU.Unbounded_String;
		File: Ada.Text_IO.File_Type;
		Finish: Boolean;
		Line: ASU.Unbounded_String;
	begin
		File_Name := Name;Ada.Text_IO.Open(File, Ada.Text_IO.In_File,
					ASU.To_String(File_Name));
	   
	   Finish := False;
		
	   while not Finish loop
	      begin
				Line := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line(File));
				space_words(Line,List);
		exception
		 when Ada.IO_Exceptions.End_Error =>
		    Finish := True;
	      end;
	   end loop;
	   Ada.Text_IO.Close(File);

	   exception

   when Usage_Error =>
      Ada.Text_IO.Put_Line("Use: ");
      Ada.Text_IO.Put_Line("       " & ACL.Command_Name & " <file>");

	
	end Read;

	procedure Menu (Name: in ASU.Unbounded_String; Print: in Boolean)is 
		
		Option:Integer range 1..5;
		List:Word_Lists.Word_List_Type;
		Word:ASU.Unbounded_String;
		Count:Natural;
		N:integer;
	begin
		n:=0;
		loop
			N := N+1;
				if n = 1 then
					Read(Name,List);
					if Print = True then
						Word_Lists.Print_All(List);
				end if;
			End if;
			Ada.Text_IO.Put_Line("Options");
			Ada.Text_IO.Put_Line("1 Add Word");
			Ada.Text_IO.Put_Line("2 Delete Word");
			Ada.Text_IO.Put_Line("3 Search word");
			Ada.Text_IO.Put_Line("4 Show all words");
			Ada.Text_IO.Put_Line("5 Quit");
			--Para que no lea constantemente
			
			Ada.Text_IO.Put_Line("Your option? ");
			Option := Integer'Value(Ada.Text_IO.Get_Line);
		
		Case Option is
			when 1 =>
				Ada.Text_IO.Put("Word? ");
				Word:= ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
				Word_Lists.Add_Word(List,Word);
				Ada.Text_IO.Put_Line("Word" & "|" & ASU.To_String(Word) &
						"|" & " added" );
				Ada.Text_IO.New_Line(2);
			when 2 =>
				Ada.Text_IO.Put("Word? ");
				Word:= ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
				Delete_Word(List,Word);

				Ada.Text_IO.Put_Line("Word" & "|" & ASU.To_String(Word) &
						 "|" & " Deleted" );

				Delete_Word(List,Word);
				Ada.Text_IO.New_Line(2);
			when 3 =>
				Ada.Text_IO.Put("Word? ");
				Word:= ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
				Search_Word(List,Word,Count);
				Ada.Text_IO.Put_Line("Word" & "|" & ASU.To_String(Word) &
						 "| " & "-" & Integer'Image(Count));
				Ada.Text_IO.New_Line(2);
				
			when 4 =>
				Ada.Text_IO.New_Line(2);
				Word_Lists.Print_All(List);
				Ada.Text_IO.New_Line(2);
			when 5 =>
				Max_Word(List);
				Exit;	
				
		end Case;
					
		end loop;
		exception 
			when  Constraint_Error =>
				Ada.Text_IO.New_Line(2);
				Ada.Text_IO.Put_Line("Opción Incorrecta");	
	End Menu;


--Declaración de Variables

   File_Name: ASU.Unbounded_String;
   File: Ada.Text_IO.File_Type;
   Line: ASU.Unbounded_String;
   List:Word_Lists.Word_List_Type;
   Argument1:ASU.Unbounded_String;
   Argument2:ASU.Unbounded_String;
   Argument3:ASU.Unbounded_String;
   Num_Arg: Integer range 1..3;
   Print:Boolean;

 
begin

   if ACL.Argument_Count > 3 or ACL.Argument_Count = 0 then
      raise Usage_Error;
   end if;

   Num_Arg:= Acl.Argument_Count;

   case Num_Arg is 

   	when 1 =>
   		Argument1 := ASU.To_Unbounded_String(ACL.Argument(1));

   		If ASU.To_String(Argument1) = "-l" then
   		Ada.Text_IO.Put_Line("Estoy en el primer caso");
   			Read(Argument1,List);
   			Word_Lists.Print_All(List);
				   			
   		Elsif  ASU.To_String(Argument1) = "-i" then
   			null;
   		else
   			Read(Argument1,List);
   			Max_Word(List);
   		End if;
   	when 2 =>
   		Argument1 := ASU.To_Unbounded_String(ACL.Argument(1));
   		Argument2 := ASU.To_Unbounded_String(ACL.Argument(2));

   		If ASU.To_String(Argument1) = "-l" then
   			Read(Argument2,List);
   			Word_Lists.Print_All(List);
   			Max_Word(List);
				   			
   		Elsif  ASU.To_String(Argument1) = "-i" then
   			Print:= False;
   			Menu(Argument2,Print);
   		else
   			Ada.Text_IO.Put_Line("Argumentos no válidos");
   		End if;
   	when 3 =>
   		Argument1 := ASU.To_Unbounded_String(ACL.Argument(1));
   		Argument2 := ASU.To_Unbounded_String(ACL.Argument(2));
   		Argument3 := ASU.To_Unbounded_String(ACL.Argument(3));

   		If ASU.To_String(Argument1) = "-l" or 
   			ASU.To_String(Argument1) ="-i" or 
   			ASU.To_String(Argument2) = "-i" or
   			ASU.To_String(Argument2) = "-l" then
				Print:= True;
				Menu(Argument3,Print);

			Else 
   			Ada.Text_IO.Put_Line("Argumentos no válidos");
   		end if;
   end case;
  
end Words;