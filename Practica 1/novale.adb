with Ada.Strings.Unbounded;
with Ada.Command_Line;
with Ada.Text_IO;

--with word_lists;


procedure Words is

--Paquetes usados

	package ACL renames Ada.Command_Line;
	package ASU renames Ada.Strings.Unbounded;


--Declaración de tipos

	type Words;
	type Acceso_Word is access Words;
	type Words is record 
			Word:ASU.Unbounded_String;
			Value:Integer;
			CountW:Integer;
			Next:Acceso_Word;
	end record;

	Type Text is access Words;

--Declaración de Procedimientos

	procedure Open_File (File_Name: in string; File: in out Ada.Text_IO.File_Type ) is

	begin
		Ada.Text_IO.Open (File, Ada.Text_IO.In_File, File_Name);
	end Open_File;

--	procedure Write_File(File_Name: in out string) is
--		File:Ada.Text_IO.File_Type;
--	begin 
		--Entonces como se pone?
		
	--Ada.Text_IO.Put_Line (File, Ada.Text_IO.In_File, File_Name);
--	end Write_File;
		
	
	procedure Close_File(File: in out Ada.Text_IO.File_Type) is

	begin
		Ada.Text_IO.Close(File);
	end Close_File;

	--procedure Save_Word();
			
	
--Parte de punteros, preguntar dudas.. no se como continuar...
-- lo de tipo text era para que compilase. No es lo que quiero poner



--	procedure Start_List(Algo: in out Text) is	
--		Word_Aux:ASU.Unbounded_String;
--		P_List: Text;
		--P_List: Acceso_Celda;
--		P_Aux: Acceso_Word;
--	begin

--		Word_Aux:=Asu.To_Unbounded_String("Incializar");
--		P_List := new Words;
--		Ada.Text_IO.Put_Line("Introduzaca una palabra: ");
--		P_List.Word:= ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
		--Esto inicializa posteriormente se contará	
--		P_List.Value:=0;
--		P_List.CountW:=1;
		--Inicializa la celda en este caso da igual va a ser igual a los
		-- datos de la siguiente celda

--		P_Aux:= new Words'(Word_Aux,0,0,null);
--		P_Aux.Next:= P_List;
--		P_List:=P_Aux;
--	end Start_List;




	procedure Read_Text(File: in Ada.Text_IO.File_Type;Line: out 
					ASU.Unbounded_String) is
	begin
		Line:=ASU.To_Unbounded_String(Ada.Text_IO.Get_Line(File));
	end Read_Text;

	procedure Write_Words(File:in Ada.Text_IO.File_Type; Line: in out ASU.Unbounded_String) is 

	begin
	--no entiendo, tengo que darle al enter para que salga todo
		while not Ada.Text_IO.End_of_file loop
			Read_Text(File,Line);
			Ada.Text_IO.Put_Line(ASU.To_String(Line));
		end loop;
	
		
	end Write_Words; 
	
--Declaración de Variables 

	
	File_Name:ASU.Unbounded_String;
	File:Ada.Text_IO.File_Type;
	Line: ASU.Unbounded_String;
	
begin

	File_Name:=ASU.To_Unbounded_String("f1.txt");
	
	Open_File(ASU.To_String(File_Name),File);
	Write_Words(File,Line);
	Close_File(File);
end Words;
