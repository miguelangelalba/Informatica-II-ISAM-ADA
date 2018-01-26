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

	


end List_Image;