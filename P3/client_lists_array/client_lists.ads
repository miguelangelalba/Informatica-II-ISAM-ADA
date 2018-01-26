--Miguel Ángel Alba Blanco
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Calendar;

package Client_Lists is
   package ASU renames Ada.Strings.Unbounded;
   package LLU renames Lower_Layer_UDP;

   type Client_List_Type is private;

   Client_List_Error: exception;

   procedure Add_Client (List: in out Client_List_Type;
                         EP: in LLU.End_Point_Type;
                         Nick: in ASU.Unbounded_String);

   procedure Delete_Client (List: in out Client_List_Type;
                            Nick: in ASU.Unbounded_String);

   function Search_Client (List: in Client_List_Type;
                           EP: in LLU.End_Point_Type)
                          return ASU.Unbounded_String;

   procedure Send_To_All (List: in Client_List_Type;
                          P_Buffer: access LLU.Buffer_Type;
                          EP_Not_Send: in LLU.End_Point_Type);

   function List_Image (List: in Client_List_Type) return String;

   procedure Update_Client (List: in out Client_List_Type;
                            EP: in LLU.End_Point_Type);

   procedure Remove_Oldest (List: in out Client_List_Type;
                EP: out LLU.End_Point_Type;
                Nick: out ASU.Unbounded_String);

   function Count (List: in Client_List_Type) return Natural;

private

   Max_Client:integer:=51;

   Type Cell;
       
   type Cell is record
      Client_EP: LLU.End_Point_Type;
      Nick: ASU.Unbounded_String;
      Time: Ada.Calendar.Time := Ada.Calendar.Clock;
      Full: Boolean := False;
   end record;

   type Lista is array (1..Max_Client) of Cell;
   
   type Client_List_Type is record
      Almacen:Lista;
      Total: integer := 0;
   end record;

end Client_Lists;
