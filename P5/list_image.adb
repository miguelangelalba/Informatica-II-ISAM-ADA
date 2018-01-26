--Miguel Ángel Alba Blanco
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Calendar;
with Chat_Handlers;
with Ada.Command_Line;

package body List_image is

   package ACL renames Ada.Command_Line;

------------------------------
-- Declaración de Funciones --
------------------------------

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
       & " " & ASU.To_String(Cadena3));
   end Unir3_Cadenas;


-----------------------------------
-- Declaración de Procedimientos --
-----------------------------------

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

function Image_EP (Warehouse_Nodo_EP: in CH.Neighbors.Keys_Array_Type) return String is
   
      Line:ASU.Unbounded_String;
      Dir_Ip:ASU.Unbounded_String;
      Puerto:ASU.Unbounded_String;
      Resultado:ASU.Unbounded_String;
      Unidas:ASU.Unbounded_String;
      --I:Integer:=1;
      Espacio:ASU.Unbounded_String;
   begin
     
     for I in 1..10  loop
     	
        	If LLU.Image(Warehouse_Nodo_EP(I)) /= LLU.Image(Null) then  

	        	Line:=ASU.To_Unbounded_String(LLU.Image(Warehouse_Nodo_EP(I)));
	         Trocear_Ep(Line,Dir_Ip,Puerto);
	         Unidas:=ASU.To_Unbounded_String(Unir3_Cadenas(Dir_Ip,Puerto,Espacio));
	         Resultado:=ASU.To_Unbounded_String(Unir2_Cadenas(Resultado,Unidas));
      	end if;
         
      end loop;
      return ASU.To_String (Resultado);

	end Image_EP;

function Dest_Image (Warehouse: in CH.Destinations_T) return String is
   
      Line:ASU.Unbounded_String;
      Dir_Ip:ASU.Unbounded_String;
      Puerto:ASU.Unbounded_String;
      Resultado:ASU.Unbounded_String;
      Unidas:ASU.Unbounded_String;
      Unidas_Aux:ASU.Unbounded_String;
      --I:Integer:=1;
      Espacio:ASU.Unbounded_String;
      Repetir:String:="";
   begin
     
      for I in 1..10  loop
     	
        	If LLU.Image(Warehouse(I).EP) /= LLU.Image(Null) then  
            Line:=ASU.To_Unbounded_String(LLU.Image(Warehouse(I).EP));
            Trocear_Ep(Line,Dir_Ip,Puerto);
            Unidas:=ASU.To_Unbounded_String(Unir3_Cadenas(Dir_Ip,Puerto,Espacio));
            --Tengo que arreglar esta parte, no pontdrá el número de repeticioens
            --Repetir:= Natural'Image((Warehouse(I).Retries));
            
            --Unidas:= Unir2_Cadenas(Unidas_Aux,ASU.To_Unbounded_String(Repetir));
            Resultado:=ASU.To_Unbounded_String(Unir2_Cadenas(Resultado,Unidas));
      	end if;
      end loop;
      return ASU.To_String (Resultado);

	end Dest_Image;

function Image_Mess_Id_T(Ep:LLU.End_Point_Type) return String is

   Resultado:ASU.Unbounded_String;
   Line:ASU.Unbounded_String;
   Dir_Ip:ASU.Unbounded_String;
   Puerto:ASU.Unbounded_String;
   Espacio:ASU.Unbounded_String;
   Unidas:ASU.Unbounded_String;
   
   begin

   Line:=ASU.To_Unbounded_String(LLU.Image(EP));
   Trocear_Ep(Line,Dir_Ip,Puerto);
   Unidas:=ASU.To_Unbounded_String(Unir3_Cadenas(Dir_Ip,Puerto,Espacio));
   Resultado:=Unidas;
--El resultado tendrá algún enter
   return ASU.To_String (Resultado);


end Image_Mess_Id_T;

function Image_Value_T (Ep:LLU.End_Point_Type) return String is

   Resultado:ASU.Unbounded_String;
   Line:ASU.Unbounded_String;
   Dir_Ip:ASU.Unbounded_String;
   Puerto:ASU.Unbounded_String;
   Espacio:ASU.Unbounded_String;
   Unidas:ASU.Unbounded_String;
   
   begin

   Line:=ASU.To_Unbounded_String(LLU.Image(EP));
   Trocear_Ep(Line,Dir_Ip,Puerto);
   Unidas:=ASU.To_Unbounded_String(Unir3_Cadenas(Dir_Ip,Puerto,Espacio));
   Resultado:=Unidas;
   --El resultado tendrá algún enter
   return ASU.To_String (Resultado);
end Image_Value_T;

end List_image;
