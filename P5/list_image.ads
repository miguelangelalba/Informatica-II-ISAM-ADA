--Miguel Ángel Alba Blanco
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Calendar;
with Chat_Handlers;

package List_Image is

   package ASU renames Ada.Strings.Unbounded;
   package LLU renames Lower_Layer_UDP;
   package CH renames Chat_Handlers;

function Image_EP (Warehouse_Nodo_EP: in CH.Neighbors.Keys_Array_Type) return String;
function Dest_Image (Warehouse: CH.Destinations_T) return String;
function Image_Mess_Id_T(Ep:LLU.End_Point_Type) return String;
function Image_Value_T (Ep:LLU.End_Point_Type) return String;

	


end List_Image;
