--Miguel Ángel Alba Blanco
with Ada.Strings.Unbounded;
with Chat_Handlers;

package Chat_Messages is
	
	package ASU renames Ada.Strings.Unbounded;
	package CH renames Chat_Handlers;

	use type CH.Buffer_A_T;

	type Message_Type is (Init,Reject,Confirm,writer,Logout,Ack);

	P_Buffer_Main:CH.Buffer_A_T;
	P_Buffer_Handler:CH.Buffer_A_T;
end Chat_Messages;
